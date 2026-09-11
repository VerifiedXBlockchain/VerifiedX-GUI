import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/base_component.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/toast.dart';
import '../../../utils/validation.dart';
import '../../encrypt/utils.dart';
import '../../global_loader/global_loading_provider.dart';
import '../../nft/models/nft.dart';
import '../../nft/providers/transferred_provider.dart';
import '../models/token_account.dart';
import '../models/token_sc_feature.dart';
import '../services/token_service.dart';

class ChangeTokenOwnershipButton extends BaseComponent {
  final Nft nft;
  final String fromAddress;

  const ChangeTokenOwnershipButton({
    super.key,
    required this.nft,
    required this.fromAddress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokenAccount = TokenAccount.fromNft(nft, ref);
    final token = TokenScFeature.fromNft(nft);

    if (tokenAccount == null || token == null) {
      return SizedBox();
    }

    final l10n = AppLocalizations.of(context);
    return AppButton(
      label: l10n.tokenChangeOwnership,
      variant: AppColorVariant.Secondary,
      onPressed: () async {
        if (fromAddress.startsWith("xRBX")) {
          if (!await passwordRequiredGuardV2(context, ref, fromAddress)) {
            return;
          }
        }
        final controller = TextEditingController();
        final toAddress = await PromptModal.show(
          title: l10n.tokenTransferToAddressTitle,
          validator: (val) => formValidatorRbxAddress(val),
          labelText: l10n.tokenToAddressLabel,
          controller: controller,
          sufixIcon: AddressChoosingIconButton(controller: controller),
        );
        if (toAddress == null || toAddress.isEmpty) {
          return;
        }
        ref.read(globalLoadingProvider.notifier).start();

        final success = await TokenService().changeOwnership(
          scId: nft.id,
          fromAddress: fromAddress,
          toAddress: toAddress,
        );
        ref.read(globalLoadingProvider.notifier).complete();

        if (success) {
          Toast.message(l10n.tokenOwnershipBroadcastedToast);
          ref.read(transferredProvider.notifier).addId(nft.id);
          Navigator.of(context).pop();
        }
      },
    );
  }
}
