import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/p2p_bid_summary.dart';
import '../models/p2p_listing.dart';
import '../models/p2p_page.dart';
import '../services/p2p_bidder.dart';
import 'p2p_session_provider.dart';

part 'p2p_listing_providers.g.dart';

/// A listing with its newest bids, or null when there is no such listing.
@riverpod
class P2pListingDetail extends _$P2pListingDetail {
  @override
  Future<P2pListing?> build(int id) {
    return ref.watch(p2pServiceProvider).getListing(id);
  }

  /// Shows [listing] as it now stands (the answer to a bid) without another
  /// read.
  void replace(P2pListing listing) {
    state = AsyncData(listing);
  }

  /// Reads the listing again, keeping what is on screen until the answer is
  /// in. A read that fails leaves a listing already shown as it is; the next
  /// one tries again.
  Future<void> refresh() async {
    final fresh = await AsyncValue.guard(() => ref.read(p2pServiceProvider).getListing(id));
    if (fresh.hasError && state.hasValue) {
      return;
    }
    state = fresh;
  }
}

/// Every bid on a listing, newest first: the listing itself carries only its
/// newest 100.
@riverpod
Future<List<P2pBidSummary>> p2pAllBids(P2pAllBidsRef ref, int listingId) async {
  // Far more than any auction should hold; a bound on the reads all the same.
  const maxPages = 50;
  final service = ref.watch(p2pServiceProvider);
  final bids = <P2pBidSummary>[];
  int? page = 1;
  for (var read = 0; page != null && read < maxPages; read++) {
    final result = await service.listBids(listingId, page: page, limit: P2pPage.maxLimit);
    bids.addAll(result.results);
    page = result.next;
  }
  return bids;
}

@Riverpod(keepAlive: true)
P2pBidder p2pBidder(P2pBidderRef ref) {
  return P2pBidder(
    service: ref.watch(p2pServiceProvider),
    session: ref.watch(p2pSessionProvider),
    signer: ref.watch(p2pSignerProvider),
  );
}
