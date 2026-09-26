import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/token/components/token_list_tile.dart';
import 'package:rbx_wallet/features/token/models/token_account.dart';
import 'package:rbx_wallet/l10n/generated/app_localizations.dart';

const account = TokenAccount(
  smartContractId: 'sc-1',
  name: 'Test Token',
  ticker: 'TKR',
  balance: 12.5,
  lockedBalance: 0,
  decimalPlaces: 2,
);

Future<void> pumpHost(WidgetTester tester, {required bool interactive}) async {
  await tester.pumpWidget(ProviderScope(
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: TokenListTile(
          address: 'RBxHolder0001',
          tokenAccount: account,
          token: null,
          interactive: interactive,
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('an interactive token row is a button named by its visible title', (tester) async {
    await pumpHost(tester, interactive: true);

    expect(find.bySemanticsLabel(RegExp(r'^\[TKR\] Test Token')), findsOneWidget);

    final data = tester.getSemantics(find.byType(ListTile)).getSemanticsData();
    expect(data.label, startsWith('[TKR] Test Token'));
    expect(data.label, contains('Balance: 12.5'));
    expect(data.hasFlag(SemanticsFlag.isButton), isTrue);
    expect(data.hasAction(SemanticsAction.tap), isTrue);
  });

  testWidgets('a non-interactive token row is not a button', (tester) async {
    await pumpHost(tester, interactive: false);

    final data = tester.getSemantics(find.byType(ListTile)).getSemanticsData();
    expect(data.hasFlag(SemanticsFlag.isButton), isFalse);
    expect(data.hasAction(SemanticsAction.tap), isFalse);
  });
}
