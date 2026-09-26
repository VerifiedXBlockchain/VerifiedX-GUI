import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/bridge/components/bridge_result.dart';
import 'package:rbx_wallet/features/bridge/models/bridge_lock_record.dart';
import 'package:rbx_wallet/l10n/generated/app_localizations.dart';

Future<void> pumpHost(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  ));
  await tester.pumpAndSettle();
}

final successfulRecord = BridgeLockRecord(
  lockId: 'lock-1',
  amount: 0.25,
  evmDestination: '0x1234567890abcdef1234567890abcdef12345678',
  statusRaw: 'MintedOnBase',
  baseTxHash: '0xabc',
);

void main() {
  testWidgets('success view labels its copy and explorer icons as buttons', (tester) async {
    await pumpHost(
      tester,
      BridgeResult(record: successfulRecord, onDone: () {}),
    );

    final copy = tester.getSemantics(find.byIcon(Icons.copy)).getSemanticsData();
    expect(copy.label, 'Copy address');
    expect(copy.hasFlag(SemanticsFlag.isButton), isTrue);
    expect(copy.hasAction(SemanticsAction.tap), isTrue);

    final open = tester.getSemantics(find.byIcon(Icons.open_in_new)).getSemanticsData();
    expect(open.label, 'View on Basescan');
    expect(open.hasFlag(SemanticsFlag.isButton), isTrue);
    expect(open.hasAction(SemanticsAction.tap), isTrue);
  });

  testWidgets('Done button carries the bridge:done key', (tester) async {
    var done = 0;
    await pumpHost(
      tester,
      BridgeResult(record: successfulRecord, onDone: () => done++),
    );

    await tester.tap(find.byKey(const Key('bridge:done')));
    expect(done, 1);
  });
}
