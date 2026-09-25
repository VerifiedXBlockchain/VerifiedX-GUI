import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/token/token_rules.dart';

void main() {
  group('isTokenTransferToSelf', () {
    const sender = 'xMfCxAbCdEfGhIjKlMnOpQrStUvWxYz1234';

    test('flags the identical address', () {
      expect(isTokenTransferToSelf(sender, sender), isTrue);
    });

    test('flags a case variant of the sender', () {
      expect(isTokenTransferToSelf(sender, sender.toLowerCase()), isTrue);
      expect(isTokenTransferToSelf(sender, sender.toUpperCase()), isTrue);
    });

    test('ignores surrounding whitespace', () {
      expect(isTokenTransferToSelf(sender, ' $sender\n'), isTrue);
    });

    test('allows a different recipient', () {
      expect(isTokenTransferToSelf(sender, 'xRBXAbCdEfGhIjKlMnOpQrStUvWxYz12345'), isFalse);
    });
  });
}
