import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/api_token_manager.dart';
import 'package:rbx_wallet/core/singletons.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_error.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_listing.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_page.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_shop.dart';
import 'package:rbx_wallet/features/p2p/screens/p2p_shop_list_screen.dart';
import 'package:rbx_wallet/features/p2p/screens/p2p_shop_screen.dart';

import 'p2p_test_helpers.dart';

void main() {
  const owner = 'xJwSHB75g85bfhPLBFJ7JS1QzkDRhNJksJ';
  // Inside both fixture listings' dates: they end on 2026-12-16.
  final now = DateTime.utc(2026, 11, 16, 16);

  late FakeP2pService service;

  P2pShop demoShop() => P2pShop.fromJson(p2pFixture('shop_detail'));
  P2pListing buyNow() => P2pListing.fromJson(p2pFixture('listing_buy_now')..remove('bids'));
  P2pListing auction() => P2pListing.fromJson(p2pFixture('listing_auction_live')..remove('bids'));

  setUpAll(() {
    if (!singleton.isRegistered<ApiTokenManager>()) {
      singleton.registerSingleton<ApiTokenManager>(ApiTokenManagerImplementation());
    }
  });

  setUp(() {
    service = FakeP2pService()
      ..shops = ((_, __) => P2pPage.fromJson(p2pFixture('shops_page'), P2pShop.fromJson))
      ..shopsByUrl = {'dryrun-demo': demoShop()}
      ..listings = ((_, __, ___) => P2pPage(count: 2, next: null, results: [auction(), buyNow()]));
  });

  Future<void> pump(WidgetTester tester, Widget screen, {String? address = 'xViewerAAAAAAAAAAAAAAAAAAAAAAAAAAA'}) async {
    tester.binding.window.physicalSizeTestValue = const Size(1400, 1000);
    tester.binding.window.devicePixelRatioTestValue = 1;
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    await tester.pumpWidget(p2pTestApp(child: screen, service: service, address: address, now: now));
    await tester.pump();
    await tester.pump();
  }

  group('shop list', () {
    testWidgets('shows each shop with its address, owner and live count', (tester) async {
      await pump(tester, const P2pShopListScreen());

      expect(find.text('Shops'), findsOneWidget);
      expect(find.byKey(const Key('p2p:dry_run_banner')), findsOneWidget);
      expect(find.byKey(const Key('p2p:shop_card:dryrun-demo')), findsOneWidget);
      expect(find.text('Dry Run Demo'), findsOneWidget);
      expect(find.text('vfx://dryrun-demo'), findsOneWidget);
      expect(find.text('1 live'), findsOneWidget);
      expect(find.text('xJwSHB…NJksJ'), findsOneWidget);
      expect(find.text('Your shop'), findsNothing);
      expect(service.calls, contains('listShops(search: , page: 1)'));
      // Each card reads a strip of what the shop sells.
      expect(service.calls, contains('listListings(dryrun-demo, collection: null, page: 1, limit: 4)'));
    });

    testWidgets('marks the selected account\'s own shop', (tester) async {
      await pump(tester, const P2pShopListScreen(), address: owner);
      expect(find.text('Your shop'), findsOneWidget);
    });

    testWidgets('an empty registry is an empty state, not an error', (tester) async {
      service.shops = (_, __) => const P2pPage(count: 0, next: null, results: []);
      await pump(tester, const P2pShopListScreen());
      expect(find.text('No shops yet'), findsOneWidget);
      expect(find.byKey(const Key('p2p:error')), findsNothing);
    });

    testWidgets('searches once typing pauses, and says when nothing matches', (tester) async {
      service.shops = (search, _) => search.isEmpty ? P2pPage.fromJson(p2pFixture('shops_page'), P2pShop.fromJson) : const P2pPage(count: 0, next: null, results: []);
      await pump(tester, const P2pShopListScreen());

      await tester.enterText(find.byKey(const Key('p2p:shop_search')), 'zebra');
      await tester.pump(const Duration(milliseconds: 100));
      expect(service.calls, isNot(contains('listShops(search: zebra, page: 1)')));

      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
      expect(service.calls, contains('listShops(search: zebra, page: 1)'));
      expect(find.text('No shops match “zebra”'), findsOneWidget);

      await tester.tap(find.byKey(const Key('p2p:shop_search_clear')));
      await tester.pump();
      await tester.pump();
      expect(find.text('Dry Run Demo'), findsOneWidget);
    });

    testWidgets('a failed load is worded and can be retried', (tester) async {
      service.error = const P2pError(status: null, code: P2pError.unreachable);
      await pump(tester, const P2pShopListScreen());
      expect(find.text('Could not reach the shop registry. Check your connection and try again.'), findsOneWidget);

      service.error = null;
      await tester.tap(find.byKey(const Key('p2p:retry')));
      await tester.pump();
      await tester.pump();
      expect(find.text('Dry Run Demo'), findsOneWidget);
    });

    testWidgets('pages by number', (tester) async {
      service.shops = (_, page) {
        final shop = demoShop().copyWith(name: 'Shop on page $page', collections: null);
        return P2pPage(count: 31, next: page == 1 ? 2 : null, results: [shop]);
      };
      await pump(tester, const P2pShopListScreen());
      expect(find.text('Shop on page 1'), findsOneWidget);
      expect(find.text('Page 1'), findsOneWidget);

      await tester.tap(find.byKey(const Key('p2p:page_next')));
      await tester.pump();
      await tester.pump();
      expect(find.text('Shop on page 2'), findsOneWidget);
      expect(service.calls, contains('listShops(search: , page: 2)'));
    });
  });

  group('shop page', () {
    testWidgets('shows the shop, and each listing with its price, clock and state', (tester) async {
      await pump(tester, const P2pShopScreen(url: 'dryrun-demo'));

      expect(service.calls, contains('getShop(dryrun-demo)'));
      expect(find.byKey(const Key('p2p:shop_header')), findsOneWidget);
      // The name is the app bar's title and the header's.
      expect(find.text('Dry Run Demo'), findsNWidgets(2));
      expect(find.text('vfx://dryrun-demo'), findsOneWidget);
      expect(find.textContaining('A test shop on testnet'), findsOneWidget);
      expect(find.text('Live listings 1'), findsOneWidget);

      // The auction: its current bid, its bid count, time left and state.
      expect(find.byKey(const Key('p2p:listing_card:2')), findsOneWidget);
      expect(find.text('E2E Good URL 08:32:52'), findsOneWidget);
      expect(find.text('Current bid'), findsOneWidget);
      expect(find.text('2 VFX'), findsOneWidget);
      expect(find.text('Auction · 1 bid'), findsOneWidget);

      // The buy-now listing.
      expect(find.byKey(const Key('p2p:listing_card:1')), findsOneWidget);
      expect(find.text('Buy now'), findsOneWidget);
      expect(find.text('5 VFX'), findsOneWidget);
      expect(find.text('Fixed price'), findsOneWidget);

      expect(find.byKey(const Key('p2p:state:live')), findsNWidgets(2));
      // 2026-11-16 16:00 to 2026-12-16 15:26:35 and 15:33:48.
      expect(find.text('Ends in 29d 23h'), findsNWidgets(2));
    });

    testWidgets('a single collection shows no filter', (tester) async {
      await pump(tester, const P2pShopScreen(url: 'dryrun-demo'));
      expect(find.byKey(const Key('p2p:collection:all')), findsNothing);
    });

    testWidgets('several collections filter the grid', (tester) async {
      final json = p2pFixture('shop_detail');
      (json['collections'] as List).add({
        'id': 9,
        'shop_url': 'dryrun-demo',
        'name': 'Prints',
        'description': '',
        'is_live': true,
        'is_default': false,
        'listing_count': 4,
      });
      service.shopsByUrl = {'dryrun-demo': P2pShop.fromJson(json)};
      await pump(tester, const P2pShopScreen(url: 'dryrun-demo'));

      expect(find.byKey(const Key('p2p:collection:all')), findsOneWidget);
      expect(find.text('Main'), findsOneWidget);
      expect(find.text('Prints'), findsOneWidget);

      await tester.tap(find.byKey(const Key('p2p:collection:9')));
      await tester.pump();
      await tester.pump();
      expect(service.calls, contains('listListings(dryrun-demo, collection: 9, page: 1, limit: null)'));
    });

    testWidgets('a picked collection the seller then hides stops filtering the grid', (tester) async {
      Map<String, dynamic> shopWith(List<Map<String, dynamic>> extra) {
        final json = p2pFixture('shop_detail');
        (json['collections'] as List).addAll(extra);
        return json;
      }

      const prints = {'id': 9, 'shop_url': 'dryrun-demo', 'name': 'Prints', 'description': '', 'is_live': true, 'is_default': false, 'listing_count': 4};
      service.shopsByUrl = {'dryrun-demo': P2pShop.fromJson(shopWith([prints]))};
      await pump(tester, const P2pShopScreen(url: 'dryrun-demo'));
      await tester.tap(find.byKey(const Key('p2p:collection:9')));
      await tester.pump();
      await tester.pump();
      expect(service.calls.last, 'listListings(dryrun-demo, collection: 9, page: 1, limit: null)');

      // The seller hides Prints: one live collection is left, so the chips go.
      service.shopsByUrl = {'dryrun-demo': demoShop()};
      service.calls.clear();
      await tester.tap(find.byKey(const Key('p2p:shop_refresh')));
      // The shop reloads, then the grid for the filter that is left.
      for (var i = 0; i < 4; i++) {
        await tester.pump();
      }

      // Once the shop has reloaded, the grid is read for every collection.
      expect(find.byKey(const Key('p2p:collection:9')), findsNothing);
      expect(find.byKey(const Key('p2p:collection:all')), findsNothing);
      expect(service.calls.where((c) => c.startsWith('listListings')).last, 'listListings(dryrun-demo, collection: null, page: 1, limit: null)');
      expect(find.byKey(const Key('p2p:listing_card:2')), findsOneWidget);

      // And it stays so on the next reload.
      service.calls.clear();
      await tester.tap(find.byKey(const Key('p2p:shop_refresh')));
      await tester.pump();
      await tester.pump();
      expect(service.calls.where((c) => c.contains('collection: 9')), isEmpty);
    });

    testWidgets('a listing in a state this build does not know is shown closed, with no clock', (tester) async {
      service.listings = (_, __, ___) => P2pPage(count: 1, next: null, results: [buyNow().copyWith(state: P2pListingState.unknown)]);
      await pump(tester, const P2pShopScreen(url: 'dryrun-demo'));
      expect(find.byKey(const Key('p2p:state:unknown')), findsOneWidget);
      expect(find.text('Closed'), findsOneWidget);
      expect(find.byKey(const Key('p2p:clock')), findsNothing);
    });

    testWidgets('a shop with nothing listed says so', (tester) async {
      service.listings = (_, __, ___) => const P2pPage(count: 0, next: null, results: []);
      await pump(tester, const P2pShopScreen(url: 'dryrun-demo'));
      expect(find.text('Nothing listed right now.'), findsOneWidget);
    });

    testWidgets('a URL with no shop says so', (tester) async {
      await pump(tester, const P2pShopScreen(url: 'nope-nope'));
      expect(find.text('No shop at this address.'), findsOneWidget);
      expect(find.text('vfx://nope-nope'), findsOneWidget);
    });

    testWidgets('marks the owner\'s own shop', (tester) async {
      await pump(tester, const P2pShopScreen(url: 'dryrun-demo'), address: owner);
      expect(find.text('Your shop'), findsOneWidget);
    });
  });
}
