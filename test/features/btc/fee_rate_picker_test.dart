import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/btc/models/btc_fee_rate_preset.dart';
import 'package:rbx_wallet/features/btc/models/btc_recommended_fees.dart';
import 'package:rbx_wallet/features/btc/utils.dart';
import 'package:rbx_wallet/l10n/generated/app_localizations.dart';

final fees = BtcRecommendedFees(
  fastestFee: 30,
  halfHourFee: 27,
  hourFee: 25,
  economyFee: 12,
  minimumFee: 6,
);

Future<BuildContext> pumpHost(WidgetTester tester) async {
  late BuildContext hostContext;
  await tester.pumpWidget(MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(builder: (context) {
      hostContext = context;
      return const SizedBox();
    }),
  ));
  await tester.pumpAndSettle();
  return hostContext;
}

void main() {
  test('feeRateForPreset reads each preset from the fee table', () {
    expect(feeRateForPreset(BtcFeeRatePreset.minimum, fees), 6);
    expect(feeRateForPreset(BtcFeeRatePreset.economy, fees), 12);
    expect(feeRateForPreset(BtcFeeRatePreset.hour, fees), 25);
    expect(feeRateForPreset(BtcFeeRatePreset.halfHour, fees), 27);
    expect(feeRateForPreset(BtcFeeRatePreset.fastest, fees), 30);
  });

  testWidgets('Continue on the default selection returns the Economy rate', (tester) async {
    final context = await pumpHost(tester);
    final result = showFeeRatePicker(context, fees);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(await result, 12);
  });

  testWidgets('picking a preset returns that preset\'s rate', (tester) async {
    final context = await pumpHost(tester);
    final result = showFeeRatePicker(context, fees);
    await tester.pumpAndSettle();

    await tester.tap(find.text(BtcFeeRatePreset.hour.labelWith(AppLocalizations.of(context))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(await result, 25);
  });

  testWidgets('every row shows its own rate', (tester) async {
    final context = await pumpHost(tester);
    final result = showFeeRatePicker(context, fees);
    await tester.pumpAndSettle();

    expect(find.textContaining('12 SATS'), findsOneWidget);
    expect(find.textContaining('30 SATS'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(await result, isNull);
  });
}
