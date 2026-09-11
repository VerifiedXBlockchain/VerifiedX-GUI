import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/base_screen.dart';
import '../providers/web_shop_full_list_provider.dart';
import '../services/web_shop_service.dart';

import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../bridge/providers/wallet_info_provider.dart';
import '../components/web_shop_list.dart';
import '../components/web_shop_list_tile.dart';
import '../models/web_shop.dart';
import '../providers/web_shop_list_provider.dart';

class WebShopListScreen extends BaseScreen {
  const WebShopListScreen({super.key})
      : super(
          includeWebDrawer: true,
        );
  Future<String?> promptForShopUrl(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context);
    String? url = await PromptModal.show(
      title: l10n.shopUrlPromptTitle,
      initialValue: "vfx://",
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.shopUrlRequired;
        }

        return null;
      },
      labelText: l10n.shopUrlLabel,
    );

    if (url == null) {
      return null;
    }

    if (!url.startsWith("vfx://")) {
      url = "vfx://$url";
    }

    return url.trim();
  }

  Future<void> loadShopWithPrompt(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final url = await promptForShopUrl(context, ref);
    if (url == null) return;

    WebShop? shop = await WebShopService().lookupShop(url);

    if (shop == null) return;

    if (ref.read(walletInfoProvider) == null || !ref.read(walletInfoProvider)!.isChainSynced) {
      final l10n = AppLocalizations.of(context);
      final cont = await ConfirmDialog.show(
        title: l10n.shopWalletNotSyncedTitle,
        body: l10n.shopWalletNotSyncedBody,
        confirmText: l10n.actionContinue,
        cancelText: l10n.actionCancel,
      );

      if (cont != true) {
        return;
      }
    }

    WebShopTile.pushToShop(context, ref, shop);
  }

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      centerTitle: true,
      leading: IconButton(
          onPressed: () {
            ref.read(webShopFullListProvider.notifier).pauseTimer();
            AutoRouter.of(context).pop();
          },
          icon: Icon(Icons.chevron_left)),
      backgroundColor: Colors.black12,
      shadowColor: Colors.transparent,
      title: Text(AppLocalizations.of(context).shopAuctionHousesTitle),
      actions: [
        kIsWeb
            ? SizedBox.shrink()
            : AppButton(
                onPressed: () async {
                  await loadShopWithPrompt(context, ref);
                },
                label: AppLocalizations.of(context).shopConnectToShop,
                type: AppButtonType.Text,
                variant: AppColorVariant.Light,
                icon: Icons.add,
              ),
        IconButton(
            onPressed: () {
              ref.read(webShopListProvider(WebShopListType.public).notifier).refresh();
            },
            icon: Icon(Icons.refresh)),
      ],
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    return const WebShopListContainer();
  }
}
