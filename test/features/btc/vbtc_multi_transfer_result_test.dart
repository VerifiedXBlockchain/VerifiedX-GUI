import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/btc/models/vbtc_multi_transfer_result.dart';

void main() {
  group('VbtcMultiTransferResult.fromJson', () {
    test('parses the hash, total and per-contract allocations', () {
      final result = VbtcMultiTransferResult.fromJson({
        'Success': true,
        'Message': 'vBTC V2 multi-contract transfer transaction created',
        'TransactionHash': 'abc123',
        'From': 'VFXsender',
        'To': 'VFXrecipient',
        'TotalAmount': 0.5,
        'Allocations': [
          {'SmartContractUID': 'abc:1234', 'Amount': 0.3},
          {'SmartContractUID': 'def:5678', 'Amount': 0.2},
        ],
      });

      expect(result.transactionHash, 'abc123');
      expect(result.totalAmount, 0.5);
      expect(result.allocations, hasLength(2));
      expect(result.allocations.first.smartContractUid, 'abc:1234');
      expect(result.allocations.first.amount, 0.3);
      expect(result.allocations.last.smartContractUid, 'def:5678');
      expect(result.allocations.last.amount, 0.2);
    });

    test('treats a missing Allocations list as empty', () {
      final result = VbtcMultiTransferResult.fromJson({
        'TransactionHash': 'abc123',
        'TotalAmount': 1,
        'Allocations': null,
      });

      expect(result.allocations, isEmpty);
      expect(result.totalAmount, 1.0);
    });

    test('accepts whole-number amounts serialized as integers', () {
      final result = VbtcMultiTransferResult.fromJson({
        'TransactionHash': 'abc123',
        'TotalAmount': 2,
        'Allocations': [
          {'SmartContractUID': 'abc:1234', 'Amount': 2},
        ],
      });

      expect(result.allocations.single.amount, 2.0);
    });
  });
}
