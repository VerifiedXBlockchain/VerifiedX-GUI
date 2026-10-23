import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/app.dart';
import 'package:rbx_wallet/features/btc_web/models/watched_withdrawal.dart';
import 'package:rbx_wallet/features/btc/components/withdrawal_processing_dialog.dart';
import 'package:rbx_wallet/features/btc/models/withdrawal_result.dart';
import 'package:rbx_wallet/l10n/generated/app_localizations.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    rootNavigatorKey = GlobalKey<NavigatorState>();
  });

  Future<void> pumpDialog(
    WidgetTester tester,
    WithdrawalResult result, {
    WatchedWithdrawal? watched,
    void Function()? onComplete,
  }) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: WithdrawalProcessingDialog(
          scUid: 'sc',
          requestHash: 'req',
          ownerAddress: 'xOwner',
          completeWithdrawalOverride: () async {
            onComplete?.call();
            return result;
          },
          watchedWithdrawalOverride: () async => watched,
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

  group('a vault the chain watches', () {
    // A pinned dialog refreshes on a timer while mounted; unmount it so the
    // timer is disposed inside the test.
    Future<void> unmount(WidgetTester tester) => tester.pumpWidget(const SizedBox.shrink());

    const pinned = WatchedWithdrawal(
      status: 'Awaiting_BTC_Confirmation',
      paid: false,
      notMinedYet: false,
      state: 'Pinned',
      requester: 'xOwner',
      feeRate: 8,
      canRaiseFee: true,
      canRelease: true,
      pinnedBtcTxHash: '80b89ae9',
    );

    testWidgets('a pinned withdrawal shows its txid, fee rate, Raise Fee and Release, and never calls CompleteWithdrawal', (tester) async {
      var completeCalls = 0;
      await pumpDialog(
        tester,
        const WithdrawalResult(success: true),
        watched: pinned,
        onComplete: () => completeCalls++,
      );

      expect(completeCalls, 0);
      expect(find.text('Withdrawal in Progress'), findsOneWidget);
      expect(find.textContaining('is fixed. The vault'), findsOneWidget);
      expect(find.text('80b89ae9'), findsOneWidget);
      expect(find.text('Current fee rate: 8 sat/vB'), findsOneWidget);
      expect(find.text('Raise Fee'), findsOneWidget);
      expect(find.text('Release'), findsOneWidget);
      expect(find.text('Withdrawal completed successfully!'), findsNothing);
      expect(find.textContaining('FROST'), findsNothing);
      await unmount(tester);
    });

    testWidgets('a CompleteWithdrawal answer for a watched vault shows its state, not completion', (tester) async {
      await pumpDialog(
        tester,
        const WithdrawalResult(success: true, watched: pinned, btcTransactionHash: '80b89ae9'),
      );

      expect(find.text('Withdrawal in Progress'), findsOneWidget);
      expect(find.text('Raise Fee'), findsOneWidget);
      expect(find.text('Withdrawal completed successfully!'), findsNothing);
      await unmount(tester);
    });

    testWidgets('a fee rate not above the current one is refused before anything is sent', (tester) async {
      await pumpDialog(tester, const WithdrawalResult(success: true), watched: pinned);

      await tester.enterText(find.byKey(const Key('withdrawal:watched-fee-rate')), '8');
      await tester.tap(find.text('Raise Fee'));
      await tester.pump();

      expect(find.text('At least 9 sat/vB'), findsWidgets);
      await unmount(tester);
    });

    testWidgets('a paid withdrawal reads as complete', (tester) async {
      await pumpDialog(
        tester,
        const WithdrawalResult(success: true),
        watched: const WatchedWithdrawal(
          status: 'Completed',
          paid: true,
          notMinedYet: false,
          state: 'Settled',
          paidBtcTxHash: 'c314d462',
        ),
      );

      expect(find.text('Withdrawal Complete'), findsOneWidget);
      expect(find.text('Withdrawal completed successfully!'), findsOneWidget);
      expect(find.text('c314d462'), findsOneWidget);
      expect(find.text('Raise Fee'), findsNothing);
    });
  });

  test('a watched withdrawal is paid only once Bitcoin confirms it', () {
    const pinned = WatchedWithdrawal(status: 'Awaiting_BTC_Confirmation', paid: false, notMinedYet: false, state: 'Pinned');
    expect(const WithdrawalResult(success: true, watched: pinned).isPaid, isFalse);
    expect(const WithdrawalResult(success: true).isPaid, isTrue);
  });
}
