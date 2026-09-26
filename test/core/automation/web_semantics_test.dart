import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/automation/web_semantics.dart';

void main() {
  group('retryUntilTrue', () {
    test('returns true after the first successful attempt', () async {
      var calls = 0;
      final result = await retryUntilTrue(
        () {
          calls++;
          return true;
        },
        delay: Duration.zero,
      );
      expect(result, isTrue);
      expect(calls, 1);
    });

    test('keeps trying until an attempt succeeds', () async {
      var calls = 0;
      final result = await retryUntilTrue(
        () {
          calls++;
          return calls == 3;
        },
        maxAttempts: 10,
        delay: Duration.zero,
      );
      expect(result, isTrue);
      expect(calls, 3);
    });

    test('gives up after maxAttempts and returns false', () async {
      var calls = 0;
      final result = await retryUntilTrue(
        () {
          calls++;
          return false;
        },
        maxAttempts: 4,
        delay: Duration.zero,
      );
      expect(result, isFalse);
      expect(calls, 4);
    });

    test('waits delay between attempts but not after the last one', () {
      fakeAsync((async) {
        var calls = 0;
        bool? result;
        retryUntilTrue(
          () {
            calls++;
            return false;
          },
          maxAttempts: 3,
          delay: const Duration(milliseconds: 300),
        ).then((value) => result = value);

        async.flushMicrotasks();
        expect(calls, 1);
        expect(result, isNull);

        async.elapse(const Duration(milliseconds: 300));
        expect(calls, 2);
        expect(result, isNull);

        async.elapse(const Duration(milliseconds: 300));
        expect(calls, 3);
        expect(result, isFalse);
      });
    });
  });

  group('enableWebSemanticsForAutomation', () {
    test('does nothing outside an automation web build', () {
      // No binding is initialised here: if the guard were missing this would
      // throw when it reached WidgetsBinding.instance.
      expect(enableWebSemanticsForAutomation, returnsNormally);
    });
  });
}
