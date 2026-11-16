import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/api_token_manager.dart';
import 'package:rbx_wallet/core/singletons.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_error.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_shop.dart';
import 'package:rbx_wallet/features/p2p/screens/p2p_my_shop_screen.dart';

import 'p2p_test_helpers.dart';

void main() {
  const owner = 'xJwSHB75g85bfhPLBFJ7JS1QzkDRhNJksJ';
  const newcomer = 'xNewcomerAAAAAAAAAAAAAAAAAAAAAAAAA';
  final now = DateTime.utc(2026, 11, 16, 17);

  late FakeP2pService service;
  late FakeP2pSigner signer;

  P2pShop demoShop() => P2pShop.fromJson(p2pFixture('shop_detail'));

  setUpAll(() {
    if (!singleton.isRegistered<ApiTokenManager>()) {
      singleton.registerSingleton<ApiTokenManager>(ApiTokenManagerImplementation());
    }
  });

  setUp(() {
    signer = FakeP2pSigner();
    service = FakeP2pService()..shopsByOwner = {owner: demoShop()};
  });

  Future<void> pump(WidgetTester tester, {String? address, double balance = 100}) async {
    tester.binding.window.physicalSizeTestValue = const Size(1400, 1100);
    tester.binding.window.devicePixelRatioTestValue = 1;
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    await tester.pumpWidget(p2pTestApp(child: const P2pMyShopScreen(), service: service, signer: signer, address: address, balance: balance, now: now));
    await settle(tester);
  }

  testWidgets('with no account selected nothing is read', (tester) async {
    await pump(tester, address: null);
    expect(find.text('Choose a VFX account to use the shop.'), findsOneWidget);
    expect(service.calls, isEmpty);
  });

  testWidgets('a Vault account is told it cannot have a shop', (tester) async {
    await pump(tester, address: 'xRBXvaultAAAAAAAAAAAAAAAAAAAAAAAAA');
    expect(find.text('A Vault account cannot have a shop or buy in one.'), findsOneWidget);
    expect(service.calls, isEmpty);
  });

  group('an account with no shop', () {
    testWidgets('sees the form that opens one, and what it costs', (tester) async {
      await pump(tester, address: newcomer);
      expect(service.calls, contains('ownerShop($newcomer)'));
      expect(find.byKey(const Key('p2p:register_shop')), findsOneWidget);
      final cost = find.byKey(const Key('p2p:register_cost'));
      expect(find.descendant(of: cost, matching: find.text('10 VFX')), findsOneWidget);
      expect(find.descendant(of: cost, matching: find.textContaining('no VFX moves')), findsOneWidget);
      // Reading whether it has a shop needs no sign-in.
      expect(signer.signed, isEmpty);
    });

    testWidgets('opens a shop: the address is checked, the transaction shown, and the dry run recorded', (tester) async {
      service.onDstr = (tx) {
        final record = tx.data['DecShop'] as Map<String, dynamic>;
        final shop = demoShop().copyWith(name: record['Name'] as String, url: record['DecShopURL'] as String, displayUrl: "vfx://${record['DecShopURL']}", ownerAddress: newcomer);
        service.shopsByOwner[newcomer] = shop;
        return shop;
      };
      await pump(tester, address: newcomer);

      await tester.enterText(find.byKey(const Key('p2p:shop_name')), 'Corner Shop');
      await tester.enterText(find.byKey(const Key('p2p:shop_url')), 'Corner-Shop');
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byKey(const Key('p2p:shop_url_checking')), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 400));
      await settle(tester);
      expect(service.calls, contains('urlAvailability(corner-shop)'));
      expect(tester.widget<Text>(find.byKey(const Key('p2p:shop_url_free'))).data, 'vfx://corner-shop is free.');

      await tester.tap(find.byKey(const Key('p2p:shop_review')));
      await settle(tester);

      // The confirmation: a DSTR, 10 VFX to DecShop_Base, marked as a dry run.
      expect(find.byKey(const Key('p2p:step_dry_run')), findsOneWidget);
      final tx = find.byKey(const Key('p2p:step_transaction'));
      expect(find.descendant(of: tx, matching: find.text('DSTR (7)')), findsOneWidget);
      expect(find.descendant(of: tx, matching: find.text('DecShopCreate()')), findsOneWidget);
      expect(find.descendant(of: tx, matching: find.text('DecShop_Base')), findsOneWidget);
      expect(find.descendant(of: tx, matching: find.text('10 VFX')), findsOneWidget);
      expect(find.descendant(of: tx, matching: find.text('corner-shop')), findsOneWidget);
      expect(service.dryRuns, isEmpty);

      await tester.tap(find.byKey(const Key('p2p:step_confirm')));
      await settle(tester);
      expect(service.calls, contains('dryRunDstr(DecShopCreate(), token: token-for-$newcomer)'));
      final sent = service.dryRuns.single;
      expect(sent.fromAddress, newcomer);
      expect((sent.data['DecShop'] as Map)['OwnerAddress'], newcomer);
      expect(find.text('Recorded as a dry run'), findsOneWidget);

      await tester.tap(find.byKey(const Key('p2p:step_done')));
      await settle(tester);
      // The account now has a shop: the form gives way to it.
      expect(find.byKey(const Key('p2p:register_shop')), findsNothing);
      expect(find.byKey(const Key('p2p:shop_header')), findsOneWidget);
      expect(find.text('Corner Shop'), findsOneWidget);
    });

    testWidgets('cannot review an address another shop holds, or fields outside the limits', (tester) async {
      service.takenUrls = {'dryrun-demo'};
      await pump(tester, address: newcomer);

      // Nothing typed.
      await tester.tap(find.byKey(const Key('p2p:shop_review')));
      await settle(tester);
      expect(find.text('Required'), findsNWidgets(2));
      expect(find.byKey(const Key('p2p:step_transaction')), findsNothing);

      await tester.enterText(find.byKey(const Key('p2p:shop_name')), 'Copycat');
      await tester.enterText(find.byKey(const Key('p2p:shop_url')), 'dryrun-demo');
      await tester.pump(const Duration(milliseconds: 400));
      await settle(tester);
      expect(find.text('This address is taken.'), findsOneWidget);
      await tester.tap(find.byKey(const Key('p2p:shop_review')));
      await settle(tester);
      expect(find.byKey(const Key('p2p:step_transaction')), findsNothing);

      await tester.enterText(find.byKey(const Key('p2p:shop_url')), '9lives');
      await tester.pump(const Duration(milliseconds: 400));
      await settle(tester);
      expect(find.textContaining('Start with a letter'), findsOneWidget);
      expect(service.calls, isNot(contains('urlAvailability(9lives)')));
    });

    testWidgets('an address the registry could not be asked about still goes to review', (tester) async {
      await pump(tester, address: newcomer);
      service.error = const P2pError(status: null, code: P2pError.unreachable);
      await tester.enterText(find.byKey(const Key('p2p:shop_name')), 'Corner Shop');
      await tester.enterText(find.byKey(const Key('p2p:shop_url')), 'corner-shop');
      await tester.pump(const Duration(milliseconds: 400));
      await settle(tester);
      expect(find.textContaining('Could not check the address'), findsOneWidget);

      service.error = null;
      await tester.tap(find.byKey(const Key('p2p:shop_review')));
      await settle(tester);
      expect(find.byKey(const Key('p2p:step_transaction')), findsOneWidget);
    });

    testWidgets('is told when its balance is under what opening a shop takes', (tester) async {
      await pump(tester, address: newcomer, balance: 3.5);
      expect(tester.widget<Text>(find.byKey(const Key('p2p:register_short'))).data, 'This account holds 3.5 VFX. Opening a shop takes 10 VFX plus the network fee.');
    });
  });

  group('the owner of a shop', () {
    testWidgets('sees it, with view, edit and delete', (tester) async {
      await pump(tester, address: owner);
      expect(find.byKey(const Key('p2p:shop_header')), findsOneWidget);
      expect(find.text('Dry Run Demo'), findsOneWidget);
      expect(find.text('Your shop'), findsOneWidget);
      expect(find.byKey(const Key('p2p:my_shop_view')), findsOneWidget);
      expect(find.byKey(const Key('p2p:my_shop_edit')), findsOneWidget);
      expect(find.byKey(const Key('p2p:my_shop_delete')), findsOneWidget);
      expect(find.byKey(const Key('p2p:register_shop')), findsNothing);
    });

    testWidgets('changes it: the cost is said, and the update is confirmed as a transaction', (tester) async {
      // Changed 34 minutes ago (15:26 to 17:00): within the 12 hours that cost 1 VFX.
      service.onDstr = (tx) => demoShop().copyWith(name: (tx.data['DecShop'] as Map)['Name'] as String);
      await pump(tester, address: owner);
      await tester.tap(find.byKey(const Key('p2p:my_shop_edit')));
      await settle(tester);

      expect(tester.widget<Text>(find.byKey(const Key('p2p:shop_edit_cost'))).data, contains('this change costs 1 VFX'));
      // Its own address is not "taken", and nothing is asked about it.
      expect(find.text('This address is taken.'), findsNothing);
      expect(service.calls.where((c) => c.startsWith('urlAvailability')), isEmpty);

      // Nothing changed yet.
      await tester.tap(find.byKey(const Key('p2p:shop_review')));
      await settle(tester);
      expect(find.byKey(const Key('p2p:shop_unchanged')), findsOneWidget);

      await tester.enterText(find.byKey(const Key('p2p:shop_name')), 'Dry Run Demo Two');
      await tester.tap(find.byKey(const Key('p2p:shop_review')));
      await settle(tester);

      final tx = find.byKey(const Key('p2p:step_transaction'));
      expect(find.descendant(of: tx, matching: find.text('DecShopUpdate()')), findsOneWidget);
      expect(find.descendant(of: tx, matching: find.text('1 VFX')), findsOneWidget);
      // The shop keeps its UniqueId.
      expect(find.descendant(of: tx, matching: find.text('XrfHqDCQVJ1794842795')), findsOneWidget);

      await tester.tap(find.byKey(const Key('p2p:step_confirm')));
      await settle(tester);
      expect(service.calls, contains('dryRunDstr(DecShopUpdate(), token: token-for-$owner)'));
    });

    testWidgets('an update more than 12 hours after the last change is free', (tester) async {
      service.shopsByOwner[owner] = demoShop().copyWith(updatedAt: now.subtract(const Duration(hours: 13)));
      await pump(tester, address: owner);
      await tester.tap(find.byKey(const Key('p2p:my_shop_edit')));
      await settle(tester);
      expect(tester.widget<Text>(find.byKey(const Key('p2p:shop_edit_cost'))).data, contains('free right now'));
    });

    testWidgets('deletes it, warned of what goes with it', (tester) async {
      service.onDstr = (tx) {
        service.shopsByOwner.remove(owner);
        return demoShop().copyWith(chainState: P2pShopChainState.deleted);
      };
      await pump(tester, address: owner);
      await tester.tap(find.byKey(const Key('p2p:my_shop_delete')));
      await settle(tester);

      final warning = tester.widget<Text>(find.byKey(const Key('p2p:step_warning'))).data!;
      expect(warning, contains('The shop and its address are released. On chain this costs 1 VFX.'));
      expect(warning, contains('Its live listings end with it.'));
      final tx = find.byKey(const Key('p2p:step_transaction'));
      expect(find.descendant(of: tx, matching: find.text('DecShopDelete()')), findsOneWidget);

      await tester.tap(find.byKey(const Key('p2p:step_confirm')));
      await settle(tester);
      expect(service.calls, contains('dryRunDstr(DecShopDelete(), token: token-for-$owner)'));
      expect(service.dryRuns.single.data, {'Function': 'DecShopDelete()', 'UniqueId': 'XrfHqDCQVJ1794842795'});

      await tester.tap(find.byKey(const Key('p2p:step_done')));
      await settle(tester);
      // With the shop gone the account can open one again.
      expect(find.byKey(const Key('p2p:register_shop')), findsOneWidget);
    });

    testWidgets('a refusal from the registry is shown in words', (tester) async {
      service.dryRunError = const P2pError(status: 409, code: 'shop_on_chain', message: 'This shop is registered on chain; a dry run cannot change it.');
      await pump(tester, address: owner);
      await tester.tap(find.byKey(const Key('p2p:my_shop_delete')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('p2p:step_confirm')));
      await settle(tester);
      expect(tester.widget<Text>(find.byKey(const Key('p2p:step_error'))).data, 'This shop is registered on chain, so a dry run cannot change it.');
    });
  });
}

/// Lets futures (reads, sign-in, the dialog's route) run to their end.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 60));
  }
}
