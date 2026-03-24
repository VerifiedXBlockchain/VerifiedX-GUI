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
  }) = _ShieldedBalance;

  factory ShieldedBalance.fromJson(Map<String, dynamic> json) => _$ShieldedBalanceFromJson(json);

  double get vfxBalance => shieldedBalances['VFX'] ?? 0.0;
}
