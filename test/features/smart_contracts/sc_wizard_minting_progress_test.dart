import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/smart_contracts/components/sc_wizard_minting_progress_dialog.dart';
import 'package:rbx_wallet/features/smart_contracts/providers/sc_wizard_minting_progress_provider.dart';
import 'package:rbx_wallet/l10n/generated/app_localizations.dart';

const _closeKey = Key('scWizardMinting:close');
const _errorKey = Key('scWizardMinting:error');

Future<ProviderContainer> _pumpDialog(WidgetTester tester) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);

  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => showDialog(context: context, builder: (_) => const ScWizardMintingProgressDialog()),
          child: const Text('open'),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pump();
  await tester.pump();
  return container;
}

bool _closeEnabled(WidgetTester tester) => tester.widget<TextButton>(find.byKey(_closeKey)).onPressed != null;

void main() {
  group('ScWizardMintingProgressProvider', () {
    test('fail keeps the progress reached and marks the run failed', () {
      final provider = ScWizardMintingProgressProvider();
      provider.start();
      provider.setLabel('Minting 1/3...');

      provider.fail('stopped');

      expect(provider.debugState.failed, isTrue);
      expect(provider.debugState.error, 'stopped');
      expect(provider.debugState.percent, 0);
      expect(provider.debugState.label, 'Minting 1/3...');
    });

    test('start clears a previous error', () {
      final provider = ScWizardMintingProgressProvider();
      provider.fail('stopped');

      provider.start();

      expect(provider.debugState.failed, isFalse);
      expect(provider.debugState.percent, 0);
    });

    test('progress updates keep the error', () {
      final provider = ScWizardMintingProgressProvider();
      provider.fail('stopped');

      provider.setLabel('x');

      expect(provider.debugState.error, 'stopped');
    });
  });

  group('ScWizardMintingProgressDialog', () {
    testWidgets('Close is disabled while minting', (tester) async {
      final container = await _pumpDialog(tester);
      container.read(scWizardMintingProgress.notifier).setLabel('Minting 1/3...');
      await tester.pump();

      expect(_closeEnabled(tester), isFalse);
      expect(find.byKey(_errorKey), findsNothing);
    });

    testWidgets('an error shows the message, enables Close, and Close dismisses the dialog', (tester) async {
      final container = await _pumpDialog(tester);
      container.read(scWizardMintingProgress.notifier).setLabel('Minting 1/3...');
      container.read(scWizardMintingProgress.notifier).fail('Minting stopped after an error. 0 of 3 minted.');
      await tester.pump();

      expect(find.text('Minting stopped after an error. 0 of 3 minted.'), findsOneWidget);
      expect(_closeEnabled(tester), isTrue);

      await tester.tap(find.byKey(_closeKey));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ScWizardMintingProgressDialog), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });
  });
}
