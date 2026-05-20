import 'dart:async';

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
import 'bridge_format.dart';

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
  bool _detailsExpanded = false;
  Timer? _refreshTimer;

  // Manual error state — keyed to the two input fields. We don't use
  // AutovalidateMode here because the requested UX is: no errors until the
  // user clicks Review Bridge, and any typing immediately clears the error
  // for that field (without re-running validation mid-keystroke).
  String? _amountError;
  String? _destinationError;

  static final _evmAddressPattern = RegExp(r'^0x[0-9a-fA-F]{40}$');

  /// Interval for auto-refreshing preflight while the form is open. Lets the
  /// user see incoming gas funds without manually retrying.
  static const _preflightRefreshInterval = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    // Poll preflight every 10s so the user can watch their ETH gas balance
    // tick up after they fund the address from an exchange / external wallet.
    _refreshTimer = Timer.periodic(_preflightRefreshInterval, (_) {
      if (!mounted) return;
      ref.invalidate(bridgePreflightProvider(_args));
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  BridgePreflightArgs get _args => BridgePreflightArgs(
        ownerAddress: widget.ownerAddress,
        scUid: widget.token.smartContractUid,
      );

  /// Public so the step's child widgets (which only have access to the state
  /// object, not setState directly) can request a rebuild after updating one
  /// of the controllers.
  void rebuild() {
    if (mounted) setState(() {});
  }

  /// Force an immediate preflight refresh — used by the "Refresh" button in
  /// the gas funding section so users don't have to wait for the next poll
  /// tick after sending a gas tx.
  void refreshPreflight() {
    ref.invalidate(bridgePreflightProvider(_args));
  }

  void _toggleDetails() {
    setState(() => _detailsExpanded = !_detailsExpanded);
  }

  void _setMax(BridgePreflight preflight) {
    widget.amountController.text = formatVbtc(preflight.availableVbtc);
    rebuild();
  }

  String? _validateAmount(String? raw, BridgePreflight preflight) {
    if (raw == null || raw.trim().isEmpty) return "Amount is required";
    final value = double.tryParse(raw.trim());
    if (value == null || value <= 0) return "Enter a positive amount";
    if (value > preflight.availableVbtc) {
      return "Exceeds available (${formatVbtc(preflight.availableVbtc)} vBTC)";
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

  /// Called from the input's onChanged. Clears the per-field error if one is
  /// currently displayed so the user gets a fresh slate while editing.
  void clearAmountError() {
    if (_amountError != null) setState(() => _amountError = null);
  }

  void clearDestinationError() {
    if (_destinationError != null) setState(() => _destinationError = null);
  }

  void _submit(BridgePreflight preflight) {
    final amountErr =
        _validateAmount(widget.amountController.text, preflight);
    final destErr = _validateDestination(widget.destinationController.text);
    if (amountErr != null || destErr != null) {
      setState(() {
        _amountError = amountErr;
        _destinationError = destErr;
      });
      return;
    }
    final amount = double.parse(widget.amountController.text.trim());
    final destination = widget.destinationController.text.trim();
    widget.onReview(preflight, amount, destination);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(bridgePreflightProvider(_args));

    return async.when(
      // Keep the previously rendered form on background re-fetches (the
      // 10s polling tick) instead of flashing back to a spinner each time —
      // otherwise the user's amount/destination input would be wiped out
      // visually every tick.
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
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
        if (!preflight.hasDerivedAddress) {
          // UX § 6 — "User has no derived Base address (key unavailable)".
          return _BlockedState(
            message:
                "Bridge unavailable — your Base address couldn't be derived. "
                "This usually means the wallet is locked. Unlock your wallet and try again.",
            onCancel: widget.onCancel,
          );
        }
        if (preflight.hasNoVbtc) {
          // `availableVbtc` is the chain-confirmed amount available to bridge
          // — it can read 0 while the wallet's cached `token.balance` still
          // shows something. There are two distinct cases:
          //   1. CLI couldn't read the balance at all (`vbtcError` set) —
          //      e.g. Electrum unreachable, contract not found in State Trei.
          //   2. CLI read it cleanly and the answer really is 0 — usually
          //      because the BTC deposit hasn't confirmed on-chain yet, or
          //      it's locked in an in-flight bridge reservation.
          final cliError = preflight.vbtcError;
          debugPrint('[bridge preflight] availableVbtc=${preflight.availableVbtc} vbtcError=$cliError');
          final message = cliError != null && cliError.isNotEmpty
              ? "Couldn't read your vBTC balance: $cliError"
              : "Nothing available to bridge yet.\n\n"
                  "Your wallet may show a balance, but the chain doesn't "
                  "see any confirmed vBTC for this contract yet. The most "
                  "common cause is a BTC deposit that hasn't received enough "
                  "Bitcoin confirmations. Bridge reservations from an earlier "
                  "attempt could also be holding the balance.\n\n"
                  "Wait a few minutes and try again, or check Bridge History "
                  "below for any in-flight operations.";
          return _BlockedState(
            message: message,
            onCancel: widget.onCancel,
            onRetry: () => ref.invalidate(bridgePreflightProvider(_args)),
          );
        }
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
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: SingleChildScrollView(
        child: Form(
          key: state._formKey,
          // No autovalidateMode — we manage error display manually so it only
          // surfaces on Review Bridge press and clears the moment the user
          // starts typing in a field.
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _OneWayDisclaimer(),
              const SizedBox(height: 16),
              const Text("Amount to bridge", style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: state.widget.amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        // Allow only digits + a single decimal point. Rejects
                        // any other character at the keystroke level so the
                        // user can't even type letters / commas / multiple dots.
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          if (newValue.text.isEmpty) return newValue;
                          final ok = RegExp(r'^\d*\.?\d*$').hasMatch(newValue.text);
                          return ok ? newValue : oldValue;
                        }),
                      ],
                      decoration: InputDecoration(
                        suffixText: "vBTC",
                        border: const OutlineInputBorder(),
                        errorText: state._amountError,
                      ),
                      onChanged: (_) {
                        state.clearAmountError();
                        state.rebuild();
                      },
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
                  "Available: ${formatVbtc(preflight.availableVbtc)} vBTC",
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Base (EVM) Address", style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              TextFormField(
                controller: state.widget.destinationController,
                decoration: InputDecoration(
                  hintText: "0x…",
                  border: const OutlineInputBorder(),
                  errorText: state._destinationError,
                ),
                onChanged: (_) {
                  state.clearDestinationError();
                  state.rebuild();
                },
              ),
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  "Paste the destination address from your DeFi provider or Base wallet.",
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ),
              const SizedBox(height: 16),
              _GasFundingSection(
                preflight: preflight,
                onRefresh: state.refreshPreflight,
              ),
              const SizedBox(height: 12),
              _DetailsToggle(
                expanded: state._detailsExpanded,
                onToggle: state._toggleDetails,
              ),
              if (state._detailsExpanded) ...[
                const SizedBox(height: 8),
                _NetworkInfo(preflight: preflight),
              ],
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
                    variant: AppColorVariant.Success,
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

/// Always-visible gas funding section. The mint transaction on Base is paid
/// from the user's derived Base address — surfaced here with current balance
/// and clear funding instructions because most users will have 0 ETH on this
/// address by default. The form polls preflight every 10s so the balance
/// updates automatically once funds arrive; the inline "Refresh" button
/// lets impatient users trigger an immediate check.
class _GasFundingSection extends StatelessWidget {
  final BridgePreflight preflight;
  final VoidCallback onRefresh;
  const _GasFundingSection({required this.preflight, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final lowGas = preflight.isLowOnGas(BRIDGE_MIN_ETH_FOR_GAS);
    final ethBalance = preflight.ethBalance;
    final hasZeroEth = ethBalance == null || ethBalance <= 0;

    // Accent color: amber for low/zero ETH, neutral white border once funded.
    final accent = lowGas ? Colors.amberAccent : Colors.white24;
    final accentBg = lowGas ? Colors.amber.withOpacity(0.06) : Colors.white.withOpacity(0.03);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accentBg,
        border: Border.all(color: accent),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(lowGas ? Icons.warning_amber : Icons.local_gas_station,
                  size: 16, color: lowGas ? Colors.amberAccent : Colors.white70),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  "Gas (paid on Base)",
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              InkWell(
                onTap: onRefresh,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.refresh, size: 14, color: Colors.white54),
                      SizedBox(width: 4),
                      Text(
                        "Refresh",
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Your gas address",
            style: TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  preflight.derivedBaseAddress.isNotEmpty
                      ? preflight.derivedBaseAddress
                      : "—",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              if (preflight.derivedBaseAddress.isNotEmpty)
                InkWell(
                  onTap: () async {
                    await Clipboard.setData(
                      ClipboardData(text: preflight.derivedBaseAddress),
                    );
                    Toast.message("Copied to clipboard");
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.copy, size: 14, color: Colors.white54),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Current balance",
            style: TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            ethBalance == null ? "—" : "${ethBalance.toStringAsFixed(6)} ETH",
            style: TextStyle(
              color: lowGas ? Colors.amberAccent : Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            hasZeroEth
                ? "This address pays the gas fee for the mint transaction on "
                    "Base. Send a small amount of Base ETH (≈ 0.001 ETH) to "
                    "the address above before bridging. You can fund it from "
                    "any exchange or Base wallet that supports withdrawing to "
                    "Base mainnet. Balance updates automatically every 10s — "
                    "tap Refresh for an immediate check."
                : "Low balance — gas costs vary. Top up the address above if "
                    "the mint fails.",
            style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }
}

/// Compact "Show details / Hide details" toggle.
class _DetailsToggle extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  const _DetailsToggle({required this.expanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              expanded ? "Hide details" : "Show details",
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(width: 4),
            Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
              size: 16,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
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
            preflight.ethBalance == null ? "—" : "${preflight.ethBalance!.toStringAsFixed(6)} ETH",
          ),
          _row(
            context,
            "vBTC.b balance",
            preflight.vbtcBBalance == null ? "—" : "${formatVbtc(preflight.vbtcBBalance!)} vBTC.b",
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
  final VoidCallback? onRetry;

  const _BlockedState({
    required this.message,
    required this.onCancel,
    this.onRetry,
  });

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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                label: "Close",
                variant: AppColorVariant.Light,
                onPressed: onCancel,
              ),
              if (onRetry != null) ...[
                const SizedBox(width: 8),
                AppButton(
                  label: "Try Again",
                  variant: AppColorVariant.Warning,
                  onPressed: onRetry!,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
