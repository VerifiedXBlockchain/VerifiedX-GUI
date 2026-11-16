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
  // Goes up with every [replace], so a read can tell whether a bid's answer
  // was shown while it was on its way.
  int _replaced = 0;

  // The reads under way, and whether one more was asked for meanwhile.
  Future<void>? _reading;
  bool _readAgain = false;

  @override
  Future<P2pListing?> build(int id) {
    return ref.watch(p2pServiceProvider).getListing(id);
  }

  /// Shows [listing] as it now stands (the answer to a bid) without another
  /// read.
  void replace(P2pListing listing) {
    _replaced++;
    state = AsyncData(listing);
  }

  /// Reads the listing again, keeping what is on screen until the answer is
  /// in.
  ///
  /// One read at a time: asked again while a read is under way, it does not
  /// start a second one beside it but reads once more when that one is in,
  /// so reads slower than the page's poll still each update the page and
  /// never pile up. A read that fails leaves a listing already shown as it
  /// is. A read that was on its way when [replace] showed a bid's answer is
  /// older than that answer and is dropped.
  Future<void> refresh() {
    final running = _reading;
    if (running != null) {
      _readAgain = true;
      return running;
    }
    final reading = _read();
    _reading = reading;
    return reading;
  }

  Future<void> _read() async {
    final service = ref.read(p2pServiceProvider);
    try {
      do {
        _readAgain = false;
        final replaced = _replaced;
        final fresh = await AsyncValue.guard(() => service.getListing(id));
        if (replaced == _replaced && !(fresh.hasError && state.hasValue)) {
          state = fresh;
        }
      } while (_readAgain);
    } finally {
      _reading = null;
    }
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
