import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/app.dart';
import 'package:rbx_wallet/features/btc/components/withdrawal_processing_dialog.dart';
import 'package:rbx_wallet/features/btc/models/withdrawal_result.dart';
import 'package:rbx_wallet/l10n/generated/app_localizations.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    rootNavigatorKey = GlobalKey<NavigatorState>();
  });

  Future<void> pumpDialog(WidgetTester tester, WithdrawalResult result) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: WithdrawalProcessingDialog(
          scUid: 'sc',
          requestHash: 'req',
          ownerAddress: 'xOwner',
          completeWithdrawalOverride: () async => result,
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('an unpayable failure explains the missing Cancel and drops Retry', (tester) async {
    await pumpDialog(
      tester,
      const WithdrawalResult(success: false, message: 'cannot be paid', unpayable: true),
    );

    expect(find.text('cannot be paid'), findsOneWidget);
    expect(find.byKey(const Key('withdrawal:no-cancel-note')), findsOneWidget);
    expect(find.textContaining('can never be paid at its fee rate'), findsOneWidget);
    expect(find.text('Cancel Withdrawal'), findsNothing);
    expect(find.text('Retry'), findsNothing);
    expect(find.text('Dismiss'), findsOneWidget);
  });

  testWidgets('a failure with no BTC tx explains why there is no Cancel and keeps Retry', (tester) async {
    await pumpDialog(tester, const WithdrawalResult(success: false, message: 'signing failed'));

    expect(find.byKey(const Key('withdrawal:no-cancel-note')), findsOneWidget);
    expect(find.textContaining('No Bitcoin transaction hash was returned'), findsOneWidget);
    expect(find.text('Cancel Withdrawal'), findsNothing);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('a failure with a BTC tx offers Cancel and no note', (tester) async {
    await pumpDialog(
      tester,
      const WithdrawalResult(success: false, message: 'stuck', btcTransactionHash: 'btctx'),
    );

    expect(find.byKey(const Key('withdrawal:no-cancel-note')), findsNothing);
    expect(find.text('Cancel Withdrawal'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
