import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/auth/models/web_btc_address_type.dart';

void main() {
  group('btcAddressTypeFromAddress on mainnet', () {
    WebBtcAddressType? detect(String address) => btcAddressTypeFromAddress(address, isTestNet: false);

    test('maps mainnet prefixes to their address types', () {
      expect(detect('1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2'), WebBtcAddressType.p2pkh);
      expect(detect('3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy'), WebBtcAddressType.p2sh);
      expect(detect('bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq'), WebBtcAddressType.bech32);
      expect(detect('bc1p5d7rjq7g6rdk2yhzks9smlaqtedr4dekq08ge8ztwac72sfr9rusxg3297'), WebBtcAddressType.bech32m);
    });

    test('accepts uppercase bech32 and surrounding whitespace', () {
      expect(detect('  BC1QAR0SRRR7XFKVY5L643LYDNW9RE59GTZZWF5MDQ '), WebBtcAddressType.bech32);
    });

    test('rejects testnet prefixes and unknown input', () {
      expect(detect('tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx'), isNull);
      expect(detect('tb1pqqqqp399et2xygdj5xreqhjjvcmzhxw4aywxecjdzew6hylgvsesf3hn0c'), isNull);
      expect(detect('mipcBbFg9gMiCh81Kj8tqqdgoZub1ZJRfn'), isNull);
      expect(detect('n3GNqMveyvaPvUbH469vDRadqpJMPc84JA'), isNull);
      expect(detect('2MzQwSSnBHWHqSAqtTVQ6v47XtaisrJa1Vc'), isNull);
      expect(detect(''), isNull);
      expect(detect('RBxNotABitcoinAddress'), isNull);
    });
  });

  group('btcAddressTypeFromAddress on testnet', () {
    WebBtcAddressType? detect(String address) => btcAddressTypeFromAddress(address, isTestNet: true);

    test('maps testnet prefixes to their address types', () {
      expect(detect('mipcBbFg9gMiCh81Kj8tqqdgoZub1ZJRfn'), WebBtcAddressType.p2pkh);
      expect(detect('n3GNqMveyvaPvUbH469vDRadqpJMPc84JA'), WebBtcAddressType.p2pkh);
      expect(detect('2MzQwSSnBHWHqSAqtTVQ6v47XtaisrJa1Vc'), WebBtcAddressType.p2sh);
      expect(detect('tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx'), WebBtcAddressType.bech32);
      expect(detect('tb1pqqqqp399et2xygdj5xreqhjjvcmzhxw4aywxecjdzew6hylgvsesf3hn0c'), WebBtcAddressType.bech32m);
    });

    test('still rejects unknown input', () {
      expect(detect(''), isNull);
      expect(detect('RBxNotABitcoinAddress'), isNull);
    });
  });
}
