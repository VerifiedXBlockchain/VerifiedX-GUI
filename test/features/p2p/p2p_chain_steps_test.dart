import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/api_token_manager.dart';
import 'package:rbx_wallet/core/services/base_service.dart';
import 'package:rbx_wallet/core/singletons.dart';
import 'package:rbx_wallet/features/p2p/chain/p2p_chain_error.dart';
import 'package:rbx_wallet/features/p2p/chain/p2p_chain_steps.dart';
import 'package:rbx_wallet/features/p2p/chain/p2p_fee_quoter.dart';
import 'package:rbx_wallet/features/p2p/chain/p2p_tx_builders.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_error.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_listing.dart';
import 'package:rbx_wallet/features/p2p/services/p2p_service.dart';
import 'package:rbx_wallet/features/p2p/services/p2p_session.dart';
import 'package:rbx_wallet/features/p2p/utils/p2p_amount.dart';

import 'p2p_test_helpers.dart';

/// Stands in for the local node's TXV1 API.
class NodeAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  final List<dynamic> bodies = [];
  int status = 200;
  String body = '{"Result":"Success","Message":"TX Fee Calculated","Fee":0.000042}';
  bool refuseConnection = false;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    bodies.add(options.data);
    if (refuseConnection) {
      throw DioException.connectionError(requestOptions: options, reason: 'Connection refused');
    }
    return ResponseBody.fromString(body, status, headers: {
      Headers.contentTypeHeader: ['text/plain; charset=utf-8'],
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  const buyer = 'xBidderAAAAAAAAAAAAAAAAAAAAAAAAAAA';

  setUpAll(() {
    // No widget binding here: it would answer the loopback registry's
    // requests itself.
    if (!singleton.isRegistered<ApiTokenManager>()) {
      singleton.registerSingleton<ApiTokenManager>(ApiTokenManagerImplementation());
    }
    BaseService.suppressErrors = true;
  });

  group('P2pCoreFeeQuoter', () {
    late NodeAdapter node;

    setUp(() {
      node = NodeAdapter();
      BaseService.httpClientAdapterOverride = node;
    });

    tearDown(() => BaseService.httpClientAdapterOverride = null);

    Future<P2pAmount> quote() {
      return P2pCoreFeeQuoter().quote(
        from: buyer,
        to: 'xSeller',
        amount: P2pAmount.parse('4.9'),
        type: 5,
        data: {'Function': 'Sale_Complete()', 'ContractUID': 'abc:1'},
        timestamp: 1794848400,
      );
    }

    test('asks Core\'s GetRawTxFee for a transaction with these fields, and reads the fee', () async {
      final fee = await quote();
      expect(fee.toDecimalString(), '0.000042');

      final request = node.requests.single;
      expect(request.method, 'POST');
      expect(request.uri.path, '/txapi/TXV1/GetRawTxFee/');
      final sent = node.bodies.single is String ? jsonDecode(node.bodies.single as String) : node.bodies.single;
      expect(sent, {
        'Timestamp': 1794848400,
        'FromAddress': buyer,
        'ToAddress': 'xSeller',
        'Amount': 4.9,
        'Fee': 0,
        'Nonce': 0,
        'TransactionType': 5,
        'Data': {'Function': 'Sale_Complete()', 'ContractUID': 'abc:1'},
      });
    });

    test('a quote Core could not make is no fee, not a zero fee', () async {
      node.body = '{"Result":"Fail","Message":"Failed to calcuate Fee."}';
      await expectLater(quote(), throwsA(isA<P2pChainError>().having((e) => e.failure, 'failure', P2pChainFailure.feeUnavailable)));

      node.body = '{"Result":"Success","Fee":0}';
      await expectLater(quote(), throwsA(isA<P2pChainError>()));
    });

    test('a node that does not answer is no fee', () async {
      node.refuseConnection = true;
      await expectLater(quote(), throwsA(isA<P2pChainError>().having((e) => e.failure, 'failure', P2pChainFailure.feeUnavailable)));
    });
  });

  group('P2pDryRunChainSteps', () {
    late P2pTestServer server;
    late FakeP2pSigner signer;
    late FakeP2pFeeQuoter fees;
    late P2pChainSteps steps;
    late P2pCannedResponse Function(P2pRecordedRequest request) onDryRun;
    final now = DateTime.utc(2026, 11, 16, 17);

    P2pListing pending() => P2pListing.fromJson(p2pFixture('listing_sale_pending'));

    setUp(() async {
      onDryRun = (_) => P2pCannedResponse(200, {...p2pFixture('listing_sale_pending'), 'state': 'sold', 'sold_price': '5'});
      var tokens = 0;
      server = await P2pTestServer.start((request) {
        if (request.path == '/auth/sign-token/') {
          tokens++;
          return P2pCannedResponse(201, {
            'token': 'token-$tokens',
            'address': (request.body as Map<String, dynamic>)['address'],
            'expires_at': DateTime.now().toUtc().add(const Duration(hours: 1)).toIso8601String(),
          });
        }
        return onDryRun(request);
      });
      final service = P2pService(hostOverride: server.host);
      signer = FakeP2pSigner();
      fees = FakeP2pFeeQuoter('0.00002');
      steps = P2pDryRunChainSteps(
        service: service,
        session: P2pSession(service: service, signer: signer),
        fees: fees,
        walletUrl: 'https://wallet-testnet.verifiedx.io',
        apiUrl: 'https://data-testnet.verifiedx.io/api/p2p/',
        now: () => now,
      );
    });

    tearDown(() => server.close());

    test('is a dry run', () {
      expect(steps.isDryRun, isTrue);
    });

    test('describing a purchase asks the registry nothing and signs nothing', () async {
      final tx = await steps.describeCompletePurchase(pending());
      expect(tx.function, 'Sale_Complete()');
      expect(tx.timestamp, now.millisecondsSinceEpoch ~/ 1000);
      expect(server.requests, isEmpty);
      expect(signer.signed, isEmpty);
    });

    test('a listing with no price to pay cannot be described', () async {
      final live = P2pListing.fromJson(p2pFixture('listing_auction_live'));
      expect(
        () => steps.describeCompletePurchase(live),
        throwsA(isA<P2pChainError>().having((e) => e.failure, 'failure', P2pChainFailure.noWinner)),
      );
    });

    test('completing posts the description as the buyer and returns the listing as the registry has it', () async {
      final listing = pending();
      final tx = await steps.describeCompletePurchase(listing);
      final sold = await steps.completePurchase(listing, tx);

      expect(sold.state, P2pListingState.sold);
      expect(sold.soldPrice, '5');

      final post = server.requests.last;
      expect(post.method, 'POST');
      expect(post.path, '/p2p/dry-run/sale-complete/');
      expect(post.authorization, 'Bearer token-1');
      final body = post.body as Map<String, dynamic>;
      expect(body['listing_id'], 3);
      expect(body['tx'], tx.toDryRunJson());

      // The only signature is the buyer's sign-in message: the description
      // itself is not signed.
      expect(signer.signed, hasLength(1));
      expect(signer.signed.single[1], buyer);
      expect(signer.signed.single[0], isNot(contains('Sale_Complete')));
    });

    test('starting a sale reads the winning bid from the seller\'s own list, then posts the Sale_Start as the seller', () async {
      const seller = 'xJwSHB75g85bfhPLBFJ7JS1QzkDRhNJksJ';
      final me = p2pFixture('me');
      final won = P2pListing.fromJson((me['selling'] as List).first as Map<String, dynamic>);
      onDryRun = (request) {
        if (request.path == '/p2p/me/') {
          return P2pCannedResponse(200, me);
        }
        return P2pCannedResponse(200, p2pFixture('listing_sale_pending'));
      };

      final tx = await steps.describeStartSale(won);
      // The description was built from GET /p2p/me/, read with the seller's token.
      final read = server.requests.last;
      expect([read.method, read.path, read.authorization], ['GET', '/p2p/me/', 'Bearer token-1']);
      expect(signer.signed.single[1], seller);
      expect(tx.function, 'Sale_Start()');
      expect([tx.fromAddress, tx.toAddress], [seller, buyer]);
      expect(tx.data['SoldFor'], 5);
      expect(tx.data['BidSignature'], ((me['selling'] as List).first as Map)['winning_bid']['signature']);

      final started = await steps.startSale(won, tx);
      expect(started.state, P2pListingState.salePending);
      final post = server.requests.last;
      expect([post.method, post.path, post.authorization], ['POST', '/p2p/dry-run/sale-start/', 'Bearer token-1']);
      expect((post.body as Map<String, dynamic>)['listing_id'], 4);
      expect((post.body as Map<String, dynamic>)['tx'], tx.toDryRunJson());
      // Still the one signature: the seller's sign-in message.
      expect(signer.signed, hasLength(1));
    });

    test('a sale cannot be started when the seller\'s list has no winning bid for it', () async {
      onDryRun = (_) => P2pCannedResponse(200, {'shop': null, 'selling': [], 'buying': []});
      final live = P2pListing.fromJson(p2pFixture('listing_buy_now'));
      await expectLater(
        steps.describeStartSale(live),
        throwsA(isA<P2pChainError>().having((e) => e.failure, 'failure', P2pChainFailure.noWinningBid)),
      );
    });

    test('cancelling a started sale posts the Sale_Cancel as the seller', () async {
      onDryRun = (_) => P2pCannedResponse(200, {...p2pFixture('listing_sale_pending'), 'state': 'cancelled'});
      final listing = pending();
      final tx = await steps.describeSaleCancellation(listing);
      expect(server.requests, isEmpty);
      expect([tx.function, tx.toAddress], ['Sale_Cancel()', buyer]);

      final cancelled = await steps.cancelSale(listing, tx);
      expect(cancelled.state, P2pListingState.cancelled);
      final post = server.requests.last;
      expect([post.method, post.path], ['POST', '/p2p/dry-run/sale-cancel/']);
      expect((post.body as Map<String, dynamic>)['listing_id'], 3);
      expect(signer.signed.single[1], listing.sellerAddress);
    });

    test('a shop step is described without asking the registry, then posted as its sender', () async {
      onDryRun = (_) => P2pCannedResponse(200, p2pFixture('shops_page')['results'][0] as Map<String, dynamic>);
      const values = P2pShopValues(name: 'Corner Shop', url: 'corner-shop', description: '');
      final tx = await steps.describeRegisterShop(buyer, values);
      expect(tx.function, 'DecShopCreate()');
      expect((tx.data['DecShop'] as Map)['ThirdPartyAPIURL'], 'https://data-testnet.verifiedx.io/api/p2p/');
      expect(server.requests, isEmpty);

      final shop = await steps.sendShopStep(tx);
      expect(shop.url, 'dryrun-demo');
      final post = server.requests.last;
      expect(post.path, '/p2p/dry-run/dstr/');
      expect(post.authorization, 'Bearer token-1');
      expect((post.body as Map<String, dynamic>).keys, ['tx']);
      expect((post.body as Map<String, dynamic>)['tx'], tx.toDryRunJson());
      // Only the sign-in was signed, as the shop's owner.
      expect(signer.signed.single[1], buyer);
    });

    test('a taken address is refused by the registry with its code', () async {
      onDryRun = (_) => const P2pCannedResponse(409, {
            'error': {
              'code': 'url_taken',
              'message': 'vfx://corner-shop is taken.',
              'fields': {'DecShopURL': 'Taken.'}
            }
          });
      final tx = await steps.describeRegisterShop(buyer, const P2pShopValues(name: 'Corner Shop', url: 'corner-shop', description: ''));
      await expectLater(steps.sendShopStep(tx), throwsA(isA<P2pError>().having((e) => e.code, 'code', 'url_taken')));
    });

    test('the registry\'s refusal is passed on with its code', () async {
      onDryRun = (_) => const P2pCannedResponse(403, {
            'error': {'code': 'not_buyer', 'message': 'Only the buyer the sale was started for completes it.', 'fields': {}}
          });
      final listing = pending();
      final tx = await steps.describeCompletePurchase(listing);
      await expectLater(
        steps.completePurchase(listing, tx),
        throwsA(isA<P2pError>().having((e) => e.code, 'code', 'not_buyer')),
      );
    });

    test('an invalid description comes back with the fields the registry named', () async {
      onDryRun = (_) => const P2pCannedResponse(400, {
            'error': {
              'code': 'invalid_transaction',
              'message': 'The payments do not cover the price.',
              'fields': {'data.Transactions': 'At least 5 in all.'}
            }
          });
      final listing = pending();
      final tx = await steps.describeCompletePurchase(listing);
      try {
        await steps.completePurchase(listing, tx);
        fail('Expected a refusal');
      } on P2pError catch (e) {
        expect(e.code, 'invalid_transaction');
        expect(e.fields, {'data.Transactions': 'At least 5 in all.'});
      }
    });
  });
}
