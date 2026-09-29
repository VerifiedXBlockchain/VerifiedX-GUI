import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/transactions/models/web_transaction.dart';
import 'package:rbx_wallet/features/web/utils/pending_debits.dart';

const _me = 'xMainAddress';
const _other = 'xSomeoneElse';

WebTransaction _tx({
  required String hash,
  String from = _me,
  double amount = 0,
  double fee = 0,
  bool isPending = true,
  Map<String, dynamic>? data,
}) {
  return WebTransaction(
    hash: hash,
    toAddress: _other,
    fromAddress: from,
    type: 0,
    amount: amount,
    fee: fee,
    date: DateTime(2026, 9, 25),
    height: 0,
    isPending: isPending,
    data: data == null ? null : jsonEncode(data),
  );
}

void main() {
  group('pendingVfxDebit', () {
    test('sums amount and fee of pending sends from the address', () {
      final txs = [
        _tx(hash: 'a', amount: 2, fee: 0.00001),
        _tx(hash: 'b', amount: 3, fee: 0.00002),
      ];
      expect(pendingVfxDebit(txs, _me), closeTo(5.00003, 1e-12));
    });

    test('ignores confirmed transactions and other senders', () {
      final txs = [
        _tx(hash: 'a', amount: 2, isPending: false),
        _tx(hash: 'b', amount: 3, from: _other),
      ];
      expect(pendingVfxDebit(txs, _me), 0);
    });

    test('counts a hash recorded twice only once', () {
      final txs = [
        _tx(hash: 'a', amount: 2, fee: 0.1),
        _tx(hash: 'a', amount: 0, fee: 0),
      ];
      expect(pendingVfxDebit(txs, _me), closeTo(2.1, 1e-12));
    });
  });

  group('pendingContractDebit', () {
    test('counts pending token transfers and burns of the same contract', () {
      final txs = [
        _tx(hash: 'a', data: {"Function": "TokenTransfer()", "ContractUID": "sc1", "Amount": 10}),
        _tx(hash: 'b', data: {"Function": "TokenBurn()", "ContractUID": "sc1", "Amount": 2.5}),
        _tx(hash: 'c', data: {"Function": "TokenTransfer()", "ContractUID": "sc2", "Amount": 99}),
        _tx(hash: 'd', data: {"Function": "TokenMint()", "ContractUID": "sc1", "Amount": 50}),
      ];
      expect(pendingContractDebit(txs, _me, 'sc1'), 12.5);
    });

    test('counts single and multi vBTC V2 transfers', () {
      final txs = [
        _tx(hash: 'a', data: {"Function": "TransferVBTCV2()", "ContractUID": "v1", "Amount": 0.1}),
        _tx(hash: 'b', data: {
          "Function": "TransferVBTCMultiV2()",
          "TotalAmount": 0.5,
          "Inputs": [
            {"SCUID": "v1", "Amount": 0.2},
            {"SCUID": "v2", "Amount": 0.3},
          ],
        }),
      ];
      expect(pendingContractDebit(txs, _me, 'v1'), closeTo(0.3, 1e-12));
      expect(pendingContractDebit(txs, _me, 'v2'), closeTo(0.3, 1e-12));
    });

    test('takes the copy with data when a hash was recorded twice', () {
      final txs = [
        _tx(hash: 'a'),
        _tx(hash: 'a', data: {"Function": "TransferVBTCV2()", "ContractUID": "v1", "Amount": 0.4}),
      ];
      expect(pendingContractDebit(txs, _me, 'v1'), closeTo(0.4, 1e-12));
    });

    test('ignores confirmed transactions', () {
      final txs = [
        _tx(hash: 'a', isPending: false, data: {"Function": "TokenTransfer()", "ContractUID": "sc1", "Amount": 10}),
      ];
      expect(pendingContractDebit(txs, _me, 'sc1'), 0);
    });
  });

  group('vfxSendShortfall', () {
    test('passes a send that fits after pending debits', () {
      expect(vfxSendShortfall(amount: 4, balance: 10, pendingDebit: 6, isVault: false), isNull);
    });

    test('reports the confirmed balance first', () {
      expect(vfxSendShortfall(amount: 11, balance: 10, pendingDebit: 0, isVault: false), VfxSendShortfall.balance);
    });

    test('reports pending sends that leave too little', () {
      expect(vfxSendShortfall(amount: 5, balance: 10, pendingDebit: 6, isVault: false), VfxSendShortfall.pending);
    });

    test('keeps a Vault at 0.5 VFX', () {
      expect(kVaultMinimumBalance, 0.5);
      expect(vfxSendShortfall(amount: 9.5, balance: 10, pendingDebit: 0, isVault: true), isNull);
      expect(vfxSendShortfall(amount: 9.6, balance: 10, pendingDebit: 0, isVault: true), VfxSendShortfall.vaultMinimum);
      expect(vfxSendShortfall(amount: 9.6, balance: 10, pendingDebit: 0, isVault: false), isNull);
    });

    test('spendableVfx never goes below zero', () {
      expect(spendableVfx(balance: 0.2, pendingDebit: 0, isVault: true), 0);
      expect(spendableVfx(balance: 1, pendingDebit: 2, isVault: false), 0);
    });
  });

  group('formatDebitAmount', () {
    test('drops trailing zeros and keeps at most 8 decimals', () {
      expect(formatDebitAmount(10), '10');
      expect(formatDebitAmount(0.5), '0.5');
      expect(formatDebitAmount(0.1 + 0.2), '0.3');
      expect(formatDebitAmount(0), '0');
      expect(formatDebitAmount(100.12345678), '100.12345678');
    });
  });
}
