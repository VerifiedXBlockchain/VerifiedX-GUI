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

  group('vbtcSenderIsVault', () {
    test('is true for a Vault sender', () {
      expect(vbtcSenderIsVault('xRBXq4bSxCk3RK4MvUW3ZJ4t8hsQo1ULmzHp'), isTrue);
    });

    test('is false for a regular sender even when the owner is a Vault', () {
      // The Withdraw button used to test token.rbxAddress (the owner); a
      // regular holder of a Vault-owned contract must still be allowed.
      expect(vbtcSenderIsVault('RNiQrW3aBUWZhfadqKxPuN46iGaR13ox7P'), isFalse);
    });

    test('is false without a sender', () {
      expect(vbtcSenderIsVault(null), isFalse);
    });
  });
}
