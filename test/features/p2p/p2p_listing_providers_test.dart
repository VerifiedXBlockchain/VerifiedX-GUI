import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_bid_summary.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_error.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_listing.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_page.dart';
import 'package:rbx_wallet/features/p2p/providers/p2p_listing_providers.dart';
import 'package:rbx_wallet/features/p2p/providers/p2p_session_provider.dart';

import 'p2p_test_helpers.dart';

/// A registry whose listing reads wait until the test lets them finish.
class SlowP2pService extends FakeP2pService {
  final List<Completer<P2pListing?>> reads = [];

  @override
  Future<P2pListing?> getListing(int id) {
    calls.add('getListing($id)');
    final read = Completer<P2pListing?>();
    reads.add(read);
    return read.future;
  }
}

/// A registry that hands out a listing's bids 100 to a page.
class PagedBidsService extends FakeP2pService {
  final int total;

  PagedBidsService(this.total);

  @override
  Future<P2pPage<P2pBidSummary>> listBids(int listingId, {int page = 1, int? limit}) async {
    calls.add('listBids($listingId, page: $page, limit: $limit)');
    final first = (page - 1) * 100;
    final count = (total - first).clamp(0, 100);
    return P2pPage(
      count: total,
      next: first + count < total ? page + 1 : null,
      results: [for (var i = 0; i < count; i++) P2pBidSummary(id: total - first - i, address: 'xBidder', amount: '1')],
    );
  }
}

