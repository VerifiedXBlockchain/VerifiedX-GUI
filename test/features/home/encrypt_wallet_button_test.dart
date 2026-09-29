import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/app.dart';
import 'package:rbx_wallet/core/providers/session_provider.dart';
import 'package:rbx_wallet/features/encrypt/providers/wallet_is_encrypted_provider.dart';
import 'package:rbx_wallet/features/global_loader/global_loading_provider.dart';
import 'package:rbx_wallet/features/home/components/home_buttons/encrypt_wallet_button.dart';
import 'package:rbx_wallet/features/wallet/models/wallet.dart';
import 'package:rbx_wallet/features/wallet/providers/wallet_list_provider.dart';
import 'package:rbx_wallet/l10n/generated/app_localizations.dart';

/// A session with the CLI marked as started that never launches it.
class StubSession extends SessionProvider {
  StubSession(Ref ref) : super(ref, const SessionModel(cliStarted: true));

  @override
  Future<void> init(bool inLoop) async {}
}

/// Reports an unencrypted wallet without asking the CLI.
class StubWalletIsEncrypted extends WalletIsEncryptedProvider {
  @override
  Future<void> check() async {}
}

final wallet = Wallet(
  id: 1,
  publicKey: 'pub-main',
  address: 'RBxMainWalletAddress0001',
  balance: 1,
  isValidating: false,
);

final l10n = lookupAppLocalizations(const Locale('en'));

/// Pumps the button and records whether encryption ever started (the global
/// loader is started right before the CLI encrypt call).
Future<List<bool>> pumpButton(WidgetTester tester) async {
  rootNavigatorKey = GlobalKey<NavigatorState>();
  final loadingStates = <bool>[];

  await tester.pumpWidget(ProviderScope(
    overrides: [
      sessionProvider.overrideWith((ref) => StubSession(ref)),
      walletIsEncryptedProvider.overrideWith((ref) => StubWalletIsEncrypted()),
      walletListProvider.overrideWith((ref) => WalletListProvider(ref, [wallet])),
    ],
    child: Consumer(builder: (context, ref, _) {
      ref.listen<bool>(globalLoadingProvider, (_, next) => loadingStates.add(next));
      return MaterialApp(
        navigatorKey: rootNavigatorKey,
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: EncryptWalletButton()),
      );
    }),
  ));
  await tester.pumpAndSettle();
  return loadingStates;
}

Future<void> enterFirstPassword(WidgetTester tester, String password) async {
  await tester.tap(find.text(l10n.r3eEncryptWallet));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField), password);
  await tester.tap(find.widgetWithText(TextButton, l10n.r3eAgree));
  await tester.pumpAndSettle();
  expect(find.text(l10n.r3eConfirmEncryptionPassword), findsOneWidget);
}

void main() {
  testWidgets('cancelling the confirm prompt does not encrypt the wallet', (tester) async {
    final loadingStates = await pumpButton(tester);

    await enterFirstPassword(tester, 'first-entry');
    await tester.tap(find.widgetWithText(TextButton, l10n.actionCancel));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(loadingStates, isEmpty);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('a mismatched confirmation does not encrypt the wallet', (tester) async {
    final loadingStates = await pumpButton(tester);

    await enterFirstPassword(tester, 'first-entry');
    await tester.enterText(find.byType(TextFormField), 'second-entry');
    await tester.tap(find.widgetWithText(TextButton, l10n.dialogSubmit));
    await tester.pumpAndSettle();

    expect(loadingStates, isEmpty);
    expect(find.text(l10n.r3ePasswordsDoNotMatchRetry), findsOneWidget);
  });
}
