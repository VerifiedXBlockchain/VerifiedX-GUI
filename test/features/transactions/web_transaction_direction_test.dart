import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/transactions/models/web_transaction.dart';

const me = 'xVWNbcBXTtiiL7ZHCqxRP1q12tcgUTQA4m';
const myVault = 'xRBXGu5Fk3zFDPMzLH1zoFFajnVG61ZcEY';
const other = 'xW66fZGQFyrqaZixkQg3yZYJxQDtYk7VYx';

WebTransaction transfer({required String from, required String to}) => WebTransaction(
      hash: 'hash',
      toAddress: to,
      fromAddress: from,
      type: 0,
      // Spyglass reports a send as a positive amount.
      amount: 20,
      fee: 0.00001,
      date: DateTime.utc(2026, 10, 21),
      height: 1,
    );

void main() {
  group('WebTransaction.isIncomingFor', () {
    test('a send to someone else is outgoing, though its amount is positive', () {
      expect(transfer(from: me, to: other).isIncomingFor(address: me, raAddress: myVault), isFalse);
      expect(transfer(from: myVault, to: other).isIncomingFor(address: me, raAddress: myVault), isFalse);
    });

    test('a payment into the VFX account or its Vault is incoming', () {
      expect(transfer(from: other, to: me).isIncomingFor(address: me, raAddress: myVault), isTrue);
      expect(transfer(from: other, to: myVault).isIncomingFor(address: me, raAddress: myVault), isTrue);
    });

    test('without a Vault only the VFX address counts', () {
      expect(transfer(from: other, to: me).isIncomingFor(address: me, raAddress: null), isTrue);
      expect(transfer(from: me, to: other).isIncomingFor(address: me, raAddress: null), isFalse);
    });
  });
}
