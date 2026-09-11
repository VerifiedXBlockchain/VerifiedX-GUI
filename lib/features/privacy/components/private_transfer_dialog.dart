import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../../../core/app_constants.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/l10n_helper.dart';
import '../../../utils/toast.dart';
import '../providers/privacy_actions_provider.dart';
import '../providers/shielded_address_provider.dart';
import '../utils/vfx_fee_guard.dart';
import '../utils/zfx_address_validation.dart';

class PrivateTransferDialog extends ConsumerStatefulWidget {
  const PrivateTransferDialog({super.key});

  static Future<void> show() async {
    await showDialog(
      context: rootNavigatorKey.currentContext!,
      builder: (_) => const PrivateTransferDialog(),
    );
  }

  @override
  ConsumerState<PrivateTransferDialog> createState() => _PrivateTransferDialogState();
}

class _PrivateTransferDialogState extends ConsumerState<PrivateTransferDialog> {
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!await VfxFeeGuard.check(ref)) return;

    final recipient = _recipientController.text.trim();
    if (!isValidZfxAddress(recipient)) {
      Toast.error(globalL10n.prvRecipientInvalidZfx);
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      Toast.error(globalL10n.prvEnterValidAmount);
      return;
    }

    final zfxAddress = ref.read(shieldedAddressProvider)?.zfxAddress;
    if (zfxAddress == null) {
      Toast.error(globalL10n.prvNoShieldedAddress);
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await ref.read(privacyActionsProvider.notifier).transfer(
          zfxAddress: zfxAddress,
          recipientZfxAddress: recipient,
          amount: amount,
        );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.prvPrivateTransferTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.prvPrivateTransferVfxBody,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _recipientController,
              decoration: InputDecoration(
                labelText: l10n.prvRecipientZfxLabel,
                hintText: "zfx_...",
                border: const OutlineInputBorder(),
              ),
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.prvAmountVfxLabel,
                border: const OutlineInputBorder(),
              ),
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.prvFeeDeductedShieldedShort(PRIVACY_TX_FIXED_FEE_LABEL),
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(
            l10n.actionCancel,
            style: TextStyle(
              color: _isSubmitting ? Colors.white24 : Colors.white70,
              fontSize: 15,
            ),
          ),
        ),
        TextButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(
                  l10n.prvTransferAction,
                  style: TextStyle(
                    color: _isSubmitting ? Colors.white24 : const Color(0xFF73c4fa),
                    fontSize: 15,
                  ),
                ),
        ),
      ],
    );
  }
}
