import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/env.dart';

void main() {
  group('Env.isAutomation', () {
    test('is false unless the AUTOMATION dart-define is set', () {
      expect(Env.isAutomation, isFalse);
    });
  });

  group('Env.explorerTransactionUrl', () {
    test('joins the explorer base and hash with a single slash', () {
      final url = Env.explorerTransactionUrl('abc123');
      expect(url, '${Env.explorerWebsiteBaseUrl}/transaction/abc123');
      expect(url.replaceFirst('https://', ''), isNot(contains('//')));
    });
  });
}
