import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/btc_web/utils/vbtc_amount.dart';

void main() {
  group('vbtcAmountWithinSatoshiPrecision', () {
    test('accepts up to 8 decimal places', () {
      expect(kVbtcMaxDecimals, 8);
      expect(vbtcAmountWithinSatoshiPrecision('1'), isTrue);
      expect(vbtcAmountWithinSatoshiPrecision('0.5'), isTrue);
      expect(vbtcAmountWithinSatoshiPrecision('0.12345678'), isTrue);
      expect(vbtcAmountWithinSatoshiPrecision('0.00000001'), isTrue);
      expect(vbtcAmountWithinSatoshiPrecision('.25'), isTrue);
      expect(vbtcAmountWithinSatoshiPrecision(' 0.1 '), isTrue);
    });

    test('refuses more than 8 significant decimal places', () {
      expect(vbtcAmountWithinSatoshiPrecision('0.123456789'), isFalse);
      expect(vbtcAmountWithinSatoshiPrecision('0.000000001'), isFalse);
      expect(vbtcAmountWithinSatoshiPrecision('1.000000005'), isFalse);
    });

    test('ignores trailing zeros, as the node compares values', () {
      expect(vbtcAmountWithinSatoshiPrecision('0.100000000'), isTrue);
      expect(vbtcAmountWithinSatoshiPrecision('0.123456780000'), isTrue);
    });

    test('judges exponent notation by value', () {
      expect(vbtcAmountWithinSatoshiPrecision('1e-8'), isTrue);
      expect(vbtcAmountWithinSatoshiPrecision('1e-9'), isFalse);
    });

    test('refuses text that is not a number', () {
      expect(vbtcAmountWithinSatoshiPrecision('abc'), isFalse);
    });
  });
}
