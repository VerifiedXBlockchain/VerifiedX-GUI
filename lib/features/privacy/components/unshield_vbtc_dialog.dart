import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../../../core/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../utils/toast.dart';
import '../../../utils/validation.dart';
import '../../btc/models/tokenized_bitcoin.dart';
import '../providers/shielded_address_provider.dart';
import '../providers/vbtc_privacy_actions_provider.dart';
import '../utils/vfx_fee_guard.dart';


class UnshieldVbtcDialog extends ConsumerStatefulWidget {
  final TokenizedBitcoin token;

  const UnshieldVbtcDialog({super.key, required this.token});

  static Future<void> show(TokenizedBitcoin token) async {
    await showDialog(
      context: rootNavigatorKey.currentContext!,
      builder: (_) => UnshieldVbtcDialog(token: token),
    );
  }

  @override
  ConsumerState<UnshieldVbtcDialog> createState() => _UnshieldVbtcDialogState();
}

class _UnshieldVbtcDialogState extends ConsumerState<UnshieldVbtcDialog> {
  final _toAddressController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _toAddressController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!await VfxFeeGuard.check(ref)) return;

    final toAddress = _toAddressController.text.trim();
    if (!isValidRbxAddress(toAddress)) {
      Toast.error("Please enter a valid VFX address");
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      Toast.error("Please enter a valid amount");
      return;
    }

    final zfxAddress = ref.read(shieldedAddressProvider)?.zfxAddress;
    if (zfxAddress == null) {
      Toast.error("No shielded address found");
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await ref.read(vbtcPrivacyActionsProvider.notifier).unshieldVbtc(
          zfxAddress: zfxAddress,
          vbtcContractUid: widget.token.smartContractUid,
          toAddress: toAddress,
          vbtcAmount: amount,
        );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Unshield vBTC"),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Move vBTC from the shielded pool back to a transparent address.",
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
            TextField(
              controller: _toAddressController,
              decoration: const InputDecoration(
                labelText: "To Address (transparent)",
                hintText: "Enter VFX address",
                border: OutlineInputBorder(),
              ),
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Amount (vBTC)",
                border: OutlineInputBorder(),
              ),
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 8),
            Text(
              "A fee of $PRIVACY_TX_FIXED_FEE_LABEL will be deducted from your shielded VFX balance.",
              style: const TextStyle(color: Colors.white38, fontSize: 11),
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
              : Text("Unshield", style: TextStyle(color: Theme.of(context).colorScheme.warning)),
        ),
      ],
    );
  }
}
