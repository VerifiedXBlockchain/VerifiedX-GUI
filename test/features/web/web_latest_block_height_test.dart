import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/web/providers/web_latest_block_provider.dart';

void main() {
  group('freshCachedHeight', () {
    final now = DateTime(2026, 10, 19, 15, 0);

    test('a recently polled block stands in for a failed read', () {
      expect(freshCachedHeight(cachedHeight: 100, fetchedAt: now.subtract(const Duration(seconds: 30)), now: now), 100);
      expect(freshCachedHeight(cachedHeight: 100, fetchedAt: now.subtract(kMaxCachedBlockAge), now: now), 100);
    });

    test('a stale block is refused, so the caller reports the height unknown', () {
      // During an explorer outage around an activation height an old height
      // would have the wallet sign for the rules before it.
      expect(freshCachedHeight(cachedHeight: 100, fetchedAt: now.subtract(const Duration(minutes: 5)), now: now), isNull);
    });

    test('nothing cached, or never fetched, is unknown', () {
      expect(freshCachedHeight(cachedHeight: null, fetchedAt: now, now: now), isNull);
      expect(freshCachedHeight(cachedHeight: 100, fetchedAt: null, now: now), isNull);
    });
  });
}
