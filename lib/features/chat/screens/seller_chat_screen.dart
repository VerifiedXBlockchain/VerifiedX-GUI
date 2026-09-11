import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/base_screen.dart';
import '../../../core/dialogs.dart';
import '../components/new_chat_message.dart';
import '../components/shop_chat_list.dart';
import '../providers/seller_chat_list_provider.dart';
import '../../../l10n/generated/app_localizations.dart';

class SellerChatScreen extends BaseScreen {
  final String address;
  const SellerChatScreen({Key? key, @PathParam("address") required this.address}) : super(key: key);

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppBar(
      title: Text(l10n.chatTitleSingle),
      actions: [
        IconButton(
          onPressed: () {
            ref.read(sellerChatListProvider(address).notifier).fetch();
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
              final success = await ref.read(sellerChatListProvider(address).notifier).deleteThread(null);
              AutoRouter.of(context).pop();
              return;
            }
          },
        )
      ],
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Expanded(
          child: ShopChatList(
            identifier: address,
            isSeller: true,
            isThirdParty: false,
          ),
        ),
        NewChatMessage(
          identifier: address,
          isSeller: true,
          isThirdParty: false,
        )
      ],
    );
  }
}
