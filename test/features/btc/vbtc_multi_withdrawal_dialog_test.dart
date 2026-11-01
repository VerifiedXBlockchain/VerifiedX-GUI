import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/app.dart';
import 'package:rbx_wallet/features/btc/components/vbtc_multi_withdrawal_dialog.dart';
import 'package:rbx_wallet/features/btc/models/vbtc_withdrawal_part.dart';
import 'package:rbx_wallet/features/btc_web/models/watched_withdrawal.dart';
import 'package:rbx_wallet/l10n/generated/app_localizations.dart';

class _FakeActions implements VbtcWithdrawalPartActions {
  final Map<String, WatchedWithdrawal?> states;
  final List<String> calls = [];

  _FakeActions(this.states);

  @override
  Future<WatchedWithdrawal?> lookUp(String scIdentifier) async => states[scIdentifier];

  @override
  Future<bool> changeFee(String scIdentifier, int feeRate, {required bool release}) async {
    calls.add('${release ? 'release' : 'raise'} $scIdentifier $feeRate');
    return true;
  }

  @override
  Future<bool> cancel(String scIdentifier) async {
    calls.add('cancel $scIdentifier');
    return true;
  }
}

const _parts = [
  VbtcWithdrawalPart(scIdentifier: 'big:1', name: 'Vault A', amount: 0.00005),
  VbtcWithdrawalPart(scIdentifier: 'small:2', name: 'Vault B', amount: 0.00002),
];

const _pinned = WatchedWithdrawal(
  status: 'Awaiting_BTC_Confirmation',
  paid: false,
  notMinedYet: false,
  state: 'Pinned',
  feeRate: 3,
  canRaiseFee: true,
  canRelease: true,
  pinnedBtcTxHash: 'c58c225f',
);

const _waiting = WatchedWithdrawal(
  status: 'Awaiting_BTC_Transaction',
  paid: false,
  notMinedYet: false,
  state: 'Waiting',
  canCancel: true,
);

const _settled = WatchedWithdrawal(
  status: 'Completed',
  paid: true,
  notMinedYet: false,
  state: 'Settled',
  paidBtcTxHash: '2407c724',
);

const _released = WatchedWithdrawal(status: 'Closed', paid: false, notMinedYet: false, state: 'Released');

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    rootNavigatorKey = GlobalKey<NavigatorState>();
  });

  Future<void> pump(WidgetTester tester, _FakeActions actions) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    await tester.pumpWidget(MaterialApp(
      navigatorKey: rootNavigatorKey,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: VbtcMultiWithdrawalDialog(requestHash: 'req', parts: _parts, actions: actions),
      ),
    ));
    await tester.pumpAndSettle();
  }

  // The dialog refreshes on a timer while mounted; unmount it so the timer is
  // disposed inside the test.
  Future<void> unmount(WidgetTester tester) => tester.pumpWidget(const SizedBox.shrink());

  testWidgets('lists each part with its own state and actions', (tester) async {
    await pump(tester, _FakeActions({'big:1': _pinned, 'small:2': _waiting}));

    expect(find.text('Withdrawal in Progress'), findsOneWidget);
    expect(find.text('Part 1 · Vault A'), findsOneWidget);
    expect(find.text('Part 2 · Vault B'), findsOneWidget);
    expect(find.text('c58c225f'), findsOneWidget);
    expect(find.text('Current fee rate: 3 sat/vB'), findsOneWidget);
    // Raise fee and release on the pinned part, Cancel only on the waiting one.
    expect(find.byKey(const Key('vbtc:multi_wd_raise_1')), findsOneWidget);
    expect(find.byKey(const Key('vbtc:multi_wd_release_1')), findsOneWidget);
    expect(find.byKey(const Key('vbtc:multi_wd_cancel_1')), findsNothing);
    expect(find.byKey(const Key('vbtc:multi_wd_cancel_2')), findsOneWidget);
    expect(find.byKey(const Key('vbtc:multi_wd_raise_2')), findsNothing);

    await unmount(tester);
  });

  testWidgets('raises one part with a rate above the current one', (tester) async {
    final actions = _FakeActions({'big:1': _pinned, 'small:2': _waiting});
    await pump(tester, actions);

    await tester.tap(find.byKey(const Key('vbtc:multi_wd_raise_1')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('vbtc:multi_wd_fee_rate')), '3');
    await tester.tap(find.text('Raise Fee').last);
    await tester.pumpAndSettle();
    expect(find.text('At least 4 sat/vB'), findsOneWidget);
    expect(actions.calls, isEmpty);

    await tester.enterText(find.byKey(const Key('vbtc:multi_wd_fee_rate')), '5');
    await tester.tap(find.text('Raise Fee').last);
    await tester.pumpAndSettle();
    expect(actions.calls, ['raise big:1 5']);
    // Locked until the chain shows the change.
    expect(find.textContaining('Sent. The actions come back'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('cancels the waiting part after confirming', (tester) async {
    final actions = _FakeActions({'big:1': _pinned, 'small:2': _waiting});
    await pump(tester, actions);

    await tester.tap(find.byKey(const Key('vbtc:multi_wd_cancel_2')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();

    expect(actions.calls, ['cancel small:2']);

    await unmount(tester);
  });

  testWidgets('says partly sent once one part paid and the other returned', (tester) async {
    await pump(tester, _FakeActions({'big:1': _settled, 'small:2': _released}));

    expect(find.text('Withdrawal Partly Sent'), findsOneWidget);
    expect(find.text('Sent'), findsOneWidget);
    expect(find.text('Closed, its vBTC was returned to you'), findsOneWidget);
    expect(find.byKey(const Key('vbtc:multi_wd_cancel_2')), findsNothing);

    await unmount(tester);
  });
}
