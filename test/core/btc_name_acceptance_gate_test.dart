import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/app_constants.dart';

void main() {
  group('btcNameAcceptanceAvailable', () {
    test('hidden while the signed BTC domain messages are not active', () {
      // BTC_NAME_SIGNED_MESSAGE_HEIGHT is still the placeholder on both networks.
      expect(btcNameAcceptanceAvailable(1180700), isFalse);
    });

    test('hidden while the chain height is unknown', () {
      expect(btcNameAcceptanceAvailable(null), isFalse);
    });

    test('offered from the block before the activation height, as the signing flows switch', () {
      expect(btcNameAcceptanceAvailable(BTC_NAME_SIGNED_MESSAGE_HEIGHT - 1), isTrue);
      expect(btcNameAcceptanceAvailable(BTC_NAME_SIGNED_MESSAGE_HEIGHT - 2), isFalse);
    });
  });
}
