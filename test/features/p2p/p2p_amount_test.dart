import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/p2p/utils/p2p_amount.dart';

void main() {
  group('P2pAmount', () {
    test('reads the API\'s decimal strings exactly, in units of 1e-8', () {
      expect(P2pAmount.parse('5').units, BigInt.from(500000000));
      expect(P2pAmount.parse('0.5').units, BigInt.from(50000000));
      expect(P2pAmount.parse('12.34567891').units, BigInt.from(1234567891));
      expect(P2pAmount.parse('0.00000001').units, BigInt.one);
      // The registry's largest amount is far past what a double holds exactly.
      expect(P2pAmount.parse('9999999999999999.99999999').units, BigInt.parse('999999999999999999999999'));
    });

    test('keeps the unit a double would lose', () {
      // 0.29 × 1e8 is 28999999.999999996 as a double.
      expect((0.29 * 1e8).truncate(), 28999999);
      expect(P2pAmount.parse('0.29').units, BigInt.from(29000000));
    });

    test('refuses anything that is not a plain decimal with at most 8 places', () {
      for (final text in ['', ' 5', '5 ', '-1', '+1', '1e3', '1,000', '.5', '5.', '0.123456789', 'abc', '1.2.3']) {
        expect(P2pAmount.tryParse(text), isNull, reason: '"$text"');
      }
      expect(P2pAmount.tryParse(null), isNull);
      expect(() => P2pAmount.parse('1e3'), throwsFormatException);
    });

    test('writes the shortest decimal string', () {
      expect(P2pAmount.parse('1.50').toDecimalString(), '1.5');
      expect(P2pAmount.parse('10.00000000').toDecimalString(), '10');
      expect(P2pAmount.parse('0.00000001').toDecimalString(), '0.00000001');
      expect(P2pAmount.fromUnits(BigInt.from(-50000000)).toDecimalString(), '-0.5');
      expect(P2pAmount.fromUnits(BigInt.zero).toDecimalString(), '0');
    });

    test('compares and adds without rounding', () {
      final a = P2pAmount.parse('0.1');
      final b = P2pAmount.parse('0.2');
      expect((a + b).toDecimalString(), '0.3');
      expect(a < b, isTrue);
      expect(b >= a, isTrue);
      expect(P2pAmount.parse('4') == P2pAmount.parse('4.0'), isTrue);
      expect((a - b).toDecimalString(), '-0.1');
      expect(a.compareTo(b), lessThan(0));
    });

    test('rounds a double balance to the nearest unit', () {
      expect(P2pAmount.fromDouble(0.29).units, BigInt.from(29000000));
      expect(P2pAmount.fromDouble(1234.5).toDecimalString(), '1234.5');
      expect(() => P2pAmount.fromDouble(-1), throwsArgumentError);
      expect(() => P2pAmount.fromDouble(double.nan), throwsArgumentError);
    });
  });

  group('P2pAmountInput', () {
    test('reads what people type', () {
      expect(P2pAmountInput.read('12').amount, P2pAmount.parse('12'));
      expect(P2pAmountInput.read(' 12.5 ').amount, P2pAmount.parse('12.5'));
      expect(P2pAmountInput.read('.5').amount, P2pAmount.parse('0.5'));
      expect(P2pAmountInput.read('12.').amount, P2pAmount.parse('12'));
    });

    test('says why it cannot read the rest', () {
      expect(P2pAmountInput.read('').error, P2pAmountInputError.empty);
      expect(P2pAmountInput.read('   ').error, P2pAmountInputError.empty);
      expect(P2pAmountInput.read('abc').error, P2pAmountInputError.format);
      expect(P2pAmountInput.read('.').error, P2pAmountInputError.format);
      expect(P2pAmountInput.read('1,000').error, P2pAmountInputError.format);
      expect(P2pAmountInput.read('1e3').error, P2pAmountInputError.format);
      expect(P2pAmountInput.read('-1').error, P2pAmountInputError.format);
      expect(P2pAmountInput.read('0.123456789').error, P2pAmountInputError.decimals);
      expect(P2pAmountInput.read('0').error, P2pAmountInputError.zero);
      expect(P2pAmountInput.read('0.0').error, P2pAmountInputError.zero);
    });
  });

  group('formatP2pAmount', () {
    test('groups the whole part and keeps the places as given', () {
      expect(formatP2pAmount('5'), '5');
      expect(formatP2pAmount('1234.5'), '1,234.5');
      expect(formatP2pAmount('1234567.00000001'), '1,234,567.00000001');
      expect(formatP2pAmount('999'), '999');
      expect(formatP2pAmount('1000'), '1,000');
    });

    test('shows what is not an amount as it came', () {
      expect(formatP2pAmount(null), '');
      expect(formatP2pAmount('n/a'), 'n/a');
    });
  });
}
