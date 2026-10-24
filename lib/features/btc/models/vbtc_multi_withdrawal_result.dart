import 'dart:convert';

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

/// What the node would send for a multi-vault withdrawal, from
/// `POST /vbtcapi/vbtc/GetRawRequestWithdrawalMultiTxData` without inputs:
/// Core's own allocation (the same plan `RequestWithdrawalMulti` uses) and
/// which of those vaults the chain watches. Nothing is signed or sent.
class VbtcMultiWithdrawalPreview {
  final List<VbtcAllocationInput> allocations;
  final Set<String> attestedContracts;

  const VbtcMultiWithdrawalPreview({
    required this.allocations,
    required this.attestedContracts,
  });

  factory VbtcMultiWithdrawalPreview.fromJson(Map<String, dynamic> json) {
    final rawAllocations = json['Allocations'];
    final rawAttested = json['AttestedContracts'];
    return VbtcMultiWithdrawalPreview(
      allocations: rawAllocations is List ? vbtcWithdrawalSharesFromJson(rawAllocations) : const [],
      attestedContracts: rawAttested is List ? rawAttested.whereType<String>().toSet() : const {},
    );
  }

  /// Vaults in the allocation the chain does not watch. A share on one
  /// would need a FROST completion this flow does not run, so the request
  /// is refused while this is not empty. An allocation Core did not report
  /// counts as unwatched too.
  List<String> get unwatchedVaults {
    if (allocations.isEmpty) return const ['(none reported)'];
    return allocations.map((a) => a.scIdentifier).where((id) => !attestedContracts.contains(id)).toList();
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

/// The parts a multi-vault withdrawal request names, read from its
/// transaction `Data` (a JSON string, or the object already decoded, either
/// possibly wrapped in a list), or null when the transaction is not one
/// (`VBTCWithdrawalRequestMultiV2()`).
List<VbtcAllocationInput>? vbtcMultiWithdrawalSharesOf(dynamic data) {
  dynamic decoded = data;
  if (data is String) {
    if (data.isEmpty) return null;
    try {
      decoded = jsonDecode(data);
    } on FormatException {
      return null;
    }
  }
  if (decoded is List && decoded.isNotEmpty) decoded = decoded.first;
  if (decoded is! Map || decoded['Function'] != vbtcMultiWithdrawalFunction) return null;
  final inputs = decoded['Inputs'];
  if (inputs is! List) return null;
  final shares = vbtcWithdrawalSharesFromJson(inputs);
  return shares.isEmpty ? null : shares;
}

/// Core's `VBTCService.MultiWithdrawalFunction`.
const vbtcMultiWithdrawalFunction = "VBTCWithdrawalRequestMultiV2()";
