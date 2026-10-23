import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/btc/components/btc_utxo_list.dart';
import 'package:rbx_wallet/features/btc/models/btc_utxo.dart';
import 'package:rbx_wallet/l10n/generated/app_localizations.dart';

void main() {
  final spent = BtcUtxo(id: 1, address: 'tb1qpy9', hash: '5a5d55f5', value: 197240, vout: 1, isUsed: false);

  Future<void> pump(WidgetTester tester, Widget tile) => tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: tile),
      ));

  testWidgets("a transaction's input carries no used/unused badge", (tester) async {
    await pump(tester, UtxoListTile(utxo: spent, showUsage: false));

    expect(find.text('Unused'), findsNothing);
    expect(find.text('Used'), findsNothing);
  });

  testWidgets('the UTXO list still shows the badge', (tester) async {
    await pump(tester, UtxoListTile(utxo: spent));

    expect(find.text('Unused'), findsOneWidget);
  });
}
