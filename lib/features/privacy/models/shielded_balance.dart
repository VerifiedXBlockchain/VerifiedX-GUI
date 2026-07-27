import 'package:freezed_annotation/freezed_annotation.dart';

import 'shielded_commitment.dart';

part 'shielded_balance.freezed.dart';
part 'shielded_balance.g.dart';

@freezed
class ShieldedBalance with _$ShieldedBalance {
  const ShieldedBalance._();

  factory ShieldedBalance({
    @JsonKey(name: "ShieldedBalances") @Default({}) Map<String, double> shieldedBalances,
    @JsonKey(name: "UnspentCommitments") @Default(0) int unspentCommitments,
    @JsonKey(name: "UnspentSum") @Default(0.0) double unspentSum,
    @JsonKey(name: "LastScannedBlock") @Default(0) int lastScannedBlock,
    @JsonKey(name: "IsViewOnly") @Default(false) bool isViewOnly,
    @JsonKey(name: "Commitments") List<ShieldedCommitment>? commitments,
    // vBTC-specific fields (GetShieldedVbtcBalance returns a different shape)
    @JsonKey(name: "ShieldedVbtcBalance") @Default(0.0) double shieldedVbtcBalance,
    @JsonKey(name: "VbtcContractUid") String? vbtcContractUid,
  }) = _ShieldedBalance;

  factory ShieldedBalance.fromJson(Map<String, dynamic> json) => _$ShieldedBalanceFromJson(json);

  double get vfxBalance => shieldedBalances['VFX'] ?? 0.0;

  /// Returns the shielded balance for a specific vBTC contract.
  /// The vBTC endpoint returns the balance in [shieldedVbtcBalance] rather
  /// than in the [shieldedBalances] map, so we check both.
  double vbtcBalance(String contractUid) {
    if (shieldedVbtcBalance > 0) return shieldedVbtcBalance;
    return shieldedBalances['VBTC:$contractUid'] ?? shieldedBalances[contractUid] ?? 0.0;
  }
}
