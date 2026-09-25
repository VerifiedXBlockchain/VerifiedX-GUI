import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/token/token_rules.dart';

void main() {
  group('isTokenTransferToSelf', () {
    const sender = 'xMfCxAbCdEfGhIjKlMnOpQrStUvWxYz1234';

    test('flags the identical address', () {
      expect(isTokenTransferToSelf(sender, sender), isTrue);
    });

    test('flags a case variant of the sender', () {
      expect(isTokenTransferToSelf(sender, sender.toLowerCase()), isTrue);
      expect(isTokenTransferToSelf(sender, sender.toUpperCase()), isTrue);
    });

    test('ignores surrounding whitespace', () {
      expect(isTokenTransferToSelf(sender, ' $sender\n'), isTrue);
    });

    test('allows a different recipient', () {
      expect(isTokenTransferToSelf(sender, 'xRBXAbCdEfGhIjKlMnOpQrStUvWxYz12345'), isFalse);
    });
  });

  group('isValidTokenSupply', () {
    test('accepts whole numbers from 0 to the int32 maximum', () {
      expect(isValidTokenSupply('0'), isTrue);
      expect(isValidTokenSupply('1'), isTrue);
      expect(isValidTokenSupply('1000000'), isTrue);
      expect(isValidTokenSupply('2147483647'), isTrue);
      expect(kTokenMaxSupply, 2147483647);
    });

    test('accepts the double form the form shows for a stored supply', () {
      expect(isValidTokenSupply('1000.0'), isTrue);
      expect(isValidTokenSupply('2147483647.0'), isTrue);
      expect(isValidTokenSupply(' 500 '), isTrue);
    });

    test('refuses a supply above the int32 maximum', () {
      expect(isValidTokenSupply('2147483648'), isFalse);
      expect(isValidTokenSupply('2147483648.0'), isFalse);
      expect(isValidTokenSupply('99999999999999999999999'), isFalse);
    });

    test('refuses fractions, negatives, exponents and text', () {
      expect(isValidTokenSupply('1.5'), isFalse);
      expect(isValidTokenSupply('-1'), isFalse);
      expect(isValidTokenSupply('1e9'), isFalse);
      expect(isValidTokenSupply(''), isFalse);
      expect(isValidTokenSupply('abc'), isFalse);
    });
  });
}
