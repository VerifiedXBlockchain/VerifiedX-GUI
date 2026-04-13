import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../../../core/app_constants.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../utils/toast.dart';
import '../../btc/models/tokenized_bitcoin.dart';
import '../providers/shielded_address_provider.dart';
import '../providers/vbtc_privacy_actions_provider.dart';

class ShieldVbtcDialog extends ConsumerStatefulWidget {
  final TokenizedBitcoin token;

  const ShieldVbtcDialog({super.key, required this.token});

  static Future<void> show(TokenizedBitcoin token) async {
    await showDialog(
      context: rootNavigatorKey.currentContext!,
      builder: (_) => ShieldVbtcDialog(token: token),
    );
  }

  @override
  ConsumerState<ShieldVbtcDialog> createState() => _ShieldVbtcDialogState();
}

class _ShieldVbtcDialogState extends ConsumerState<ShieldVbtcDialog> {
  final _amountController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final wallet = ref.read(sessionProvider).currentWallet;
    if (wallet == null) {
      Toast.error("No wallet selected");
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount < MIN_SHIELD_AMOUNT_VBTC) {
      Toast.error("Minimum shield amount is $MIN_SHIELD_AMOUNT_VBTC vBTC");
      return;
    }

    final zfxAddress = ref.read(shieldedAddressProvider)?.zfxAddress;
    if (zfxAddress == null) {
      Toast.error("No shielded address found");
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await ref.read(vbtcPrivacyActionsProvider.notifier).shieldVbtc(
          fromAddress: wallet.address,
          vbtcContractUid: widget.token.smartContractUid,
          vbtcAmount: amount,
          recipientZfxAddress: zfxAddress,
        );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(sessionProvider.select((v) => v.currentWallet));

    return AlertDialog(
      title: const Text("Shield vBTC"),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Move vBTC from your transparent wallet into the shielded pool.",
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
            const SizedBox(height: 8),
            Text(
              "From: ${wallet?.address ?? 'No wallet selected'}",
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Amount (vBTC)",
                hintText: "Min: $MIN_SHIELD_AMOUNT_VBTC",
                border: OutlineInputBorder(),
              ),
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 8),
            const Text(
              "Transparent network fee will be auto-calculated.",
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text("Shield", style: TextStyle(color: AppColors.getBtc())),
        ),
      ],
    );
  }
}
