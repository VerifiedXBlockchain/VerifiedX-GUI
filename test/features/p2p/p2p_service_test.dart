import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/api_token_manager.dart';
import 'package:rbx_wallet/core/services/base_service.dart';
import 'package:rbx_wallet/core/singletons.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_error.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_listing.dart';
import 'package:rbx_wallet/features/p2p/services/p2p_service.dart';

import 'p2p_test_helpers.dart';

void main() {
  late P2pTestServer server;
  late P2pService service;

  setUpAll(() {
    if (!singleton.isRegistered<ApiTokenManager>()) {
      singleton.registerSingleton<ApiTokenManager>(ApiTokenManagerImplementation());
    }
    BaseService.suppressErrors = true;
  });

  setUp(() async {
    server = await P2pTestServer.start();
    service = P2pService(hostOverride: server.host);
  });

  tearDown(() => server.close());

  Future<P2pError> refusal(Future<Object?> Function() call) async {
    try {
      await call();
    } on P2pError catch (e) {
      return e;
    }
    fail('Expected a P2pError');
  }

  group('reads', () {
    test('listShops asks for the page and search it is given, with no token', () async {
      server.always(200, p2pFixture('shops_page'));
      final page = await service.listShops(search: '  dry ', page: 2, limit: 12);

      final request = server.requests.single;
      expect(request.method, 'GET');
      expect(request.path, '/p2p/shops/');
      expect(request.uri.queryParameters, {'search': 'dry', 'page': '2', 'limit': '12'});
      expect(request.authorization, isNull);
      expect(page.results.single.url, 'dryrun-demo');
    });

    test('listShops leaves out what it was not given', () async {
      server.always(200, p2pFixture('shops_page'));
      await service.listShops(search: '');
      expect(server.requests.single.uri.queryParameters, {'page': '1'});
    });

    test('listShops can ask for one owner\'s shops', () async {
      server.always(200, p2pFixture('shops_page'));
      await service.listShops(owner: 'xOwner');
      expect(server.requests.single.uri.queryParameters, {'owner': 'xOwner', 'page': '1'});
    });

    test('getShop reads a shop by its URL', () async {
      server.always(200, p2pFixture('shop_detail'));
      final shop = await service.getShop('dryrun-demo');
      expect(server.requests.single.path, '/p2p/shops/dryrun-demo/');
      expect(shop!.collections, hasLength(1));
    });

    test('getShop is null when no shop has the URL', () async {
      server.always(404, p2pFixture('error_shop_not_found'));
      expect(await service.getShop('nope-nope'), isNull);
    });

    test('urlAvailability sends the URL as typed', () async {
      server.always(200, p2pFixture('url_taken'));
      final answer = await service.urlAvailability('vfx://DryRun-Demo');
      final request = server.requests.single;
      expect(request.path, '/p2p/shops/available/');
      expect(request.uri.queryParameters, {'url': 'vfx://DryRun-Demo'});
      expect(answer.available, isFalse);
    });

    test('listCollections and getCollection use the collection paths', () async {
      server.always(200, {'count': 0, 'next': null, 'results': []});
      await service.listCollections('dryrun-demo');
      expect(server.requests.last.path, '/p2p/shops/dryrun-demo/collections/');

      server.always(200, (p2pFixture('shop_detail')['collections'] as List).first);
      final collection = await service.getCollection(3);
      expect(server.requests.last.path, '/p2p/collections/3/');
      expect(collection!.name, 'Main');
    });

    test('listListings filters by collection and state', () async {
      server.always(200, p2pFixture('listings_page'));
      final page = await service.listListings(
        'dryrun-demo',
        collectionId: 3,
        state: P2pListingState.awaitingSaleStart,
        page: 3,
      );
      final request = server.requests.single;
      expect(request.path, '/p2p/shops/dryrun-demo/listings/');
      expect(request.uri.queryParameters, {'collection': '3', 'state': 'awaiting_sale_start', 'page': '3'});
      expect(page.results.single.id, 1);
    });

    test('getListing reads a listing with its bids, and is null on 404', () async {
      server.always(200, p2pFixture('listing_auction'));
      final listing = await service.getListing(2);
      expect(server.requests.single.path, '/p2p/listings/2/');
      expect(listing!.bids, hasLength(2));

      server.always(404, {
        'error': {'code': 'not_found', 'message': 'Listing not found.', 'fields': {}}
      });
      expect(await service.getListing(999), isNull);
    });

    test('listBids pages through a listing\'s bids', () async {
      server.always(200, {'count': 2, 'next': null, 'results': p2pFixture('listing_auction')['bids']});
      final page = await service.listBids(2, page: 2, limit: 100);
      final request = server.requests.single;
      expect(request.path, '/p2p/listings/2/bids/');
      expect(request.uri.queryParameters, {'page': '2', 'limit': '100'});
      expect(page.results.first.amount, '3.5');
    });
  });

  group('with the sign-in token', () {
    test('me sends it as Authorization: Bearer', () async {
      server.always(200, p2pFixture('me'));
      final me = await service.me('tok-123');
      final request = server.requests.single;
      expect(request.method, 'GET');
      expect(request.path, '/p2p/me/');
      expect(request.authorization, 'Bearer tok-123');
      expect(me.buying, hasLength(2));
    });

    test('placeBid posts the amount as a string, the flag and the signature', () async {
      server.always(201, p2pFixture('bid_result'));
      final result = await service.placeBid(
        token: 'tok-123',
        listingId: 2,
        amount: '4',
        isBuyNow: false,
        signature: 'SIG.KEY',
      );
      final request = server.requests.single;
      expect(request.method, 'POST');
      expect(request.path, '/p2p/listings/2/bids/');
      expect(request.authorization, 'Bearer tok-123');
      expect(request.body, {'amount': '4', 'is_buy_now': false, 'signature': 'SIG.KEY'});
      expect(result.bid.id, 13);
      expect(result.listing.nextMinBid, '4.5');
    });
  });

  group('dry runs and the listed flag', () {
    test('dryRunSaleComplete posts the listing id and the description with the token', () async {
      server.always(200, {...p2pFixture('listing_sale_pending'), 'state': 'sold'});
      final tx = P2pListing.fromJson(p2pFixture('listing_sale_pending')).sale!.start!;
      final listing = await service.dryRunSaleComplete(token: 'tok-9', listingId: 3, tx: tx);

      final request = server.requests.single;
      expect(request.method, 'POST');
      expect(request.path, '/p2p/dry-run/sale-complete/');
      expect(request.authorization, 'Bearer tok-9');
      expect((request.body as Map)['listing_id'], 3);
      expect(((request.body as Map)['tx'] as Map).keys, ['type', 'function', 'from_address', 'to_address', 'amount', 'fee', 'timestamp', 'data']);
      expect(listing.state, P2pListingState.sold);
    });

    test('listedNftIds reads an owner\'s listed NFT ids, with no token', () async {
      server.always(200, {
        'results': ['0b6ea1abd1da425fab80029f8f20944c:1794213169', 'fd6f04f2368b4d06b621e0959dc14b36:1794213174']
      });
      final ids = await service.listedNftIds('xJwSHB75g85bfhPLBFJ7JS1QzkDRhNJksJ');
      final request = server.requests.single;
      expect(request.path, '/nft/listed/xJwSHB75g85bfhPLBFJ7JS1QzkDRhNJksJ/');
      expect(request.authorization, isNull);
      expect(ids, {'0b6ea1abd1da425fab80029f8f20944c:1794213169', 'fd6f04f2368b4d06b621e0959dc14b36:1794213174'});
    });

    test('a listed answer out of shape is a bad response, not an empty set', () async {
      server.always(200, {'detail': 'nope'});
      final error = await refusal(() => service.listedNftIds('xOwner'));
      expect(error.code, P2pError.badResponse);
    });
  });

  group('refusals', () {
    test('a 400 carries the contract\'s code, message and fields', () async {
      server.always(400, p2pFixture('error_bid_too_low'));
      final error = await refusal(
        () => service.placeBid(token: 't', listingId: 2, amount: '1', isBuyNow: false, signature: 's'),
      );
      expect(error.status, 400);
      expect(error.code, 'bid_too_low');
      expect(error.message, 'The bid is below the next minimum bid.');
      expect(error.fields, {'amount': 'At least 4.'});
    });

    test('a 401 is told from other refusals', () async {
      server.always(401, p2pFixture('error_token_expired'));
      final error = await refusal(() => service.me('stale'));
      expect(error.isUnauthorized, isTrue);
      expect(error.code, P2pError.tokenExpired);
    });

    test('a 409 keeps its code', () async {
      server.always(409, p2pFixture('error_listing_not_live'));
      final error = await refusal(
        () => service.placeBid(token: 't', listingId: 2, amount: '5', isBuyNow: true, signature: 's'),
      );
      expect(error.status, 409);
      expect(error.code, 'listing_not_live');
    });

    test('a 404 on a list is a refusal, not an empty list', () async {
      server.always(404, p2pFixture('error_shop_not_found'));
      final error = await refusal(() => service.listListings('nope-nope'));
      expect(error.code, 'shop_not_found');
    });

    test('an error page that is not JSON is worded by its status', () async {
      server.always(502, '<html>Bad gateway</html>');
      final error = await refusal(() => service.listShops());
      expect(error.status, 502);
      expect(error.code, 'server_error');
    });

    test('a body out of shape is a bad response', () async {
      server.always(200, {'detail': 'not a page'});
      final error = await refusal(() => service.listShops());
      expect(error.status, isNull);
      expect(error.code, P2pError.badResponse);
    });

    test('no answer at all is unreachable', () async {
      await server.close();
      final error = await refusal(() => service.listShops());
      expect(error.status, isNull);
      expect(error.code, P2pError.unreachable);
    });
  });
}
