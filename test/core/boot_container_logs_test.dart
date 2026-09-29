import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/components/boot_container.dart';

void main() {
  group('latestBootLogs', () {
    test('returns nothing for no logs', () {
      expect(latestBootLogs(<String>[]), isEmpty);
    });

    test('shows a single log line', () {
      expect(latestBootLogs(['Starting VFXCore...']), ['Starting VFXCore...']);
    });

    test('keeps every line, including the newest, below the cap', () {
      expect(latestBootLogs(['a', 'b', 'c']), ['a', 'b', 'c']);
    });

    test('keeps the newest lines up to the cap', () {
      final logs = List.generate(10, (i) => 'line $i');
      final shown = latestBootLogs(logs);

      expect(shown, hasLength(bootLogMaxLines));
      expect(shown.first, 'line 3');
      expect(shown.last, 'line 9');
    });

    test('shows exactly the cap when there are exactly that many lines', () {
      final logs = List.generate(bootLogMaxLines, (i) => 'line $i');
      expect(latestBootLogs(logs), logs);
    });
  });
}
