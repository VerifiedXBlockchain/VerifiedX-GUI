import '../../../core/app_constants.dart';

const int _satsPerVbtc = 100000000;

int _toSats(double amount) => (amount * _satsPerVbtc).round();
double _fromSats(int sats) => sats / _satsPerVbtc;

/// One contract's share of a multi-contract vBTC transfer.
class VbtcAllocationInput {
  final String scIdentifier;
  final double amount;

  const VbtcAllocationInput({
    required this.scIdentifier,
    required this.amount,
  });
}

enum VbtcAllocationFailure { insufficientBalance, tooManyInputs }

class VbtcAllocation {
  final List<VbtcAllocationInput> inputs;
  final VbtcAllocationFailure? failure;

  /// Combined spendable balance across every candidate, after rounding.
  final double available;

  const VbtcAllocation({
    required this.inputs,
    required this.available,
    this.failure,
  });

  bool get ok => failure == null;
}

/// Splits [total] across [balances] (contract id to spendable vBTC) the way
/// the CLI's own allocator does: largest balance first, ties broken by
/// ordinal contract id, greedy until covered.
///
/// Works in integer satoshis so the input amounts sum to the total exactly;
/// consensus rejects any drift between `TotalAmount` and the inputs.
VbtcAllocation allocateVbtcInputs(Map<String, double> balances, double total) {
  final candidates = balances.entries
      .map((e) => MapEntry(e.key, _toSats(e.value)))
      .where((e) => e.value > 0)
      .toList()
    ..sort((a, b) {
      final byBalance = b.value.compareTo(a.value);
      return byBalance != 0 ? byBalance : a.key.compareTo(b.key);
    });

  final available =
      _fromSats(candidates.fold<int>(0, (sum, e) => sum + e.value));

  var remaining = _toSats(total);
  final inputs = <VbtcAllocationInput>[];
  for (final candidate in candidates) {
    if (remaining <= 0) {
      break;
    }
    final take = remaining < candidate.value ? remaining : candidate.value;
    inputs.add(VbtcAllocationInput(
      scIdentifier: candidate.key,
      amount: _fromSats(take),
    ));
    remaining -= take;
  }

  if (remaining > 0) {
    return VbtcAllocation(
      inputs: const [],
      available: available,
      failure: VbtcAllocationFailure.insufficientBalance,
    );
  }
  if (inputs.length > VBTC_MULTI_MAX_INPUTS) {
    return VbtcAllocation(
      inputs: const [],
      available: available,
      failure: VbtcAllocationFailure.tooManyInputs,
    );
  }
  return VbtcAllocation(inputs: inputs, available: available);
}

/// The `Data` payload for a `TransferVBTCMultiV2()` transaction. Exactly
/// these five keys: consensus rejects a top-level `ContractUID`.
Map<String, dynamic> buildVbtcMultiTransferData({
  required String fromAddress,
  required String toAddress,
  required double totalAmount,
  required List<VbtcAllocationInput> inputs,
}) {
  return {
    "Function": "TransferVBTCMultiV2()",
    "FromAddress": fromAddress,
    "ToAddress": toAddress,
    "TotalAmount": _fromSats(_toSats(totalAmount)),
    "Inputs": inputs
        .map((input) => {"SCUID": input.scIdentifier, "Amount": input.amount})
        .toList(),
  };
}
