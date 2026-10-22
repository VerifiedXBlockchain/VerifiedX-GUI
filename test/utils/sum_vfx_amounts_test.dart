import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/utils/formatting.dart';

void main() {
  group('sumVfxAmounts', () {
    test('adds 8-decimal balances without float noise', () {
      // As plain doubles this sum is 274.99998786000003.
      expect(248.87653108 + 26.12345678 + 0.0, isNot(274.99998786));
      expect(sumVfxAmounts([248.87653108, 26.12345678, 0.0]), 274.99998786);
      expect('${sumVfxAmounts([248.87653108, 26.12345678, 0.0])}', '274.99998786');
    });

    test('an empty wallet list totals 0', () {
      expect(sumVfxAmounts([]), 0);
    });
  });
}
