import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/base_component.dart';
import '../models/listing.dart';
import '../providers/seller_bid_list_provider.dart';
import '../../remote_shop/components/bid_status_indicator.dart';
import '../../../l10n/generated/app_localizations.dart';

class AuctionActivity extends BaseComponent {
  final Listing listing;
  const AuctionActivity(this.listing, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final identifier = "${listing.collectionId}_${listing.id}";

    final bids = ref.watch(sellerBidListProvider(identifier));

    if (bids.isEmpty) {
      return Center(
        child: Text(l10n.mktNoBidsYet),
      );
    }

    return ListView.builder(
      itemCount: bids.length,
      itemBuilder: (context, index) {
        final bid = bids[index];

        return ListTile(
          leading: BidStatusIndicator(bid),
          title: Text("${bid.bidAmount} VFX"),
          subtitle: Text(bid.bidAddress),
          trailing: Text(bid.bidSendTimeLabel),
        );
      },
    );
  }
}
