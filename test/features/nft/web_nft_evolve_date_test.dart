import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/nft/models/web_nft.dart';

void main() {
  group('webEvolveDate', () {
    test('reads the ISO date the chain stores for a date/time stage', () {
      expect(webEvolveDate('2026-10-22T04:00:00Z'), DateTime.utc(2026, 10, 22, 4));
    });

    test('still reads epoch seconds', () {
      expect(webEvolveDate(1792641600), DateTime.fromMillisecondsSinceEpoch(1792641600 * 1000));
    });

    test('a stage without a date, or with an unreadable one, has none', () {
      expect(webEvolveDate(null), isNull);
      expect(webEvolveDate('not a date'), isNull);
    });
  });
}
