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

  group('vbtcWithdrawalLeavesDust (Core: amount - VSize(1) x rate >= 546)', () {
    test('TC-BTC-044: 1,000 sats at 3 sat/vB leaves 538, refused', () {
      expect(vbtcWithdrawalMinimumSats(3), 1008);
      expect(vbtcWithdrawalLeavesDust(0.00001, 3), isTrue);
    });

    test('the minimum itself, and the run\'s 0.00002 at 3 sat/vB, pass', () {
      expect(vbtcWithdrawalLeavesDust(0.00001008, 3), isFalse);
      expect(vbtcWithdrawalLeavesDust(0.00002, 3), isFalse);
    });

    test('a higher rate raises the minimum', () {
      // 2,000 sats: 154 x 9 + 546 = 1,932 fits, 154 x 10 + 546 = 2,086 does not.
      expect(vbtcWithdrawalLeavesDust(0.00002, 9), isFalse);
      expect(vbtcWithdrawalLeavesDust(0.00002, 10), isTrue);
    });

    test('no fee rate is left to the node', () {
      expect(vbtcWithdrawalLeavesDust(0.000001, 0), isFalse);
    });
  });
}
