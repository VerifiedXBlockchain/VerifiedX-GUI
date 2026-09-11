import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/base_component.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../global_loader/global_loading_provider.dart';
import '../../nft/services/nft_service.dart';
import '../services/token_service.dart';
import '../../../utils/toast.dart';
import '../../../utils/validation.dart';
import '../../../core/utils/tx_refresh.dart';

class BurnTokensButton extends BaseComponent {
  final String scId;
  final String fromAddress;
  final double currentBalance;
  final bool elevated;
  final VoidCallback showRaErrorMessage;
  final bool isOwnedByRA;

  const BurnTokensButton({
    super.key,
    required this.scId,
    required this.fromAddress,
    required this.currentBalance,
    this.elevated = true,
    required this.showRaErrorMessage,
    required this.isOwnedByRA,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppButton(
      label: l10n.tokenBurn,
      variant: AppColorVariant.Danger,
      useDisabledColor: isOwnedByRA,
      type: elevated ? AppButtonType.Elevated : AppButtonType.Text,
      onPressed: () async {
        if (isOwnedByRA) {
          showRaErrorMessage();
          return;
        }

        final nft = await NftService().getNftData(scId);

        if (nft?.tokenStateDetails?.burnable != true) {
          Toast.error(l10n.tokenNotBurnableToast);
          return;
        }

        final amount = await PromptModal.show(
          title: l10n.tokenAmountToBurnTitle,
          validator: (val) => formValidatorNumber(val, l10n.tokenAmountLabel),
          labelText: l10n.tokenAmountLabel,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9.]"))],
        );
        if (amount == null || amount.isEmpty) {
          return;
        }

        final amountDouble = double.tryParse(amount);

        if (amountDouble == null) {
          Toast.error(l10n.tokenInvalidAmountToast);
          return;
        }

        if (amountDouble > currentBalance) {
          Toast.error(l10n.tokenInsufficientBalanceToast);
          return;
        }
        ref.read(globalLoadingProvider.notifier).start();
        final success = await TokenService().burn(
          scId: scId,
          fromAddress: fromAddress,
          amount: amountDouble,
        );
        ref.read(globalLoadingProvider.notifier).complete();

        if (success) {
          Toast.message(l10n.tokenBurnBroadcastedToast);
          notifyTransactionSubmitted();
        }
      },
    );
  }
}
