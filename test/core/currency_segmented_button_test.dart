import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/components/currency_segmented_button.dart';
import 'package:rbx_wallet/core/providers/currency_segmented_button_provider.dart';
import 'package:rbx_wallet/core/providers/session_provider.dart';
import 'package:rbx_wallet/l10n/generated/app_localizations.dart';

/// A session with a VFX account selected that never launches the CLI.
class StubSession extends SessionProvider {
  StubSession(Ref ref) : super(ref, const SessionModel(cliStarted: true));

  @override
  Future<void> init(bool inLoop) async {}
}

void main() {
  group('currencyMatchingSession', () {
    test('BTC shown over a VFX account goes back to VFX, and the reverse', () {
      expect(currencyMatchingSession(CurrencyType.btc, btcSelected: false, includeAny: true), CurrencyType.vfx);
      expect(currencyMatchingSession(CurrencyType.vfx, btcSelected: true, includeAny: false), CurrencyType.btc);
    });

    test('a segment that agrees with the account is left alone', () {
      expect(currencyMatchingSession(CurrencyType.vfx, btcSelected: false, includeAny: true), isNull);
      expect(currencyMatchingSession(CurrencyType.btc, btcSelected: true, includeAny: false), isNull);
    });

    test('All agrees with either account only where the screen offers it', () {
      expect(currencyMatchingSession(CurrencyType.any, btcSelected: true, includeAny: true), isNull);
      expect(currencyMatchingSession(CurrencyType.any, btcSelected: false, includeAny: false), CurrencyType.vfx);
    });
  });

  group('CurrencySegementedButton', () {
    Future<ProviderContainer> pump(WidgetTester tester, {required bool followSession}) async {
      final container = ProviderContainer(overrides: [
        sessionProvider.overrideWith((ref) => StubSession(ref)),
      ]);
      addTearDown(container.dispose);
      // What the BTC price card's View Chart leaves behind.
      container.read(currencySegementedButtonProvider.notifier).follow(CurrencyType.btc);

      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: CurrencySegementedButton(followSession: followSession)),
        ),
      ));
      await tester.pumpAndSettle();
      return container;
    }

    testWidgets('on Send and Receive it shows the currency of the account on screen', (tester) async {
      final container = await pump(tester, followSession: true);
      expect(container.read(currencySegementedButtonProvider), CurrencyType.vfx);
    });

    testWidgets('elsewhere it keeps the app-wide choice', (tester) async {
      final container = await pump(tester, followSession: false);
      expect(container.read(currencySegementedButtonProvider), CurrencyType.btc);
    });
  });
}
