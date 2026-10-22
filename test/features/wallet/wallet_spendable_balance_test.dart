import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/wallet/models/wallet.dart';

void main() {
  group('Wallet.spendableBalance', () {
    test('a Vault with a timelocked send pending can spend only its available VFX', () {
      // As the wallet list builds a Vault from GetAllReserveAccounts: Balance
      // is set to TotalBalance.
      final vault = Wallet.fromJson({
        'Id': 0,
        'PublicKey': 'pub',
        'Address': 'xRBXGu5Fk3zFDPMzLH1zoFFajnVG61ZcEY',
        'Balance': 10.99998665,
        'IsValidating': false,
        'RecoveryAddress': 'xRecoveryAddress',
        'AvailableBalance': 8.99998665,
        'LockedBalance': 2.0,
        'TotalBalance': 10.99998665,
      });

      expect(vault.isReserved, isTrue);
      expect(vault.spendableBalance, 8.99998665);
    });

    test('an ordinary account spends its balance', () {
      final account = Wallet(id: 1, publicKey: 'pub', address: 'xD5hREu1jsJ4tmDmfYZPYhgQNJMGmMqjP6', balance: 248.87653108, isValidating: false);

      expect(account.spendableBalance, 248.87653108);
    });
  });
}
