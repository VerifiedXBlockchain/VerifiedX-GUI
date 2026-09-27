import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/app.dart';
import 'package:rbx_wallet/features/global_loader/global_loading_provider.dart';
import 'package:rbx_wallet/features/token/components/transfer_tokens_button.dart';
import 'package:rbx_wallet/l10n/generated/app_localizations.dart';

// A vault-style address passes formValidatorRbxAddress without reading Env.
const holder = 'xRBXAbCdEfGhIjKlMnOpQrStUvWxYz1234';

void main() {
  setUpAll(() {
    rootNavigatorKey = GlobalKey<NavigatorState>();
  });

  testWidgets('refuses a transfer to the holder\'s own address before sending', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        navigatorKey: rootNavigatorKey,
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: TransferTokensButton(scId: 'sc-1', fromAddress: holder, currentBalance: 10),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('token:transfer')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '1');
    await tester.tap(find.widgetWithText(TextButton, 'Submit'));
    await tester.pumpAndSettle();

    // Same address in lower case: the node would refuse it too.
    await tester.enterText(find.byType(TextFormField), holder.toLowerCase().replaceFirst('xrbx', 'xRBX'));
    await tester.tap(find.widgetWithText(TextButton, 'Submit'));
    await tester.pumpAndSettle();

    expect(find.text('Tokens cannot be transferred to the address that holds them.'), findsOneWidget);
    // The transfer never started, so the global loader was never shown.
    expect(container.read(globalLoadingProvider), isFalse);
  });
}
