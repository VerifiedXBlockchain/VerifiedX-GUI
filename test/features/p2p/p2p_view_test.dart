import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_listing.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_me.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_shop.dart';
import 'package:rbx_wallet/features/p2p/utils/p2p_amount.dart';
import 'package:rbx_wallet/features/p2p/utils/p2p_view.dart';

import 'p2p_test_helpers.dart';

void main() {
  P2pListing listing(String fixture, [Map<String, dynamic> changes = const {}]) {
    return P2pListing.fromJson({...p2pFixture(fixture), ...changes});
  }

  test('an address is shortened for a card, a short one left alone', () {
    expect(shortP2pAddress('xJwSHB75g85bfhPLBFJ7JS1QzkDRhNJksJ'), 'xJwSHB…NJksJ');
    expect(shortP2pAddress('xShort'), 'xShort');
  });

  group('P2pCountdown', () {
    test('shows the two largest units worth reading', () {
      final days = P2pCountdown.of(const Duration(days: 2, hours: 4, minutes: 30))!;
      expect(days.unit, P2pCountdownUnit.daysHours);
      expect([days.days, days.hours], [2, 4]);

      final hours = P2pCountdown.of(const Duration(hours: 3, minutes: 12, seconds: 59))!;
      expect(hours.unit, P2pCountdownUnit.hoursMinutes);
      expect([hours.hours, hours.minutes], [3, 12]);

      final minutes = P2pCountdown.of(const Duration(minutes: 4, seconds: 9))!;
      expect(minutes.unit, P2pCountdownUnit.minutesSeconds);
      expect([minutes.minutes, minutes.seconds], [4, 9]);

      final seconds = P2pCountdown.of(const Duration(seconds: 12))!;
      expect(seconds.unit, P2pCountdownUnit.seconds);
      expect(seconds.seconds, 12);
    });

    test('rounds a part of a second up, so it never shows 0s with time left', () {
      expect(P2pCountdown.of(const Duration(milliseconds: 200))!.seconds, 1);
    });

    test('is null once the time has run out', () {
      expect(P2pCountdown.of(Duration.zero), isNull);
      expect(P2pCountdown.of(const Duration(seconds: -5)), isNull);
    });
  });

  group('P2pListingClock', () {
    // The buy-now fixture runs 2026-11-16 15:26:35 to 2026-12-16 15:26:35.
    final live = listing('listing_buy_now');

    test('a live listing before its start is upcoming, until the start', () {
      final clock = P2pListingClock.of(live, DateTime.utc(2026, 11, 16, 15));
      expect(clock.kind, P2pClockKind.upcoming);
      expect(clock.until, live.startsAt);
    });

    test('a live listing inside its dates is open, until the end', () {
      final clock = P2pListingClock.of(live, DateTime.utc(2026, 11, 20));
      expect(clock.kind, P2pClockKind.open);
      expect(clock.until, live.endsAt);
    });

    test('a live listing past its end is closing: the registry has not settled it yet', () {
      final clock = P2pListingClock.of(live, DateTime.utc(2026, 12, 17));
      expect(clock.kind, P2pClockKind.closing);
      expect(clock.until, isNull);
    });

    test('a won listing counts down the seller\'s 48 hours', () {
      final won = listing('listing_sale_pending', {'state': 'awaiting_sale_start'});
      final clock = P2pListingClock.of(won, DateTime.utc(2026, 11, 17));
      expect(clock.kind, P2pClockKind.awaitingSeller);
      expect(clock.until, won.saleStartDeadline);
      expect(P2pListingClock.of(won, DateTime.utc(2026, 11, 19)).kind, P2pClockKind.none);
    });

    test('a closed listing has no clock, whatever its dates say', () {
      for (final state in ['sale_pending', 'sold', 'cancelled', 'expired', 'unfulfilled', 'ended', 'something_new']) {
        final closed = listing('listing_buy_now', {'state': state});
        expect(P2pListingClock.of(closed, DateTime.utc(2026, 11, 20)).kind, P2pClockKind.none, reason: state);
      }
    });
  });

  group('P2pHeadline', () {
    test('a buy-now listing leads with its price', () {
      final headline = P2pHeadline.of(listing('listing_buy_now'))!;
      expect(headline.kind, P2pHeadlineKind.buyNow);
      expect(headline.amount, '5');
    });

    test('an auction leads with its starting bid, then its current bid', () {
      final noBids = P2pHeadline.of(listing('listing_auction', {'high_bid': null}))!;
      expect(noBids.kind, P2pHeadlineKind.startingBid);
      expect(noBids.amount, '2.5');

      final bid = P2pHeadline.of(listing('listing_auction'))!;
      expect(bid.kind, P2pHeadlineKind.currentBid);
      expect(bid.amount, '3.5');
    });

    test('a won listing leads with the winning bid, a sold one with its price', () {
      final won = P2pHeadline.of(listing('listing_sale_pending'))!;
      expect(won.kind, P2pHeadlineKind.winningBid);
      expect(won.amount, '5');

      final sold = P2pHeadline.of(listing('listing_sale_pending', {'state': 'sold', 'sold_price': '4.9'}))!;
      expect(sold.kind, P2pHeadlineKind.soldFor);
      expect(sold.amount, '4.9');
    });

    test('is null with no price at all', () {
      expect(P2pHeadline.of(listing('listing_buy_now', {'buy_now_price': null})), isNull);
    });
  });

  group('who is looking', () {
    final pending = listing('listing_sale_pending');

    test('the seller, the winner and everyone else', () {
      expect(p2pViewerRole(pending, pending.sellerAddress), P2pViewerRole.seller);
      expect(p2pViewerRole(pending, pending.winnerAddress), P2pViewerRole.winner);
      expect(p2pViewerRole(pending, 'xSomeoneElse'), P2pViewerRole.visitor);
      expect(p2pViewerRole(pending, null), P2pViewerRole.visitor);
    });
  });

  group('p2pBuyBlock', () {
    final live = listing('listing_buy_now');
    final open = DateTime.utc(2026, 11, 20);

    test('a visitor with an ordinary account can buy an open listing', () {
      expect(p2pBuyBlock(live, 'xBuyer', open), isNull);
    });

    test('says why not, the listing\'s own reasons first', () {
      expect(p2pBuyBlock(listing('listing_sale_pending'), 'xBuyer', open), P2pBuyBlock.notLive);
      expect(p2pBuyBlock(listing('listing_buy_now', {'state': 'paused'}), 'xBuyer', open), P2pBuyBlock.notLive);
      expect(p2pBuyBlock(live, 'xBuyer', DateTime.utc(2026, 11, 16, 15)), P2pBuyBlock.notOpenYet);
      expect(p2pBuyBlock(live, 'xBuyer', DateTime.utc(2026, 12, 17)), P2pBuyBlock.closing);
      expect(p2pBuyBlock(live, null, open), P2pBuyBlock.noAccount);
      expect(p2pBuyBlock(live, 'xRBXvault', open), P2pBuyBlock.vault);
      expect(p2pBuyBlock(live, live.sellerAddress, open), P2pBuyBlock.ownListing);
    });
  });

  test('a royalty below 1 is the share of the price a sale pays', () {
    expect(p2pRoyaltyPercent(P2pRoyalty(amount: '0.02', payTo: 'xArtist')), '2');
    expect(p2pRoyaltyPercent(P2pRoyalty(amount: '0.075', payTo: 'xArtist')), '7.5');
    expect(p2pRoyaltyPercent(P2pRoyalty(amount: '0.99999999', payTo: 'xArtist')), '99.999999');
  });

  test('a royalty of 1 or more is a flat amount, never a percent', () {
    // 2 is not "200% of the price".
    expect(p2pRoyaltyPercent(P2pRoyalty(amount: '2', payTo: 'xArtist')), isNull);
    expect(p2pRoyaltyPercent(P2pRoyalty(amount: '1', payTo: 'xArtist')), isNull);
    expect(p2pRoyaltyPercent(P2pRoyalty(amount: 'lots', payTo: 'xArtist')), isNull);
  });

  group('p2pListingTimeline', () {
    List<String> shape(P2pListing l) {
      return p2pListingTimeline(l).map((s) => "${s.state.name}:${s.stopped ? 'stopped' : s.current ? 'current' : s.done ? 'done' : 'upcoming'}").toList();
    }

    test('a live listing is at the first of four steps', () {
      expect(shape(listing('listing_buy_now')), ['live:current', 'awaitingSaleStart:upcoming', 'salePending:upcoming', 'sold:upcoming']);
    });

    test('a started sale has passed two steps and dates them', () {
      final pending = listing('listing_sale_pending');
      expect(shape(pending), ['live:done', 'awaitingSaleStart:done', 'salePending:current', 'sold:upcoming']);
      final steps = p2pListingTimeline(pending);
      expect(steps[0].at, pending.startsAt);
      // The win is 48 hours before the deadline.
      expect(steps[1].at, DateTime.utc(2026, 11, 16, 16, 20));
      expect(steps[2].at, pending.sale!.start!.at);
      expect(steps[3].at, isNull);
    });

    test('a side exit shows the steps reached, then the exit as a stopped last step', () {
      expect(shape(listing('listing_buy_now', {'state': 'expired'})), ['live:done', 'expired:stopped']);
      expect(shape(listing('listing_buy_now', {'state': 'cancelled'})), ['live:done', 'cancelled:stopped']);
      expect(shape(listing('listing_sale_pending', {'state': 'unfulfilled'})), ['live:done', 'awaitingSaleStart:done', 'unfulfilled:stopped']);
      expect(shape(listing('listing_sale_pending', {'state': 'ended'})), ['live:done', 'awaitingSaleStart:done', 'salePending:done', 'ended:stopped']);
      expect(shape(listing('listing_buy_now', {'state': 'ended', 'end_reason': 'nft_moved'})), ['live:done', 'ended:stopped']);
    });

    test('a state this build does not know is a stopped step, never a live one', () {
      expect(shape(listing('listing_buy_now', {'state': 'paused'})), ['live:done', 'unknown:stopped']);
    });
  });

  group('p2pBuyingStatus', () {
    const me = 'xBidderAAAAAAAAAAAAAAAAAAAAAAAAAAA';

    P2pBuyingEntry entry(String fixture, [Map<String, dynamic> changes = const {}, String? action]) {
      return P2pBuyingEntry(listing: listing(fixture, changes), action: action);
    }

    test('a started sale for this buyer is to be paid', () {
      expect(p2pBuyingStatus(entry('listing_sale_pending', {}, 'complete_purchase'), me), P2pBuyingStatus.pay);
      // Even if the action is missing, the state and the winner say so.
      expect(p2pBuyingStatus(entry('listing_sale_pending'), me), P2pBuyingStatus.pay);
    });

    test('won, sold, and lost to someone else', () {
      expect(p2pBuyingStatus(entry('listing_sale_pending', {'state': 'awaiting_sale_start'}), me), P2pBuyingStatus.wonWaiting);
      expect(p2pBuyingStatus(entry('listing_sale_pending', {'state': 'sold'}), me), P2pBuyingStatus.purchased);
      expect(p2pBuyingStatus(entry('listing_sale_pending', {'state': 'sold'}), 'xOther'), P2pBuyingStatus.lost);
      expect(p2pBuyingStatus(entry('listing_sale_pending'), 'xOther'), P2pBuyingStatus.lost);
    });

    test('on a live auction: the high bidder, with or without the reserve, or outbid', () {
      const high = 'xBidderBBBBBBBBBBBBBBBBBBBBBBBBBBB';
      expect(p2pBuyingStatus(entry('listing_auction'), high), P2pBuyingStatus.reserveNotMet);
      expect(p2pBuyingStatus(entry('listing_auction', {'reserve_met': true}), high), P2pBuyingStatus.winning);
      expect(p2pBuyingStatus(entry('listing_auction'), me), P2pBuyingStatus.outbid);
    });

    test('a listing that closed without a sale, or in a state unknown here, has ended', () {
      for (final state in ['cancelled', 'expired', 'unfulfilled', 'ended', 'paused']) {
        expect(p2pBuyingStatus(entry('listing_auction', {'state': state}), me), P2pBuyingStatus.closed, reason: state);
      }
    });
  });

  group('a sale started for more than the buyer bid', () {
    test('the buyer\'s own bid is the high bid when it is theirs, else the largest of theirs shown', () {
      final auction = listing('listing_auction');
      expect(p2pOwnBid(auction, 'xBidderBBBBBBBBBBBBBBBBBBBBBBBBBBB')!.toDecimalString(), '3.5');
      expect(p2pOwnBid(auction, 'xBidderAAAAAAAAAAAAAAAAAAAAAAAAAAA')!.toDecimalString(), '2.5');
      expect(p2pOwnBid(auction, 'xNobody'), isNull);
    });

    test('is told from one at or under the bid; an unknown bid does not block', () {
      final five = P2pAmount.parse('5');
      expect(p2pSaleAsksMoreThanBid(P2pAmount.parse('5.00000001'), five), isTrue);
      expect(p2pSaleAsksMoreThanBid(five, five), isFalse);
      expect(p2pSaleAsksMoreThanBid(P2pAmount.parse('4'), five), isFalse);
      expect(p2pSaleAsksMoreThanBid(five, null), isFalse);
    });
  });

  group('a shop address as it is typed', () {
    P2pUrlAvailability answer(String url, {bool available = true, String? reason}) {
      return P2pUrlAvailability(url: url, normalized: url, available: available, reason: reason);
    }

    test('empty and invalid are told before the registry is asked', () {
      expect(p2pShopUrlStatus('', '', null), P2pShopUrlStatus.empty);
      expect(p2pShopUrlStatus('vfx://', '', null), P2pShopUrlStatus.empty);
      expect(p2pShopUrlStatus('9lives', '9lives', null), P2pShopUrlStatus.invalid);
    });

    test('is checking until typing has settled and the answer for it is in', () {
      expect(p2pShopUrlStatus('corner', 'corne', answer('corne')), P2pShopUrlStatus.checking);
      expect(p2pShopUrlStatus('corner', 'corner', null), P2pShopUrlStatus.checking);
      // An answer for an earlier spelling is not this one's.
      expect(p2pShopUrlStatus('corner', 'corner', answer('corne')), P2pShopUrlStatus.checking);
    });

    test('free, taken, or invalid by the registry\'s own rule', () {
      expect(p2pShopUrlStatus('Corner', 'Corner', answer('corner')), P2pShopUrlStatus.free);
      expect(p2pShopUrlStatus('corner', 'corner', answer('corner', available: false, reason: 'taken')), P2pShopUrlStatus.taken);
      expect(p2pShopUrlStatus('corner', 'corner', answer('corner', available: false, reason: 'invalid')), P2pShopUrlStatus.invalid);
    });

    test('the shop\'s own address, when editing, is unchanged and not taken', () {
      expect(p2pShopUrlStatus('vfx://Corner', 'x', null, 'corner'), P2pShopUrlStatus.unchanged);
    });
  });
}
