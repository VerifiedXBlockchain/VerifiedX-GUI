import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/api_token_manager.dart';
import 'package:rbx_wallet/core/singletons.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_error.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_listing.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_me.dart';
import 'package:rbx_wallet/features/p2p/screens/p2p_my_bids_screen.dart';

import 'p2p_test_helpers.dart';

void main() {
  // The bidder of the fixture's /me/.
  const me = 'xBidderAAAAAAAAAAAAAAAAAAAAAAAAAAA';
  final now = DateTime.utc(2026, 11, 16, 17);

  late FakeP2pService service;
  late FakeP2pSigner signer;

  setUpAll(() {
    if (!singleton.isRegistered<ApiTokenManager>()) {
      singleton.registerSingleton<ApiTokenManager>(ApiTokenManagerImplementation());
    }
  });

  setUp(() {
    signer = FakeP2pSigner();
    service = FakeP2pService()..onMe = (_) => P2pMe.fromJson(p2pFixture('me'));
  });

  Future<void> pump(WidgetTester tester, {String? address = me}) async {
    tester.binding.window.physicalSizeTestValue = const Size(1400, 1000);
    tester.binding.window.devicePixelRatioTestValue = 1;
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    await tester.pumpWidget(p2pTestApp(child: const P2pMyBidsScreen(), service: service, signer: signer, address: address, now: now));
    for (var i = 0; i < 5; i++) {
      await tester.pump();
    }
  }

  testWidgets('signs the account in and shows where it stands on each listing', (tester) async {
    await pump(tester);

    // Reading /me/ took a sign-in: a message signed for this account.
    expect(signer.signed.single[1], me);
    expect(service.calls, contains('me(token-for-$me)'));

    // A purchase to complete: the sale has started for this buyer.
    final toPay = find.byKey(const Key('p2p:buying:3'));
    expect(find.descendant(of: toPay, matching: find.byKey(const Key('p2p:buying_status:pay'))), findsOneWidget);
    expect(find.descendant(of: toPay, matching: find.text('Complete your purchase')), findsOneWidget);
    expect(find.descendant(of: toPay, matching: find.text('The seller has started the sale. Pay to take ownership.')), findsOneWidget);
    expect(find.descendant(of: toPay, matching: find.text('Your bid')), findsOneWidget);
    expect(find.byKey(const Key('p2p:complete_purchase:3')), findsOneWidget);

    // An auction where someone bid higher.
    final outbid = find.byKey(const Key('p2p:buying:2'));
    expect(find.descendant(of: outbid, matching: find.byKey(const Key('p2p:buying_status:outbid'))), findsOneWidget);
    expect(find.descendant(of: outbid, matching: find.text('Someone bid higher.')), findsOneWidget);
    expect(find.descendant(of: outbid, matching: find.text('2.5 VFX')), findsOneWidget);
    expect(find.descendant(of: outbid, matching: find.text('Current bid')), findsOneWidget);
    expect(find.descendant(of: outbid, matching: find.text('3.5 VFX')), findsOneWidget);
    expect(find.byKey(const Key('p2p:complete_purchase:2')), findsNothing);
  });

  testWidgets('completes a purchase from the list as a dry run, and reads the list again', (tester) async {
    final pending = P2pListing.fromJson(p2pFixture('listing_sale_pending'));
    service.onSaleComplete = (_, __) => pending.copyWith(state: P2pListingState.sold, soldPrice: '5');
    await pump(tester);
    final readsBefore = service.calls.where((c) => c.startsWith('me(')).length;

    await tester.tap(find.byKey(const Key('p2p:complete_purchase:3')));
    for (var i = 0; i < 6; i++) {
      await tester.pump();
    }
    expect(find.byKey(const Key('p2p:step_dry_run')), findsOneWidget);
    expect(find.text('Sale_Complete()'), findsOneWidget);

    await tester.tap(find.byKey(const Key('p2p:step_confirm')));
    for (var i = 0; i < 6; i++) {
      await tester.pump();
    }
    expect(service.calls, contains('dryRunSaleComplete(3, token: token-for-$me)'));
    expect(find.text('Recorded as a dry run'), findsOneWidget);

    await tester.tap(find.byKey(const Key('p2p:step_done')));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(service.calls.where((c) => c.startsWith('me(')).length, readsBefore + 1);
  });

  testWidgets('withholds a purchase whose sale asks more than the account bid', (tester) async {
    final json = p2pFixture('me');
    final first = ((json['buying'] as List).first as Map<String, dynamic>)['listing'] as Map<String, dynamic>;
    (((first['sale'] as Map)['start'] as Map)['data'] as Map)['SoldFor'] = '8';
    service.onMe = (_) => P2pMe.fromJson(json);
    await pump(tester);

    expect(find.byKey(const Key('p2p:purchase_over_bid')), findsOneWidget);
    expect(find.byKey(const Key('p2p:complete_purchase:3')), findsNothing);
  });

  testWidgets('an account with no bids says so', (tester) async {
    service.onMe = (_) => const P2pMe();
    await pump(tester);
    expect(find.text('No bids from this account yet.'), findsOneWidget);
  });

  testWidgets('with no account selected nothing is read and nothing is signed', (tester) async {
    await pump(tester, address: null);
    expect(find.text('Choose a VFX account to see its bids.'), findsOneWidget);
    expect(signer.signed, isEmpty);
    expect(service.calls.where((c) => c.startsWith('me(')), isEmpty);
  });

  testWidgets('a Vault account is told it cannot bid, without a sign-in', (tester) async {
    await pump(tester, address: 'xRBXvaultAAAAAAAAAAAAAAAAAAAAAAAAA');
    expect(find.text('A Vault account cannot bid or buy, so it has no bids.'), findsOneWidget);
    expect(signer.signed, isEmpty);
  });

  testWidgets('a failed read is worded and can be retried', (tester) async {
    service.error = const P2pError(status: null, code: P2pError.unreachable);
    await pump(tester);
    expect(find.text('Could not reach the shop registry. Check your connection and try again.'), findsOneWidget);

    service.error = null;
    await tester.tap(find.byKey(const Key('p2p:retry')));
    for (var i = 0; i < 5; i++) {
      await tester.pump();
    }
    expect(find.byKey(const Key('p2p:buying:3')), findsOneWidget);
  });
}
