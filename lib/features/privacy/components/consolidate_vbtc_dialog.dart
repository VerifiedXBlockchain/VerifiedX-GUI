import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../../../core/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../utils/toast.dart';
import '../../btc/models/tokenized_bitcoin.dart';
import '../providers/shielded_address_provider.dart';
import '../providers/shielded_vbtc_balance_provider.dart';
import '../providers/vbtc_privacy_actions_provider.dart';

class ConsolidateVbtcDialog extends ConsumerStatefulWidget {
  final TokenizedBitcoin token;

  const ConsolidateVbtcDialog({super.key, required this.token});

  static Future<void> show(TokenizedBitcoin token) async {
    await showDialog(
      context: rootNavigatorKey.currentContext!,
      builder: (_) => ConsolidateVbtcDialog(token: token),
    );
  }

  @override
  ConsumerState<ConsolidateVbtcDialog> createState() => _ConsolidateVbtcDialogState();
}

class _ConsolidateVbtcDialogState extends ConsumerState<ConsolidateVbtcDialog> {
  bool _isSubmitting = false;

  Future<void> _submit() async {
    final zfxAddress = ref.read(shieldedAddressProvider)?.zfxAddress;
    if (zfxAddress == null) {
      Toast.error("No shielded address found");
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await ref.read(vbtcPrivacyActionsProvider.notifier).consolidateVbtc(
          zfxAddress: zfxAddress,
          vbtcContractUid: widget.token.smartContractUid,
        );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final balanceMap = ref.watch(shieldedVbtcBalanceProvider);
    final balance = balanceMap[widget.token.smartContractUid];
    final noteCount = balance?.unspentCommitments ?? 0;
    final canConsolidate = noteCount >= 2;

    return AlertDialog(
      title: const Text("Consolidate vBTC Notes"),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Merge your 2 smallest vBTC notes into a single note. This reduces dust and improves privacy.",
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Text(
              "Contract: ${widget.token.tokenName}",
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              widget.token.smartContractUid,
              style: const TextStyle(color: Colors.white38, fontSize: 11, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 12),
            Text(
              "Current notes: $noteCount",
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              "Fee: $PRIVACY_TX_FIXED_FEE_LABEL (deducted from shielded VFX balance)",
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
            if (!canConsolidate) ...[
              const SizedBox(height: 12),
              Text(
                "At least 2 unspent notes are required to consolidate.",
                style: TextStyle(color: Theme.of(context).colorScheme.danger, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: _isSubmitting || !canConsolidate ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(
                  "Consolidate",
                  style: TextStyle(
                    color: canConsolidate ? Theme.of(context).colorScheme.info : Colors.white38,
                  ),
                ),
        ),
      ],
    );
  }
}
