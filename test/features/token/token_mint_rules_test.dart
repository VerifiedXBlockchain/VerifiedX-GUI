import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/token/token_rules.dart';

void main() {
  group('plainDecimalString', () {
    test('never uses exponent notation', () {
      expect(plainDecimalString(0.0000001), '0.0000001');
      expect(plainDecimalString(1e-12), '0.000000000001');
      expect(plainDecimalString(1e21), '1000000000000000000000');
      expect(plainDecimalString(1.5e22), '15000000000000000000000');
    });

    test('keeps ordinary amounts as typed, without trailing zeros', () {
      expect(plainDecimalString(12.5), '12.5');
      expect(plainDecimalString(100.0), '100');
      expect(plainDecimalString(0.1), '0.1');
      expect(plainDecimalString(-2.25), '-2.25');
    });
  });

  group('decimalPlacesOf', () {
    test('counts the significant decimals', () {
      expect(decimalPlacesOf(100.0), 0);
      expect(decimalPlacesOf(0.25), 2);
      expect(decimalPlacesOf(0.0000001), 7);
    });
  });

  group('tokenMintProblem', () {
    test('a mint within the rules passes', () {
      expect(tokenMintProblem(amount: 10.5, decimalPlaces: 2, isPaused: false, currentSupply: 1000, holderBalance: 500), isNull);
    });

    test('a paused contract refuses any mint', () {
      expect(tokenMintProblem(amount: 1, decimalPlaces: 8, isPaused: true), TokenMintProblem.paused);
    });

    test("more decimals than the token's are refused", () {
      expect(tokenMintProblem(amount: 1.001, decimalPlaces: 2), TokenMintProblem.tooManyDecimals);
      expect(tokenMintProblem(amount: 0.5, decimalPlaces: 0), TokenMintProblem.tooManyDecimals);
      expect(tokenMintProblem(amount: 0.0000001, decimalPlaces: 6), TokenMintProblem.tooManyDecimals);
      expect(tokenMintProblem(amount: 0.0000001, decimalPlaces: 7), isNull);
      expect(tokenMintProblem(amount: 5, decimalPlaces: -1), TokenMintProblem.tooManyDecimals);
    });

    test('a mint past the largest supply or balance is refused', () {
      expect(tokenMintProblem(amount: 1e28, decimalPlaces: 0, currentSupply: 7e28), TokenMintProblem.overflow);
      expect(tokenMintProblem(amount: 1e28, decimalPlaces: 0, currentSupply: 0, holderBalance: 7e28), TokenMintProblem.overflow);
      expect(tokenMintProblem(amount: 1e28, decimalPlaces: 0, currentSupply: 1e28, holderBalance: 1e28), isNull);
    });

    test('double rounding near the limit never refuses a mint', () {
      // decimal.MaxValue - 1000 has room for 1, but as a double it is the
      // limit itself, so the wallet leaves the call to the node.
      const supply = 79228162514264337593543950335.0 - 1000;
      expect(supply, kTokenMaxAmount);
      expect(tokenMintProblem(amount: 1, decimalPlaces: 0, currentSupply: supply), isNull);
      expect(tokenMintProblem(amount: 1, decimalPlaces: 0, currentSupply: 0, holderBalance: supply), isNull);
    });

    test('unknown state is left to the node', () {
      expect(tokenMintProblem(amount: 1e29, decimalPlaces: 0), isNull);
      expect(tokenMintProblem(amount: 1.123456789, decimalPlaces: null), isNull);
    });
  });
}
