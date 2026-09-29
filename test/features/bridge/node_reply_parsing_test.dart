import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/bridge/services/bridge_service.dart';

void main() {
  group('BridgeService.newAddressRefusal', () {
    test('returns the reason after the remediated "Fail." prefix', () {
      expect(
        BridgeService.newAddressRefusal(
          'Fail. No address was created: an encrypted wallet must be unlocked with its password, and an HD wallet cannot be used in an encrypted wallet.',
        ),
        'No address was created: an encrypted wallet must be unlocked with its password, and an HD wallet cannot be used in an encrypted wallet.',
      );
    });

    test('returns an empty reason for the bare "Fail" reply', () {
      expect(BridgeService.newAddressRefusal('Fail'), '');
    });

    test('does not treat the JSON address reply as a refusal', () {
      expect(BridgeService.newAddressRefusal('[{"Address":"xAbc","PrivateKey":"0f4b"}]'), isNull);
    });
  });

  group('BridgeService.hdRestoreFailure', () {
    test('accepts both restored replies', () {
      expect(BridgeService.hdRestoreFailure('{"Result":"Mnemonic Restored... 3 previously used address(es) restored."}'), isNull);
      expect(
        BridgeService.hdRestoreFailure(
          '{"Result":"Mnemonic Restored... Address scan failed after restoring 1 address(es). Remaining addresses can be re-derived one at a time with the new address command."}',
        ),
        isNull,
      );
    });

    test('returns the refusal text', () {
      expect(
        BridgeService.hdRestoreFailure('{"Result":"An HD wallet cannot be used in an encrypted wallet: its seed and derived keys would be stored unencrypted."}'),
        'An HD wallet cannot be used in an encrypted wallet: its seed and derived keys would be stored unencrypted.',
      );
      expect(BridgeService.hdRestoreFailure('{"Result":"HD Wallet Already Exist"}'), 'HD Wallet Already Exist');
      expect(BridgeService.hdRestoreFailure('{"Result":"Invalid Mnemonic Entered... Please Try again."}'), 'Invalid Mnemonic Entered... Please Try again.');
    });

    test('returns the plain-text error reply', () {
      expect(BridgeService.hdRestoreFailure('ERROR! Message: FormatException: bad word'), 'ERROR! Message: FormatException: bad word');
    });
  });
}
