import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/dialogs.dart';
import 'package:rbx_wallet/l10n/generated/app_localizations.dart';

Future<BuildContext> pumpHost(WidgetTester tester) async {
  late BuildContext hostContext;
  await tester.pumpWidget(ProviderScope(
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(builder: (context) {
        hostContext = context;
        return const SizedBox();
      }),
    ),
  ));
  await tester.pumpAndSettle();
  return hostContext;
}

const fieldKey = ValueKey('auth:password');
const submitKey = Key('auth:password_submit');

void main() {
  testWidgets('applies fieldKey and submitKey to the field and confirm button', (tester) async {
    final context = await pumpHost(tester);

    final result = PromptModal.show(
      contextOverride: context,
      title: 'Unlock',
      labelText: 'Password',
      validator: (_) => null,
      fieldKey: fieldKey,
      submitKey: submitKey,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(fieldKey), findsOneWidget);
    expect(find.byKey(submitKey), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Submit'), findsOneWidget);

    // The keyed submit button drives the same path as before: the dialog pops
    // with the field's value.
    await tester.enterText(find.byKey(fieldKey), 'hunter2');
    await tester.tap(find.byKey(submitKey));
    await tester.pumpAndSettle();

    expect(await result, 'hunter2');
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('leaves the field and confirm button unkeyed by default', (tester) async {
    final context = await pumpHost(tester);

    PromptModal.show(
      contextOverride: context,
      title: 'Unlock',
      labelText: 'Password',
      validator: (_) => null,
    );
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.byKey(fieldKey), findsNothing);
    expect(find.byKey(submitKey), findsNothing);
  });
}
