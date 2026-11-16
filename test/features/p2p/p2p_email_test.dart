import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/api_token_manager.dart';
import 'package:rbx_wallet/core/services/base_service.dart';
import 'package:rbx_wallet/core/singletons.dart';
import 'package:rbx_wallet/core/theme/pretty_icons.dart';
import 'package:rbx_wallet/features/navigation/components/root_container_side_nav_item.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_auth_token.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_error.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_listing.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_shop.dart';
import 'package:rbx_wallet/features/p2p/providers/p2p_sale_notices_provider.dart';
import 'package:rbx_wallet/features/p2p/screens/p2p_listing_screen.dart';
import 'package:rbx_wallet/features/p2p/screens/p2p_my_shop_screen.dart';
import 'package:rbx_wallet/features/p2p/screens/p2p_shop_list_screen.dart';
import 'package:rbx_wallet/features/p2p/services/p2p_email_prompt.dart';
import 'package:rbx_wallet/features/p2p/services/p2p_session.dart';
import 'package:rbx_wallet/features/p2p/utils/p2p_rules.dart';

import 'p2p_test_helpers.dart';

/// The sales waiting to be started, held still.
class _Waiting extends P2pSaleNotices {
  final List<P2pListing> waiting;

  _Waiting(this.waiting);

  @override
  List<P2pListing> build() => waiting;

  @override
  Future<void> poll({bool force = false, DateTime? now}) async {}

  @override
  Future<void> shopsChanged() async {}
}

