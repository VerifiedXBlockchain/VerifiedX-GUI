import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/privacy/utils/unshield_amount.dart';

void main() {
  group('unshieldAmountFitsProof', () {
    test('accepts up to 8 decimal places', () {
      expect(unshieldAmountFitsProof('1'), isTrue);
      expect(unshieldAmountFitsProof('0.5'), isTrue);
      expect(unshieldAmountFitsProof('0.00000001'), isTrue);
      // Trailing zeros carry no precision.
      expect(unshieldAmountFitsProof('0.1000000000'), isTrue);
    });

    test('refuses a ninth decimal place, which the proof would truncate', () {
      expect(unshieldAmountFitsProof('0.000000001'), isFalse);
      expect(unshieldAmountFitsProof('1.123456789'), isFalse);
    });

    test('refuses what is not a plain decimal', () {
      expect(unshieldAmountFitsProof('1e-9'), isFalse);
      expect(unshieldAmountFitsProof(''), isFalse);
    });
  });
}
