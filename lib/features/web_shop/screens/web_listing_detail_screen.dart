import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/base_screen.dart';
import '../../../core/components/centered_loader.dart';
import '../../../core/components/empty_placeholder.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../components/web_listing_detail.dart';

import '../providers/web_listing_detail_provider.dart';

class WebListingDetailScreen extends BaseScreen {
  final int shopId;
  final int collectionId;
  final int listingId;

  const WebListingDetailScreen({
    super.key,
    @PathParam("shopId") required this.shopId,
    @PathParam("collectionId") required this.collectionId,
    @PathParam("listingId") required this.listingId,
  }) : super();

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    final data = ref.watch(webListingDetailProvider("$shopId,$collectionId,$listingId"));
    return data.when(
      data: (listing) => listing != null
          ? AppBar(
              centerTitle: true,
              backgroundColor: Colors.black12,
              shadowColor: Colors.transparent,
              title: Text("${listing.collection.shop?.name} > ${listing.collection.name} > ${listing.nft?.name} "),
            )
          : AppBar(
              title: Text(AppLocalizations.of(context).shopErrorTitle),
            ),
      error: (_, __) => AppBar(
        title: Text(AppLocalizations.of(context).shopErrorTitle),
        backgroundColor: Colors.black12,
        shadowColor: Colors.transparent,
      ),
      loading: () => AppBar(
        title: Text(AppLocalizations.of(context).shopLoading),
        backgroundColor: Colors.black12,
        shadowColor: Colors.transparent,
      ),
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final data = ref.watch(webListingDetailProvider("$shopId,$collectionId,$listingId"));
    final l10n = AppLocalizations.of(context);

    return data.when(
      data: (listing) => listing != null ? Center(child: WebListingDetails(listing: listing)) : Center(child: EmptyPlaceholder(title: l10n.shopErrorTitle)),
      error: (_, __) => Center(child: EmptyPlaceholder(title: l10n.shopErrorTitle)),
      loading: () => const CenteredLoader(),
    );
  }
}
