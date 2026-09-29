import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/app.dart';
import 'package:rbx_wallet/features/btc/components/btc_adnr_card.dart';
import 'package:rbx_wallet/features/btc/providers/btc_adnr_create_form_provider.dart';
import 'package:rbx_wallet/l10n/generated/app_localizations.dart';

void main() {
  // The name validator reads through `globalL10n`; a detached root key makes
  // it fall back to English instead of resolving the router through get_it.
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    rootNavigatorKey = GlobalKey<NavigatorState>();
  });

  Future<ProviderContainer> pumpSheet(WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(btcAdnrCreateFormProvider.notifier).initWithData(btcAddress: 'tb1qexampleaddress');

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: Text('home')),
      ),
    ));
    // Push the sheet over a home route so a wrong pop() would be visible.
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.push(MaterialPageRoute(
      builder: (_) => const Scaffold(body: SingleChildScrollView(child: CreateBtcAdnrModal())),
    ));
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('an empty name shows the field error and no success toast', (tester) async {
    await pumpSheet(tester);

    await tester.tap(find.text('Create BTC Domain'));
    await tester.pumpAndSettle();

    expect(find.text('Domain Name Required'), findsOneWidget);
    expect(find.text('Transaction Broadcasted!'), findsNothing);
    expect(find.byType(CreateBtcAdnrModal), findsOneWidget);
  });

  testWidgets('an invalid name shows the field error and no success toast', (tester) async {
    final container = await pumpSheet(tester);
    container.read(btcAdnrCreateFormProvider.notifier).nameController.text = 'qa-bad';

    await tester.tap(find.text('Create BTC Domain'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid domain. Must only contain letters and/or numbers.'), findsOneWidget);
    expect(find.text('Transaction Broadcasted!'), findsNothing);
    expect(find.byType(CreateBtcAdnrModal), findsOneWidget);
  });
}
