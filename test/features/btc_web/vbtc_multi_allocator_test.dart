import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/btc_web/utils/vbtc_multi_allocator.dart';

void main() {
  group('allocateVbtcInputs', () {
    test('takes from the largest balance first', () {
      final result = allocateVbtcInputs(
        {'small:1': 0.1, 'big:2': 0.5, 'mid:3': 0.3},
        0.6,
      );

      expect(result.ok, isTrue);
      expect(result.inputs.map((i) => i.scIdentifier), ['big:2', 'mid:3']);
      expect(result.inputs.map((i) => i.amount), [0.5, 0.1]);
    });

    test('breaks balance ties by contract id, ordinal order', () {
      final result = allocateVbtcInputs(
        {'zeta:9': 0.2, 'Alpha:1': 0.2, 'beta:2': 0.2},
        0.5,
      );

      expect(result.inputs.map((i) => i.scIdentifier),
          ['Alpha:1', 'beta:2', 'zeta:9']);
      expect(result.inputs.last.amount, 0.1);
    });

    test('input amounts sum to the total exactly', () {
      final result = allocateVbtcInputs(
        {'a:1': 0.1, 'b:2': 0.2, 'c:3': 0.3},
        0.6,
      );

      final sum = result.inputs.fold<double>(0, (s, i) => s + i.amount);
      expect(sum, 0.6);
      expect(result.available, 0.6);
    });

    test('uses a single input when one contract covers the total', () {
      final result = allocateVbtcInputs({'a:1': 1.0, 'b:2': 0.4}, 0.25);

      expect(result.inputs, hasLength(1));
      expect(result.inputs.single.scIdentifier, 'a:1');
      expect(result.inputs.single.amount, 0.25);
    });

    test('ignores zero and negative balances', () {
      final result = allocateVbtcInputs(
        {'empty:1': 0.0, 'neg:2': -0.5, 'ok:3': 0.2},
        0.2,
      );

      expect(result.inputs.map((i) => i.scIdentifier), ['ok:3']);
      expect(result.available, 0.2);
    });

    test('fails when the combined balance is short', () {
      final result = allocateVbtcInputs({'a:1': 0.1, 'b:2': 0.2}, 0.31);

      expect(result.ok, isFalse);
      expect(result.failure, VbtcAllocationFailure.insufficientBalance);
      expect(result.inputs, isEmpty);
      expect(result.available, 0.3);
    });

    test('fails when more than 25 inputs would be needed', () {
      final balances = {
        for (var i = 0; i < 30; i++) 'c:${i.toString().padLeft(2, '0')}': 0.01
      };
      final result = allocateVbtcInputs(balances, 0.26);

      expect(result.failure, VbtcAllocationFailure.tooManyInputs);
    });

    test('exactly 25 inputs is allowed', () {
      final balances = {
        for (var i = 0; i < 30; i++) 'c:${i.toString().padLeft(2, '0')}': 0.01
      };
      final result = allocateVbtcInputs(balances, 0.25);

      expect(result.ok, isTrue);
      expect(result.inputs, hasLength(25));
    });
  });

  group('buildVbtcMultiTransferData', () {
    test('emits exactly the five consensus keys', () {
      final data = buildVbtcMultiTransferData(
        fromAddress: 'VFXsender',
        toAddress: 'VFXrecipient',
        totalAmount: 0.5,
        inputs: const [
          VbtcAllocationInput(scIdentifier: 'abc:1234', amount: 0.3),
          VbtcAllocationInput(scIdentifier: 'def:5678', amount: 0.2),
        ],
      );

      expect(data.keys.toList(),
          ['Function', 'FromAddress', 'ToAddress', 'TotalAmount', 'Inputs']);
      expect(data['Function'], 'TransferVBTCMultiV2()');
      expect(data['TotalAmount'], 0.5);
      expect(data['Inputs'], [
        {'SCUID': 'abc:1234', 'Amount': 0.3},
        {'SCUID': 'def:5678', 'Amount': 0.2},
      ]);
    });
  });
}
