import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/providers/session_provider.dart';
import 'package:rbx_wallet/features/wallet/components/manage_wallet_bottom_sheet.dart';
import 'package:rbx_wallet/features/wallet/models/wallet.dart';
import 'package:rbx_wallet/l10n/generated/app_localizations.dart';

/// A session that never starts the CLI and only records wallet switches.
class StubSession extends SessionProvider {
  StubSession(Ref ref, SessionModel model) : super(ref, model);

  final switchedTo = <Wallet>[];

  @override
  Future<void> init(bool inLoop) async {}

  @override
  void setCurrentWallet(Wallet wallet, [bool updateGlobalCurrency = true]) {
    switchedTo.add(wallet);
  }
}

final wallet = Wallet(
  id: 1,
  publicKey: 'pub-main',
  address: 'RBxMainWalletAddress0001',
  friendlyName: 'Main wallet',
  balance: 12.5,
  isValidating: false,
);

Future<StubSession> pumpHost(WidgetTester tester, {Wallet? current}) async {
  late StubSession session;
  await tester.pumpWidget(ProviderScope(
    overrides: [
      sessionProvider.overrideWith((ref) => session = StubSession(ref, SessionModel(currentWallet: current))),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: ManageWalletListTile(wallet: wallet)),
    ),
  ));
  await tester.pumpAndSettle();
  return session;
}

void main() {
  testWidgets('an unselected wallet row is a button named by its visible label', (tester) async {
    final session = await pumpHost(tester);

    final tile = find.byKey(Key('vfx_wallet_${wallet.address}_false'));
    expect(tile, findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('^Main wallet')), findsOneWidget);

    final data = tester.getSemantics(tile).getSemanticsData();
    expect(data.label, startsWith('Main wallet'));
    expect(data.label, contains(wallet.address));
    expect(data.hasFlag(SemanticsFlag.isButton), isTrue);
    expect(data.hasAction(SemanticsAction.tap), isTrue);

    await tester.tap(tile);
    expect(session.switchedTo, [wallet]);
  });

  testWidgets('the selected wallet row is not a button', (tester) async {
    await pumpHost(tester, current: wallet);

    final tile = find.byKey(Key('vfx_wallet_${wallet.address}_true'));
    expect(tile, findsOneWidget);

    final data = tester.getSemantics(tile).getSemanticsData();
    expect(data.hasFlag(SemanticsFlag.isButton), isFalse);
    expect(data.hasAction(SemanticsAction.tap), isFalse);
  });
}
