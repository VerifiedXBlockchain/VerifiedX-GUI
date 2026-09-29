import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/app.dart';
import 'package:rbx_wallet/features/transactions/components/vfx_transaction_filter_button.dart';
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

void main() {
  // `TxHelper.typeName` reads through `globalL10n`; a detached root key makes
  // it fall back to English instead of resolving the router through get_it.
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    rootNavigatorKey = GlobalKey<NavigatorState>();
  });

  testWidgets('filter button is keyed, named by its tooltip and opens the keyed filter sheet', (tester) async {
    await pumpHost(tester, const VfxTransactionFilterButton());

    final button = find.byKey(const Key('tx:filter'));
    expect(button, findsOneWidget);
    expect(find.byTooltip('Transaction Filters'), findsOneWidget);

    final data = tester.getSemantics(button).getSemanticsData();
    expect(data.tooltip, 'Transaction Filters');
    expect(data.hasFlag(SemanticsFlag.isButton), isTrue);
    expect(data.hasAction(SemanticsAction.tap), isTrue);

    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tx:filter_clear')), findsOneWidget);
    expect(find.byKey(const Key('tx:filter_close')), findsOneWidget);
    expect(find.byKey(const Key('tx:filter_address')), findsOneWidget);
    expect(find.byKey(const Key('tx:filter_type_0')), findsOneWidget);

    await tester.tap(find.byKey(const Key('tx:filter_close')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tx:filter_clear')), findsNothing);
  });
}
