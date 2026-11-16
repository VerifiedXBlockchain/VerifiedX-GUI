import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_bid_summary.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_error.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_listing.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_me.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_page.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_shop.dart';

import 'p2p_test_helpers.dart';

void main() {
  group('P2pShop', () {
    test('reads a page of shops as the testnet API sends it', () {
      final page = P2pPage.fromJson(p2pFixture('shops_page'), P2pShop.fromJson);
      expect(page.count, 1);
      expect(page.next, isNull);
      expect(page.hasNext, isFalse);

      final shop = page.results.single;
      expect(shop.id, 2);
      expect(shop.uniqueId, 'XrfHqDCQVJ1794842795');
      expect(shop.url, 'dryrun-demo');
      expect(shop.displayUrl, 'vfx://dryrun-demo');
      expect(shop.name, 'Dry Run Demo');
      expect(shop.ownerAddress, 'xJwSHB75g85bfhPLBFJ7JS1QzkDRhNJksJ');
      expect(shop.chainState, P2pShopChainState.dryRun);
      expect(shop.isDryRun, isTrue);
      expect(shop.registeredAt, DateTime.utc(2026, 11, 16, 15, 26, 35));
      expect(shop.collectionCount, 1);
      expect(shop.liveListingCount, 1);
      // A list row carries no collections.
      expect(shop.collections, isNull);
    });

    test('reads a shop page with its collections', () {
      final shop = P2pShop.fromJson(p2pFixture('shop_detail'));
      final main = shop.collections!.single;
      expect(main.id, 3);
      expect(main.shopUrl, 'dryrun-demo');
      expect(main.name, 'Main');
      expect(main.isLive, isTrue);
      expect(main.isDefault, isTrue);
      expect(main.listingCount, 1);
      expect(shop.liveCollections, [main]);
    });

    test('knows its owner', () {
      final shop = P2pShop.fromJson(p2pFixture('shop_detail'));
      expect(shop.isOwnedBy('xJwSHB75g85bfhPLBFJ7JS1QzkDRhNJksJ'), isTrue);
      expect(shop.isOwnedBy('xSomeoneElse'), isFalse);
      expect(shop.isOwnedBy(null), isFalse);
    });

    test('reads a chain state it does not know as unknown', () {
      final json = p2pFixture('shop_detail')..['chain_state'] = 'frozen';
      expect(P2pShop.fromJson(json).chainState, P2pShopChainState.unknown);
    });

    test('reads a URL availability answer', () {
      final taken = P2pUrlAvailability.fromJson(p2pFixture('url_taken'));
      expect(taken.normalized, 'dryrun-demo');
      expect(taken.available, isFalse);
      expect(taken.reason, 'taken');
    });
  });

  group('P2pListing', () {
    test('reads a buy-now listing as the testnet API sends it', () {
      final listing = P2pListing.fromJson(p2pFixture('listing_buy_now'));
      expect(listing.id, 1);
      expect(listing.shopUrl, 'dryrun-demo');
      expect(listing.collectionId, 3);
      expect(listing.state, P2pListingState.live);
      expect(listing.isLive, isTrue);
      expect(listing.smartContractUid, '0b6ea1abd1da425fab80029f8f20944c:1794213169');
      expect(listing.nft!.name, 'E2E Bulk Mint B 08:32');
      expect(listing.nft!.minterName, 'Web wallet e2e');
      expect(listing.nft!.thumbnailUrl, startsWith('https://rbx-nft-web-assets-testnet.s3.amazonaws.com/'));
      expect(listing.nft!.royalty!.amount, '0.02');
      expect(listing.nft!.royalty!.payTo, 'xJwSHB75g85bfhPLBFJ7JS1QzkDRhNJksJ');
      expect(listing.sellerAddress, 'xJwSHB75g85bfhPLBFJ7JS1QzkDRhNJksJ');
      // Amounts stay the strings the API sent.
      expect(listing.buyNowPrice, '5');
      expect(listing.floorPrice, isNull);
      expect(listing.reservePrice, isNull);
      expect(listing.isAuction, isFalse);
      expect(listing.hasBuyNow, isTrue);
      expect(listing.reserveMet, isTrue);
      expect(listing.startsAt, DateTime.utc(2026, 11, 16, 15, 26, 35));
      expect(listing.endsAt, DateTime.utc(2026, 12, 16, 15, 26, 35));
      expect(listing.purchaseKey, 'QLHYeWQCuH1794842796');
      expect(listing.highBid, isNull);
      expect(listing.bidCount, 0);
      expect(listing.nextMinBid, isNull);
      expect(listing.winnerAddress, isNull);
      expect(listing.chainState, P2pListingChainState.dryRun);
      expect(listing.isDryRun, isTrue);
      expect(listing.sale!.start, isNull);
      expect(listing.sale!.complete, isNull);
      expect(listing.royaltyEnforced, isTrue);
      expect(listing.endReason, isNull);
      expect(listing.bids, isEmpty);
    });

    test('a list row has no bids', () {
      final page = P2pPage.fromJson(p2pFixture('listings_page'), P2pListing.fromJson);
      expect(page.results.single.id, 1);
      expect(page.results.single.bids, isNull);
    });

    test('reads an auction with its high bid, minimum and bid history', () {
      final listing = P2pListing.fromJson(p2pFixture('listing_auction'));
      expect(listing.isAuction, isTrue);
      expect(listing.floorPrice, '2.5');
      expect(listing.reservePrice, '10');
      expect(listing.reserveMet, isFalse);
      expect(listing.buyNowPrice, '40');
      expect(listing.nextMinBid, '4');
      expect(listing.bidCount, 2);
      expect(listing.highBid!.amount, '3.5');
      expect(listing.highBid!.address, 'xBidderBBBBBBBBBBBBBBBBBBBBBBBBBBB');
      expect(listing.highBid!.at, DateTime.utc(2026, 11, 16, 16, 5, 10));
      expect(listing.nft!.royalty, isNull);

      final bids = listing.bids!;
      expect(bids, hasLength(2));
      expect(bids.first.id, 12);
      expect(bids.first.status, P2pBidStatus.accepted);
      expect(bids.first.isBuyNow, isFalse);
      expect(bids.last.status, P2pBidStatus.outbid);
      expect(bids.last.amount, '2.5');
    });

    test('reads a started sale: the step is described and its bid signature withheld', () {
      final listing = P2pListing.fromJson(p2pFixture('listing_sale_pending'));
      expect(listing.state, P2pListingState.salePending);
      expect(listing.winnerAddress, 'xBidderAAAAAAAAAAAAAAAAAAAAAAAAAAA');
      expect(listing.saleStartDeadline, DateTime.utc(2026, 11, 18, 16, 20));
      final start = listing.sale!.start!;
      expect(start.type, 5);
      expect(start.function, 'Sale_Start()');
      expect(start.fromAddress, listing.sellerAddress);
      expect(start.toAddress, listing.winnerAddress);
      expect(start.amount, '0');
      expect(start.fee, '0.000042');
      expect(start.timestamp, 1794846300);
      expect(start.at, DateTime.fromMillisecondsSinceEpoch(1794846300000, isUtc: true));
      expect(start.data['SoldFor'], '5');
      expect(start.data['BidSignature'], isNull);
      expect(start.hash, isNull);
      expect(listing.sale!.complete, isNull);
      expect(listing.bids!.single.status, P2pBidStatus.won);
      expect(listing.bids!.single.isBuyNow, isTrue);
    });

    test('every state the contract names is read', () {
      const states = {
        'live': P2pListingState.live,
        'awaiting_sale_start': P2pListingState.awaitingSaleStart,
        'sale_pending': P2pListingState.salePending,
        'sold': P2pListingState.sold,
        'cancelled': P2pListingState.cancelled,
        'expired': P2pListingState.expired,
        'unfulfilled': P2pListingState.unfulfilled,
        'ended': P2pListingState.ended,
      };
      states.forEach((wire, state) {
        final json = p2pFixture('listing_buy_now')..['state'] = wire;
        expect(P2pListing.fromJson(json).state, state, reason: wire);
        expect(state.wire, wire);
      });
    });

    test('an unknown or missing state reads as closed, never as live', () {
      final unknown = P2pListing.fromJson(p2pFixture('listing_buy_now')..['state'] = 'paused');
      expect(unknown.state, P2pListingState.unknown);
      expect(unknown.isLive, isFalse);

      final missing = P2pListing.fromJson(p2pFixture('listing_buy_now')..remove('state'));
      expect(missing.state, P2pListingState.unknown);
      expect(missing.isLive, isFalse);
    });

    test('a listing with no NFT record is titled by its contract id', () {
      final listing = P2pListing.fromJson(p2pFixture('listing_buy_now')..['nft'] = null);
      expect(listing.nft, isNull);
      expect(listing.title, listing.smartContractUid);
      expect(P2pListing.fromJson(p2pFixture('listing_buy_now')).title, 'E2E Bulk Mint B 08:32');
    });

    test('an indexed sale step carries its hash and height', () {
      final json = p2pFixture('listing_sale_pending');
      final start = (json['sale'] as Map<String, dynamic>)['start'] as Map<String, dynamic>;
      start['hash'] = 'abc123';
      start['height'] = 8123;
      final listing = P2pListing.fromJson(json..['chain_state'] = 'live');
      expect(listing.chainState, P2pListingChainState.live);
      expect(listing.isDryRun, isFalse);
      expect(listing.sale!.start!.hash, 'abc123');
      expect(listing.sale!.start!.height, 8123);
    });

    test('reads the answer to a placed bid', () {
      final result = P2pBidResult.fromJson(p2pFixture('bid_result'));
      expect(result.bid.id, 13);
      expect(result.bid.amount, '4');
      expect(result.bid.status, P2pBidStatus.accepted);
      expect(result.listing.nextMinBid, '4.5');
      expect(result.listing.highBid!.address, result.bid.address);
      expect(result.listing.bids, hasLength(3));
    });

    test('a bid status it does not know reads as unknown', () {
      final json = p2pFixture('bid_result')['bid'] as Map<String, dynamic>;
      expect(P2pBidSummary.fromJson(json..['status'] = 'pending').status, P2pBidStatus.unknown);
    });
  });

  group('P2pMe', () {
    test('reads the shop, the listings sold and the listings bid on', () {
      final me = P2pMe.fromJson(p2pFixture('me'));
      expect(me.shop!.url, 'dryrun-demo');

      expect(me.selling, hasLength(2));
      final toStart = me.selling.first;
      expect(toStart.listing.id, 4);
      expect(toStart.listing.state, P2pListingState.awaitingSaleStart);
      expect(toStart.action, 'start_sale');
      expect(toStart.canStartSale, isTrue);
      expect(toStart.winningBid!.amount, '5');
      expect(toStart.winningBid!.address, 'xBidderAAAAAAAAAAAAAAAAAAAAAAAAAAA');
      expect(toStart.winningBid!.signature, isNotEmpty);
      final live = me.selling.last;
      expect(live.canStartSale, isFalse);
      expect(live.winningBid, isNull);

      expect(me.buying, hasLength(2));
      final toPay = me.buying.first;
      expect(toPay.listing.state, P2pListingState.salePending);
      expect(toPay.canCompletePurchase, isTrue);
      expect(toPay.myHighBid!.amount, '5');
      expect(toPay.myHighBid!.status, P2pBidStatus.won);
      final outbid = me.buying.last;
      expect(outbid.canCompletePurchase, isFalse);
      expect(outbid.myHighBid!.status, P2pBidStatus.outbid);
    });

    test('an address with no shop and no activity reads as empty', () {
      final me = P2pMe.fromJson({'shop': null, 'selling': [], 'buying': []});
      expect(me.shop, isNull);
      expect(me.selling, isEmpty);
      expect(me.buying, isEmpty);
    });

    test('a winning bid never prints its signature', () {
      final winning = P2pMe.fromJson(p2pFixture('me')).selling.first.winningBid!;
      expect(winning.toString(), isNot(contains(winning.signature)));
    });
  });

  group('P2pPage', () {
    test('carries the next page number', () {
      final page = P2pPage.fromJson({'count': 61, 'next': 2, 'results': []}, P2pShop.fromJson);
      expect(page.count, 61);
      expect(page.next, 2);
      expect(page.hasNext, isTrue);
      expect(page.results, isEmpty);
    });

    test('refuses a body that is not a list page', () {
      expect(() => P2pPage.fromJson({'detail': 'nope'}, P2pShop.fromJson), throwsFormatException);
    });
  });

  group('P2pError', () {
    test('reads the code, the message and the fields of a refusal', () {
      final error = P2pError.fromResponse(400, p2pFixture('error_bid_too_low'));
      expect(error.status, 400);
      expect(error.code, 'bid_too_low');
      expect(error.message, 'The bid is below the next minimum bid.');
      expect(error.fields, {'amount': 'At least 4.'});
    });

    test('reads the testnet API\'s own 404 and 401', () {
      final notFound = P2pError.fromResponse(404, p2pFixture('error_shop_not_found'));
      expect(notFound.code, 'shop_not_found');
      expect(notFound.isNotFound, isTrue);
      expect(notFound.fields, isEmpty);

      final unauthorized = P2pError.fromResponse(401, p2pFixture('error_not_authenticated'));
      expect(unauthorized.code, P2pError.notAuthenticated);
      expect(unauthorized.isUnauthorized, isTrue);
    });

    test('reads a field whose message is a list', () {
      final error = P2pError.fromResponse(400, {
        'error': {
          'code': 'invalid',
          'message': 'Some fields are not valid.',
          'fields': {
            'amount': ['Too many places.', 'Too large.'],
            'data.DecShop.Name': 'At most 64 characters.',
            'empty': [],
          },
        },
      });
      expect(error.fields, {'amount': 'Too many places. Too large.', 'data.DecShop.Name': 'At most 64 characters.'});
    });

    test('falls back to a code for the status when the body carries none', () {
      expect(P2pError.fromResponse(401, null).code, 'not_authenticated');
      expect(P2pError.fromResponse(403, {}).code, 'forbidden');
      expect(P2pError.fromResponse(404, '<html>').code, 'not_found');
      expect(P2pError.fromResponse(409, {'error': {}}).code, 'conflict');
      expect(P2pError.fromResponse(429, null).code, 'throttled');
      expect(P2pError.fromResponse(400, null).code, 'invalid');
      expect(P2pError.fromResponse(502, null).code, 'server_error');
      expect(P2pError.fromResponse(null, null).code, P2pError.unreachable);
    });
  });
}
