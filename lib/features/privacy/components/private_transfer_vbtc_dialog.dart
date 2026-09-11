import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../../../core/app_constants.dart';
import '../../../core/theme/colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/l10n_helper.dart';
import '../../../utils/toast.dart';
import '../../btc/models/tokenized_bitcoin.dart';
import '../providers/shielded_address_provider.dart';
import '../providers/vbtc_privacy_actions_provider.dart';
import '../utils/vfx_fee_guard.dart';
import '../utils/zfx_address_validation.dart';

class PrivateTransferVbtcDialog extends ConsumerStatefulWidget {
  final TokenizedBitcoin token;

  const PrivateTransferVbtcDialog({super.key, required this.token});

  static Future<void> show(TokenizedBitcoin token) async {
    await showDialog(
      context: rootNavigatorKey.currentContext!,
      builder: (_) => PrivateTransferVbtcDialog(token: token),
    );
  }

  @override
  ConsumerState<PrivateTransferVbtcDialog> createState() => _PrivateTransferVbtcDialogState();
}

class _PrivateTransferVbtcDialogState extends ConsumerState<PrivateTransferVbtcDialog> {
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

    final success = await ref.read(vbtcPrivacyActionsProvider.notifier).transferVbtc(
          zfxAddress: zfxAddress,
          vbtcContractUid: widget.token.smartContractUid,
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
      title: Text(l10n.prvPrivateTransferVbtcTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.prvPrivateTransferVbtcBody,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.prvContractName(widget.token.tokenName),
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              widget.token.smartContractUid,
              style: const TextStyle(color: Colors.white38, fontSize: 11, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 12),
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
                labelText: l10n.prvAmountVbtcLabel,
                border: const OutlineInputBorder(),
              ),
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.prvFeeDeductedShieldedVfxLong(PRIVACY_TX_FIXED_FEE_LABEL),
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        TextButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.prvTransferAction, style: TextStyle(color: AppColors.getBtc())),
        ),
      ],
    );
  }
}
