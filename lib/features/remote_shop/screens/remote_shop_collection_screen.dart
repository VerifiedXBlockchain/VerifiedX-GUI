import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/core/app_router.gr.dart';
import 'package:rbx_wallet/core/base_component.dart';
import 'package:rbx_wallet/core/base_screen.dart';
import 'package:rbx_wallet/features/dst/models/dec_shop.dart';
import 'package:rbx_wallet/features/remote_shop/components/listing_details_list_tile.dart';
import 'package:rbx_wallet/features/remote_shop/components/remote_asset_preview.dart';
import 'package:rbx_wallet/features/remote_shop/components/shop_connected_indicator.dart';
import 'package:rbx_wallet/features/remote_shop/models/shop_data.dart';
import 'package:rbx_wallet/features/remote_shop/providers/connected_shop_provider.dart';
import 'package:collection/collection.dart';
import 'package:rbx_wallet/features/remote_shop/providers/shop_list_view_provider.dart';
import 'package:rbx_wallet/features/remote_shop/services/remote_shop_service.dart';
import 'package:rbx_wallet/features/remote_shop/utils.dart';
import 'package:rbx_wallet/features/wallet/components/wallet_selector.dart';

import '../../../core/components/buttons.dart';
import '../../../core/theme/app_theme.dart';
import "../components/listing_details.dart";

class RemoteShopCollectionScreen extends BaseScreen {
  final int collectionId;
  final String url;

  const RemoteShopCollectionScreen({
    super.key,
    @PathParam("collectionId") required this.collectionId,
    @PathParam("url") required this.url,
  }) : super();

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    final model = ref.watch(connectedShopProvider);
    final shop = model.data;

    if (shop == null) {
      return AppBar();
    }
    final collection = shop.collections.firstWhereOrNull((c) => c.id == collectionId);

    if (collection == null) {
      return AppBar();
    }

    return AppBar(
      title: Text(collection.name),
      backgroundColor: Colors.black12,
      shadowColor: Colors.transparent,
      actions: [
        Align(
          alignment: Alignment.center,
          child: ShopConnectedIndicator(
            shopUrl: url,
          ),
        ),
        SizedBox(
          width: 8,
        ),
        WalletSelector(),
        IconButton(
          onPressed: () {
            ref.read(connectedShopProvider.notifier).refresh(true);
          },
          icon: Icon(Icons.refresh),
        ),
        AppButton(
          type: AppButtonType.Text,
          variant: AppColorVariant.Light,
          icon: Icons.chat_bubble_outline,
          label: 'Chat',
          onPressed: () {
            AutoRouter.of(context).push(ShopChatScreenRoute(shopUrl: url));
          },
        )
      ],
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final provider = ref.read(connectedShopProvider.notifier);
    final model = ref.watch(connectedShopProvider);

    final isExpanded = ref.watch(shopListViewProvider);

    final shop = model.data;
    if (shop == null) {
      return Center(child: Text("Shop Error"));
    }

    final collection = shop.collections.firstWhereOrNull((c) => c.id == collectionId);

    if (collection == null) {
      return Center(child: Text("Collection Error"));
    }

    final validListings = collection.listings.where((l) => l.nft != null && !l.hide).toList();

    if (validListings.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(collection: collection),
          Expanded(
            child: Center(
              child: Text("No Active Listings"),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: validListings.length,
            itemBuilder: (context, index) {
              final listing = validListings[index];

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (index == 0) _Header(collection: collection),
                  isExpanded ? ListingDetails(listing: listing) : ListingDetailsListTile(listing: listing),
                ],
              );
            },
          ),
        )
      ],
    );
  }
}

class _Header extends BaseComponent {
  const _Header({
    super.key,
    required this.collection,
  });

  final OrganizedCollection collection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listModeProvider = ref.read(shopListViewProvider.notifier);
    final isExpanded = ref.watch(shopListViewProvider);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              collection.description,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white),
              textAlign: TextAlign.start,
            ),
          ),
          SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  listModeProvider.setExpanded();
                },
                icon: Icon(
                  Icons.grid_on,
                  color: isExpanded ? Colors.white : Colors.white38,
                ),
              ),
              IconButton(
                onPressed: () {
                  listModeProvider.setCondensed();
                },
                icon: Icon(
                  Icons.list_outlined,
                  color: !isExpanded ? Colors.white : Colors.white38,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}