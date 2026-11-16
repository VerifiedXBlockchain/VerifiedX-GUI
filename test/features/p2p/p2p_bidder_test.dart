import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/api_token_manager.dart';
import 'package:rbx_wallet/core/env.dart';
import 'package:rbx_wallet/core/services/base_service.dart';
import 'package:rbx_wallet/core/singletons.dart';
import 'package:rbx_wallet/features/encrypt/providers/password_required_provider.dart';
import 'package:rbx_wallet/features/p2p/chain/p2p_chain_steps.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_error.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_listing.dart';
import 'package:rbx_wallet/features/p2p/providers/p2p_listing_providers.dart';
import 'package:rbx_wallet/features/p2p/services/p2p_bidder.dart';
import 'package:rbx_wallet/features/p2p/services/p2p_service.dart';
import 'package:rbx_wallet/features/p2p/services/p2p_session.dart';
import 'package:rbx_wallet/features/p2p/services/p2p_signer.dart';
import 'package:rbx_wallet/features/p2p/utils/p2p_amount.dart';

import 'p2p_test_helpers.dart';

void main() {
  const bidder = 'xBidderAAAAAAAAAAAAAAAAAAAAAAAAAAA';
  const seller = 'xJwSHB75g85bfhPLBFJ7JS1QzkDRhNJksJ';

  late P2pTestServer server;
  late FakeP2pSigner signer;
  late P2pBidder bids;
  late Map<String, dynamic> listingBody;
  late P2pCannedResponse Function(P2pRecordedRequest request) onBid;
  late int tokens;

  setUpAll(() {
    if (!singleton.isRegistered<ApiTokenManager>()) {
      singleton.registerSingleton<ApiTokenManager>(ApiTokenManagerImplementation());
    }
    BaseService.suppressErrors = true;
  });

  setUp(() async {
    tokens = 0;
    listingBody = p2pFixture('listing_auction');
    onBid = (_) => P2pCannedResponse(201, p2pFixture('bid_result'));
    server = await P2pTestServer.start((request) {
      if (request.method == 'GET' && request.path.startsWith('/p2p/listings/')) {
        return P2pCannedResponse(200, listingBody);
      }
      if (request.method == 'POST' && request.path == '/auth/sign-token/') {
        tokens++;
        return P2pCannedResponse(201, {
          'token': 'token-$tokens',
          'address': (request.body as Map<String, dynamic>)['address'],
          'expires_at': DateTime.now().toUtc().add(const Duration(hours: 1)).toIso8601String(),
        });
      }
      if (request.method == 'POST' && request.path.endsWith('/bids/')) {
        return onBid(request);
      }
      return const P2pCannedResponse(404, {
        'error': {'code': 'not_found', 'message': 'Not found.', 'fields': {}}
      });
    });
    final service = P2pService(hostOverride: server.host);
    signer = FakeP2pSigner('BIDSIG.KEY');
    bids = P2pBidder(service: service, session: P2pSession(service: service, signer: signer), signer: signer);
  });

  tearDown(() => server.close());

  Future<Object> failure(Future<Object?> Function() call) async {
    try {
      await call();
    } on P2pError catch (e) {
      return e;
    } on P2pSigningError catch (e) {
      return e;
    }
    fail('Expected a refusal');
  }

  List<String> requests() => server.requests.map((r) => '${r.method} ${r.path}').toList();

  group('a bid', () {
    test('reads the listing fresh, signs the bid message through the signer and posts it with the token', () async {
      final result = await bids.place(
        listingId: 2,
        address: bidder,
        amount: P2pAmount.parse('4'),
        isBuyNow: false,
        balance: P2pAmount.parse('100'),
      );

      expect(requests(), ['GET /p2p/listings/2/', 'POST /auth/sign-token/', 'POST /p2p/listings/2/bids/']);

      // Two signatures, both plain messages: the sign-in, then the bid over
      // {purchase key}_{amount × 1e8}_{address} with the fresh purchase key.
      expect(signer.signed, hasLength(2));
      expect(signer.signed[0][1], bidder);
      expect(signer.signed[1], ['AbCdEfGhIj1794842900_400000000_$bidder', bidder]);

      final post = server.requests.last;
      expect(post.authorization, 'Bearer token-1');
      expect(post.body, {'amount': '4', 'is_buy_now': false, 'signature': 'BIDSIG.KEY'});

      expect(result.bid.amount, '4');
      expect(result.listing.nextMinBid, '4.5');
    });

    test('signs the units exactly: 0.29 is 29000000, not a double\'s 28999999', () async {
      listingBody = {...listingBody, 'floor_price': '0.1', 'next_min_bid': '0.1', 'high_bid': null};
      await bids.place(listingId: 2, address: bidder, amount: P2pAmount.parse('0.29'), isBuyNow: false);
      expect(signer.signed.last[0], 'AbCdEfGhIj1794842900_29000000_$bidder');
      expect((server.requests.last.body as Map)['amount'], '0.29');
    });

    test('uses the purchase key of the fresh read, not one seen earlier', () async {
      listingBody = {...listingBody, 'purchase_key': 'FreshKeyXY1794849999'};
      await bids.place(listingId: 2, address: bidder, amount: P2pAmount.parse('4'), isBuyNow: false);
      expect(signer.signed.last[0], startsWith('FreshKeyXY1794849999_'));
    });
  });

  group('buy now', () {
    setUp(() {
      listingBody = p2pFixture('listing_buy_now');
    });

    test('offers the buy-now price exactly, flagged as buy now', () async {
      await bids.place(listingId: 1, address: bidder, amount: P2pAmount.parse('5'), isBuyNow: true);
      expect(signer.signed.last[0], 'QLHYeWQCuH1794842796_500000000_$bidder');
      expect(server.requests.last.body, {'amount': '5', 'is_buy_now': true, 'signature': 'BIDSIG.KEY'});
    });

    test('is refused here when the price is no longer the one the buyer saw', () async {
      listingBody = {...listingBody, 'buy_now_price': '6'};
      final error = await failure(() => bids.place(listingId: 1, address: bidder, amount: P2pAmount.parse('5'), isBuyNow: true)) as P2pError;
      expect(error.code, 'amount_mismatch');
      expect(requests(), ['GET /p2p/listings/1/']);
      expect(signer.signed, isEmpty);
    });
  });

  group('refused here, before anything is signed or posted', () {
    Future<String> code({
      Map<String, dynamic> changes = const {},
      String address = bidder,
      String amount = '4',
      bool isBuyNow = false,
      String? balance = '100',
    }) async {
      listingBody = {...listingBody, ...changes};
      final error = await failure(() => bids.place(
            listingId: 2,
            address: address,
            amount: P2pAmount.parse(amount),
            isBuyNow: isBuyNow,
            balance: balance == null ? null : P2pAmount.parse(balance),
          )) as P2pError;
      expect(requests(), ['GET /p2p/listings/2/'], reason: error.code);
      expect(signer.signed, isEmpty, reason: error.code);
      return error.code;
    }

    test('a listing that is no longer live', () async {
      expect(await code(changes: {'state': 'awaiting_sale_start'}), 'listing_not_live');
    });

    test('a listing in a state this build does not know', () async {
      expect(await code(changes: {'state': 'paused'}), 'listing_not_live');
    });

    test('the seller\'s own listing', () async {
      expect(await code(address: seller), 'seller_cannot_bid');
    });

    test('a vault address', () async {
      expect(await code(address: 'xRBXvaultAAAAAAAAAAAAAAAAAAAAAAAAA'), 'reserve_address');
    });

    test('a bid under the next minimum', () async {
      expect(await code(amount: '3.99999999'), 'bid_too_low');
    });

    test('a bid at or above the buy-now price', () async {
      expect(await code(amount: '40'), 'use_buy_now');
      server.requests.clear();
      expect(await code(amount: '41'), 'use_buy_now');
    });

    test('a bid on a listing that takes none', () async {
      expect(await code(changes: {'floor_price': null, 'next_min_bid': null}), 'not_an_auction');
    });

    test('buy now on a listing with no buy-now price', () async {
      expect(await code(changes: {'buy_now_price': null}, isBuyNow: true, amount: '40'), 'no_buy_now');
    });

    test('an amount the account cannot cover', () async {
      expect(await code(balance: '3.5'), 'insufficient_balance');
    });
  });

  test('a balance that is not known is left to the registry', () async {
    await bids.place(listingId: 2, address: bidder, amount: P2pAmount.parse('4'), isBuyNow: false);
    expect(requests().last, 'POST /p2p/listings/2/bids/');
  });

  test('a listing that is gone is not found', () async {
    listingBody = {};
    server.respond = (_) => const P2pCannedResponse(404, {
          'error': {'code': 'not_found', 'message': 'Listing not found.', 'fields': {}}
        });
    final error = await failure(() => bids.place(listingId: 9, address: bidder, amount: P2pAmount.parse('4'), isBuyNow: false)) as P2pError;
    expect(error.code, 'not_found');
    expect(signer.signed, isEmpty);
  });

  test('the registry\'s refusal is passed on with its code', () async {
    onBid = (_) => P2pCannedResponse(400, p2pFixture('error_bid_too_low'));
    final error = await failure(() => bids.place(listingId: 2, address: bidder, amount: P2pAmount.parse('4'), isBuyNow: false)) as P2pError;
    expect(error.status, 400);
    expect(error.code, 'bid_too_low');
  });

  test('an expired token signs in once more and posts the same signed bid again', () async {
    var posts = 0;
    onBid = (_) {
      posts++;
      return posts == 1 ? P2pCannedResponse(401, p2pFixture('error_token_expired')) : P2pCannedResponse(201, p2pFixture('bid_result'));
    };
    final result = await bids.place(listingId: 2, address: bidder, amount: P2pAmount.parse('4'), isBuyNow: false);

    expect(result.bid.id, 13);
    expect(requests(), [
      'GET /p2p/listings/2/',
      'POST /auth/sign-token/',
      'POST /p2p/listings/2/bids/',
      'POST /auth/sign-token/',
      'POST /p2p/listings/2/bids/',
    ]);
    final bidPosts = server.requests.where((r) => r.path.endsWith('/bids/')).toList();
    expect(bidPosts.map((r) => r.authorization), ['Bearer token-1', 'Bearer token-2']);
    expect(bidPosts[0].body, bidPosts[1].body);
    // Two sign-ins and one bid: the bid message is signed once.
    expect(signer.signed.where((s) => s[0].contains('_400000000_')), hasLength(1));
    expect(signer.signed, hasLength(3));
  });

  test('a wallet that stays locked stops the bid before anything is posted', () async {
    signer.error = const P2pSigningError(P2pSigningFailure.walletLocked);
    final error = await failure(() => bids.place(listingId: 2, address: bidder, amount: P2pAmount.parse('4'), isBuyNow: false));
    expect((error as P2pSigningError).failure, P2pSigningFailure.walletLocked);
    expect(requests(), ['GET /p2p/listings/2/']);
  });

  group('checkP2pBid', () {
    final auction = P2pListing.fromJson(p2pFixture('listing_auction'));

    test('lets through a bid from the minimum up to just under the buy-now price', () {
      for (final amount in ['4', '4.00000001', '39.99999999']) {
        expect(checkP2pBid(auction, address: bidder, amount: P2pAmount.parse(amount), isBuyNow: false), isNull, reason: amount);
      }
    });

    test('before any bid the floor price is the minimum', () {
      final fresh = auction.copyWith(highBid: null, nextMinBid: null);
      expect(checkP2pBid(fresh, address: bidder, amount: P2pAmount.parse('2.5'), isBuyNow: false), isNull);
      expect(checkP2pBid(fresh, address: bidder, amount: P2pAmount.parse('2.49'), isBuyNow: false), 'bid_too_low');
    });

    test('a buy-now offer equal to the price in another spelling is the price', () {
      final listing = auction.copyWith(buyNowPrice: '40.0');
      expect(checkP2pBid(listing, address: bidder, amount: P2pAmount.parse('40'), isBuyNow: true), isNull);
    });
  });

  group('no transaction is ever built', () {
    // Constraint of the audit hold: the shop builds, signs and sends no
    // transaction. Nothing under lib/features/p2p may name a Core route that
    // signs, sends or completes one, or that records a bid in Core.
    const forbidden = [
      'SendRawTransaction',
      'VerifyRawTransaction',
      'GetTxHash',
      'SendTransaction',
      'CreateBeaconUploadRequest',
      'CompleteNFTPurchase',
      'SendBid',
      'SendBuyNowBid',
      'SaveDecShop',
      'GetPublishDecShop',
      'CancelSale',
      '/dstapi/',
      'RawService',
      'RawTransaction',
    ];

    Iterable<File> sources() {
      return Directory('lib/features/p2p').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
    }

    test('the P2P feature names none of Core\'s signing, sending or shop routes', () {
      expect(sources(), isNotEmpty);
      for (final file in sources()) {
        final source = file.readAsStringSync();
        for (final name in forbidden) {
          expect(source.contains(name), isFalse, reason: '${file.path} mentions $name');
        }
      }
    });

    test('all that is asked of Core is a message signature and a fee quote', () {
      // Every class that talks to the node, and the one route each uses.
      // (The "List an NFT" picker reads the wallet's NFTs through the app's
      // own NFT service, outside this feature: a read.)
      final nodeServices = <String, String>{};
      for (final file in sources()) {
        final source = file.readAsStringSync();
        if (!source.contains('extends BaseService')) {
          continue;
        }
        if (source.contains('Env.explorerApiBaseUrl')) {
          continue; // Spyglass, not the node.
        }
        final routes = RegExp(r"'/([A-Za-z]+)[/']").allMatches(source).map((m) => m.group(1)!).toSet();
        nodeServices[file.path.split('/').last] = routes.join(',');
      }
      expect(nodeServices, {
        // A plain message: the sign-in and a bid.
        'p2p_signer.dart': 'CreateSignature',
        // A calculation: Core builds nothing it keeps, signs and sends nothing.
        'p2p_fee_quoter.dart': 'GetRawTxFee',
      });
    });

    test('chain steps are dry runs: no build setting turns sending on', () {
      expect(Env.p2pBroadcast, isFalse);
      // The chain steps hold the session, which follows the wallet's lock
      // state. The real lock-state provider asks the node as soon as it is
      // built and writes the answer whenever it comes, which can be after
      // this test has disposed the container: the stub asks nothing.
      final container = ProviderContainer(overrides: [
        passwordRequiredProvider.overrideWith((ref) => StubPasswordRequired()),
      ]);
      addTearDown(container.dispose);
      expect(container.read(p2pChainStepsProvider).isDryRun, isTrue);
      expect(container.read(p2pChainStepsProvider), isA<P2pDryRunChainSteps>());
    });
  });
}
