import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/api_token_manager.dart';
import 'package:rbx_wallet/core/singletons.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_collection.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_error.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_listing.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_me.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_owned_nft.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_shop.dart';
import 'package:rbx_wallet/features/p2p/providers/p2p_listed_nfts_provider.dart';
import 'package:rbx_wallet/features/p2p/providers/p2p_seller_providers.dart';
import 'package:rbx_wallet/features/p2p/screens/p2p_my_shop_screen.dart';
import 'package:rbx_wallet/features/p2p/services/p2p_nft_source.dart';

import 'p2p_test_helpers.dart';

/// The registry's listed flags, held still.
class _Listed extends P2pListedNfts {
  final Set<String> ids;

  _Listed(this.ids);

  @override
  Set<String> build() => ids;

  @override
  Future<void> refresh() async {}
}

void main() {
  const owner = 'xJwSHB75g85bfhPLBFJ7JS1QzkDRhNJksJ';
  const other = 'xOtherAccountAAAAAAAAAAAAAAAAAAAAA';
  const harbor = 'aa11bb22cc33dd44ee55ff6677889900:1794213200';
  const cube = '0b6ea1abd1da425fab80029f8f20944c:1794213169';
  final now = DateTime.utc(2026, 11, 16, 17);

  late FakeP2pService service;
  late FakeP2pSigner signer;
  late FakeP2pNftSource nfts;
  Set<String> listed = {};

  P2pShop demoShop() => P2pShop.fromJson(p2pFixture('shop_detail'));

  P2pListing listing(String fixture, [Map<String, dynamic> changes = const {}]) {
    return P2pListing.fromJson({...p2pFixture(fixture), ...changes});
  }

  setUpAll(() {
    if (!singleton.isRegistered<ApiTokenManager>()) {
      singleton.registerSingleton<ApiTokenManager>(ApiTokenManagerImplementation());
    }
  });

  setUp(() {
    signer = FakeP2pSigner();
    listed = {};
    nfts = FakeP2pNftSource(const [
      P2pOwnedNft(id: harbor, name: 'Harbor at Dusk', owner: owner),
      P2pOwnedNft(id: cube, name: 'E2E Bulk Mint B 08:32', owner: owner),
      P2pOwnedNft(id: 'vault:1', name: 'vBTC Vault', owner: owner, isSellable: false),
      P2pOwnedNft(id: 'elsewhere:1', name: 'Kept Elsewhere', owner: other),
    ]);
    service = FakeP2pService()
      ..shopsByOwner = {owner: demoShop()}
      ..collectionsByShop = {
        'dryrun-demo': [
          P2pCollection(id: 3, shopUrl: 'dryrun-demo', name: 'Main', isDefault: true, listingCount: 1),
          P2pCollection(id: 8, shopUrl: 'dryrun-demo', name: 'Prints', description: 'On paper', isLive: false),
        ],
      };
  });

  Future<void> pump(WidgetTester tester, {String? listNftId}) async {
    tester.binding.window.physicalSizeTestValue = const Size(1400, 1400);
    tester.binding.window.devicePixelRatioTestValue = 1;
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    await tester.pumpWidget(p2pTestApp(
      child: const P2pMyShopScreen(),
      service: service,
      signer: signer,
      nfts: nfts,
      address: owner,
      now: now,
      overrides: [
        p2pListedNftsProvider.overrideWith(() => _Listed(listed)),
        // As the NFT's own page leaves it when "List for sale" is pressed.
        if (listNftId != null) p2pListRequestProvider.overrideWith((ref) => listNftId),
      ],
    ));
    await settle(tester);
  }

  String text(WidgetTester tester, String key) => tester.widget<Text>(find.byKey(Key(key))).data!;

  group('collections', () {
    testWidgets('the owner sees every collection, the hidden one too, read with its token', (tester) async {
      await pump(tester);
      expect(service.calls, contains('listCollections(dryrun-demo, token: token-for-$owner)'));
      final main = find.byKey(const Key('p2p:collection_row:3'));
      expect(find.descendant(of: main, matching: find.text('Main')), findsOneWidget);
      expect(find.descendant(of: main, matching: find.text('Default')), findsOneWidget);
      expect(find.descendant(of: main, matching: find.text('1 active')), findsOneWidget);
      final prints = find.byKey(const Key('p2p:collection_row:8'));
      expect(find.descendant(of: prints, matching: find.text('Hidden')), findsOneWidget);
      expect(find.descendant(of: prints, matching: find.text('On paper')), findsOneWidget);
      // One sign-in serves the collections and the listings.
      expect(signer.signed, hasLength(1));
    });

    testWidgets('a new collection is posted and joins the list', (tester) async {
      await pump(tester);
      await tester.tap(find.byKey(const Key('p2p:collection_new')));
      await settle(tester);
      // Nothing to save without a name.
      await tester.tap(find.byKey(const Key('p2p:collection_save')), warnIfMissed: false);
      await settle(tester);
      expect(service.calls.where((c) => c.startsWith('createCollection')), isEmpty);

      await tester.enterText(find.byKey(const Key('p2p:collection_name')), '  Posters ');
      await tester.enterText(find.byKey(const Key('p2p:collection_description')), 'Large format');
      await tester.pump();
      await tester.tap(find.byKey(const Key('p2p:collection_save')));
      await settle(tester);

      expect(service.calls, contains('createCollection(dryrun-demo, Posters, token: token-for-$owner)'));
      expect(find.byKey(const Key('p2p:collection_name')), findsNothing);
      expect(find.text('Posters'), findsOneWidget);
    });

    testWidgets('a collection is renamed', (tester) async {
      await pump(tester);
      await tester.tap(find.byKey(const Key('p2p:collection_edit:8')));
      await settle(tester);
      expect(tester.widget<TextField>(find.byKey(const Key('p2p:collection_name'))).controller!.text, 'Prints');
      await tester.enterText(find.byKey(const Key('p2p:collection_name')), 'Fine Prints');
      await tester.pump();
      await tester.tap(find.byKey(const Key('p2p:collection_save')));
      await settle(tester);
      expect(service.calls, contains('updateCollection(8, name: Fine Prints, description: On paper, isLive: null, token: token-for-$owner)'));
      expect(find.text('Fine Prints'), findsOneWidget);
    });

    testWidgets('a collection is hidden and shown again', (tester) async {
      await pump(tester);
      await tester.tap(find.byKey(const Key('p2p:collection_toggle:3')));
      await settle(tester);
      expect(service.calls, contains('updateCollection(3, name: null, description: null, isLive: false, token: token-for-$owner)'));
      expect(find.descendant(of: find.byKey(const Key('p2p:collection_row:3')), matching: find.text('Hidden')), findsOneWidget);

      await tester.tap(find.byKey(const Key('p2p:collection_toggle:3')));
      await settle(tester);
      expect(find.descendant(of: find.byKey(const Key('p2p:collection_row:3')), matching: find.text('Hidden')), findsNothing);
    });

    testWidgets('a collection is deleted after a confirmation; the default one cannot be', (tester) async {
      await pump(tester);
      expect(tester.widget<IconButton>(find.byKey(const Key('p2p:collection_delete:3'))).onPressed, isNull);

      await tester.tap(find.byKey(const Key('p2p:collection_delete:8')));
      await settle(tester);
      expect(find.textContaining('Delete “Prints”?'), findsOneWidget);
      expect(service.calls.where((c) => c.startsWith('deleteCollection')), isEmpty);

      await tester.tap(find.byKey(const Key('p2p:collection_delete_confirm')));
      await settle(tester);
      expect(service.calls, contains('deleteCollection(8, token: token-for-$owner)'));
      expect(find.byKey(const Key('p2p:collection_row:8')), findsNothing);
    });

    testWidgets('a refusal is shown in words and the collection stays', (tester) async {
      await pump(tester);
      service.collectionError = const P2pError(status: 409, code: 'collection_has_active_listings', message: 'Cancel or finish this collection\'s listings first.');
      await tester.tap(find.byKey(const Key('p2p:collection_delete:8')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('p2p:collection_delete_confirm')));
      await settle(tester);
      expect(text(tester, 'p2p:collections_error'), 'Cancel or finish this collection’s listings first.');
      expect(find.byKey(const Key('p2p:collection_row:8')), findsOneWidget);
    });
  });

  group('listing an NFT', () {
    P2pListing posted(int collectionId, P2pListingInput input) {
      return listing('listing_auction', {
        'id': 9,
        'collection_id': collectionId,
        'smart_contract_uid': input.smartContractUid,
        'buy_now_price': input.buyNowPrice,
        'floor_price': input.floorPrice,
        'reserve_price': input.reservePrice,
        'bid_count': 0,
        'high_bid': null,
      });
    }

    testWidgets('the picker offers this account\'s NFTs, and marks what cannot be listed', (tester) async {
      listed = {cube};
      await pump(tester);
      await tester.tap(find.byKey(const Key('p2p:list_open')));
      await settle(tester);

      expect(find.byKey(const Key('p2p:list_pick:$harbor')), findsOneWidget);
      // Another account's NFT is not offered at all.
      expect(find.byKey(const Key('p2p:list_pick:elsewhere:1')), findsNothing);
      expect(find.descendant(of: find.byKey(const Key('p2p:list_pick:$cube')), matching: find.text('Listed')), findsOneWidget);
      expect(find.descendant(of: find.byKey(const Key('p2p:list_pick:vault:1')), matching: find.text('Cannot be sold')), findsOneWidget);

      // A marked NFT cannot be chosen.
      await tester.tap(find.byKey(const Key('p2p:list_pick:$cube')));
      await settle(tester);
      expect(find.byKey(const Key('p2p:list_submit')), findsNothing);
    });

    testWidgets('a fixed price: media is uploaded first, then the listing is posted', (tester) async {
      P2pListingInput? sent;
      int? sentTo;
      service.onCreateListing = (collectionId, input) {
        sent = input;
        sentTo = collectionId;
        return posted(collectionId, input);
      };
      await pump(tester);
      await tester.tap(find.byKey(const Key('p2p:list_open')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('p2p:list_pick:$harbor')));
      await settle(tester);

      // No price yet.
      await tester.tap(find.byKey(const Key('p2p:list_submit')));
      await settle(tester);
      expect(find.text('Required'), findsOneWidget);
      expect(service.calls.where((c) => c.startsWith('createListing')), isEmpty);

      await tester.enterText(find.byKey(const Key('p2p:list_price')), '12.5');
      await tester.pump();
      // Seven days from now, unless told otherwise.
      expect(text(tester, 'p2p:list_closes_on'), startsWith('Closes Nov 23, 2026'));
      await tester.tap(find.byKey(const Key('p2p:list_days:3')));
      await tester.pump();
      expect(text(tester, 'p2p:list_closes_on'), startsWith('Closes Nov 19, 2026'));

      await tester.tap(find.byKey(const Key('p2p:list_submit')));
      await settle(tester);

      // Spyglass had no media for it: uploaded as the owner before listing.
      expect(nfts.uploaded, ['$harbor as token-for-$owner']);
      expect(service.calls, contains('createListing(3, $harbor, token: token-for-$owner)'));
      expect(sentTo, 3);
      expect(sent!.toJson(), {
        'smart_contract_uid': harbor,
        'buy_now_price': '12.5',
        'floor_price': null,
        'reserve_price': null,
        'starts_at': '2026-11-16T17:00:00Z',
        'ends_at': '2026-11-19T17:00:00Z',
      });
      // The dialog closes and says so.
      expect(find.byKey(const Key('p2p:list_submit')), findsNothing);
      expect(find.text('“Harbor at Dusk” is listed.'), findsOneWidget);
    });

    testWidgets('an NFT whose media Spyglass already holds is not uploaded again', (tester) async {
      nfts.withMedia = {harbor};
      service.onCreateListing = posted;
      await pump(tester);
      await tester.tap(find.byKey(const Key('p2p:list_open')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('p2p:list_pick:$harbor')));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('p2p:list_price')), '5');
      await tester.tap(find.byKey(const Key('p2p:list_submit')));
      await settle(tester);
      expect(nfts.uploaded, isEmpty);
      expect(service.calls, contains('createListing(3, $harbor, token: token-for-$owner)'));
    });

    testWidgets('an auction: starting bid, reserve and buy-now are checked, then posted to the chosen collection', (tester) async {
      nfts.withMedia = {harbor};
      P2pListingInput? sent;
      int? sentTo;
      service.onCreateListing = (collectionId, input) {
        sent = input;
        sentTo = collectionId;
        return posted(collectionId, input);
      };
      await pump(tester);
      await tester.tap(find.byKey(const Key('p2p:list_open')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('p2p:list_pick:$harbor')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('p2p:list_kind_auction')));
      await tester.pump();

      await tester.enterText(find.byKey(const Key('p2p:list_floor')), '5');
      await tester.enterText(find.byKey(const Key('p2p:list_reserve')), '4');
      await tester.tap(find.byKey(const Key('p2p:list_submit')));
      await settle(tester);
      expect(find.text('The reserve cannot be below the starting bid.'), findsOneWidget);
      expect(sent, isNull);

      await tester.enterText(find.byKey(const Key('p2p:list_reserve')), '10');
      await tester.enterText(find.byKey(const Key('p2p:list_buy_now')), '40');
      await tester.pump();
      // The hidden collection can hold it: it is offered, marked hidden.
      await tester.tap(find.byKey(const Key('p2p:list_collection')));
      await settle(tester);
      await tester.tap(find.text('Prints (Hidden)').last);
      await settle(tester);

      await tester.tap(find.byKey(const Key('p2p:list_submit')));
      await settle(tester);
      expect(sentTo, 8);
      expect([sent!.floorPrice, sent!.reservePrice, sent!.buyNowPrice], ['5', '10', '40']);
    });

    testWidgets('media that cannot be uploaded: said so, and it can be listed without a picture', (tester) async {
      nfts.uploadError = const P2pMediaUploadError('harbor.png');
      service.onCreateListing = posted;
      await pump(tester);
      await tester.tap(find.byKey(const Key('p2p:list_open')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('p2p:list_pick:$harbor')));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('p2p:list_price')), '5');
      await tester.tap(find.byKey(const Key('p2p:list_submit')));
      await settle(tester);

      expect(find.byKey(const Key('p2p:list_media_failed')), findsOneWidget);
      expect(service.calls.where((c) => c.startsWith('createListing')), isEmpty);

      await tester.tap(find.byKey(const Key('p2p:list_skip_media')));
      await settle(tester);
      expect(service.calls, contains('createListing(3, $harbor, token: token-for-$owner)'));
    });

    testWidgets('a refusal from the registry is shown in words, and the form stays', (tester) async {
      nfts.withMedia = {harbor};
      service.listingError = const P2pError(status: 400, code: 'nft_not_found', message: 'This NFT is not indexed.');
      await pump(tester);
      await tester.tap(find.byKey(const Key('p2p:list_open')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('p2p:list_pick:$harbor')));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('p2p:list_price')), '5');
      await tester.tap(find.byKey(const Key('p2p:list_submit')));
      await settle(tester);
      expect(text(tester, 'p2p:list_error'), 'The explorer has not indexed this NFT yet. Try again in a moment.');
      expect(find.byKey(const Key('p2p:list_submit')), findsOneWidget);
    });

    testWidgets('an NFT with a royalty says what a sale pays, or that it cannot be sold', (tester) async {
      const payTo = 'xRoyaltyAAAAAAAAAAAAAAAAAAAAAAAAAA';
      nfts.nfts = [
        P2pOwnedNft(id: harbor, name: 'Harbor at Dusk', owner: owner, royalty: P2pRoyalty(amount: '0.05', payTo: payTo)),
        P2pOwnedNft(id: cube, name: 'Cube', owner: owner, royalty: P2pRoyalty(amount: '3', payTo: payTo)),
      ];
      await pump(tester);
      await tester.tap(find.byKey(const Key('p2p:list_open')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('p2p:list_pick:$harbor')));
      await settle(tester);
      expect(text(tester, 'p2p:list_royalty'), 'A sale of this NFT pays 5% of the price to xRoyal…AAAAA. It comes out of the price.');

      await tester.tap(find.byKey(const Key('p2p:list_change')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('p2p:list_pick:$cube')));
      await settle(tester);
      expect(text(tester, 'p2p:list_royalty'), contains('cannot be paid through a sale'));
    });

    testWidgets('from the NFT\'s own page: the form opens for that NFT', (tester) async {
      await pump(tester, listNftId: harbor);
      expect(find.byKey(const Key('p2p:list_submit')), findsOneWidget);
      expect(find.text('Harbor at Dusk'), findsOneWidget);
    });

    testWidgets('from the NFT\'s own page: an NFT that cannot be listed says why, above the picker', (tester) async {
      listed = {cube};
      await pump(tester, listNftId: cube);
      expect(text(tester, 'p2p:list_cannot'), 'That NFT is already listed.');
      expect(find.byKey(const Key('p2p:list_picker')), findsOneWidget);
    });

    testWidgets('from the NFT\'s own page: another account\'s NFT is told to switch', (tester) async {
      await pump(tester, listNftId: 'elsewhere:1');
      expect(text(tester, 'p2p:list_cannot'), 'That NFT belongs to another account. Switch to it to list it.');
    });

    testWidgets('an account with no shop is told to open one first', (tester) async {
      service.shopsByOwner = {};
      await pump(tester, listNftId: harbor);
      expect(find.byKey(const Key('p2p:list_needs_shop')), findsOneWidget);
      expect(find.byKey(const Key('p2p:register_shop')), findsOneWidget);
      expect(find.byKey(const Key('p2p:list_submit')), findsNothing);
    });

    testWidgets('the form opens once: closing it does not bring it back', (tester) async {
      await pump(tester, listNftId: harbor);
      await tester.tap(find.byKey(const Key('p2p:list_cancel')));
      await settle(tester);
      expect(find.byKey(const Key('p2p:list_submit')), findsNothing);
      // Reading the shop again does not open it either.
      await tester.tap(find.byKey(const Key('p2p:my_shop_refresh')));
      await settle(tester);
      expect(find.byKey(const Key('p2p:list_submit')), findsNothing);
    });
  });

  group('the seller\'s listings', () {
    setUp(() {
      service.onMe = (_) => P2pMe(
            shop: demoShop(),
            selling: [
              P2pSellingListing(listing: listing('listing_buy_now')),
              P2pSellingListing(listing: listing('listing_auction_live')),
              P2pSellingListing(listing: listing('listing_buy_now', {'id': 5, 'state': 'sold', 'sold_price': '5'})),
            ],
          );
    });

    testWidgets('are grouped, each with what its seller can do', (tester) async {
      await pump(tester);
      expect(text(tester, 'p2p:selling_group:live'), 'Live · 2');
      expect(text(tester, 'p2p:selling_group:sold'), 'Sold · 1');
      // No bids: change or withdraw. A bid: only withdraw. Sold: nothing.
      expect(find.byKey(const Key('p2p:listing_edit:1')), findsOneWidget);
      expect(find.byKey(const Key('p2p:listing_cancel:1')), findsOneWidget);
      expect(find.byKey(const Key('p2p:listing_edit:2')), findsNothing);
      expect(find.byKey(const Key('p2p:listing_cancel:2')), findsOneWidget);
      expect(find.byKey(const Key('p2p:listing_cancel:5')), findsNothing);
    });

    testWidgets('with nothing listed, says how to start', (tester) async {
      service.onMe = (_) => P2pMe(shop: demoShop());
      await pump(tester);
      expect(find.text('Nothing listed yet.'), findsOneWidget);
    });

    testWidgets('a listing with no bids is changed: the form opens with its values', (tester) async {
      P2pListingInput? sent;
      service.onUpdateListing = (id, input) {
        sent = input;
        return listing('listing_buy_now', {'buy_now_price': input.buyNowPrice});
      };
      await pump(tester);
      await tester.tap(find.byKey(const Key('p2p:listing_edit:1')));
      await settle(tester);

      expect(tester.widget<TextField>(find.byKey(const Key('p2p:list_price'))).controller!.text, '5');
      // It is open already: when it opened is not asked again.
      expect(find.byKey(const Key('p2p:list_opens_now')), findsNothing);
      await tester.enterText(find.byKey(const Key('p2p:list_price')), '6.5');
      await tester.tap(find.byKey(const Key('p2p:list_submit')));
      await settle(tester);

      expect(service.calls, contains('updateListing(1, token: token-for-$owner)'));
      expect(sent!.toJson(forUpdate: true), {
        'buy_now_price': '6.5',
        'floor_price': null,
        'reserve_price': null,
        // Its own start and end, unchanged.
        'starts_at': '2026-11-16T15:26:35Z',
        'ends_at': '2026-12-16T15:26:35Z',
      });
      expect(find.byKey(const Key('p2p:list_submit')), findsNothing);
    });

    testWidgets('a change the registry refuses is shown in words', (tester) async {
      service.listingError = const P2pError(status: 409, code: 'listing_has_bids', message: 'Prices and dates are fixed once a bid exists.');
      await pump(tester);
      await tester.tap(find.byKey(const Key('p2p:listing_edit:1')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('p2p:list_submit')));
      await settle(tester);
      expect(text(tester, 'p2p:list_error'), 'Prices and dates are fixed once a bid exists.');
    });

    testWidgets('a listing is withdrawn after a confirmation, with no transaction', (tester) async {
      service.onCancelListing = (id) => listing('listing_buy_now', {'state': 'cancelled'});
      await pump(tester);
      await tester.tap(find.byKey(const Key('p2p:listing_cancel:1')));
      await settle(tester);
      expect(find.textContaining('Take “E2E Bulk Mint B 08:32” off sale?'), findsOneWidget);
      expect(service.calls.where((c) => c.startsWith('cancelListing')), isEmpty);

      await tester.tap(find.byKey(const Key('p2p:listing_cancel_confirm')));
      await settle(tester);
      expect(service.calls, contains('cancelListing(1, token: token-for-$owner)'));
      expect(service.dryRuns, isEmpty);
      expect(find.byKey(const Key('p2p:listing_cancel_confirm')), findsNothing);
    });

    testWidgets('a withdrawal the registry refuses is shown in words', (tester) async {
      service.listingError = const P2pError(status: 409, code: 'sale_pending', message: 'The sale has started on chain; cancel it with Sale_Cancel.');
      await pump(tester);
      await tester.tap(find.byKey(const Key('p2p:listing_cancel:1')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('p2p:listing_cancel_confirm')));
      await settle(tester);
      expect(text(tester, 'p2p:listing_cancel_error'), 'The sale has started, so the listing cannot be withdrawn. Cancel the sale instead.');
    });
  });

  group('a sale', () {
    const buyer = 'xBidderAAAAAAAAAAAAAAAAAAAAAAAAAAA';
    late Map<String, dynamic> me;

    setUp(() {
      me = p2pFixture('me');
      service.onMe = (_) => P2pMe(
            shop: demoShop(),
            selling: [
              // Listing 4: a winner at 5 VFX, with the winning bid's signature.
              P2pSellingListing.fromJson((me['selling'] as List).first as Map<String, dynamic>),
              P2pSellingListing(listing: listing('listing_sale_pending')),
              P2pSellingListing(listing: listing('listing_auction', {'id': 6, 'state': 'unfulfilled', 'smart_contract_uid': harbor})),
            ],
          );
    });

    testWidgets('a listing with a winner leads the list, with its 48 hours counting down', (tester) async {
      await pump(tester);
      expect(text(tester, 'p2p:selling_group:needsYou'), 'Start the sale · 1');
      expect(text(tester, 'p2p:selling_group:waitingForBuyer'), 'Waiting for the buyer · 1');
      final row = find.byKey(const Key('p2p:selling_row:4'));
      // Won 16:20 on the 16th; it is 17:00: 47 hours 20 minutes left.
      expect(find.descendant(of: row, matching: find.textContaining('1d 23h')), findsOneWidget);
      expect(find.byKey(const Key('p2p:sale_start:4')), findsOneWidget);
      // Until the sale starts the listing can still be withdrawn.
      expect(find.byKey(const Key('p2p:listing_cancel:4')), findsOneWidget);
    });

    testWidgets('is started: the Sale_Start carries the winning bid, and is recorded as a dry run', (tester) async {
      service.onSaleStart = (id, tx) => listing('listing_sale_pending', {'id': id});
      await pump(tester);
      await tester.tap(find.byKey(const Key('p2p:sale_start:4')));
      await settle(tester);

      expect(find.byKey(const Key('p2p:step_dry_run')), findsOneWidget);
      final tx = find.byKey(const Key('p2p:step_transaction'));
      expect(find.descendant(of: tx, matching: find.text('Sale_Start()')), findsOneWidget);
      // To the winner, in full.
      expect(find.descendant(of: tx, matching: find.text(buyer)), findsWidgets);
      expect(service.dryRuns, isEmpty);

      await tester.tap(find.byKey(const Key('p2p:step_confirm')));
      await settle(tester);
      expect(service.calls, contains('dryRunSaleStart(4, token: token-for-$owner)'));
      final sent = service.dryRuns.single;
      expect([sent.fromAddress, sent.toAddress, sent.amount], [owner, buyer, '0']);
      expect(sent.data['SoldFor'], 5);
      expect(sent.data['KeySign'], 'KlMnOpQrSt1794843000');
      expect(sent.data['BidSignature'], ((me['selling'] as List).first as Map)['winning_bid']['signature']);
      expect(find.text('Recorded as a dry run'), findsOneWidget);
    });

    testWidgets('cannot be started when the winning bid is not in the seller\'s list', (tester) async {
      await pump(tester);
      // The registry's list changes between the screen's read and the step's.
      service.onMe = (_) => P2pMe(shop: demoShop());
      await tester.tap(find.byKey(const Key('p2p:sale_start:4')));
      await settle(tester);
      expect(text(tester, 'p2p:step_error'), 'The winning bid for this listing could not be read. Refresh and try again.');
      expect(find.byKey(const Key('p2p:step_transaction')), findsNothing);
    });

    testWidgets('a refusal to start it is shown in words', (tester) async {
      service.dryRunError = const P2pError(status: 409, code: 'listing_not_awaiting_sale_start', message: 'The listing is unfulfilled.');
      await pump(tester);
      await tester.tap(find.byKey(const Key('p2p:sale_start:4')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('p2p:step_confirm')));
      await settle(tester);
      expect(text(tester, 'p2p:step_error'), 'This listing is not waiting for its sale to start.');
    });

    testWidgets('once started, is cancelled with a Sale_Cancel after a warning', (tester) async {
      service.onSaleCancel = (id, tx) => listing('listing_sale_pending', {'state': 'cancelled'});
      await pump(tester);
      // A started sale cannot be withdrawn as a listing.
      expect(find.byKey(const Key('p2p:listing_cancel:3')), findsNothing);
      await tester.tap(find.byKey(const Key('p2p:sale_cancel:3')));
      await settle(tester);

      expect(text(tester, 'p2p:step_warning'), 'The buyer has not paid. Cancelling releases the NFT so it can be listed again.');
      final tx = find.byKey(const Key('p2p:step_transaction'));
      expect(find.descendant(of: tx, matching: find.text('Sale_Cancel()')), findsOneWidget);

      await tester.tap(find.byKey(const Key('p2p:step_confirm')));
      await settle(tester);
      expect(service.calls, contains('dryRunSaleCancel(3, token: token-for-$owner)'));
      expect(service.dryRuns.single.data, {
        'Function': 'Sale_Cancel()',
        'ContractUID': cube,
        'KeySign': 'KlMnOpQrSt1794843000',
      });
    });

    testWidgets('never started in its 48 hours: the NFT can be listed again', (tester) async {
      await pump(tester);
      await tester.tap(find.byKey(const Key('p2p:listing_again:6')));
      await settle(tester);
      // The listing form, for that NFT.
      expect(find.byKey(const Key('p2p:list_submit')), findsOneWidget);
      expect(find.byKey(const Key('p2p:list_change')), findsOneWidget);
      expect(find.text('Harbor at Dusk'), findsWidgets);
    });
  });
}

/// Lets futures (reads, sign-in, the dialog's route) run to their end.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 60));
  }
}
