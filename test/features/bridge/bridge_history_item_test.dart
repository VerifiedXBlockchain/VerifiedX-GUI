import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/app.dart';
import 'package:rbx_wallet/features/bridge/components/bridge_history_item.dart';
import 'package:rbx_wallet/features/bridge/models/bridge_lock_record.dart';
import 'package:rbx_wallet/l10n/generated/app_localizations.dart';

Future<void> pumpHost(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  ));
  await tester.pumpAndSettle();
}

final record = BridgeLockRecord(
  lockId: 'lock-1',
  amount: 0.25,
  evmDestination: '0x1234567890abcdef1234567890abcdef12345678',
  statusRaw: 'Minted',
);

void main() {
  // `friendlyStatus` reads through `globalL10n`; a detached root key makes it
  // fall back to English instead of resolving the router through get_it.
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    rootNavigatorKey = GlobalKey<NavigatorState>();
  });

  testWidgets('history row is a button named by its visible text', (tester) async {
    var taps = 0;
    await pumpHost(
      tester,
      BridgeHistoryItem(record: record, onTap: () => taps++),
    );

    final wrapper = find
        .descendant(
          of: find.byType(BridgeHistoryItem),
          matching: find.byType(Semantics),
        )
        .first;
    final data = tester.getSemantics(wrapper).getSemanticsData();
    // No explicit label: the amount/destination line and the status pill are
    // the accessible name.
    expect(data.label, contains('0.25'));
    expect(data.label, contains('0x1234'));
    expect(data.label, contains('Minted'));
    expect(data.hasFlag(SemanticsFlag.isButton), isTrue);
    expect(data.hasAction(SemanticsAction.tap), isTrue);

    await tester.tap(wrapper);
    expect(taps, 1);
  });
}
