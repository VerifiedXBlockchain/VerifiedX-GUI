// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shielded_balance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ShieldedBalance _$$_ShieldedBalanceFromJson(Map<String, dynamic> json) =>
    _$_ShieldedBalance(
      shieldedBalances:
          (json['ShieldedBalances'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, (e as num).toDouble()),
              ) ??
              const {},
      unspentCommitments: json['UnspentCommitments'] as int? ?? 0,
      unspentSum: (json['UnspentSum'] as num?)?.toDouble() ?? 0.0,
      lastScannedBlock: json['LastScannedBlock'] as int? ?? 0,
      isViewOnly: json['IsViewOnly'] as bool? ?? false,
      commitments: (json['Commitments'] as List<dynamic>?)
          ?.map((e) => ShieldedCommitment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$_ShieldedBalanceToJson(_$_ShieldedBalance instance) =>
    <String, dynamic>{
      'ShieldedBalances': instance.shieldedBalances,
      'UnspentCommitments': instance.unspentCommitments,
      'UnspentSum': instance.unspentSum,
      'LastScannedBlock': instance.lastScannedBlock,
      'IsViewOnly': instance.isViewOnly,
      'Commitments': instance.commitments,
    };
