/// One contract debited by a multi-contract vBTC transfer, as reported in the
/// CLI's `TransferVBTCMulti` response.
class VbtcMultiTransferAllocation {
  final String smartContractUid;
  final double amount;

  const VbtcMultiTransferAllocation({
    required this.smartContractUid,
    required this.amount,
  });

  factory VbtcMultiTransferAllocation.fromJson(Map<String, dynamic> json) {
    return VbtcMultiTransferAllocation(
      smartContractUid: json['SmartContractUID'] as String,
      amount: (json['Amount'] as num).toDouble(),
    );
  }
}

/// Successful `POST /vbtcapi/vbtc/TransferVBTCMulti` response.
///
/// The CLI chooses the inputs itself, so [allocations] is the only record of
/// which contracts were debited. When a single contract covers the total the
/// CLI broadcasts a plain single-contract transfer and still reports one
/// allocation here.
class VbtcMultiTransferResult {
  final String transactionHash;
  final double totalAmount;
  final List<VbtcMultiTransferAllocation> allocations;

  const VbtcMultiTransferResult({
    required this.transactionHash,
    required this.totalAmount,
    required this.allocations,
  });

  factory VbtcMultiTransferResult.fromJson(Map<String, dynamic> json) {
    final rawAllocations = json['Allocations'];
    return VbtcMultiTransferResult(
      transactionHash: json['TransactionHash'] as String,
      totalAmount: (json['TotalAmount'] as num).toDouble(),
      allocations: rawAllocations is List
          ? rawAllocations
              .map((a) => VbtcMultiTransferAllocation.fromJson(
                  a as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }
}
