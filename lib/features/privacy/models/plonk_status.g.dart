// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plonk_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_PlonkStatus _$$_PlonkStatusFromJson(Map<String, dynamic> json) =>
    _$_PlonkStatus(
      proofProvingImplemented:
          json['ProofProvingImplemented'] as bool? ?? false,
      proofVerificationImplemented:
          json['ProofVerificationImplemented'] as bool? ?? false,
      enforcePlonkProofsForZk:
          json['EnforcePlonkProofsForZk'] as bool? ?? false,
      capVerifyV1: json['CapVerifyV1'] as bool? ?? false,
      capProveV1: json['CapProveV1'] as bool? ?? false,
    );

Map<String, dynamic> _$$_PlonkStatusToJson(_$_PlonkStatus instance) =>
    <String, dynamic>{
      'ProofProvingImplemented': instance.proofProvingImplemented,
      'ProofVerificationImplemented': instance.proofVerificationImplemented,
      'EnforcePlonkProofsForZk': instance.enforcePlonkProofsForZk,
      'CapVerifyV1': instance.capVerifyV1,
      'CapProveV1': instance.capProveV1,
    };
