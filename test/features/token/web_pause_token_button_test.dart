import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/components/buttons.dart';
import 'package:rbx_wallet/features/token/components/web_token_management_actions.dart';
import 'package:rbx_wallet/features/token/models/web_fungible_token.dart';
import 'package:rbx_wallet/features/token/providers/pending_token_pause_provider.dart';
import 'package:rbx_wallet/features/token/providers/web_token_detail_provider.dart';
import 'package:rbx_wallet/l10n/generated/app_localizations.dart';

const scId = 'sc-1';

WebFungibleToken buildToken({required bool isPaused}) {
  return WebFungibleToken(
    smartContractId: scId,
    name: 'Test Token',
    ticker: 'TKR',
    ownerAddress: 'RBxOwner0001',
    canMint: true,
    canBurn: true,
    canVote: false,
    isPaused: isPaused,
    circulatingSupply: 0,
    initialSupply: 0,
    bannedAddresses: const [],
    createdAt: DateTime(2026),
  );
}

void main() {
  group('WebPendingTokenPauseProvider', () {
    test('a requested pause is pending until the chain reports it', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(webPendingTokenPauseProvider.notifier).add(scId, requestedPaused: true);
      final pending = container.read(webPendingTokenPauseProvider);

      expect(isWebTokenPausePending(pending, scId, isPaused: false), isTrue);
      expect(isWebTokenPausePending(pending, scId, isPaused: true), isFalse);
      expect(isWebTokenPausePending(pending, 'other', isPaused: false), isFalse);
    });

    test('resolve drops the entry only once the requested state is observed', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(webPendingTokenPauseProvider.notifier);
      notifier.add(scId, requestedPaused: true);

      notifier.resolve(scId, isPaused: false);
      expect(container.read(webPendingTokenPauseProvider), {scId: true});

      notifier.resolve(scId, isPaused: true);
      expect(container.read(webPendingTokenPauseProvider), isEmpty);
    });
  });

  group('WebPauseTokenButton', () {
    Future<ProviderContainer> pump(WidgetTester tester, {required bool isPaused, bool? requestedPaused}) async {
      final token = buildToken(isPaused: isPaused);
      final container = ProviderContainer(overrides: [
        webTokenDetailProvider(scId).overrideWith((ref) async => WebFungibleTokenDetail(token: token, holders: const {})),
      ]);
      addTearDown(container.dispose);
      if (requestedPaused != null) {
        container.read(webPendingTokenPauseProvider.notifier).add(scId, requestedPaused: requestedPaused);
      }

      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: WebPauseTokenButton(token: token)),
        ),
      ));
      await tester.pump();
      return container;
    }

    testWidgets('shows Pause TXs when nothing is pending', (tester) async {
      await pump(tester, isPaused: false);

      expect(find.byKey(const Key('token:pause')), findsOneWidget);
      expect(find.text('Pause TXs'), findsOneWidget);
    });

    testWidgets('shows a processing Pending Pause after a pause was broadcast', (tester) async {
      await pump(tester, isPaused: false, requestedPaused: true);

      final button = tester.widget<AppButton>(find.byKey(const Key('token:pause-pending')));
      expect(button.processing, isTrue);
      expect(button.label, 'Pending Pause');
    });

    testWidgets('shows Pending Resume after a resume was broadcast', (tester) async {
      await pump(tester, isPaused: true, requestedPaused: false);

      final button = tester.widget<AppButton>(find.byKey(const Key('token:pause-pending')));
      expect(button.label, 'Pending Resume');
    });

    testWidgets('clears the pending entry once the refreshed detail reports the new state', (tester) async {
      final container = await pump(tester, isPaused: true, requestedPaused: true);
      await tester.pump();

      expect(find.byKey(const Key('token:pause')), findsOneWidget);
      expect(find.text('Resume TXs'), findsOneWidget);
      expect(container.read(webPendingTokenPauseProvider), isEmpty);
    });
  });
}
