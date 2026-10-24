import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/btc/models/vbtc_withdrawal_part.dart';
import 'package:rbx_wallet/features/btc/screens/vbtc_multi_withdrawal_screen.dart';
import 'package:rbx_wallet/features/btc_web/utils/vbtc_multi_withdrawal.dart';
import 'package:rbx_wallet/l10n/generated/app_localizations.dart';
import 'package:rbx_wallet/l10n/generated/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();

  testWidgets('shows every part, the fee per part and in total, and what arrives', (tester) async {
    final plan = planVbtcMultiWithdrawal({'small:1': 0.00002, 'big:2': 0.00005}, 0.00007, 3);
    const parts = [
      VbtcWithdrawalPart(scIdentifier: 'big:2', name: 'Vault A', amount: 0.00005),
      VbtcWithdrawalPart(scIdentifier: 'small:1', name: 'Vault B', amount: 0.00002),
    ];

    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: VbtcMultiWithdrawalSummary(parts: parts, plan: plan, btcAddress: 'tb1qdest'),
      ),
    ));

    expect(find.text('To: tb1qdest'), findsOneWidget);
    expect(find.text('Fee rate: 3 sat/vB'), findsOneWidget);
    expect(find.text('Part 1 · Vault A: 0.00005 vBTC'), findsOneWidget);
    expect(find.text('Part 2 · Vault B: 0.00002 vBTC'), findsOneWidget);
    expect(find.text('Bitcoin fee per part: at least 462 sats (0.00000462 BTC), taken out of that part'), findsOneWidget);
    expect(find.text('Total Bitcoin fees: at least 924 sats (0.00000924 BTC) for 2 parts'), findsOneWidget);
    expect(find.text('Arrives at the address: about 0.00006076 BTC'), findsOneWidget);
  });

  group('vbtcWithdrawalPlanError', () {
    test('names the part under the floor and the minimum', () {
      final plan = planVbtcMultiWithdrawal({'small:1': 0.00002, 'big:2': 0.00005}, 0.000054, 3);

      expect(
        vbtcWithdrawalPlanError(l10n, plan, 0.000054),
        'Part 2 would be 0.000004 BTC, below the Bitcoin fee floor at 3 sat/vB (each part needs at least 0.00001008 BTC). Lower the fee rate or the amount.',
      );
    });

    test('says when the amount needs more than 10 vaults', () {
      final balances = {for (var i = 0; i < 11; i++) 'c:$i': 0.0001};
      final plan = planVbtcMultiWithdrawal(balances, 0.0011, 1);

      expect(vbtcWithdrawalPlanError(l10n, plan, 0.0011), 'This amount needs more than 10 vaults. Withdraw a smaller amount.');
    });
  });
}
