import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/components.dart';
import '../../../utils/guards.dart';
import '../../../utils/toast.dart';

import '../../../core/app_router.gr.dart';
import '../../../core/base_component.dart';
import '../../../core/components/badges.dart';
import '../../../core/dialogs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/web_router.gr.dart' as webRouter;
import '../../bridge/providers/wallet_info_provider.dart';
import '../../remote_shop/providers/connected_shop_provider.dart';
import '../models/web_shop.dart';
import '../../../l10n/generated/app_localizations.dart';

class WebShopTile extends BaseComponent {
  final WebShop shop;

  final bool requiresAuth;
  const WebShopTile(this.shop, {Key? key, this.requiresAuth = false}) : super(key: key);
  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentUrl = ref.watch(connectedShopProvider.select((v) => v.url));
    final isConnected = ref.watch(connectedShopProvider.select((v) => v.isConnected));
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AppCard(
        padding: 0,
        margin: EdgeInsets.zero,
        child: ListTile(
          title: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              children: [
                TextSpan(
                  text: shop.name,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                if (shop.isOwner(ref))
                  TextSpan(
                    text: l10n.r3bMyShopSuffix,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.warning,
                    ),
                  ),
              ],
            ),
          ),
          subtitle: RichText(
            text: TextSpan(style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500), children: [
              TextSpan(
                text: shop.url,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                ),
              ),
              TextSpan(text: " "),
              TextSpan(
                text: shop.ownerAddress,
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ]),
          ),
          leading: Icon(
            Icons.house,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (shop.isPublished)
                AppBadge(
                  label: shop.isOnline ? l10n.r3bOnline : l10n.r3bOffline,
                  variant: shop.isOnline ? AppColorVariant.Success : AppColorVariant.Danger,
                ),
              if (!shop.isPublished && shop.isOwner(ref)) AppBadge(label: l10n.r3bUnpublished, variant: AppColorVariant.Warning),
              Icon(Icons.chevron_right),
            ],
          ),
          onTap: () async {
            if (requiresAuth) {
              if (!await guardWebAuthorized(ref, shop.ownerAddress)) {
                Toast.error(l10n.r3bNotAuthorized);
                return;
              }
            }

            if (!requiresAuth && shop.isOwner(ref) && !kIsWeb) {
              Toast.error(l10n.r3bThisIsYourShop);
              return;
            }

            if (!shop.isOnline) {
              Toast.error(l10n.r3bShopIsOffline);
              return;
            }

            //If is web just push the web route
            if (kIsWeb) {
              AutoRouter.of(context).push(webRouter.WebShopDetailScreenRoute(shopId: shop.id));
              return;
            }

            await pushToShop(context, ref, shop);
          },
        ),
      ),
    );
    // return Card(
    //   color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
    //   child: ListTile(
    //     title: Text(shop.name),
    //     trailing: Icon(Icons.chevron_right_outlined),
    //     onTap: () {
    //       if (Env.isWeb) {
    //         AutoRouter.of(context).push(WebShopDetailScreenRoute(shopId: shop.id));
    //       } else {
    //         AutoRouter.of(context).push(DebugWebShopDetailScreenRoute(shopId: shop.id));
    //       }
    //     },
    //   ),
    // );
  }

  static Future pushToShop(BuildContext context, WidgetRef ref, WebShop shop) async {
    final l10n = AppLocalizations.of(context);
    if (shop.isThirdParty) {
      AutoRouter.of(context).push(WebShopDetailScreenRoute(shopId: shop.id));
      return;
    }

    if (ref.read(walletInfoProvider) == null || !ref.read(walletInfoProvider)!.isChainSynced) {
      final cont = await ConfirmDialog.show(
        title: l10n.shopWalletNotSyncedTitle,
        body: l10n.r3bWalletNotSyncedBody,
        confirmText: l10n.actionContinue,
        cancelText: l10n.actionCancel,
      );

      if (cont != true) {
        return;
      }
    }

    await ref.read(connectedShopProvider.notifier).loadShop(context, ref, shop.url);

    return;

    final currentUrl = ref.watch(connectedShopProvider.select((v) => v.url));
    final isConnected = ref.watch(connectedShopProvider.select((v) => v.isConnected));

    if (currentUrl == shop.url && isConnected) {
      ref.read(connectedShopProvider.notifier).refresh();
      ref.read(connectedShopProvider.notifier).activateRefreshTimer();
      AutoRouter.of(context).push(RemoteShopDetailScreenRoute(shopUrl: shop.url));
    } else {
      await ref.read(connectedShopProvider.notifier).loadShop(context, ref, shop.url);
    }
  }
}
