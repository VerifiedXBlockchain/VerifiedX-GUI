import 'package:freezed_annotation/freezed_annotation.dart';

part 'shielded_commitment.freezed.dart';
part 'shielded_commitment.g.dart';

@freezed
class ShieldedCommitment with _$ShieldedCommitment {
  const ShieldedCommitment._();

  factory ShieldedCommitment({
    @JsonKey(name: "Commitment") required String commitment,
    @JsonKey(name: "AssetType") required String assetType,
    @JsonKey(name: "Amount") @Default(0.0) double amount,
    @JsonKey(name: "TreePosition") @Default(0) int treePosition,
    @JsonKey(name: "BlockHeight") @Default(0) int blockHeight,
    @JsonKey(name: "IsSpent") @Default(false) bool isSpent,
  }) = _ShieldedCommitment;

  factory ShieldedCommitment.fromJson(Map<String, dynamic> json) => _$ShieldedCommitmentFromJson(json);
}
