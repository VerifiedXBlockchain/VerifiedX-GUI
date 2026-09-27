import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/app_constants.dart';
import 'package:rbx_wallet/utils/formatting.dart';

void main() {
  test('drops float noise from sats-derived amounts', () {
    // The web Send badge showed 0.013661920000000001 BTC.
    expect(formatBtcAmount(0.013661920000000001), '0.01366192');
    expect(formatBtcAmount(1314812 * BTC_SATOSHI_MULTIPLIER), '0.01314812');
  });

  test('keeps satoshi precision without scientific notation', () {
    expect(formatBtcAmount(0.00000005), '0.00000005');
    expect(formatBtcAmount(0.00000001), '0.00000001');
  });

  test('trims trailing zeros', () {
    expect(formatBtcAmount(0.0005), '0.0005');
    expect(formatBtcAmount(1), '1');
    expect(formatBtcAmount(10), '10');
    expect(formatBtcAmount(0), '0');
  });

  test('rounds beyond 8 decimals and handles negatives', () {
    expect(formatBtcAmount(0.123456789), '0.12345679');
    expect(formatBtcAmount(-0.0000138), '-0.0000138');
    expect(formatBtcAmount(-0.000000001), '0');
  });
}