void main() {
  P2pListing auction() => P2pListing.fromJson(p2pFixture('listing_auction_live'));

  ProviderContainer containerFor(FakeP2pService service) {
    final container = ProviderContainer(overrides: [p2pServiceProvider.overrideWithValue(service)]);
    addTearDown(container.dispose);
    return container;
  }

  group('p2pListingDetailProvider', () {
    test('replace shows the listing a bid answered with, without another read', () async {
      final service = FakeP2pService()..listingsById = {2: auction()};
      final container = containerFor(service);
      final subscription = container.listen(p2pListingDetailProvider(2), (_, __) {});
      addTearDown(subscription.close);
      await container.read(p2pListingDetailProvider(2).future);

      container.read(p2pListingDetailProvider(2).notifier).replace(auction().copyWith(bidCount: 9));
      expect(container.read(p2pListingDetailProvider(2)).value!.bidCount, 9);
      expect(service.calls.where((c) => c == 'getListing(2)'), hasLength(1));
    });

    test('refresh keeps the listing on screen when the read fails', () async {
      final service = FakeP2pService()..listingsById = {2: auction()};
      final container = containerFor(service);
      final subscription = container.listen(p2pListingDetailProvider(2), (_, __) {});
      addTearDown(subscription.close);
      await container.read(p2pListingDetailProvider(2).future);

      service.error = const P2pError(status: null, code: P2pError.unreachable);
      await container.read(p2pListingDetailProvider(2).notifier).refresh();
      final shown = container.read(p2pListingDetailProvider(2));
      expect(shown.hasError, isFalse);
      expect(shown.value!.id, 2);

      // The next read that works brings the newer listing.
      service.error = null;
      service.listingsById[2] = auction().copyWith(bidCount: 4);
      await container.read(p2pListingDetailProvider(2).notifier).refresh();
      expect(container.read(p2pListingDetailProvider(2)).value!.bidCount, 4);
    });

    test('a read that left before a bid was accepted does not put the old listing back', () async {
      final service = SlowP2pService();
      final container = containerFor(service);
      final subscription = container.listen(p2pListingDetailProvider(2), (_, __) {});
      addTearDown(subscription.close);
      service.reads.removeAt(0).complete(auction());
      await container.read(p2pListingDetailProvider(2).future);
      final notifier = container.read(p2pListingDetailProvider(2).notifier);

      // A poll sets out, then the bid's answer arrives, then the poll lands
      // with the listing as it was before the bid.
      final poll = notifier.refresh();
      notifier.replace(auction().copyWith(bidCount: 2, nextMinBid: '3.5'));
      service.reads.removeAt(0).complete(auction());
      await poll;

      final shown = container.read(p2pListingDetailProvider(2)).value!;
      expect(shown.bidCount, 2);
      expect(shown.nextMinBid, '3.5');
    });

    test('asked again while a read is under way, it reads once more afterwards and never two at once', () async {
      final service = SlowP2pService();
      final container = containerFor(service);
      final subscription = container.listen(p2pListingDetailProvider(2), (_, __) {});
      addTearDown(subscription.close);
      service.reads.removeAt(0).complete(auction());
      await container.read(p2pListingDetailProvider(2).future);
      final notifier = container.read(p2pListingDetailProvider(2).notifier);

      final first = notifier.refresh();
      // Three more asks while the first read is still out: no new request.
      notifier.refresh();
      notifier.refresh();
      final last = notifier.refresh();
      expect(service.reads, hasLength(1));

      // The first read lands and is shown; one follow-up read sets out.
      service.reads.removeAt(0).complete(auction().copyWith(bidCount: 3));
      await Future<void>.delayed(Duration.zero);
      expect(container.read(p2pListingDetailProvider(2)).value!.bidCount, 3);
      expect(service.reads, hasLength(1));

      service.reads.removeAt(0).complete(auction().copyWith(bidCount: 4));
      await Future.wait([first, last]);
      expect(container.read(p2pListingDetailProvider(2)).value!.bidCount, 4);
      expect(service.reads, isEmpty);
    });

    test('reads slower than the poll still each update the page', () async {
      // Every read takes longer than the 15 seconds between polls.
      final service = SlowP2pService();
      final container = containerFor(service);
      final subscription = container.listen(p2pListingDetailProvider(2), (_, __) {});
      addTearDown(subscription.close);
      service.reads.removeAt(0).complete(auction());
      await container.read(p2pListingDetailProvider(2).future);
      final notifier = container.read(p2pListingDetailProvider(2).notifier);

      for (var round = 1; round <= 3; round++) {
        notifier.refresh(); // a poll
        notifier.refresh(); // the next poll, the read still out
        service.reads.removeAt(0).complete(auction().copyWith(bidCount: round));
        await Future<void>.delayed(Duration.zero);
        expect(container.read(p2pListingDetailProvider(2)).value!.bidCount, round, reason: 'read $round was dropped');
        // The follow-up read the second poll asked for is out now.
        service.reads.removeAt(0).complete(auction().copyWith(bidCount: round));
        await Future<void>.delayed(Duration.zero);
      }
      expect(service.reads, isEmpty);
    });

    test('a refresh that ends after the page has closed is harmless', () async {
      final service = SlowP2pService();
      final container = containerFor(service);
      final subscription = container.listen(p2pListingDetailProvider(2), (_, __) {});
      service.reads.removeAt(0).complete(auction());
      await container.read(p2pListingDetailProvider(2).future);

      final refreshing = container.read(p2pListingDetailProvider(2).notifier).refresh();
      // The page closes while the read is on its way.
      subscription.close();
      await Future<void>.delayed(Duration.zero);
      service.reads.removeAt(0).complete(auction().copyWith(bidCount: 7));

      await expectLater(refreshing, completes);
    });
  });

  group('p2pAllBidsProvider', () {
    test('reads every page of a listing\'s bids, newest first', () async {
      final service = PagedBidsService(230);
      final bids = await containerFor(service).read(p2pAllBidsProvider(2).future);
      expect(bids, hasLength(230));
      expect(bids.first.id, 230);
      expect(bids.last.id, 1);
      expect(service.calls, [
        'listBids(2, page: 1, limit: 100)',
        'listBids(2, page: 2, limit: 100)',
        'listBids(2, page: 3, limit: 100)',
      ]);
    });

    test('stops at a bound of pages even if the registry never says it is done', () async {
      final service = PagedBidsService(1000000);
      final bids = await containerFor(service).read(p2pAllBidsProvider(2).future);
      expect(bids, hasLength(5000));
      expect(service.calls, hasLength(50));
    });
  });
}
