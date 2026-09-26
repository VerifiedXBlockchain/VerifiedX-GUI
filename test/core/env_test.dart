import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/env.dart';

void main() {
  group('Env.isAutomation', () {
    test('is false unless the AUTOMATION dart-define is set', () {
      expect(Env.isAutomation, isFalse);
    });
  });
}
