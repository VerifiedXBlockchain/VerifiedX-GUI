import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/btc/utils.dart';

void main() {
  const owner = 'OWNER_ADDRESS';
  const holder = 'HOLDER_ADDRESS';

  group('vbtcTransferSenderAddress', () {
    test('V2 sends from the current wallet, not the contract owner', () {
      expect(
        vbtcTransferSenderAddress(
          version: 2,
          ownerAddress: owner,
          currentWalletAddress: holder,
        ),
        holder,
      );
    });

    test('V2 with no current wallet has no sender', () {
      expect(
        vbtcTransferSenderAddress(
          version: 2,
          ownerAddress: owner,
          currentWalletAddress: null,
        ),
        isNull,
      );
    });

    test('V1 sends from the token owner', () {
      expect(
        vbtcTransferSenderAddress(
          version: 1,
          ownerAddress: owner,
          currentWalletAddress: holder,
        ),
        owner,
      );
    });
  });
}
