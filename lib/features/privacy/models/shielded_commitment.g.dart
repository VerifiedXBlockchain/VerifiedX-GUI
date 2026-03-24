// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shielded_commitment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ShieldedCommitment _$$_ShieldedCommitmentFromJson(
        Map<String, dynamic> json) =>
    _$_ShieldedCommitment(
      commitment: json['Commitment'] as String,
      assetType: json['AssetType'] as String,
      amount: (json['Amount'] as num?)?.toDouble() ?? 0.0,
      treePosition: json['TreePosition'] as int? ?? 0,
      blockHeight: json['BlockHeight'] as int? ?? 0,
      isSpent: json['IsSpent'] as bool? ?? false,
    );

Map<String, dynamic> _$$_ShieldedCommitmentToJson(
        _$_ShieldedCommitment instance) =>
    <String, dynamic>{
      'Commitment': instance.commitment,
      'AssetType': instance.assetType,
      'Amount': instance.amount,
      'TreePosition': instance.treePosition,
      'BlockHeight': instance.blockHeight,
      'IsSpent': instance.isSpent,
    };
