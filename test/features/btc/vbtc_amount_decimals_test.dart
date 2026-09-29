import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/btc/utils.dart';

void main() {
  group('vbtcAmountHasTooManyDecimals', () {
    test('accepts up to 8 decimal places', () {
      expect(vbtcAmountHasTooManyDecimals('1'), isFalse);
      expect(vbtcAmountHasTooManyDecimals('0.5'), isFalse);
      expect(vbtcAmountHasTooManyDecimals('0.12345678'), isFalse);
      expect(vbtcAmountHasTooManyDecimals(' 0.00000001 '), isFalse);
    });

    test('refuses more than 8 decimal places', () {
      expect(vbtcAmountHasTooManyDecimals('0.123456789'), isTrue);
      expect(vbtcAmountHasTooManyDecimals('1.000000001'), isTrue);
    });
  });
}
