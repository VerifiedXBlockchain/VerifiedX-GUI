import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/app.dart';
import 'package:rbx_wallet/core/providers/session_provider.dart';
import 'package:rbx_wallet/features/smart_contracts/components/sc_creator/common/compile_animation.dart';
import 'package:rbx_wallet/features/smart_contracts/providers/create_smart_contract_provider.dart';
import 'package:rbx_wallet/features/wallet/models/wallet.dart';
import 'package:rbx_wallet/l10n/generated/app_localizations.dart';

/// A session that never starts the CLI.
class _StubSession extends SessionProvider {
  _StubSession(Ref ref, SessionModel model) : super(ref, model);

  @override
  Future<void> init(bool inLoop) async {}
}

final _wallet = Wallet(
  id: 1,
  publicKey: 'pub-main',
  address: 'RBxMainWalletAddress0001',
  friendlyName: 'Main wallet',
  balance: 12.5,
  isValidating: false,
);

Widget _app(Locale locale, Widget child) => MaterialApp(
      navigatorKey: rootNavigatorKey,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    rootNavigatorKey = GlobalKey<NavigatorState>();
  });

  group('isValidForCompile', () {
    Future<List<String>> errorsFor(WidgetTester tester, Locale locale) async {
      await tester.pumpWidget(_app(locale, const SizedBox()));
      await tester.pumpAndSettle();
      final container = ProviderContainer(overrides: [
        sessionProvider.overrideWith((ref) => _StubSession(ref, SessionModel(currentWallet: _wallet))),
      ]);
      final errors = container.read(createSmartContractProvider.notifier).isValidForCompile();
      // Building the provider clears the multi-asset form, which resets its
      // state after a 300ms delay; let that timer fire before disposing.
      await tester.pump(const Duration(seconds: 1));
      container.dispose();
      return errors;
    }

    testWidgets('lists the missing fields in English', (tester) async {
      expect(await errorsFor(tester, const Locale('en')), [
        '- Asset is required',
        '- Name is required',
        '- Minter name is required',
        '- Description is required',
      ]);
    });

    testWidgets('lists the missing fields in Spanish', (tester) async {
      expect(await errorsFor(tester, const Locale('es')), [
        '- Se requiere un archivo',
        '- El nombre es obligatorio',
        '- El nombre del emisor es obligatorio',
        '- La descripción es obligatoria',
      ]);
    });
  });

  group('CompileAnimationComplete', () {
    Future<void> pumpComplete(WidgetTester tester, Locale locale, bool mint) async {
      await tester.pumpWidget(_app(locale, CompileAnimationComplete(mint)));
      await tester.pump(const Duration(milliseconds: 700));
    }

    testWidgets('shows Minted! / Compiled! in English', (tester) async {
      await pumpComplete(tester, const Locale('en'), true);
      expect(find.text('Minted!'), findsOneWidget);
      await pumpComplete(tester, const Locale('en'), false);
      expect(find.text('Compiled!'), findsOneWidget);
    });

    testWidgets('shows the Spanish headline', (tester) async {
      await pumpComplete(tester, const Locale('es'), true);
      expect(find.text('¡Emitido!'), findsOneWidget);
      await pumpComplete(tester, const Locale('es'), false);
      expect(find.text('¡Compilado!'), findsOneWidget);
    });
  });
}
