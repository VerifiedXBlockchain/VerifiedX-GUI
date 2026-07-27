import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'web_import_shop_button.dart';
import '../../../core/components/buttons.dart';
import '../../../core/web_router.gr.dart';
import 'web_shop_list_tile.dart';
import '../models/web_shop.dart';

import '../../../core/base_component.dart';
import '../../../core/components/infinite_list.dart';
import '../../../core/env.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/web_shop_form_provider.dart';
import '../providers/web_shop_list_provider.dart';
import '../providers/web_shop_search_provider.dart';
import '../../../l10n/generated/app_localizations.dart';

class WebMyShopList extends BaseComponent {
  const WebMyShopList({
    Key? key,
  }) : super(key: key);

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final listProvider = ref.read(webShopListProvider(WebShopListType.mine).notifier);
    final model = ref.watch(webShopListProvider(WebShopListType.mine));

    final searchQuery = ref.watch(webShopSearchProvider).toLowerCase();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: ref.read(webShopSearchProvider.notifier).controller,
                autofocus: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white70,
                  ),
                  hintText: l10n.shopSearchAuctionHouseHint,
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: searchQuery.isEmpty ? Colors.white10 : Colors.white,
                    ),
                    onPressed: () {
                      ref.read(webShopSearchProvider.notifier).clear();
                      listProvider.refresh();
                    },
                  ),
                ),
                onChanged: (val) {
                  ref.read(webShopSearchProvider.notifier).update(val);
                },
                onFieldSubmitted: (val) {
                  listProvider.refresh();
                },
              ),
            ),
            IconButton(
                onPressed: () {
                  listProvider.refresh();
                },
                icon: Icon(Icons.search))
          ],
        ),
        Expanded(
          child: InfiniteList<WebShop>(
            pagingController: listProvider.pagingController,
            itemBuilder: (context, shop, index) => WebShopTile(
              shop,
              requiresAuth: true,
            ),
            emptyText: l10n.r3bNoAuctionHouses,
            emptyWidget: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.r3bSetupAuctionHousePrompt,
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  _CreateShopButton(buttonType: AppButtonType.Elevated, variant: AppColorVariant.Light),
                ],
              ),
            ),
            onRefresh: listProvider.refresh,
          ),
        ),
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF040f26),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _CreateShopButton(
                  buttonType: AppButtonType.Elevated,
                  variant: AppColorVariant.Success,
                  withImport: false,
                ),
                WebImportShopButton(
                  type: AppButtonType.Elevated,
                  variant: AppColorVariant.Light,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CreateShopButton extends BaseComponent {
  final AppButtonType buttonType;
  final AppColorVariant variant;
  final bool withImport;

  const _CreateShopButton({
    this.buttonType = AppButtonType.Elevated,
    this.variant = AppColorVariant.Success,
    this.withImport = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppButton(
          label: l10n.r3bSetupAuctionHouse,
          icon: Icons.store,
          type: buttonType,
          variant: variant,
          onPressed: () async {
            ref.read(webShopFormProvider.notifier).clear();
            if (Env.isWeb) {
              AutoRouter.of(context).push(const CreateWebShopContainerScreenRoute());
            }
          },
        ),
        if (withImport) ...[
          SizedBox(
            height: 8,
          ),
          Text(
            l10n.r3bOr,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
          WebImportShopButton()
        ],
      ],
    );
  }
}
