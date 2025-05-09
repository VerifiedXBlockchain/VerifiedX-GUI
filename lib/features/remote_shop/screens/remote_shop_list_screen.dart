import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/theme/app_theme.dart';
import '../../bridge/providers/wallet_info_provider.dart';
import '../../dst/models/dec_shop.dart';
import '../components/remote_shop_list_tile.dart';
import '../providers/connected_shop_provider.dart';
import '../providers/global_remote_shop_list_provider.dart';
import '../providers/remote_shop_search_provider.dart';
import '../../../core/app_router.gr.dart';
import '../../../core/base_screen.dart';

class RemoteShopListScreen extends BaseScreen {
  const RemoteShopListScreen({Key? key})
      : super(
          key: key,
          verticalPadding: 0,
          horizontalPadding: 0,
        );

  Future<String?> promptForShopUrl(
    BuildContext context,
    WidgetRef ref,
  ) async {
    String? url = await PromptModal.show(
      title: "Shop URL",
      initialValue: "vfx://",
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Shop URL required";
        }

        return null;
      },
      labelText: "Input Shop Name Only",
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

    if (ref.read(walletInfoProvider) == null || !ref.read(walletInfoProvider)!.isChainSynced) {
      final cont = await ConfirmDialog.show(
        title: "Wallet Not Synced",
        body: "Since your wallet is not synced there may be some issues viewing the data in this shop. Continue anyway?",
        confirmText: "Continue",
        cancelText: "Cancel",
      );

      if (cont != true) {
        return;
      }
    }

    if (url != null) {
      ref.read(connectedShopProvider.notifier).loadShop(context, ref, url);
    }
  }

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: const Text("Auction Houses"),
      backgroundColor: Colors.black12,
      shadowColor: Colors.transparent,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          Icons.navigate_before,
          size: 32,
        ),
        onPressed: () {
          AutoRouter.of(context).pop();
        },
      ),
      actions: [
        AppButton(
          type: AppButtonType.Text,
          variant: AppColorVariant.Light,
          icon: Icons.chat_bubble_outline,
          label: 'Chat',
          onPressed: () {
            AutoRouter.of(context).push(BuyerChatThreadListScreenRoute());
          },
        ),
        AppButton(
          onPressed: () async {
            await loadShopWithPrompt(context, ref);
          },
          label: "Connect to a Shop",
          type: AppButtonType.Text,
          variant: AppColorVariant.Light,
          icon: Icons.add,
        ),
        // WalletSelector(),
      ],
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final globalShops = ref.watch(globalRemoteShopListProvider);

    if (globalShops.isEmpty) {
      return Center(
        child: AppButton(
          label: "Connect to a Shop",
          variant: AppColorVariant.Success,
          onPressed: () async {
            await loadShopWithPrompt(context, ref);
          },
        ),
      );
    }

    final searchQuery = ref.watch(remoteShopSearchProvider).toLowerCase();

    final List<DecShop> filteredGlobalShops = searchQuery.isEmpty
        ? [...globalShops]
        : [...globalShops]
            .where((s) => s.name.toLowerCase().contains(searchQuery) || s.urlWithoutPrefix.toLowerCase().contains(searchQuery))
            .toList();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: ref.read(remoteShopSearchProvider.notifier).controller,
                autofocus: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white70,
                  ),
                  hintText: "Search for auction house...",
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: searchQuery.isEmpty ? Colors.white10 : Colors.white,
                    ),
                    onPressed: () {
                      ref.read(remoteShopSearchProvider.notifier).clear();
                    },
                  ),
                ),
                onChanged: (val) {
                  ref.read(remoteShopSearchProvider.notifier).update(val);
                },
              ),
            ),
            IconButton(
                onPressed: () {
                  ref.read(globalRemoteShopListProvider.notifier).load();
                },
                icon: Icon(Icons.refresh))
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredGlobalShops.length,
            itemBuilder: (context, index) {
              final shop = filteredGlobalShops[index];

              return RemoteShopListTile(key: Key(shop.url), shop: shop);
            },
          ),
        ),
      ],
    );
  }
}
