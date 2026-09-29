import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/send/send_amount.dart';

void main() {
  group('amountDecimalPlaces', () {
    test('counts the digits after the point', () {
      expect(amountDecimalPlaces('1'), 0);
      expect(amountDecimalPlaces('1.5'), 1);
      expect(amountDecimalPlaces('0.12345678'), 8);
      expect(amountDecimalPlaces('0.0000000000000000001'), 19);
      expect(amountDecimalPlaces('.25'), 2);
      expect(amountDecimalPlaces(' 2.50 '), 1);
    });

    test('ignores trailing zeros', () {
      expect(amountDecimalPlaces('1.000000000000'), 0);
      expect(amountDecimalPlaces('0.123456780000'), 8);
      expect(amountDecimalPlaces('5.'), 0);
    });

    test('returns null for anything but a plain decimal', () {
      expect(amountDecimalPlaces(''), isNull);
      expect(amountDecimalPlaces('.'), isNull);
      expect(amountDecimalPlaces('1e-8'), isNull);
      expect(amountDecimalPlaces('-1.5'), isNull);
      expect(amountDecimalPlaces('1,5'), isNull);
      expect(amountDecimalPlaces('abc'), isNull);
    });

    test('VFX and BTC both allow 8 decimals', () {
      expect(kVfxMaxDecimals, 8);
      expect(kBtcMaxDecimals, 8);
      expect(amountDecimalPlaces('0.00000001')! <= kVfxMaxDecimals, isTrue);
      expect(amountDecimalPlaces('0.000000001')! <= kVfxMaxDecimals, isFalse);
    });
  });

  group('formatSendAmount', () {
    test('never uses exponent notation', () {
      expect(formatSendAmount(0.0000001), '0.0000001');
      expect(formatSendAmount(0.00000001), '0.00000001');
    });

    test('drops trailing zeros and a bare point', () {
      expect(formatSendAmount(12.5), '12.5');
      expect(formatSendAmount(3), '3');
      expect(formatSendAmount(0.1 + 0.2), '0.3');
    });

    test('keeps up to 8 decimals', () {
      expect(formatSendAmount(9.99998), '9.99998');
      expect(formatSendAmount(0.12345678), '0.12345678');
    });
  });

  group('fitAmountWithFee', () {
    Future<double?> Function(double) fixedFee(double fee, [List<double>? asked]) {
      return (amount) async {
        asked?.add(amount);
        return fee;
      };
    }

    test('keeps an amount that fits with its fee', () async {
      final result = await fitAmountWithFee(amount: 5, spendable: 10, feeFor: fixedFee(0.00002));
      expect(result, isNotNull);
      expect(result!.adjusted, isFalse);
      expect(result.amount, 5);
      expect(result.fee, 0.00002);
    });

    test('keeps an amount that exactly uses the balance with its fee', () async {
      final result = await fitAmountWithFee(amount: 9.99998, spendable: 10, feeFor: fixedFee(0.00002));
      expect(result!.adjusted, isFalse);
      expect(result.amount, 9.99998);
    });

    test('lowers a full-balance send to balance minus fee', () async {
      final asked = <double>[];
      final result = await fitAmountWithFee(amount: 10, spendable: 10, feeFor: fixedFee(0.00002, asked));
      expect(result!.adjusted, isTrue);
      expect(result.feeNotCovered, isFalse);
      expect(result.amount, 9.99998);
      expect(result.fee, 0.00002);
      // The fee is quoted again for the lowered amount.
      expect(asked, [10, 9.99998]);
    });

    test('works in whole 10^-8 units despite double noise', () async {
      final result = await fitAmountWithFee(amount: 0.3, spendable: 0.1 + 0.2, feeFor: fixedFee(0.00000003));
      expect(result!.adjusted, isTrue);
      expect(formatSendAmount(result.amount), '0.29999997');
    });

    test('re-fits when the lowered amount is quoted a higher fee', () async {
      // First quote is 1 unit lower than the real fee for the lowered amount.
      final quotes = [0.00001, 0.00002, 0.00002];
      var call = 0;
      final result = await fitAmountWithFee(
        amount: 1,
        spendable: 1,
        feeFor: (_) async => quotes[call++],
      );
      expect(result!.adjusted, isTrue);
      expect(result.amount, 0.99998);
      expect(result.fee, 0.00002);
      expect(call, 3);
    });

    test('reports a fee larger than the whole balance', () async {
      final result = await fitAmountWithFee(amount: 0.00001, spendable: 0.00001, feeFor: fixedFee(0.00002));
      expect(result!.feeNotCovered, isTrue);
      expect(result.fee, 0.00002);
    });

    test('returns null when no fee can be quoted', () async {
      expect(await fitAmountWithFee(amount: 10, spendable: 10, feeFor: (_) async => null), isNull);

      var call = 0;
      final secondFails = await fitAmountWithFee(
        amount: 10,
        spendable: 10,
        feeFor: (_) async => call++ == 0 ? 0.00002 : null,
      );
      expect(secondFails, isNull);
    });
  });

  group('isOwnSendAddress', () {
    const own = ['RNiQrW3aBUWZhfadqKxPuN46iGaR13ox7P', 'xRBXq4bSxCk3RK4MvUW3ZJ4t8hsQo1ULmzHp', 'alice.vfx', null, ''];

    test('matches an own address, ignoring surrounding whitespace', () {
      expect(isOwnSendAddress('RNiQrW3aBUWZhfadqKxPuN46iGaR13ox7P', own), isTrue);
      expect(isOwnSendAddress('  xRBXq4bSxCk3RK4MvUW3ZJ4t8hsQo1ULmzHp\n', own), isTrue);
    });

    test('treats base58 addresses as case sensitive', () {
      expect(isOwnSendAddress('rniqrw3abuwzhfadqkxpun46igar13ox7p', own), isFalse);
    });

    test('matches domains and bech32 addresses case-insensitively', () {
      expect(isOwnSendAddress('Alice.VFX', own), isTrue);
      expect(isOwnSendAddress('BC1QW508D6QEJXTDG4Y5R3ZARVARY0C5XW7KV8F3T4', ['bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4']), isTrue);
    });

    test('does not match someone else or an empty destination', () {
      expect(isOwnSendAddress('RBdwbhyqwJCTnoNe1n7vTXPJqi5HKc6NTH', own), isFalse);
      expect(isOwnSendAddress('bob.vfx', own), isFalse);
      expect(isOwnSendAddress('', own), isFalse);
      expect(isOwnSendAddress('   ', own), isFalse);
    });
  });
}
