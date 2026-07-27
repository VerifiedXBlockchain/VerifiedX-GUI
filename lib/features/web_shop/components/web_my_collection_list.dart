import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/components/buttons.dart';
import '../../../core/theme/app_theme.dart';
import 'web_collection_list_tile.dart';
import '../providers/web_collection_form_provider.dart';
import '../providers/web_shop_detail_provider.dart';
import '../screens/my_create_collection_container_screen.dart';

import '../../../core/base_component.dart';
import '../../../core/components/infinite_list.dart';
import '../models/web_collection.dart';
import '../providers/web_collection_list_provider.dart';
import '../../../l10n/generated/app_localizations.dart';

class WebMyCollectionList extends BaseComponent {
  final int shopId;
  const WebMyCollectionList(
    this.shopId, {
    Key? key,
  }) : super(key: key);

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final listProvider = ref.read(webCollectionListProvider(shopId).notifier);

    return InfiniteList<WebCollection>(
      pagingController: listProvider.pagingController,
      itemBuilder: (context, collection, index) => WebCollectionTile(
        collection,
      ),
      emptyText: l10n.r3bNoCollections,
      emptyWidget: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.r3bCreateCollectionsHint,
              style: TextStyle(
                fontSize: 18,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 32,
            ),
            _CreateCollectionButton(
              buttonType: AppButtonType.Elevated,
              shopId: shopId,
            ),
          ],
        ),
      ),
      onRefresh: listProvider.refresh,
    );
  }
}

class _CreateCollectionButton extends BaseComponent {
  final int shopId;
  final AppButtonType buttonType;
  const _CreateCollectionButton({
    required this.shopId,
    this.buttonType = AppButtonType.Elevated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final shop = ref.read(webShopDetailProvider(shopId)).value;

    if (shop == null) {
      return SizedBox();
    }

    return AppButton(
      label: l10n.shopCreateCollection,
      icon: Icons.add,
      type: buttonType,
      variant: AppColorVariant.Success,
      onPressed: () async {
        ref.read(webCollectionFormProvider.notifier).clear(shop);
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => MyCreateCollectionContainerScreen()));
      },
    );
  }
}
