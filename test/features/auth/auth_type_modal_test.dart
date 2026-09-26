import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/auth/components/auth_type_modal.dart';
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
  testWidgets('a login tile is a button whose accessible name is its visible title', (tester) async {
    var mnemonicTaps = 0;
    await pumpHost(
      tester,
      AuthTypeModal(
        handleUsername: () {},
        handleMnemonic: () => mnemonicTaps++,
      ),
    );

    final tile = find.byKey(const ValueKey('auth:type_mnemonic'));
    expect(tile, findsOneWidget);
    expect(find.bySemanticsLabel('Mnemonic (HD account)'), findsOneWidget);

    final data = tester.getSemantics(tile).getSemanticsData();
    expect(data.label, 'Mnemonic (HD account)');
    expect(data.hasFlag(SemanticsFlag.isButton), isTrue);
    expect(data.hasAction(SemanticsAction.tap), isTrue);

    await tester.tap(tile);
    expect(mnemonicTaps, 1);
  });

  testWidgets('every rendered login tile carries the button role', (tester) async {
    await pumpHost(
      tester,
      AuthTypeModal(
        handleUsername: () {},
        handleMnemonic: () {},
        handlePrivateKey: (_) {},
        handleBtcPrivateKey: (_) {},
        handleExtension: (_) {},
      ),
    );

    for (final key in const [
      'auth:type_email_password',
      'auth:type_mnemonic',
      'auth:type_vfx_private_key',
      'auth:type_btc_private_key',
      'auth:type_extension',
    ]) {
      final data = tester.getSemantics(find.byKey(ValueKey(key))).getSemanticsData();
      expect(data.hasFlag(SemanticsFlag.isButton), isTrue, reason: '$key should be a button');
      expect(data.hasAction(SemanticsAction.tap), isTrue, reason: '$key should be tappable');
      expect(data.label, isNotEmpty, reason: '$key should be named by its title');
    }
  });
}
