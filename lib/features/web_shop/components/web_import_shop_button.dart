import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_constants.dart';
import '../../../core/base_component.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../global_loader/global_loading_provider.dart';
import '../services/web_shop_service.dart';
import '../utils/shop_publishing.dart';
import '../../../utils/toast.dart';
import '../../../l10n/generated/app_localizations.dart';

class WebImportShopButton extends BaseComponent {
  final AppColorVariant variant;
  final AppButtonType type;
  const WebImportShopButton({
    super.key,
    this.variant = AppColorVariant.Light,
    this.type = AppButtonType.Text,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppButton(
      label: l10n.dstImportShop,
      type: type,
      variant: variant,
      icon: type == AppButtonType.Text ? null : Icons.upload,
      onPressed: () async {
        final myAddress = ref.read(webSessionProvider).keypair?.address;
        if (myAddress == null) {
          Toast.error(l10n.txpNoAccountFound);
          return;
        }

        String? shopUrl = await PromptModal.show(
          contextOverride: context,
          title: l10n.shopUrlPromptTitle,
          validator: (_) => null,
          labelText: l10n.shopUrlPromptTitle,
          body: l10n.r3bShopUrlImportPrompt,
          prefixText: "vfx://",
        );

        if (shopUrl == null || shopUrl.isEmpty) {
          return;
        }

        if (!shopUrl.contains("vfx://")) {
          shopUrl = "vfx://$shopUrl";
        }

        final shop = await WebShopService().lookupShop(shopUrl);

        if (shop == null) {
          Toast.error(l10n.r3bShopNotFound);
          return;
        }

        if (shop.ownerAddress != myAddress) {
          Toast.error(l10n.r3bNotOwnerLoginAs(shop.ownerAddress));
          return;
        }

        final confirmed = await ConfirmDialog.show(
          title: l10n.r3bReadyToImport,
          body: l10n.r3bImportShopConfirmBody(SHOP_UPDATE_COST.toString()),
          confirmText: l10n.r3bImportAndPublish,
          cancelText: l10n.actionCancel,
        );

        if (confirmed != true) {
          return;
        }

        ref.read(globalLoadingProvider.notifier).start();

        final success = await broadcastShopTx(ref.read(webSessionProvider).keypair!, shop, ShopPublishTxType.update);
        ref.read(globalLoadingProvider.notifier).complete();

        if (success == true) {
          InfoDialog.show(
            title: l10n.mktTxBroadcastedToast,
            body: l10n.r3bImportShopBroadcastBody,
          );
        }
      },
    );
  }
}
