import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/utils/html_helpers.dart';

void main() {
  group('HtmlHelpers (non-web implementation)', () {
    test('enableSemantics returns false because there is no DOM', () {
      expect(HtmlHelpers().enableSemantics(), isFalse);
    });
  });
}
