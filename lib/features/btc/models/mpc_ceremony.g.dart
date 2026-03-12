// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mpc_ceremony.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_MpcCeremony _$$_MpcCeremonyFromJson(Map<String, dynamic> json) =>
    _$_MpcCeremony(
      ceremonyId: json['CeremonyId'] as String,
      status: mpcCeremonyStatusFromString(json['Status'] as String),
      progressPercentage: json['ProgressPercentage'] as int? ?? 0,
      depositAddress: json['DepositAddress'] as String?,
      frostGroupPublicKey: json['FrostGroupPublicKey'] as String?,
      dkgProof: json['DkgProof'] as String?,
      validatorCount: json['ValidatorCount'] as int?,
      requiredThreshold: json['RequiredThreshold'] as int?,
      proofBlockHeight: json['ProofBlockHeight'] as int?,
    );

Map<String, dynamic> _$$_MpcCeremonyToJson(_$_MpcCeremony instance) =>
    <String, dynamic>{
      'CeremonyId': instance.ceremonyId,
      'Status': _$MpcCeremonyStatusEnumMap[instance.status]!,
      'ProgressPercentage': instance.progressPercentage,
      'DepositAddress': instance.depositAddress,
      'FrostGroupPublicKey': instance.frostGroupPublicKey,
      'DkgProof': instance.dkgProof,
      'ValidatorCount': instance.validatorCount,
      'RequiredThreshold': instance.requiredThreshold,
      'ProofBlockHeight': instance.proofBlockHeight,
    };

const _$MpcCeremonyStatusEnumMap = {
  MpcCeremonyStatus.initiated: 'initiated',
  MpcCeremonyStatus.validatingValidators: 'validatingValidators',
  MpcCeremonyStatus.round1InProgress: 'round1InProgress',
  MpcCeremonyStatus.round2InProgress: 'round2InProgress',
  MpcCeremonyStatus.round3InProgress: 'round3InProgress',
  MpcCeremonyStatus.completed: 'completed',
  MpcCeremonyStatus.failed: 'failed',
  MpcCeremonyStatus.timedOut: 'timedOut',
};
