import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/api_token_manager.dart';
import 'package:rbx_wallet/core/models/paginated_response.dart';
import 'package:rbx_wallet/core/services/base_service.dart';
import 'package:rbx_wallet/core/singletons.dart';
import 'package:rbx_wallet/features/nft/models/nft.dart';
import 'package:rbx_wallet/features/nft/services/nft_service.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_error.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_listing.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_me.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_owned_nft.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_page.dart';
import 'package:rbx_wallet/features/p2p/services/p2p_nft_source.dart';
import 'package:rbx_wallet/features/p2p/services/p2p_seller.dart';
import 'package:rbx_wallet/features/p2p/services/p2p_service.dart';
import 'package:rbx_wallet/features/p2p/services/p2p_session.dart';
import 'package:rbx_wallet/features/p2p/utils/p2p_view.dart';

import 'p2p_test_helpers.dart';

/// Core's NFT routes from memory: the list, a page at a time, says nothing
/// of who owns an NFT; the single read does.
class _FakeNftService extends NftService {
  final List<List<Nft>> pages;
  final Map<String, String> owners;
  final List<String> calls = [];

  _FakeNftService(this.pages, this.owners);

  @override
  Future<CliPaginatedResponse<Nft>> list(int page, {String search = "", bool forTokens = false}) async {
    calls.add('list($page)');
    final results = page <= pages.length ? pages[page - 1] : <Nft>[];
    return CliPaginatedResponse(page: page, count: pages.fold<int>(0, (sum, p) => sum + p.length), results: results);
  }

  @override
  Future<Nft?> retrieve(String id) async {
    calls.add('retrieve($id)');
    final owner = owners[id];
    if (owner == null) {
      return null;
    }
    return pages.expand((p) => p).firstWhere((n) => n.id == id).copyWith(currentOwner: owner);
  }
}

