import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../../../core/app_constants.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/l10n_helper.dart';
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
      Toast.error(globalL10n.prvNoWalletSelected);
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount < MIN_SHIELD_AMOUNT_VBTC) {
      Toast.error(globalL10n.prvMinShieldAmountVbtc(MIN_SHIELD_AMOUNT_VBTC.toString()));
      return;
    }

    final zfxAddress = ref.read(shieldedAddressProvider)?.zfxAddress;
    if (zfxAddress == null) {
      Toast.error(globalL10n.prvNoShieldedAddress);
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
    final l10n = AppLocalizations.of(context);
    final wallet = ref.watch(sessionProvider.select((v) => v.currentWallet));

    return AlertDialog(
      title: Text(l10n.prvShieldVbtcTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.prvShieldVbtcBody,
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
            const SizedBox(height: 8),
            Text(
              l10n.prvFromAddress(wallet?.address ?? l10n.prvNoWalletSelected),
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.prvAmountVbtcLabel,
                hintText: l10n.prvMinHint(MIN_SHIELD_AMOUNT_VBTC.toString()),
                border: const OutlineInputBorder(),
              ),
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.prvTransparentFeeAutoCalc,
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
              : Text(l10n.prvShieldAction, style: TextStyle(color: AppColors.getBtc())),
        ),
      ],
    );
  }
}
