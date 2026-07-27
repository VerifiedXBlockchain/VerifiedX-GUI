import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/base_screen.dart';
import '../../../core/components/centered_loader.dart';
import '../../../core/dialogs.dart';
import '../components/new_chat_message.dart';
import '../components/shop_chat_list.dart';
import '../providers/shop_chat_list_provider.dart';
import '../providers/web_shop_chat_list_provider.dart';
import '../../remote_shop/providers/remote_shop_detail_provider.dart';
import '../../../l10n/generated/app_localizations.dart';

class ShopChatScreen extends BaseScreen {
  final String url;
  const ShopChatScreen({Key? key, @PathParam("url") required this.url}) : super(key: key);

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final data = ref.watch(remoteShopDetailProvider(url));

    return data.when(
      data: (shop) => shop != null
          ? AppBar(
              title: Text(l10n.chatChattingWith(shop.name)),
              centerTitle: true,
              backgroundColor: Colors.black,
              actions: [
                IconButton(
                  onPressed: () {
                    if (shop.isThirdParty) {
                      ref.read(webShopChatListProvider(url).notifier).fetch();
                    } else {
                      ref.read(shopChatListProvider(url).notifier).fetch();
                    }
                  },
                  icon: Icon(Icons.refresh),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    final confirmed = await ConfirmDialog.show(
                      title: l10n.chatDeleteThread,
                      body: l10n.mktDeleteChatThreadLocalBody,
                      destructive: true,
                      confirmText: l10n.actionDelete,
                      cancelText: l10n.actionCancel,
                    );

                    if (confirmed == true) {
                      final success = await ref.read(shopChatListProvider(url).notifier).deleteThread(null);
                      // if (success) {
                      AutoRouter.of(context).pop();
                      return;
                      // }
                    }
                  },
                )
              ],
            )
          : AppBar(
              title: Text(l10n.chatErrorTitle),
            ),
      error: (_, __) => AppBar(
        title: Text(l10n.chatErrorTitle),
      ),
      loading: () => AppBar(
        title: const Text(""),
        backgroundColor: Colors.black,
      ),
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final data = ref.watch(remoteShopDetailProvider(url));

    return data.when(
      data: (shop) => shop != null
          ? Column(
              children: [
                Expanded(
                  child: ShopChatList(
                    identifier: url,
                    isThirdParty: shop.isThirdParty,
                  ),
                ),
                NewChatMessage(
                  identifier: url,
                  isThirdParty: shop.isThirdParty,
                )
              ],
            )
          : Center(child: Text(l10n.chatErrorTitle)),
      error: (_, __) => Text(l10n.chatErrorTitle),
      loading: () => const CenteredLoader(),
    );
  }
}
