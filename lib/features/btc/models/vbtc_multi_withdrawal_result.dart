import '../../btc_web/utils/vbtc_multi_allocator.dart';

/// Successful `POST /vbtcapi/vbtc/RequestWithdrawalMulti` response.
///
/// Core picks the vaults itself (largest first), so [allocations] is the only
/// record of which vaults the request draws on; each is paid by its own
/// Bitcoin transaction. When one vault covers the total Core sends the
/// single-vault shape and still reports one allocation.
class VbtcMultiWithdrawalResult {
  final String requestHash;
  final List<VbtcAllocationInput> allocations;

  const VbtcMultiWithdrawalResult({
    required this.requestHash,
    required this.allocations,
  });

  factory VbtcMultiWithdrawalResult.fromJson(Map<String, dynamic> json) {
    final rawAllocations = json['Allocations'];
    return VbtcMultiWithdrawalResult(
      requestHash: json['RequestHash'] as String,
      allocations: rawAllocations is List ? vbtcWithdrawalSharesFromJson(rawAllocations) : const [],
    );
  }
}

/// Core's `VBTCV2MultiWithdrawalInput` list (`{SCUID, Amount}`), as in a
/// request's answer or a multi request's transaction `Data.Inputs`.
List<VbtcAllocationInput> vbtcWithdrawalSharesFromJson(List<dynamic> json) {
  return json
      .whereType<Map>()
      .where((a) => a['SCUID'] is String && a['Amount'] is num)
      .map((a) => VbtcAllocationInput(
            scIdentifier: a['SCUID'] as String,
            amount: (a['Amount'] as num).toDouble(),
          ))
      .toList();
}
