import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/token/screens/token_management_screen.dart';
import 'package:rbx_wallet/l10n/generated/app_localizations.dart';

Future<void> pumpHost(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('copyable row exposes its copy icon as a button named "Copy"', (tester) async {
    await pumpHost(
      tester,
      const TokenDetailRow(label: 'Owner', value: 'RAbc123', copyable: true),
    );

    // The tile has no tap of its own, so the labelled copy icon merges into it
    // (one node: value, label and "Copy") and gives the whole row the button role.
    final data = tester.getSemantics(find.byIcon(Icons.copy)).getSemanticsData();
    expect(data.label, contains('Copy'));
    expect(data.label, contains('RAbc123'));
    expect(data.hasFlag(SemanticsFlag.isButton), isTrue);
    expect(data.hasAction(SemanticsAction.tap), isTrue);
  });

  testWidgets('non-copyable row is not a button', (tester) async {
    await pumpHost(
      tester,
      const TokenDetailRow(label: 'Owner', value: 'RAbc123'),
    );

    expect(find.byIcon(Icons.copy), findsNothing);
    final data = tester.getSemantics(find.text('RAbc123')).getSemanticsData();
    expect(data.hasFlag(SemanticsFlag.isButton), isFalse);
    expect(data.hasAction(SemanticsAction.tap), isFalse);
  });
}
