import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../core/app_constants.dart';
import '../../../core/components/buttons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../utils/toast.dart';
import '../../btc/models/tokenized_bitcoin.dart';
import '../models/bridge_preflight.dart';
import '../providers/bridge_preflight_provider.dart';
import 'bridge_explorer_links.dart';

/// Step 1 of the bridge flow. Owns no state of its own — the parent dialog
/// passes the amount/destination controllers in so values survive when the
/// user navigates back from Step 2.
class BridgePreflightForm extends ConsumerStatefulWidget {
  final TokenizedBitcoin token;
  final String ownerAddress;
  final TextEditingController amountController;
  final TextEditingController destinationController;

  /// Called when the user taps "Review Bridge" with a valid form. The dialog
  /// uses this to advance to Step 2 (Confirmation).
  final void Function(BridgePreflight preflight, double amount, String destination) onReview;

  /// Called when the user dismisses the dialog from this step.
  final VoidCallback onCancel;

  const BridgePreflightForm({
    super.key,
    required this.token,
    required this.ownerAddress,
    required this.amountController,
    required this.destinationController,
    required this.onReview,
    required this.onCancel,
  });

  @override
  ConsumerState<BridgePreflightForm> createState() => _BridgePreflightFormState();
}

class _BridgePreflightFormState extends ConsumerState<BridgePreflightForm> {
  final _formKey = GlobalKey<FormState>();
  bool _destinationEdited = false;

  static final _evmAddressPattern = RegExp(r'^0x[0-9a-fA-F]{40}$');

  BridgePreflightArgs get _args => BridgePreflightArgs(
        ownerAddress: widget.ownerAddress,
        scUid: widget.token.smartContractUid,
      );

  void _maybeSeedDestination(BridgePreflight preflight) {
    // Auto-fill the destination with the derived Base address the first time
    // preflight returns one, unless the user has already typed something.
    if (_destinationEdited) return;
    if (widget.destinationController.text.isNotEmpty) return;
    if (preflight.derivedBaseAddress.isEmpty) return;
    widget.destinationController.text = preflight.derivedBaseAddress;
  }

  /// Public so the step's child widgets (which only have access to the state
  /// object, not setState directly) can request a rebuild after updating one
  /// of the controllers.
  void rebuild() {
    if (mounted) setState(() {});
  }

  void _resetToDerived(BridgePreflight preflight) {
    if (preflight.derivedBaseAddress.isEmpty) return;
    widget.destinationController.text = preflight.derivedBaseAddress;
    _destinationEdited = false;
    rebuild();
  }

  void _setMax(BridgePreflight preflight) {
    widget.amountController.text = preflight.availableVbtc.toString();
    rebuild();
  }

  String? _validateAmount(String? raw, BridgePreflight preflight) {
    if (raw == null || raw.trim().isEmpty) return "Amount is required";
    final value = double.tryParse(raw.trim());
    if (value == null || value <= 0) return "Enter a positive amount";
    if (value > preflight.availableVbtc) {
      return "Exceeds available (${preflight.availableVbtc} vBTC)";
    }
    return null;
  }

  String? _validateDestination(String? raw) {
    if (raw == null || raw.trim().isEmpty) return "Base address is required";
    if (!_evmAddressPattern.hasMatch(raw.trim())) {
      return "Must be a valid 0x Base address (40 hex chars)";
    }
    return null;
  }

  void _submit(BridgePreflight preflight) {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(widget.amountController.text.trim());
    final destination = widget.destinationController.text.trim();
    widget.onReview(preflight, amount, destination);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(bridgePreflightProvider(_args));

    return async.when(
      loading: () => _Loading(onCancel: widget.onCancel),
      error: (err, _) => _ErrorState(
        message: "Couldn't reach the bridge service. Check your connection and try again.",
        onCancel: widget.onCancel,
        onRetry: () => ref.invalidate(bridgePreflightProvider(_args)),
      ),
      data: (preflight) {
        if (preflight == null || !preflight.success) {
          return _ErrorState(
            message: preflight?.message ?? "Couldn't load bridge info.",
            onCancel: widget.onCancel,
            onRetry: () => ref.invalidate(bridgePreflightProvider(_args)),
          );
        }
        if (!preflight.bridgeConfigured) {
          return _BlockedState(
            message: "Bridging is currently unavailable. The CLI is not configured to talk to Base.",
            onCancel: widget.onCancel,
          );
        }
        if (preflight.hasNoVbtc) {
          return _BlockedState(
            message: "You don't have any vBTC in this contract to bridge.",
            onCancel: widget.onCancel,
          );
        }
        _maybeSeedDestination(preflight);
        return _Form(
          state: this,
          preflight: preflight,
        );
      },
    );
  }
}

class _Form extends StatelessWidget {
  final _BridgePreflightFormState state;
  final BridgePreflight preflight;

  const _Form({required this.state, required this.preflight});

