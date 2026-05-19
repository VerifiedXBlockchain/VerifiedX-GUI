import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../core/components/buttons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../utils/toast.dart';
import '../models/bridge_lock_record.dart';
import 'bridge_explorer_links.dart';

/// Step 4 of the bridge flow. Stateless terminal screen.
///
/// Renders the success or failure view based on `record.isSuccessful` /
/// `record.isFailed`. The parent owns navigation back to history detail
/// (failure case) and closing the dialog.
class BridgeResult extends StatelessWidget {
  final BridgeLockRecord record;
  final VoidCallback onDone;

  /// Optional handler for the "View Details" failure action. When null, the
  /// failure view just shows the Close button. Phase 5 will wire this to the
  /// history detail screen.
  final VoidCallback? onViewDetails;

  const BridgeResult({
    super.key,
    required this.record,
    required this.onDone,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (record.isSuccessful) {
      return _Success(record: record, onDone: onDone);
    }
    return _Failure(record: record, onDone: onDone, onViewDetails: onViewDetails);
  }
}

class _Success extends StatelessWidget {
  final BridgeLockRecord record;
  final VoidCallback onDone;

  const _Success({required this.record, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final basescanUrl = (record.baseTxHash ?? '').isNotEmpty
        ? BridgeExplorerLinks.baseTx(record.baseTxHash!)
        : BridgeExplorerLinks.baseAddress(record.evmDestination);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.greenAccent, size: 22),
              const SizedBox(width: 8),
              const Text(
                "Bridged to Base",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "You now have ${record.amount} vBTC.b on Base",
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  "at ${record.evmDestination}",
                  style: const TextStyle(color: Colors.white54, fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
              InkWell(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: record.evmDestination));
                  Toast.message("Copied to clipboard");
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(Icons.copy, size: 14, color: Colors.white54),
                ),
              ),
              InkWell(
                onTap: () => launchUrlString(basescanUrl),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(Icons.open_in_new, size: 14, color: Colors.white54),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              border: Border.all(color: Colors.white12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "What's next?",
                  style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 6),
                Text(
                  "Use your DeFi provider or another Base (EVM) wallet to:",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                SizedBox(height: 4),
                _Bullet("Earn yield via Base DeFi"),
                _Bullet("Transfer to another Base address"),
                _Bullet(
                  "Exit back to vBTC on VFX or directly to BTC "
                  "(whoever holds the vBTC.b initiates the exit; the network will "
                  "detect it and credit you back automatically)",
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                label: "View on Basescan",
                type: AppButtonType.Outlined,
                variant: AppColorVariant.Info,
                onPressed: () => launchUrlString(basescanUrl),
              ),
              const SizedBox(width: 8),
              AppButton(
                label: "Done",
                variant: AppColorVariant.Success,
                onPressed: onDone,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Failure extends StatelessWidget {
  final BridgeLockRecord record;
  final VoidCallback onDone;
  final VoidCallback? onViewDetails;

  const _Failure({required this.record, required this.onDone, this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.cancel, color: Colors.redAccent, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Bridge failed",
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            record.errorMessage ?? "The bridge could not complete.",
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(height: 8),
          const Text(
            "Your vBTC may still be locked on VFX. Check Bridge History for details, or contact support if this persists.",
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                label: "Close",
                type: AppButtonType.Text,
                variant: AppColorVariant.Light,
                onPressed: onDone,
              ),
              if (onViewDetails != null) ...[
                const SizedBox(width: 8),
                AppButton(
                  label: "View Details",
                  variant: AppColorVariant.Warning,
                  onPressed: onViewDetails!,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2, right: 6),
            child: Text("•", style: TextStyle(color: Colors.white54, fontSize: 12)),
          ),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
