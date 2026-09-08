import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/bridge/utils/cli_exit.dart';

void main() {
  group('waitUntilCliStops', () {
    test('returns true once the CLI stops answering', () async {
      var polls = 0;
      final stopped = await waitUntilCliStops(
        () async => ++polls < 3,
        maxWait: const Duration(seconds: 1),
        interval: const Duration(milliseconds: 1),
      );

      expect(stopped, isTrue);
      expect(polls, 3);
    });

    test('returns false when the CLI keeps answering past the deadline',
        () async {
      var polls = 0;
      final stopped = await waitUntilCliStops(
        () async {
          polls++;
          return true;
        },
        maxWait: const Duration(milliseconds: 200),
        interval: const Duration(milliseconds: 10),
      );

      expect(stopped, isFalse);
      expect(polls, greaterThanOrEqualTo(1));
    });
  });
}