void main() {
  const owner = 'xJwSHB75g85bfhPLBFJ7JS1QzkDRhNJksJ';
  final now = DateTime.utc(2026, 11, 16, 17);

  P2pListing listing(String fixture, [Map<String, dynamic> changes = const {}]) {
    return P2pListing.fromJson({...p2pFixture(fixture), ...changes});
  }

  group('a new listing\'s prices and dates', () {
    P2pListingFormCheck check({
      String buyNow = '',
      bool auction = false,
      String floor = '',
      String reserve = '',
      DateTime? startsAt,
      DateTime? endsAt,
    }) {
      return P2pListingFormCheck.of(
        buyNow: buyNow,
        auction: auction,
        floor: floor,
        reserve: reserve,
        startsAt: startsAt,
        endsAt: endsAt ?? now.add(const Duration(days: 7)),
        now: now,
      );
    }

    test('a fixed price is a buy-now price alone', () {
      final fixed = check(buyNow: ' 12.50 ');
      expect(fixed.ok, isTrue);
      expect(fixed.buyNowPrice, '12.5');
      expect(fixed.floorPrice, isNull);
      expect(fixed.reservePrice, isNull);
    });

    test('with no price at all there is nothing to post', () {
      final none = check();
      expect(none.ok, isFalse);
      expect(none.noPrice, isTrue);
    });

    test('an auction needs a starting bid; reserve and buy-now are optional', () {
      expect(check(auction: true).errors['floor'], P2pListingFieldError.required);
      final plain = check(auction: true, floor: '2');
      expect(plain.ok, isTrue);
      expect([plain.floorPrice, plain.reservePrice, plain.buyNowPrice], ['2', null, null]);
      final full = check(auction: true, floor: '2', reserve: '4', buyNow: '25');
      expect(full.ok, isTrue);
      expect([full.floorPrice, full.reservePrice, full.buyNowPrice], ['2', '4', '25']);
    });

    test('a fixed-price listing ignores what was typed for an auction', () {
      final fixed = check(buyNow: '5', floor: 'abc', reserve: '1');
      expect(fixed.ok, isTrue);
      expect(fixed.floorPrice, isNull);
      expect(fixed.reservePrice, isNull);
    });

    test('starting bid ≤ reserve ≤ buy-now, as the registry checks', () {
      expect(check(auction: true, floor: '5', reserve: '4').errors['reserve'], P2pListingFieldError.belowFloor);
      expect(check(auction: true, floor: '2', reserve: '10', buyNow: '9').errors['buyNow'], P2pListingFieldError.belowReserve);
      expect(check(auction: true, floor: '5', buyNow: '4').errors['buyNow'], P2pListingFieldError.belowStart);
      // Equal is allowed at each step.
      expect(check(auction: true, floor: '5', reserve: '5', buyNow: '5').ok, isTrue);
    });

    test('an amount that is not one, or has more than 8 places, is said so', () {
      expect(check(buyNow: 'ten').errors['buyNow'], P2pListingFieldError.format);
      expect(check(buyNow: '0').errors['buyNow'], P2pListingFieldError.format);
      expect(check(buyNow: '1.123456789').errors['buyNow'], P2pListingFieldError.decimals);
      expect(check(buyNow: 'ten').noPrice, isFalse);
    });

    test('it closes after it opens, and in the future', () {
      expect(check(buyNow: '5', endsAt: now).errors['endsAt'], P2pListingFieldError.beforeStart);
      final opens = now.add(const Duration(days: 2));
      expect(check(buyNow: '5', startsAt: opens, endsAt: opens.subtract(const Duration(hours: 1))).errors['endsAt'], P2pListingFieldError.beforeStart);
      expect(check(buyNow: '5', startsAt: opens, endsAt: opens.add(const Duration(hours: 1))).ok, isTrue);
      // A listing already open, changed to close at a time now past.
      final opened = now.subtract(const Duration(days: 3));
      expect(check(buyNow: '5', startsAt: opened, endsAt: now.subtract(const Duration(hours: 1))).errors['endsAt'], P2pListingFieldError.past);
    });

    test('goes to the registry with UTC times to the second, and prices left out as null', () {
      final input = P2pListingInput(
        smartContractUid: 'abc:1',
        buyNowPrice: '5',
        startsAt: DateTime.utc(2026, 11, 16, 17, 0, 0, 250),
        endsAt: DateTime.utc(2026, 11, 23, 17),
      );
      expect(input.toJson(), {
        'smart_contract_uid': 'abc:1',
        'buy_now_price': '5',
        'floor_price': null,
        'reserve_price': null,
        'starts_at': '2026-11-16T17:00:00Z',
        'ends_at': '2026-11-23T17:00:00Z',
      });
      // A change cannot move the listing to another NFT.
      expect(input.toJson(forUpdate: true).containsKey('smart_contract_uid'), isFalse);
    });
  });

  group('a date and time picker', () {
    test('opens on this computer\'s clock for a listing\'s UTC time, at the same moment', () {
      final closes = DateTime.utc(2026, 12, 16, 15, 26, 35);
      final start = p2pPickerStart(closes, now);
      // Read as local numbers, so the time picked is not moved by the zone.
      expect(start.isUtc, isFalse);
      expect(start.isAtSameMomentAs(closes), isTrue);
      expect([start.hour, start.minute], [closes.toLocal().hour, closes.toLocal().minute]);
    });

    test('does not open before today', () {
      final start = p2pPickerStart(now.subtract(const Duration(days: 3)), now);
      final localNow = now.toLocal();
      expect(start, DateTime(localNow.year, localNow.month, localNow.day));
    });
  });

  group('a list in pages', () {
    P2pPage<int> page(List<int> items, int? next) => P2pPage(count: 5, next: next, results: items);

    test('is read to its last page', () async {
      final asked = <int>[];
      final all = await p2pReadAllPages((n) async {
        asked.add(n);
        return n == 1 ? page([1, 2], 2) : (n == 2 ? page([3, 4], 3) : page([5], null));
      });
      expect(all, [1, 2, 3, 4, 5]);
      expect(asked, [1, 2, 3]);
    });

    test('stops at its bound even if the registry always names a next page', () async {
      var reads = 0;
      final all = await p2pReadAllPages((n) async {
        reads++;
        return page([n], n + 1);
      }, maxPages: 4);
      expect(reads, 4);
      expect(all, [1, 2, 3, 4]);
    });
  });

  group('what a seller can do with a listing', () {
    P2pSellerActions actions(String fixture, [Map<String, dynamic> changes = const {}]) => P2pSellerActions.of(listing(fixture, changes));

    test('live with no bids: change it or withdraw it', () {
      final live = actions('listing_buy_now');
      expect([live.editListing, live.cancelListing, live.startSale, live.cancelSale, live.listAgain], [true, true, false, false, false]);
    });

    test('live with a bid: prices and dates are fixed, withdrawing is not', () {
      final bid = actions('listing_auction_live');
      expect([bid.editListing, bid.cancelListing], [false, true]);
    });

    test('with a winner: start the sale, or still withdraw', () {
      final won = actions('listing_buy_now', {'state': 'awaiting_sale_start'});
      expect([won.startSale, won.cancelListing, won.editListing], [true, true, false]);
    });

    test('a started sale can only be cancelled on chain', () {
      final pending = actions('listing_sale_pending');
      expect([pending.cancelSale, pending.cancelListing, pending.startSale], [true, false, false]);
    });

    test('a sale never started can be listed again; other ends offer nothing', () {
      expect(actions('listing_buy_now', {'state': 'unfulfilled'}).listAgain, isTrue);
      for (final state in ['sold', 'cancelled', 'expired', 'ended', 'something_new']) {
        expect(actions('listing_buy_now', {'state': state}).any, isFalse, reason: state);
      }
    });
  });

  test('a seller\'s listings are grouped by what they need, a sale to start first', () {
    P2pSellingListing selling(int id, String state) => P2pSellingListing(listing: listing('listing_buy_now', {'id': id, 'state': state}));
    final groups = p2pGroupSelling([
      selling(1, 'sold'),
      selling(2, 'live'),
      selling(3, 'cancelled'),
      selling(4, 'awaiting_sale_start'),
      selling(5, 'sale_pending'),
      selling(6, 'unfulfilled'),
      selling(7, 'live'),
    ]);
    expect(groups.keys.toList(), [
      P2pSellingGroup.needsYou,
      P2pSellingGroup.live,
      P2pSellingGroup.waitingForBuyer,
      P2pSellingGroup.sold,
      P2pSellingGroup.closed,
    ]);
    expect(groups[P2pSellingGroup.live]!.map((s) => s.listing.id), [2, 7]);
    expect(groups[P2pSellingGroup.closed]!.map((s) => s.listing.id), [3, 6]);
    expect(p2pGroupSelling(const []), isEmpty);
  });

  group('which of the wallet\'s NFTs an account can list', () {
    const nft = P2pOwnedNft(id: 'abc:1', name: 'Harbor', owner: owner);

    test('its own minted NFT that is not listed', () {
      expect(p2pNftBlock(nft, address: owner, listed: const {}), isNull);
    });

    test('not another account\'s, a token or vault, an unminted one, or one already listed', () {
      expect(p2pNftBlock(nft, address: 'xOther', listed: const {}), P2pNftBlock.notYours);
      expect(p2pNftBlock(const P2pOwnedNft(id: 'abc:1', name: 'T', owner: owner, isSellable: false), address: owner, listed: const {}), P2pNftBlock.unsellable);
      expect(p2pNftBlock(const P2pOwnedNft(id: 'abc:1', name: 'T', owner: owner, isMinted: false), address: owner, listed: const {}), P2pNftBlock.notMinted);
      expect(p2pNftBlock(nft, address: owner, listed: const {'abc:1'}), P2pNftBlock.listed);
    });
  });

  group('an NFT as Core sends it', () {
    Map<String, dynamic> core({List<Map<String, dynamic>> features = const [], bool published = true, String file = 'harbor.png'}) {
      return {
        'Name': 'Harbor at Dusk',
        'Description': 'A harbor',
        'CurrentOwner': owner,
        'MinterAddress': owner,
        'MinterName': 'Tester',
        'SmartContractUID': 'abc:1',
        'SmartContractAsset': {'AssetId': 'a1', 'Name': file, 'Location': '/tmp/assets/$file', 'Extension': 'png', 'FileSize': 10},
        'IsPublic': true,
        'IsPublished': published,
        'IsMinter': true,
        'Features': features,
      };
    }

    test('is read for the picker: owner, minted, sellable, its picture', () {
      final nft = p2pOwnedNftOf(Nft.fromJson(core()));
      expect([nft.id, nft.name, nft.owner], ['abc:1', 'Harbor at Dusk', owner]);
      expect([nft.isMinted, nft.isSellable], [true, true]);
      expect(nft.royalty, isNull);
      expect(nft.imagePath, '/tmp/assets/harbor.png');
    });

    test('carries its royalty, whether Core writes the amount as 0.05 or as a whole number', () {
      final fraction = p2pOwnedNftOf(Nft.fromJson(core(features: [
        {
          'FeatureName': 1,
          'FeatureFeatures': {'RoyaltyType': 1, 'RoyaltyAmount': 0.05, 'RoyaltyPayToAddress': 'xRoyalty'},
        },
      ])));
      expect([fraction.royalty!.amount, fraction.royalty!.payTo], ['0.05', 'xRoyalty']);

      final whole = p2pOwnedNftOf(Nft.fromJson(core(features: [
        {
          'FeatureName': 1,
          'FeatureFeatures': {'RoyaltyType': 0, 'RoyaltyAmount': 3, 'RoyaltyPayToAddress': 'xRoyalty'},
        },
      ])));
      expect(whole.royalty!.amount, '3');
    });

    test('the wallet\'s NFTs are read a page at a time, then each for its owner', () async {
      if (!singleton.isRegistered<ApiTokenManager>()) {
        singleton.registerSingleton<ApiTokenManager>(ApiTokenManagerImplementation());
      }
      // As Core's list sends them: no CurrentOwner.
      Nft listed(String id) => Nft.fromJson({...core(), 'SmartContractUID': id}..remove('CurrentOwner'));
      final core2 = _FakeNftService(
        [
          [listed('a:1'), listed('b:2')],
          [listed('c:3')],
        ],
        {'a:1': owner, 'b:2': 'xOther'},
      );
      final nfts = await P2pWalletNftSource(nfts: core2).walletNfts();
      expect(core2.calls.where((c) => c.startsWith('list')), ['list(1)', 'list(2)']);
      expect(nfts.map((n) => "${n.id} ${n.owner}"), ['a:1 $owner', 'b:2 xOther', 'c:3 ']);
      // One whose owner could not be read is nobody's here: it is not offered.
      expect(p2pNftBlock(nfts.last, address: owner, listed: const {}), P2pNftBlock.notYours);
    });

    test('a token or a vBTC vault is not sellable; an unminted one says so; a video has no picture', () {
      for (final feature in [3, 13]) {
        final nft = p2pOwnedNftOf(Nft.fromJson(core(features: [
          {'FeatureName': feature, 'FeatureFeatures': <String, dynamic>{}},
        ])));
        expect(nft.isSellable, isFalse, reason: 'feature $feature');
      }
      expect(p2pOwnedNftOf(Nft.fromJson(core(published: false))).isMinted, isFalse);
      expect(p2pOwnedNftOf(Nft.fromJson(core(file: 'clip.mp4'))).imagePath, isNull);
    });
  });

  group('against the registry', () {
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

    final collection = {'id': 7, 'shop_url': 'dryrun-demo', 'name': 'Prints', 'description': 'On paper', 'is_live': true, 'is_default': false, 'listing_count': 0};

    test('the owner\'s token shows the hidden collections too', () async {
      server.always(200, {'count': 1, 'next': null, 'previous': null, 'results': [collection]});
      await service.listCollections('dryrun-demo', token: 'tok', limit: 100);
      final request = server.requests.single;
      expect(request.path, '/p2p/shops/dryrun-demo/collections/');
      expect(request.authorization, 'Bearer tok');
      // A visitor sends none.
      await service.listCollections('dryrun-demo');
      expect(server.requests.last.authorization, isNull);
    });

    test('the owner\'s collections are read past the first hundred', () async {
      server.respond = (request) {
        if (request.path == '/auth/sign-token/') {
          return P2pCannedResponse(201, {
            'token': 'tok',
            'address': owner,
            'expires_at': DateTime.now().toUtc().add(const Duration(hours: 1)).toIso8601String(),
          });
        }
        final second = request.uri.queryParameters['page'] == '2';
        return P2pCannedResponse(200, {
          'count': 2,
          'next': second ? null : 2,
          'results': [
            {...collection, 'id': second ? 8 : 7},
          ],
        });
      };
      final seller = P2pSeller(service: service, session: P2pSession(service: service, signer: FakeP2pSigner()), nfts: FakeP2pNftSource());
      final all = await seller.collections(owner, 'dryrun-demo');
      expect(all.map((c) => c.id), [7, 8]);
      final reads = server.requests.where((r) => r.path == '/p2p/shops/dryrun-demo/collections/').toList();
      expect(reads.map((r) => r.uri.queryParameters['page']), ['1', '2']);
      expect(reads.every((r) => r.authorization == 'Bearer tok'), isTrue);
    });

    test('createCollection posts the name and description to the shop', () async {
      server.always(201, collection);
      final created = await service.createCollection(token: 'tok', shopUrl: 'dryrun-demo', name: 'Prints', description: 'On paper');
      final request = server.requests.single;
      expect([request.method, request.path, request.authorization], ['POST', '/p2p/shops/dryrun-demo/collections/', 'Bearer tok']);
      expect(request.body, {'name': 'Prints', 'description': 'On paper', 'is_live': true});
      expect(created.id, 7);
    });

    test('updateCollection sends only what changes', () async {
      server.always(200, {...collection, 'is_live': false});
      final hidden = await service.updateCollection(token: 'tok', id: 7, isLive: false);
      final request = server.requests.single;
      expect([request.method, request.path], ['PATCH', '/p2p/collections/7/']);
      expect(request.body, {'is_live': false});
      expect(hidden.isLive, isFalse);
    });

    test('deleteCollection is done on a 204, and a refusal keeps its code', () async {
      server.always(204);
      await service.deleteCollection(token: 'tok', id: 7);
      expect([server.requests.single.method, server.requests.single.path], ['DELETE', '/p2p/collections/7/']);

      server.always(409, {
        'error': {'code': 'collection_has_active_listings', 'message': 'Cancel or finish this collection\'s listings first.', 'fields': {}},
      });
      try {
        await service.deleteCollection(token: 'tok', id: 7);
        fail('Expected a P2pError');
      } on P2pError catch (e) {
        expect([e.status, e.code], [409, 'collection_has_active_listings']);
      }
    });

    test('createListing posts the NFT, prices and dates to the collection', () async {
      server.always(201, p2pFixture('listing_buy_now'));
      final input = P2pListingInput(smartContractUid: 'abc:1', floorPrice: '2', reservePrice: '4', startsAt: now, endsAt: now.add(const Duration(days: 7)));
      final listed = await service.createListing(token: 'tok', collectionId: 3, input: input);
      final request = server.requests.single;
      expect([request.method, request.path, request.authorization], ['POST', '/p2p/collections/3/listings/', 'Bearer tok']);
      expect(request.body, {
        'smart_contract_uid': 'abc:1',
        'buy_now_price': null,
        'floor_price': '2',
        'reserve_price': '4',
        'starts_at': '2026-11-16T17:00:00Z',
        'ends_at': '2026-11-23T17:00:00Z',
      });
      expect(listed.id, 1);
    });

    test('updateListing patches prices and dates, without the NFT', () async {
      server.always(200, p2pFixture('listing_buy_now'));
      final input = P2pListingInput(smartContractUid: 'abc:1', buyNowPrice: '6', startsAt: now, endsAt: now.add(const Duration(days: 1)));
      await service.updateListing(token: 'tok', id: 1, input: input);
      final request = server.requests.single;
      expect([request.method, request.path], ['PATCH', '/p2p/listings/1/']);
      expect(request.body, {
        'buy_now_price': '6',
        'floor_price': null,
        'reserve_price': null,
        'starts_at': '2026-11-16T17:00:00Z',
        'ends_at': '2026-11-17T17:00:00Z',
      });
    });

    test('subscribeEmail sends the address and email with the token as Authorization: basic', () async {
      server.always(200, {'successs': true});
      await service.subscribeEmail(token: 'tok', address: owner, email: 'seller@example.com');
      final request = server.requests.single;
      expect([request.method, request.path], ['POST', '/auth/email-subscribe/']);
      // Outside /api/p2p/: this endpoint reads "basic", not "Bearer".
      expect(request.authorization, 'basic tok');
      expect(request.body, {'address': owner, 'email': 'seller@example.com'});
    });

    test('subscribeEmail with a token Spyglass does not take is a sign-in refusal', () async {
      server.always(401, {'message': 'Not authenticated'});
      try {
        await service.subscribeEmail(token: 'old', address: owner, email: 'seller@example.com');
        fail('Expected a P2pError');
      } on P2pError catch (e) {
        expect(e.isUnauthorized, isTrue);
      }
    });

    test('cancelListing deletes it and reads it back as cancelled', () async {
      server.always(200, {...p2pFixture('listing_buy_now'), 'state': 'cancelled'});
      final cancelled = await service.cancelListing(token: 'tok', id: 1);
      expect([server.requests.single.method, server.requests.single.path], ['DELETE', '/p2p/listings/1/']);
      expect(cancelled.state, P2pListingState.cancelled);
    });
  });

  group('P2pSeller', () {
    late FakeP2pService service;
    late FakeP2pSigner signer;
    late FakeP2pNftSource nfts;
    late P2pSeller seller;

    setUp(() {
      service = FakeP2pService();
      signer = FakeP2pSigner();
      nfts = FakeP2pNftSource();
      seller = P2pSeller(service: service, session: P2pSession(service: service, signer: signer), nfts: nfts);
    });

    test('signs the owner in once and writes with its token', () async {
      await seller.createCollection(owner, 'dryrun-demo', name: 'Prints');
      await seller.collections(owner, 'dryrun-demo');
      expect(signer.signed, hasLength(1));
      expect(service.calls, [
        'signToken($owner)',
        'createCollection(dryrun-demo, Prints, token: token-for-$owner)',
        'listCollections(dryrun-demo, token: token-for-$owner)',
      ]);
    });

    test('uploads an NFT\'s media as its owner', () async {
      expect(await seller.hasMedia('abc:1'), isFalse);
      await seller.uploadMedia(owner, 'abc:1');
      expect(nfts.uploaded, ['abc:1 as token-for-$owner']);
      expect(await seller.hasMedia('abc:1'), isTrue);
    });

    test('a token the registry no longer takes is replaced and the write sent again', () async {
      var refusals = 1;
      service.onCancelListing = (id) {
        if (refusals-- > 0) {
          throw const P2pError(status: 401, code: P2pError.tokenExpired);
        }
        return listing('listing_buy_now', {'state': 'cancelled'});
      };
      final cancelled = await seller.cancelListing(owner, 1);
      expect(cancelled.state, P2pListingState.cancelled);
      expect(signer.signed, hasLength(2));
    });
  });
}