  @override
  Widget build(BuildContext context) {
    final lowGas = preflight.isLowOnGas(BRIDGE_MIN_ETH_FOR_GAS);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: SingleChildScrollView(
        child: Form(
          key: state._formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _OneWayDisclaimer(),
              const SizedBox(height: 16),
              if (lowGas) ...[
                _GasWarning(address: preflight.derivedBaseAddress),
                const SizedBox(height: 16),
              ],
              const Text("Amount to bridge", style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: state.widget.amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        suffixText: "vBTC",
                        border: OutlineInputBorder(),
                      ),
                      validator: (raw) => state._validateAmount(raw, preflight),
                      onChanged: (_) => state.rebuild(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => state._setMax(preflight),
                    child: const Text("Max"),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "Available: ${preflight.availableVbtc} vBTC",
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Base (EVM) Address", style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              TextFormField(
                controller: state.widget.destinationController,
                decoration: const InputDecoration(
                  hintText: "0x…",
                  border: OutlineInputBorder(),
                ),
                validator: state._validateDestination,
                onChanged: (_) {
                  state._destinationEdited = true;
                  state.rebuild();
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Auto-derived from your VFX key. Edit to send to a different Base address (get this from your DeFi provider / Base wallet).",
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ),
                    if (preflight.derivedBaseAddress.isNotEmpty)
                      TextButton(
                        onPressed: () => state._resetToDerived(preflight),
                        child: const Text("Reset to derived"),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _NetworkInfo(preflight: preflight),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    label: "Cancel",
                    type: AppButtonType.Text,
                    variant: AppColorVariant.Light,
                    onPressed: state.widget.onCancel,
                  ),
                  const SizedBox(width: 8),
                  AppButton(
                    label: "Review Bridge",
                    variant: AppColorVariant.Info,
                    onPressed: () => state._submit(preflight),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OneWayDisclaimer extends StatelessWidget {
  const _OneWayDisclaimer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.info_outline, size: 18, color: Colors.white70),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "Bridging is one-way from this app. Once vBTC.b is on Base, use your DeFi provider or another Base (EVM) wallet to manage, transfer, or exit.",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _GasWarning extends StatelessWidget {
  final String address;
  const _GasWarning({required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.08),
        border: Border.all(color: Colors.amber.withOpacity(0.6)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber, size: 18, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Low ETH on your Base address for gas. Consider funding ${_short(address)} with more ETH before bridging.",
              style: const TextStyle(color: Colors.amberAccent, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _short(String addr) {
    if (addr.length < 12) return addr;
    return "${addr.substring(0, 6)}…${addr.substring(addr.length - 4)}";
  }
}

class _NetworkInfo extends StatelessWidget {
  final BridgePreflight preflight;
  const _NetworkInfo({required this.preflight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Network info", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          _row(context, "Network", preflight.networkName ?? "Base"),
          if ((preflight.contractAddress ?? '').isNotEmpty)
            _row(
              context,
              "Contract",
              preflight.contractAddress!,
              copyValue: preflight.contractAddress,
              explorerUrl: BridgeExplorerLinks.baseAddress(preflight.contractAddress!),
              monospace: true,
            ),
          if (preflight.derivedBaseAddress.isNotEmpty)
            _row(
              context,
              "Your Base address",
              preflight.derivedBaseAddress,
              copyValue: preflight.derivedBaseAddress,
              monospace: true,
            ),
          _row(
            context,
            "ETH for gas",
            preflight.ethBalance == null ? "—" : "${preflight.ethBalance} ETH",
          ),
          _row(
            context,
            "vBTC.b balance",
            preflight.vbtcBBalance == null ? "—" : "${preflight.vbtcBBalance} vBTC.b",
          ),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    String value, {
    String? copyValue,
    String? explorerUrl,
    bool monospace = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: monospace ? 'monospace' : null,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (copyValue != null)
            InkWell(
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: copyValue));
                Toast.message("Copied to clipboard");
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.copy, size: 14, color: Colors.white54),
              ),
            ),
          if (explorerUrl != null)
            InkWell(
              onTap: () => launchUrlString(explorerUrl),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.open_in_new, size: 14, color: Colors.white54),
              ),
            ),
        ],
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  final VoidCallback onCancel;
  const _Loading({required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(height: 16),
            const Text("Checking your accounts…", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: AppButton(
                label: "Cancel",
                type: AppButtonType.Text,
                variant: AppColorVariant.Light,
                onPressed: onCancel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onCancel;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onCancel, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                label: "Cancel",
                type: AppButtonType.Text,
                variant: AppColorVariant.Light,
                onPressed: onCancel,
              ),
              const SizedBox(width: 8),
              AppButton(
                label: "Retry",
                variant: AppColorVariant.Warning,
                onPressed: onRetry,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BlockedState extends StatelessWidget {
  final String message;
  final VoidCallback onCancel;

  const _BlockedState({required this.message, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: AppButton(
              label: "Close",
              variant: AppColorVariant.Light,
              onPressed: onCancel,
            ),
          ),
        ],
      ),
    );
  }
}
