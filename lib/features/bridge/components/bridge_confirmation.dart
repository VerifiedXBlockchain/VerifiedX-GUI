import 'package:flutter/material.dart';

import '../../../core/components/buttons.dart';
import '../../../core/theme/app_theme.dart';

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
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("You're about to bridge", style: TextStyle(color: Colors.white70, fontSize: 12)),
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
                  "$amount vBTC",
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const Text("from VFX", style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 10),
                const Icon(Icons.arrow_downward, size: 16, color: Colors.white38),
                const SizedBox(height: 10),
                Text(
                  "$amount vBTC.b",
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Text(
                  "to ${_shortDestination()} on Base",
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
          const Text("This will:", style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 6),
          _StepLine(index: 1, label: "Lock your $amount vBTC on VFX"),
          const _StepLine(index: 2, label: "Wait for validator signatures"),
          _StepLine(
            index: 3,
            label: "Submit a mintWithProof transaction on Base "
                "(paid from your derived Base address)",
          ),
          const SizedBox(height: 8),
          const Text(
            "Estimated time: 2–5 minutes once submitted.",
            style: TextStyle(color: Colors.white54, fontSize: 11),
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
              children: const [
                Icon(Icons.info_outline, size: 16, color: Colors.white54),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Reminder: this is one-way from this app. You'll use your DeFi provider or another Base (EVM) wallet for any further actions on vBTC.b.",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
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
                label: "Back",
                type: AppButtonType.Text,
                variant: AppColorVariant.Light,
                onPressed: isSubmitting ? () {} : onBack,
                disabled: isSubmitting,
              ),
              const SizedBox(width: 8),
              AppButton(
                label: "Confirm & Bridge",
                variant: AppColorVariant.Info,
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
