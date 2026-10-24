import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/privacy/services/privacy_service.dart';

void main() {
  group('shieldedWalletHeldFromResult', () {
    test('a wallet the node holds reports its LastScannedBlock', () {
      expect(
        shieldedWalletHeldFromResult({
          'Success': true,
          'Result': {'ShieldedBalances': {'VFX': 1.5}, 'UnspentCommitments': 2, 'LastScannedBlock': 7785, 'IsViewOnly': false},
        }),
        isTrue,
      );
    });

    test('a held wallet that has not scanned yet still counts as held', () {
      expect(shieldedWalletHeldFromResult({'Success': true, 'Result': {'ShieldedBalances': {}, 'UnspentCommitments': 0, 'LastScannedBlock': 0, 'IsViewOnly': false}}), isTrue);
    });

    test('an address the node does not hold answers with an empty balance only', () {
      expect(shieldedWalletHeldFromResult({'Success': true, 'Result': {'ShieldedBalances': {}, 'UnspentCommitments': 0}}), isFalse);
    });

    test('a failed or unreadable answer decides nothing', () {
      expect(shieldedWalletHeldFromResult({'Success': false, 'Message': 'zfxAddress query required.'}), isNull);
      expect(shieldedWalletHeldFromResult({'Success': true}), isNull);
    });
  });
}
