import 'package:flutter/material.dart';

import '../../../core/components/buttons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'bridge_format.dart';

/// Step 2 of the bridge flow. Stateless review screen — the parent owns the
/// data and the actions.
class BridgeConfirmation extends StatelessWidget {
  final double amount;
  final String destination;
  final bool isSubmitting;
  final VoidCallback onBack;
  final VoidCallback onConfirm;

  const BridgeConfirmation({
    super.key,
    required this.amount,
    required this.destination,
    required this.isSubmitting,
    required this.onBack,
    required this.onConfirm,
  });

  String _shortDestination() {
    if (destination.length < 12) return destination;
    return "${destination.substring(0, 6)}…${destination.substring(destination.length - 4)}";
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.prvBridgeAboutTo, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              border: Border.all(color: Colors.white12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.prvVbtcAmountSuffix(formatVbtc(amount)),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Text(l10n.prvBridgeFromVfx, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 10),
                const Icon(Icons.arrow_downward, size: 16, color: Colors.white38),
                const SizedBox(height: 10),
                Text(
                  l10n.prvBridgeVbtcbAmount(formatVbtc(amount)),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Text(
                  l10n.prvBridgeToDestOnBase(_shortDestination()),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  destination,
                  style: const TextStyle(color: Colors.white38, fontSize: 11, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.prvBridgeThisWill, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 6),
          _StepLine(index: 1, label: l10n.prvBridgeStepLock(formatVbtc(amount))),
          _StepLine(index: 2, label: l10n.prvBridgeStepWaitSignatures),
          _StepLine(
            index: 3,
            label: l10n.prvBridgeStepMint,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.prvBridgeEstimatedTime,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              border: Border.all(color: Colors.white24),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.white54),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.prvBridgeOneWayReminder,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                label: l10n.prvBack,
                type: AppButtonType.Text,
                variant: AppColorVariant.Light,
                onPressed: isSubmitting ? () {} : onBack,
                disabled: isSubmitting,
              ),
              const SizedBox(width: 8),
              AppButton(
                label: l10n.prvBridgeConfirmAndBridge,
                variant: AppColorVariant.Success,
                processing: isSubmitting,
                onPressed: isSubmitting ? () {} : onConfirm,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  final int index;
  final String label;
  const _StepLine({required this.index, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            child: Text(
              "$index.",
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
