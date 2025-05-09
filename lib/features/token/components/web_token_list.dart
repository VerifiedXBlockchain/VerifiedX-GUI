import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_router.gr.dart';
import '../../../core/base_component.dart';
import '../../../core/components/buttons.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/web_router.gr.dart';
import 'token_list_tile.dart';
import '../models/token_account.dart';
import '../providers/token_nfts_provider.dart';
import '../../../utils/toast.dart';

import '../../../core/components/badges.dart';
import '../../../core/theme/components.dart';
import '../../../core/theme/pretty_icons.dart';
import '../models/web_fungible_token.dart';
import '../providers/web_token_detail_provider.dart';
import '../providers/web_token_list_provider.dart';

class WebTokenList extends BaseComponent {
  final String? filterByToken;
  final bool shrinkWrap;
  const WebTokenList({
    super.key,
    this.filterByToken,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(webTokenListProvider);

    if (accounts.isEmpty) {
      if (shrinkWrap) {
        return SizedBox();
      }
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "No Fungible Tokens",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text("You have no fungible tokens with supply in any of your accounts."),
            SizedBox(height: 16),
            AppButton(
              label: "Create Token",
              variant: AppColorVariant.Success,
              onPressed: () {
                if (kIsWeb) {
                  AutoRouter.of(context).push(WebTokenCreateScreenRoute());
                } else {
                  AutoRouter.of(context).push(TokenCreateScreenRoute());
                }
              },
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        shrinkWrap: shrinkWrap,
        itemCount: accounts.length,
        itemBuilder: (context, index) {
          final account = accounts[index];
          final token = account.token;
          final isOwnedByRA = account.address.startsWith("xRBX");

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AppCard(
              padding: 0,
              child: ListTile(
                leading: token.imageUrl != null && token.imageUrl!.isNotEmpty
                    ? Image.network(token.imageUrl!, width: 48, height: 48, fit: BoxFit.cover)
                    : PrettyIcon(
                        type: PrettyIconType.fungibleToken,
                      ),
                title: Text("[${token.ticker}] ${token.name}"),
                subtitle: Text(
                  account.address,
                  style: TextStyle(
                    color: isOwnedByRA ? Theme.of(context).colorScheme.reserve : null,
                  ),
                ),
                trailing: AppBadge(
                  label: "${account.balance} ${token.ticker}",
                  variant: account.address.startsWith("xRBX") ? AppColorVariant.Reserve : AppColorVariant.Secondary,
                ),
                onTap: () {
                  ref.invalidate(webTokenDetailProvider(token.smartContractId));
                  AutoRouter.of(context).push(WebTokenDetailScreenRoute(scId: token.smartContractId));
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
