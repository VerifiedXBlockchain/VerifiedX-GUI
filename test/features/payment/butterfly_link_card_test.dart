import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/app.dart';
import 'package:rbx_wallet/features/payment/components/butterfly_link_card.dart';
import 'package:rbx_wallet/features/payment/models/butterfly_link.dart';
import 'package:rbx_wallet/l10n/generated/app_localizations.dart';

Future<void> pumpHost(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(ProviderScope(
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  ));
  await tester.pumpAndSettle();
}

final claimedLink = ButterflyLink(
  linkId: 'link-1',
  shortUrl: 'https://vfx.link/abc',
  fullUrl: 'https://vfx.link/abc?full=1',
  escrowAddress: 'RBxEscrow',
  amount: 1.5,
  claimAmount: 1.25,
  message: 'Happy birthday',
  icon: ButterflyIcon.gift,
  status: ButterflyLinkStatus.claimed,
  senderAddress: 'RBxSender',
  createdAt: DateTime(2026, 1, 1),
);

void main() {
  // The status badge reads through `globalL10n`; a detached root key makes it
  // fall back to English instead of resolving the router through get_it.
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    rootNavigatorKey = GlobalKey<NavigatorState>();
  });

  testWidgets('link card is a button named by its visible amount and message', (tester) async {
    var taps = 0;
    await pumpHost(
      tester,
      ButterflyLinkCard(link: claimedLink, onTap: () => taps++),
    );

    final wrapper = find
        .descendant(
          of: find.byType(ButterflyLinkCard),
          matching: find.byType(Semantics),
        )
        .first;
    final data = tester.getSemantics(wrapper).getSemanticsData();
    // No explicit label: the amount and message are the accessible name.
    expect(data.label, contains('1.25 VFX'));
    expect(data.label, contains('Happy birthday'));
    expect(data.hasFlag(SemanticsFlag.isButton), isTrue);
    expect(data.hasAction(SemanticsAction.tap), isTrue);

    await tester.tap(wrapper);
    expect(taps, 1);
  });
}