void main() {
  const owner = 'xJwSHB75g85bfhPLBFJ7JS1QzkDRhNJksJ';
  const newcomer = 'xNewcomerAAAAAAAAAAAAAAAAAAAAAAAAA';
  final now = DateTime.utc(2026, 11, 16, 16);

  P2pShop demoShop() => P2pShop.fromJson(p2pFixture('shop_detail'));

  setUpAll(() {
    if (!singleton.isRegistered<ApiTokenManager>()) {
      singleton.registerSingleton<ApiTokenManager>(ApiTokenManagerImplementation());
    }
    BaseService.suppressErrors = true;
  });

  test('an email has an @ and a dot after it, and nothing else is judged here', () {
    expect(isP2pEmail('seller@example.com'), isTrue);
    expect(isP2pEmail('a.b+shop@mail.example.co'), isTrue);
    for (final bad in ['', 'seller', 'seller@', 'seller@example', '@example.com', 'two words@example.com', 'a@b@c.com']) {
      expect(isP2pEmail(bad), isFalse, reason: bad);
    }
  });

  group('signing in', () {
    test('the answer carries the email Spyglass holds, or none', () {
      final body = {'token': 't', 'address': owner, 'expires_at': '2026-11-16T18:00:00Z'};
      expect(P2pAuthToken.fromJson(body).email, isNull);
      expect(P2pAuthToken.fromJson({...body, 'email': null}).email, isNull);
      expect(P2pAuthToken.fromJson({...body, 'email': ''}).email, isNull);
      expect(P2pAuthToken.fromJson({...body, 'email': 'seller@example.com'}).email, 'seller@example.com');
    });

    test('the session knows the email of an account it signed in, and one given since', () async {
      final service = FakeP2pService()..emails = {owner: 'seller@example.com'};
      final session = P2pSession(service: service, signer: FakeP2pSigner());
      // Not signed in: nothing is known either way.
      expect(session.emailOf(owner), isNull);
      await session.token(owner);
      expect(session.emailOf(owner), 'seller@example.com');

      await session.token(newcomer);
      expect(session.emailOf(newcomer), isNull);
      session.noteEmail(newcomer, 'new@example.com');
      expect(session.emailOf(newcomer), 'new@example.com');
      // The token itself is untouched.
      expect(session.cached(newcomer), 'token-for-$newcomer');
    });
  });

  group('who is asked for an email', () {
    late FakeP2pService service;
    late P2pSession session;
    late FakeP2pEmailAsked asked;
    late List<String> shown;
    late P2pEmailPrompt prompt;

    setUp(() {
      service = FakeP2pService();
      session = P2pSession(service: service, signer: FakeP2pSigner());
      asked = FakeP2pEmailAsked();
      shown = [];
      prompt = P2pEmailPrompt(session: session, asked: asked, show: (address) async => shown.add(address));
    });

    test('an account Spyglass holds no email for, once', () async {
      await session.token(newcomer);
      await prompt.maybeAsk(newcomer);
      await prompt.maybeAsk(newcomer);
      expect(shown, [newcomer]);
      expect(asked.wasAsked(newcomer), isTrue);
    });

    test('not an account Spyglass already holds one for', () async {
      service.emails = {owner: 'seller@example.com'};
      await session.token(owner);
      await prompt.maybeAsk(owner);
      expect(shown, isEmpty);
      // It was not asked, so it would be if the email were ever gone.
      expect(asked.wasAsked(owner), isFalse);
    });

    test('each account for itself', () async {
      await session.token(newcomer);
      await session.token(owner);
      await prompt.maybeAsk(newcomer);
      await prompt.maybeAsk(owner);
      expect(shown, [newcomer, owner]);
    });
  });

  group('the prompt', () {
    late FakeP2pService service;
    late FakeP2pEmailAsked asked;

    setUp(() {
      asked = FakeP2pEmailAsked();
      service = FakeP2pService()..shopsByOwner = {owner: demoShop()};
    });

    Future<void> pump(WidgetTester tester, Widget screen, {String address = owner}) async {
      tester.binding.window.physicalSizeTestValue = const Size(1400, 1400);
      tester.binding.window.devicePixelRatioTestValue = 1;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
      await tester.pumpWidget(p2pTestApp(child: screen, service: service, address: address, now: now, emailAsked: asked));
      await settle(tester);
    }

    Future<void> openShop(WidgetTester tester) async {
      service.onDstr = (tx) {
        final shop = demoShop().copyWith(name: 'Corner Shop', url: 'corner-shop', displayUrl: 'vfx://corner-shop', ownerAddress: newcomer);
        service.shopsByOwner[newcomer] = shop;
        return shop;
      };
      await pump(tester, const P2pMyShopScreen(), address: newcomer);
      await tester.enterText(find.byKey(const Key('p2p:shop_name')), 'Corner Shop');
      await tester.enterText(find.byKey(const Key('p2p:shop_url')), 'corner-shop');
      await tester.pump(const Duration(milliseconds: 400));
      await settle(tester);
      await tester.tap(find.byKey(const Key('p2p:shop_review')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('p2p:step_confirm')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('p2p:step_done')));
      await settle(tester);
    }

    testWidgets('follows opening a shop, and saves the email with the owner\'s token', (tester) async {
      await openShop(tester);
      expect(find.text('Get an email when a sale needs you'), findsOneWidget);

      // Not an email yet.
      await tester.enterText(find.byKey(const Key('p2p:email_field')), 'seller@');
      await tester.tap(find.byKey(const Key('p2p:email_save')));
      await settle(tester);
      expect(find.text('Enter an email address.'), findsOneWidget);
      expect(service.calls.where((c) => c.startsWith('subscribeEmail')), isEmpty);

      await tester.enterText(find.byKey(const Key('p2p:email_field')), ' seller@example.com ');
      await tester.tap(find.byKey(const Key('p2p:email_save')));
      await settle(tester);
      expect(service.calls, contains('subscribeEmail($newcomer, seller@example.com, token: token-for-$newcomer)'));
      expect(find.byKey(const Key('p2p:email_field')), findsNothing);
      expect(find.text('Email saved.'), findsOneWidget);
    });

    testWidgets('can be passed over, and is not shown again', (tester) async {
      await openShop(tester);
      await tester.tap(find.byKey(const Key('p2p:email_skip')));
      await settle(tester);
      expect(find.byKey(const Key('p2p:email_field')), findsNothing);
      expect(service.calls.where((c) => c.startsWith('subscribeEmail')), isEmpty);
      expect(asked.wasAsked(newcomer), isTrue);
    });

    testWidgets('does not follow for an account Spyglass has an email for', (tester) async {
      service.emails = {newcomer: 'known@example.com'};
      await openShop(tester);
      expect(find.byKey(const Key('p2p:email_field')), findsNothing);
    });

    testWidgets('an email Spyglass does not take is said so, and can be tried again', (tester) async {
      await openShop(tester);
      service.emailError = const P2pError(status: 400, code: 'invalid');
      await tester.enterText(find.byKey(const Key('p2p:email_field')), 'seller@example.com');
      await tester.tap(find.byKey(const Key('p2p:email_save')));
      await settle(tester);
      expect(tester.widget<Text>(find.byKey(const Key('p2p:email_error'))).data, 'The email could not be saved. Try again later.');
      expect(find.byKey(const Key('p2p:email_field')), findsOneWidget);
    });

    testWidgets('follows a first bid', (tester) async {
      const viewer = 'xViewerAAAAAAAAAAAAAAAAAAAAAAAAAAA';
      final auction = P2pListing.fromJson(p2pFixture('listing_auction_live'));
      service.listingsById = {2: auction};
      service.onBid = (id, amount, isBuyNow, signature) => P2pBidResult.fromJson(p2pFixture('bid_result'));
      await pump(tester, const P2pListingScreen(id: 2), address: viewer);

      await tester.tap(find.byKey(const Key('p2p:bid_open')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('p2p:bid_submit')));
      await settle(tester);
      // The bid's own result first; the prompt only once that is closed.
      expect(find.byKey(const Key('p2p:email_field')), findsNothing);
      await tester.tap(find.byKey(const Key('p2p:bid_done')));
      await settle(tester);
      expect(find.byKey(const Key('p2p:email_field')), findsOneWidget);
    });

    testWidgets('a bid dialog closed without a bid asks for nothing', (tester) async {
      const viewer = 'xViewerAAAAAAAAAAAAAAAAAAAAAAAAAAA';
      service.listingsById = {2: P2pListing.fromJson(p2pFixture('listing_auction_live'))};
      await pump(tester, const P2pListingScreen(id: 2), address: viewer);
      await tester.tap(find.byKey(const Key('p2p:bid_open')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('p2p:bid_cancel')));
      await settle(tester);
      expect(find.byKey(const Key('p2p:email_field')), findsNothing);
    });

    testWidgets('My shop keeps a way to it, showing the email already held', (tester) async {
      service.emails = {owner: 'seller@example.com'};
      await pump(tester, const P2pMyShopScreen());
      await tester.tap(find.byKey(const Key('p2p:email_add')));
      await settle(tester);
      expect(tester.widget<TextField>(find.byKey(const Key('p2p:email_field'))).controller!.text, 'seller@example.com');
    });
  });

  group('sales waiting to be started are counted', () {
    P2pListing won(int id) => P2pListing.fromJson({...p2pFixture('listing_buy_now'), 'id': id, 'state': 'awaiting_sale_start'});

    testWidgets('beside My shop on the shops screen', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1400, 1000);
      tester.binding.window.devicePixelRatioTestValue = 1;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
      await tester.pumpWidget(p2pTestApp(
        child: const P2pShopListScreen(),
        service: FakeP2pService(),
        now: now,
        overrides: [p2pSaleNoticesProvider.overrideWith(() => _Waiting([won(4), won(7)]))],
      ));
      await settle(tester);
      expect(find.descendant(of: find.byKey(const Key('p2p:sales_to_start')), matching: find.text('2 to start')), findsOneWidget);
    });

    testWidgets('and not shown when none are', (tester) async {
      await tester.pumpWidget(p2pTestApp(
        child: const P2pShopListScreen(),
        service: FakeP2pService(),
        now: now,
        overrides: [p2pSaleNoticesProvider.overrideWith(() => _Waiting(const []))],
      ));
      await settle(tester);
      expect(find.byKey(const Key('p2p:sales_to_start')), findsNothing);
    });

    testWidgets('on a side-nav entry, as a count beside its title', (tester) async {
      Widget item(int count) {
        return MaterialApp(
          home: Scaffold(
            body: RootContainerSideNavItem(
              title: 'Shops',
              onPressed: () {},
              isActive: false,
              isExpanded: true,
              iconType: PrettyIconType.custom,
              icon: Icons.storefront,
              badgeCount: count,
            ),
          ),
        );
      }

      await tester.pumpWidget(item(3));
      expect(find.descendant(of: find.byKey(const Key('nav:badge_count')), matching: find.text('3')), findsOneWidget);
      await tester.pumpWidget(item(0));
      expect(find.byKey(const Key('nav:badge_count')), findsNothing);
    });
  });
}

/// Lets futures (reads, sign-in, the dialog's route) run to their end.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 60));
  }
}
