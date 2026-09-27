import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/send/utils.dart';

void main() {
  group('prefilledSendAmountText', () {
    test('keeps a numeric amount', () {
      expect(prefilledSendAmountText('12.5'), '12.5');
      expect(prefilledSendAmountText('3'), '3.0');
    });

    test('returns empty for a non-numeric amount instead of throwing', () {
      expect(prefilledSendAmountText('abc'), '');
      expect(prefilledSendAmountText(''), '');
      expect(prefilledSendAmountText('1,5'), '');
    });

    test('returns empty for zero, negative, NaN and infinite amounts', () {
      expect(prefilledSendAmountText('0'), '');
      expect(prefilledSendAmountText('-2'), '');
      expect(prefilledSendAmountText('NaN'), '');
      expect(prefilledSendAmountText('Infinity'), '');
    });
  });

  group('sanitizePastedSendAddress', () {
    test('keeps the dot in a .vfx domain', () {
      expect(sanitizePastedSendAddress('name.vfx'), 'name.vfx');
    });

    test('strips whitespace and characters invalid in addresses and domains', () {
      expect(sanitizePastedSendAddress('  xAbc123\n'), 'xAbc123');
      expect(sanitizePastedSendAddress('"name.vfx",'), 'name.vfx');
    });
  });
}
