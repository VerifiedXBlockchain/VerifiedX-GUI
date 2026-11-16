import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/app.dart';
import 'package:rbx_wallet/core/api_token_manager.dart';
import 'package:rbx_wallet/core/singletons.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_bid_summary.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_error.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_listing.dart';
import 'package:rbx_wallet/features/p2p/screens/p2p_listing_screen.dart';
import 'package:rbx_wallet/features/p2p/services/p2p_signer.dart';

import 'p2p_test_helpers.dart';

void main() {
  const viewer = 'xViewerAAAAAAAAAAAAAAAAAAAAAAAAAAA';
  const seller = 'xJwSHB75g85bfhPLBFJ7JS1QzkDRhNJksJ';
  // Inside the fixture listings' dates: they end on 2026-12-16.
  final now = DateTime.utc(2026, 11, 16, 16);

  late FakeP2pService service;
  late FakeP2pSigner signer;

  P2pListing auction() => P2pListing.fromJson(p2pFixture('listing_auction_live'));
  P2pListing buyNow() => P2pListing.fromJson(p2pFixture('listing_buy_now'));
  P2pListing pending() => P2pListing.fromJson(p2pFixture('listing_sale_pending'));

  setUpAll(() {
    if (!singleton.isRegistered<ApiTokenManager>()) {
      singleton.registerSingleton<ApiTokenManager>(ApiTokenManagerImplementation());
    }
  });

  setUp(() {
    signer = FakeP2pSigner('BIDSIG.KEY');
    service = FakeP2pService()..listingsById = {2: auction(), 1: buyNow(), 3: pending()};
  });

  Future<void> pump(WidgetTester tester, int id, {String? address = viewer, double balance = 100}) async {
    tester.binding.window.physicalSizeTestValue = const Size(1400, 1600);
    tester.binding.window.devicePixelRatioTestValue = 1;
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    await tester.pumpWidget(p2pTestApp(
      child: P2pListingScreen(id: id),
      service: service,
      signer: signer,
      address: address,
      balance: balance,
      now: now,
    ));
    await tester.pump();
    await tester.pump();
  }

  /// Lets the bid's futures (read, sign-in, sign, post) run to their end.
  Future<void> settleBid(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump();
    }
  }

  String noteText(WidgetTester tester) => tester.widget<Text>(find.byKey(const Key('p2p:action_note'))).data!;

  group('an auction', () {
    testWidgets('shows the media, prices, state, clock, bids and details', (tester) async {
      await pump(tester, 2);

      expect(find.byKey(const Key('p2p:listing_media')), findsOneWidget);
      expect(tester.widget<Text>(find.byKey(const Key('p2p:listing_title'))).data, 'E2E Good URL 08:32:52');
      expect(find.text('By Web wallet e2e'), findsOneWidget);
      expect(find.text('Media on the bucket'), findsOneWidget);
      expect(find.byKey(const Key('p2p:state:live')), findsOneWidget);
      expect(find.text('Auction'), findsOneWidget);
      expect(find.byKey(const Key('p2p:dry_run_banner')), findsOneWidget);

      final panel = find.byKey(const Key('p2p:price_panel'));
      expect(find.descendant(of: panel, matching: find.text('Current bid')), findsOneWidget);
      expect(find.descendant(of: find.byKey(const Key('p2p:headline_price')), matching: find.text('2 VFX')), findsOneWidget);
      expect(find.descendant(of: panel, matching: find.text('1 bid')), findsOneWidget);
      expect(find.text('Reserve not met'), findsOneWidget);
      expect(find.descendant(of: find.byKey(const Key('p2p:next_min_bid')), matching: find.text('2.5 VFX')), findsOneWidget);
      expect(find.descendant(of: find.byKey(const Key('p2p:buy_now_price')), matching: find.text('25 VFX')), findsOneWidget);
      expect(find.text('Ends in 29d 23h'), findsOneWidget);

      expect(find.byKey(const Key('p2p:bid_open')), findsOneWidget);
      expect(find.text('Buy now · 25 VFX'), findsOneWidget);

      // The bid history: who, how they stand, how much.
      final bid = find.byKey(const Key('p2p:bid:1'));
      expect(find.descendant(of: bid, matching: find.text('xJDgwg…vox7g')), findsOneWidget);
      expect(find.descendant(of: bid, matching: find.text('Highest')), findsOneWidget);
      expect(find.descendant(of: bid, matching: find.text('2 VFX')), findsOneWidget);

      final details = find.byKey(const Key('p2p:details'));
      expect(find.descendant(of: details, matching: find.text('vfx://dryrun-demo')), findsOneWidget);
      expect(find.descendant(of: details, matching: find.text('xJwSHB…NJksJ')), findsOneWidget);
      expect(find.descendant(of: details, matching: find.text('None')), findsOneWidget);
      expect(find.descendant(of: details, matching: find.text('fd6f04f2…94213174')), findsOneWidget);

      // Live is the current step of four.
      final timeline = find.byKey(const Key('p2p:timeline'));
      for (final step in ['Live', 'Winner chosen', 'Sale started', 'Sold']) {
        expect(find.descendant(of: timeline, matching: find.text(step)), findsOneWidget, reason: step);
      }
    });

    testWidgets('tells the high bidder where they stand', (tester) async {
      await pump(tester, 2, address: 'xJDgwgQoKv1PbPQMTsT3uJgCtnEV5vox7g');
      expect(tester.widget<Text>(find.byKey(const Key('p2p:leading_note'))).data, 'Your bid is the highest, but the reserve is not met yet.');
      expect(find.descendant(of: find.byKey(const Key('p2p:bid:1')), matching: find.text('You')), findsOneWidget);
    });

    testWidgets('loads every bid when the listing has more than it shows', (tester) async {
      final listing = auction();
      service.listingsById[2] = listing.copyWith(bidCount: 3);
      service.allBids = [
        listing.bids!.single.copyWith(id: 30, amount: '3', status: P2pBidStatus.accepted),
        listing.bids!.single.copyWith(id: 20, amount: '2.5', status: P2pBidStatus.outbid),
        listing.bids!.single.copyWith(status: P2pBidStatus.outbid),
      ];
      await pump(tester, 2);
      expect(find.text('Showing the newest 1 of 3 bids.'), findsOneWidget);

      await tester.tap(find.byKey(const Key('p2p:all_bids')));
      await tester.pump();
      await tester.pump();
      expect(service.calls, contains('listBids(2, page: 1)'));
      expect(find.byKey(const Key('p2p:bid:30')), findsOneWidget);
      expect(find.byKey(const Key('p2p:bid:20')), findsOneWidget);
      expect(find.byKey(const Key('p2p:all_bids')), findsNothing);
    });
  });

  testWidgets('a flat royalty is shown as the contract states it, not as a percent', (tester) async {
    final json = p2pFixture('listing_buy_now');
    ((json['nft'] as Map<String, dynamic>)['royalty'] as Map<String, dynamic>)['amount'] = '2';
    service.listingsById[1] = P2pListing.fromJson(json);
    await pump(tester, 1);
    final royalty = tester.widget<Text>(find.byKey(const Key('p2p:royalty'))).data!;
    expect(royalty, '2 (flat amount set by the NFT’s contract)');
    expect(royalty, isNot(contains('%')));
  });

  group('a fixed-price listing', () {
    testWidgets('leads with its buy-now price and offers only Buy now', (tester) async {
      await pump(tester, 1);
      expect(find.text('Fixed price'), findsOneWidget);
      expect(find.descendant(of: find.byKey(const Key('p2p:headline_price')), matching: find.text('5 VFX')), findsOneWidget);
      expect(find.byKey(const Key('p2p:bid_open')), findsNothing);
      expect(find.byKey(const Key('p2p:buy_open')), findsOneWidget);
      expect(find.byKey(const Key('p2p:next_min_bid')), findsNothing);
      expect(find.byKey(const Key('p2p:reserve')), findsNothing);
      expect(find.text('No offers yet.'), findsOneWidget);
      expect(tester.widget<Text>(find.byKey(const Key('p2p:royalty'))).data, '2% of the price');
    });
  });

  group('who cannot bid or buy is told why', () {
    testWidgets('the seller', (tester) async {
      await pump(tester, 2, address: seller);
      expect(find.text('Your listing'), findsOneWidget);
      expect(noteText(tester), 'This is your listing. You cannot bid on it.');
      expect(find.byKey(const Key('p2p:bid_open')), findsNothing);
      expect(find.byKey(const Key('p2p:buy_open')), findsNothing);
    });

    testWidgets('no account selected', (tester) async {
      await pump(tester, 2, address: null);
      expect(noteText(tester), 'Choose a VFX account to bid or buy.');
      expect(find.byKey(const Key('p2p:bid_open')), findsNothing);
    });

    testWidgets('a Vault account', (tester) async {
      await pump(tester, 2, address: 'xRBXvaultAAAAAAAAAAAAAAAAAAAAAAAAA');
      expect(noteText(tester), 'A Vault account cannot bid or buy. Choose another account.');
    });

    testWidgets('a listing past its end, which the registry has not settled yet', (tester) async {
      service.listingsById[2] = auction().copyWith(endsAt: now.subtract(const Duration(minutes: 1)));
      await pump(tester, 2);
      expect(noteText(tester), 'Bidding has closed. The result will show in a moment.');
      expect(find.text('Closing…'), findsOneWidget);
    });

    testWidgets('a listing that has not opened', (tester) async {
      service.listingsById[2] = auction().copyWith(startsAt: now.add(const Duration(hours: 2)));
      await pump(tester, 2);
      expect(noteText(tester), 'Bidding has not opened yet.');
      expect(find.text('Opens in 2h 0m'), findsOneWidget);
    });

    testWidgets('a listing someone else won', (tester) async {
      await pump(tester, 3);
      expect(find.byKey(const Key('p2p:state:salePending')), findsOneWidget);
      expect(noteText(tester), 'A winner has been chosen. This listing no longer takes bids.');
      expect(find.byKey(const Key('p2p:buy_open')), findsNothing);
      // The sale's start is on the timeline, dated.
      expect(find.descendant(of: find.byKey(const Key('p2p:timeline')), matching: find.text('Sale started')), findsOneWidget);
    });

    testWidgets('a listing in a state this build does not know is closed', (tester) async {
      service.listingsById[2] = auction().copyWith(state: P2pListingState.unknown);
      await pump(tester, 2);
      expect(find.byKey(const Key('p2p:state:unknown')), findsOneWidget);
      expect(noteText(tester), 'This listing is over.');
      expect(find.byKey(const Key('p2p:bid_open')), findsNothing);
      expect(find.byKey(const Key('p2p:buy_open')), findsNothing);
      expect(find.byKey(const Key('p2p:clock')), findsNothing);
    });

    testWidgets('a sold listing shows its price and why nothing else can be done', (tester) async {
      service.listingsById[3] = pending().copyWith(state: P2pListingState.sold, soldPrice: '5');
      await pump(tester, 3);
      expect(noteText(tester), 'Sold for 5 VFX.');
      expect(find.text('Buyer'), findsOneWidget);
    });

    testWidgets('a listing that closed without a sale says why', (tester) async {
      service.listingsById[2] = auction().copyWith(state: P2pListingState.ended, endReason: 'nft_moved');
      await pump(tester, 2);
      expect(tester.widget<Text>(find.byKey(const Key('p2p:end_reason'))).data, 'The NFT was moved');
    });
  });

  group('the winner', () {
    const winner = 'xBidderAAAAAAAAAAAAAAAAAAAAAAAAAAA';

    testWidgets('waits for the seller to start the sale', (tester) async {
      service.listingsById[3] = pending().copyWith(state: P2pListingState.awaitingSaleStart, sale: null);
      await pump(tester, 3, address: winner);
      expect(find.text('You won'), findsOneWidget);
      expect(noteText(tester), startsWith('You won this at 5 VFX.'));
    });

    testWidgets('is told the purchase cannot be completed from this wallet yet', (tester) async {
      await pump(tester, 3, address: winner);
      expect(noteText(tester), 'The seller has started the sale. Completing the purchase from this wallet is not available yet.');
    });
  });

  testWidgets('a listing that does not exist says so', (tester) async {
    await pump(tester, 404);
    expect(find.text('This listing was not found.'), findsOneWidget);
  });

  testWidgets('a failed load is worded and can be retried', (tester) async {
    service.error = const P2pError(status: 500, code: 'server_error', message: 'Server error');
    await pump(tester, 2);
    expect(find.text('The shop registry had a problem. Try again in a moment.'), findsOneWidget);
    service.error = null;
    await tester.tap(find.byKey(const Key('p2p:retry')));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('p2p:price_panel')), findsOneWidget);
  });

  group('placing a bid', () {
    P2pBidResult accepted(String amount, {P2pBidStatus status = P2pBidStatus.accepted}) {
      final listing = auction();
      final bid = P2pBidSummary(id: 77, address: viewer, amount: amount, status: status, at: now);
      return P2pBidResult(
        bid: bid,
        listing: listing.copyWith(
          highBid: P2pHighBid(amount: amount, address: viewer, at: now),
          bidCount: 2,
          nextMinBid: '3.5',
          bids: [bid, listing.bids!.single.copyWith(status: P2pBidStatus.outbid)],
        ),
      );
    }

    testWidgets('says it is a signed message, checks what is typed, signs through Core and shows the result', (tester) async {
      service.onBid = (_, amount, __, ___) => accepted(amount);
      await pump(tester, 2);

      await tester.tap(find.byKey(const Key('p2p:bid_open')));
      await tester.pump();
      expect(find.text('Place a bid'), findsOneWidget);
      // The field opens at the least the bid can be.
      expect(tester.widget<TextField>(find.byKey(const Key('p2p:bid_amount'))).controller!.text, '2.5');
      expect(find.text('At least 2.5 VFX'), findsOneWidget);
      expect(tester.widget<Text>(find.byKey(const Key('p2p:bid_sign_note'))).data, contains('It is a signed message, not a transaction'));

      // Too low: refused in the field, nothing signed or sent.
      await tester.enterText(find.byKey(const Key('p2p:bid_amount')), '1');
      await tester.tap(find.byKey(const Key('p2p:bid_submit')));
      await settleBid(tester);
      expect(find.text('Bid at least 2.5 VFX.'), findsOneWidget);
      expect(signer.signed, isEmpty);
      expect(service.calls.where((c) => c.startsWith('placeBid')), isEmpty);

      await tester.enterText(find.byKey(const Key('p2p:bid_amount')), '3');
      await tester.tap(find.byKey(const Key('p2p:bid_submit')));
      await settleBid(tester);

      // Core signed the sign-in message and then the bid message, exactly.
      expect(signer.signed.last, ['KamFWBujBu1794843228_300000000_$viewer', viewer]);
      expect(service.calls, contains('placeBid(2, 3, buyNow: false, token: token-for-$viewer)'));

      expect(find.byKey(const Key('p2p:bid_placed')), findsOneWidget);
      expect(find.text('Bid placed'), findsOneWidget);
      expect(find.text('Your 3 VFX bid is the highest, but the reserve is not met yet.'), findsOneWidget);

      await tester.tap(find.byKey(const Key('p2p:bid_done')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // The page shows the listing as the registry answered it.
      expect(find.descendant(of: find.byKey(const Key('p2p:headline_price')), matching: find.text('3 VFX')), findsOneWidget);
      expect(find.byKey(const Key('p2p:bid:77')), findsOneWidget);
      expect(find.byKey(const Key('p2p:leading_note')), findsOneWidget);
    });

    testWidgets('a page showing every bid reads them again after a bid', (tester) async {
      final listing = auction();
      final older = listing.bids!.single;
      service.listingsById[2] = listing.copyWith(bidCount: 2);
      service.allBids = [older, older.copyWith(id: 20, amount: '1.5', status: P2pBidStatus.outbid)];
      service.onBid = (_, amount, __, ___) {
        final placed = accepted(amount);
        // The registry has the new bid from here on.
        service.allBids = [placed.bid, older.copyWith(status: P2pBidStatus.outbid), service.allBids.last];
        return P2pBidResult(bid: placed.bid, listing: placed.listing.copyWith(bidCount: 3, bids: [placed.bid]));
      };
      await pump(tester, 2);
      await tester.tap(find.byKey(const Key('p2p:all_bids')));
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const Key('p2p:bid:20')), findsOneWidget);
      expect(find.byKey(const Key('p2p:bid:77')), findsNothing);
      final readsBefore = service.calls.where((c) => c.startsWith('listBids')).length;

      await tester.tap(find.byKey(const Key('p2p:bid_open')));
      await tester.pump();
      await tester.enterText(find.byKey(const Key('p2p:bid_amount')), '3');
      await tester.tap(find.byKey(const Key('p2p:bid_submit')));
      await settleBid(tester);
      await tester.tap(find.byKey(const Key('p2p:bid_done')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(service.calls.where((c) => c.startsWith('listBids')).length, readsBefore + 1);
      expect(find.byKey(const Key('p2p:bid:77')), findsOneWidget);
      expect(find.byKey(const Key('p2p:bid:20')), findsOneWidget);
    });

    testWidgets('a bid that meets the reserve says the bidder is winning', (tester) async {
      service.onBid = (_, amount, __, ___) => accepted(amount, status: P2pBidStatus.winning);
      await pump(tester, 2);
      await tester.tap(find.byKey(const Key('p2p:bid_open')));
      await tester.pump();
      await tester.enterText(find.byKey(const Key('p2p:bid_amount')), '4');
      await tester.tap(find.byKey(const Key('p2p:bid_submit')));
      await settleBid(tester);
      expect(find.text('You are the high bidder at 4 VFX.'), findsOneWidget);
    });

    testWidgets('what is typed is checked before anything is signed', (tester) async {
      await pump(tester, 2, balance: 10);
      await tester.tap(find.byKey(const Key('p2p:bid_open')));
      await tester.pump();

      Future<void> submit(String typed) async {
        await tester.enterText(find.byKey(const Key('p2p:bid_amount')), typed);
        await tester.tap(find.byKey(const Key('p2p:bid_submit')));
        await settleBid(tester);
      }

      await submit('');
      expect(find.text('Enter your bid.'), findsOneWidget);
      await submit('abc');
      expect(find.text('Enter an amount, like 12.5.'), findsOneWidget);
      await submit('3.123456789');
      expect(find.text('Use at most 8 decimal places.'), findsOneWidget);
      await submit('25');
      expect(find.text('At 25 VFX or more, use Buy now.'), findsOneWidget);
      await submit('12');
      expect(find.text('This account’s balance does not cover that.'), findsOneWidget);

      expect(signer.signed, isEmpty);
      expect(service.calls.where((c) => c.startsWith('placeBid')), isEmpty);
    });

    testWidgets('the registry\'s refusal is shown in words and the listing is read again', (tester) async {
      service.bidError = const P2pError(status: 400, code: 'bid_too_low', message: 'The bid is below the next minimum bid.');
      await pump(tester, 2);
      await tester.tap(find.byKey(const Key('p2p:bid_open')));
      await tester.pump();
      await tester.enterText(find.byKey(const Key('p2p:bid_amount')), '3');
      final readsBefore = service.calls.where((c) => c == 'getListing(2)').length;
      await tester.tap(find.byKey(const Key('p2p:bid_submit')));
      await settleBid(tester);

      expect(tester.widget<Text>(find.byKey(const Key('p2p:bid_error'))).data,
          'Your bid is below the next minimum bid. Someone may have bid just before you.');
      expect(find.byKey(const Key('p2p:bid_placed')), findsNothing);
      // Once fresh for the bid, once more after the refusal.
      expect(service.calls.where((c) => c == 'getListing(2)').length, readsBefore + 2);
    });

    for (final refusal in const {
      'use_buy_now': 'At the buy-now price or more, use Buy now.',
      'insufficient_balance': 'This account’s balance does not cover the amount.',
      'listing_not_live': 'This listing is not taking bids any more.',
      'bad_signature': 'The shop registry could not verify this account’s signature. Try again.',
      'listing_ended': 'This listing has ended.',
      'duplicate_bid': 'This bid was already placed.',
    }.entries) {
      testWidgets('the registry\'s ${refusal.key} is shown in words', (tester) async {
        service.bidError = P2pError(status: 400, code: refusal.key, message: 'Server words.');
        await pump(tester, 2);
        await tester.tap(find.byKey(const Key('p2p:bid_open')));
        await tester.pump();
        await tester.enterText(find.byKey(const Key('p2p:bid_amount')), '3');
        await tester.tap(find.byKey(const Key('p2p:bid_submit')));
        await settleBid(tester);
        expect(tester.widget<Text>(find.byKey(const Key('p2p:bid_error'))).data, refusal.value);
      });
    }

    testWidgets('a wallet that stays locked is said so, and nothing is posted', (tester) async {
      signer.error = const P2pSigningError(P2pSigningFailure.walletLocked);
      await pump(tester, 2);
      await tester.tap(find.byKey(const Key('p2p:bid_open')));
      await tester.pump();
      await tester.enterText(find.byKey(const Key('p2p:bid_amount')), '3');
      await tester.tap(find.byKey(const Key('p2p:bid_submit')));
      await settleBid(tester);
      expect(tester.widget<Text>(find.byKey(const Key('p2p:bid_error'))).data, 'Your wallet is locked. Unlock it with your password and try again.');
      expect(service.calls.where((c) => c.startsWith('placeBid')), isEmpty);
    });

    testWidgets('Cancel closes the dialog with nothing signed', (tester) async {
      await pump(tester, 2);
      await tester.tap(find.byKey(const Key('p2p:bid_open')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('p2p:bid_cancel')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Place a bid'), findsNothing);
      expect(signer.signed, isEmpty);
    });
  });

  group('buying now', () {
    testWidgets('offers the buy-now price exactly as a signed message', (tester) async {
      service.onBid = (_, amount, __, ___) {
        final bid = P2pBidSummary(id: 88, address: viewer, amount: amount, isBuyNow: true, status: P2pBidStatus.won, at: now);
        return P2pBidResult(
          bid: bid,
          listing: buyNow().copyWith(
            state: P2pListingState.awaitingSaleStart,
            winnerAddress: viewer,
            highBid: P2pHighBid(amount: amount, address: viewer, at: now),
            bidCount: 1,
            saleStartDeadline: now.add(const Duration(hours: 48)),
            bids: [bid],
          ),
        );
      };
      await pump(tester, 1);

      await tester.tap(find.byKey(const Key('p2p:buy_open')));
      await tester.pump();
      expect(find.byKey(const Key('p2p:bid_amount')), findsNothing);
      expect(tester.widget<Text>(find.byKey(const Key('p2p:bid_sign_note'))).data, contains('you pay when you complete the purchase'));

      await tester.tap(find.byKey(const Key('p2p:bid_submit')));
      await settleBid(tester);

      expect(signer.signed.last, ['QLHYeWQCuH1794842796_500000000_$viewer', viewer]);
      expect(service.calls, contains('placeBid(1, 5, buyNow: true, token: token-for-$viewer)'));
      expect(find.text('It’s yours to complete'), findsOneWidget);

      await tester.tap(find.byKey(const Key('p2p:bid_done')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // The listing moved on at once: a winner is chosen, and it is this account.
      expect(find.byKey(const Key('p2p:state:awaitingSaleStart')), findsOneWidget);
      expect(find.text('You won'), findsOneWidget);
      expect(noteText(tester), startsWith('You won this at 5 VFX.'));
      expect(find.text('Sale starts within 2d 0h'), findsOneWidget);
      expect(find.byKey(const Key('p2p:buy_open')), findsNothing);
    });

    testWidgets('an account that cannot cover the price cannot sign', (tester) async {
      await pump(tester, 1, balance: 1);
      await tester.tap(find.byKey(const Key('p2p:buy_open')));
      await tester.pump();
      expect(find.text('This account’s balance does not cover that.'), findsOneWidget);
      await tester.tap(find.byKey(const Key('p2p:bid_submit')));
      await settleBid(tester);
      expect(signer.signed, isEmpty);
      expect(service.calls.where((c) => c.startsWith('placeBid')), isEmpty);
    });

    testWidgets('a price that changed is refused before anything is signed', (tester) async {
      await pump(tester, 1);
      await tester.tap(find.byKey(const Key('p2p:buy_open')));
      await tester.pump();
      // The seller changed the price after the page was read.
      service.listingsById[1] = buyNow().copyWith(buyNowPrice: '9');
      await tester.tap(find.byKey(const Key('p2p:bid_submit')));
      await settleBid(tester);
      expect(tester.widget<Text>(find.byKey(const Key('p2p:bid_error'))).data, 'The price changed. Check the listing and try again.');
      expect(signer.signed, isEmpty);
    });
  });

  testWidgets('a listing page under another page does not keep reading, and reads again when it is back in view', (tester) async {
    // No picture: a covered page's image load is not what this is about.
    service.listingsById[2] = auction().copyWith(nft: auction().nft!.copyWith(thumbnailUrl: null));
    await pump(tester, 2);
    int reads() => service.calls.where((c) => c == 'getListing(2)').length;

    rootNavigatorKey.currentState!.push(MaterialPageRoute<void>(builder: (_) => const Scaffold(body: Text('Another page'))));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Another page'), findsOneWidget);
    final covered = reads();

    await tester.pump(const Duration(seconds: 46));
    await tester.pump();
    expect(reads(), covered, reason: 'a covered page polled');

    rootNavigatorKey.currentState!.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(reads(), covered + 1, reason: 'the page did not read when it came back into view');

    await tester.pump(const Duration(seconds: 16));
    await tester.pump();
    expect(reads(), greaterThan(covered + 1));
  });

  testWidgets('an open listing page reads its listing again every 15 seconds', (tester) async {
    await pump(tester, 2);
    final before = service.calls.where((c) => c == 'getListing(2)').length;
    await tester.pump(const Duration(seconds: 16));
    await tester.pump();
    expect(service.calls.where((c) => c == 'getListing(2)').length, before + 1);
  });
}
