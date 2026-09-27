import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/bridge/components/bridge_preflight_form.dart';
import 'package:rbx_wallet/features/bridge/models/bridge_preflight.dart';
import 'package:rbx_wallet/features/bridge/providers/bridge_preflight_provider.dart';
import 'package:rbx_wallet/features/btc/models/tokenized_bitcoin.dart';
import 'package:rbx_wallet/l10n/generated/app_localizations.dart';

// QA MTI#7.3: after the preflight failed, neither the 10 s poll nor Retry sent
// a new request until the modal was reopened. The form used `ref.invalidate`,
// which only refetches when Riverpod's scheduler runs on a later frame and is
// a no-op while that refetch is still pending. These tests advance time
// without pumping frames (`binding.delayed`) and tap Retry without a pump, so
// they only pass if each poll tick and each Retry sends the request itself.

final _token = TokenizedBitcoin(
  id: 1,
  smartContractUid: 'sc-uid:1',
  rbxAddress: 'xOwner',
  tokenName: 'vBTC',
  tokenDescription: '',
  smartContractMainId: 1,
  isPublished: true,
);

Future<void> _pumpForm(WidgetTester tester, Future<BridgePreflight?> Function() fetch) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [
      bridgePreflightProvider.overrideWith((ref, args) => fetch()),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: BridgePreflightForm(
          token: _token,
          ownerAddress: 'xOwner',
          amountController: TextEditingController(),
          destinationController: TextEditingController(),
          onReview: (BridgePreflight p, double a, String d) {},
          onCancel: () {},
        ),
      ),
    ),
  ));
  await tester.pump();
  await tester.pump();
}

Future<void> _expectRefetchesWithoutFrames(WidgetTester tester, int Function() calls) async {
  expect(calls(), 1);
  expect(find.text('Retry'), findsOneWidget);

  // Retry sends the request right away, and again on a second press.
  await tester.tap(find.text('Retry'));
  expect(calls(), 2);
  await tester.tap(find.text('Retry'));
  expect(calls(), 3);

  // The 10 s poll keeps running, without waiting for a frame.
  await tester.binding.delayed(const Duration(seconds: 10));
  expect(calls(), 4);
  await tester.binding.delayed(const Duration(seconds: 10));
  expect(calls(), 5);

  // Still in the error state after all that; Retry still works.
  await tester.pump();
  expect(find.text('Retry'), findsOneWidget);
  await tester.tap(find.text('Retry'));
  expect(calls(), 6);

  await tester.pumpWidget(const SizedBox());
}

void main() {
  testWidgets('preflight that throws: Retry and the poll refetch', (tester) async {
    var calls = 0;
    await _pumpForm(tester, () async {
      calls++;
      throw Exception('node unreachable');
    });
    await _expectRefetchesWithoutFrames(tester, () => calls);
  });

  testWidgets('preflight that returns success=false: Retry and the poll refetch', (tester) async {
    var calls = 0;
    await _pumpForm(tester, () async {
      calls++;
      return BridgePreflight.fromJson({
        'success': false,
        'message': 'Preflight error: FormatException: Input string was not in a correct format.',
      });
    });
    await _expectRefetchesWithoutFrames(tester, () => calls);
  });
}
