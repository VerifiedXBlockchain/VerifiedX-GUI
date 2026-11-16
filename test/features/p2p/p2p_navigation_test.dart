import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/app_router.gr.dart';
import 'package:rbx_wallet/features/navigation/constants.dart';
import 'package:rbx_wallet/features/navigation/root_container.dart';
import 'package:rbx_wallet/features/p2p/components/p2p_dry_run_banner.dart';
import 'package:rbx_wallet/l10n/generated/app_localizations.dart';

void main() {
  group('desktop root tabs', () {
    test('the shops tab is the last tab when the P2P shop is on', () {
      final tabs = desktopRootTabs(p2pEnabled: true);
      expect(tabs, hasLength(DESKTOP_P2P_SHOPS_TAB_INDEX + 1));
      expect(tabs[DESKTOP_P2P_SHOPS_TAB_INDEX], isA<P2pTabRouter>());
    });

    test('there is no shops tab when the P2P shop is off', () {
      final tabs = desktopRootTabs(p2pEnabled: false);
      expect(tabs, hasLength(DESKTOP_P2P_SHOPS_TAB_INDEX));
      expect(tabs.whereType<P2pTabRouter>(), isEmpty);
    });

    test('every other tab keeps its index either way, the old shop included', () {
      final off = desktopRootTabs(p2pEnabled: false).map((r) => r.routeName).toList();
      final on = desktopRootTabs(p2pEnabled: true).map((r) => r.routeName).toList();
      expect(on.sublist(0, off.length), off);
      expect(off[9], DstsTabRouter.name);
    });
  });

  group('routes', () {
    test('a shop page is addressed by its URL and a listing by its id', () {
      expect(const P2pTabRouter().path, 'p2p');
      expect(P2pShopScreenRoute(url: 'dryrun-demo').path, 'shop/:url');
      expect(P2pShopScreenRoute(url: 'dryrun-demo').rawPathParams, {'url': 'dryrun-demo'});
      expect(P2pListingScreenRoute(id: 7).path, 'listing/:id');
      expect(P2pListingScreenRoute(id: 7).rawPathParams, {'id': 7});
    });

    test('the web build\'s router does not reach the new shop screens', () {
      // Its own "p2p" path is the old web shop, which is left as it is.
      final webRouter = File('lib/core/web_router.dart').readAsStringSync();
      expect(webRouter, isNot(contains('features/p2p/')));
      expect(webRouter, isNot(contains('P2pShop')));
      expect(webRouter, isNot(contains('P2pListing')));
    });
  });

  testWidgets('the dry-run banner says nothing is signed or sent', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: P2pDryRunBanner()),
    ));
    expect(find.byKey(const Key('p2p:dry_run_banner')), findsOneWidget);
    expect(find.textContaining('Dry run', findRichText: true), findsOneWidget);
    expect(find.textContaining('Nothing is signed into a transaction or sent to the network', findRichText: true), findsOneWidget);
  });
}
