// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bridge_lock_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_BridgeLockRequest _$$_BridgeLockRequestFromJson(Map<String, dynamic> json) =>
    _$_BridgeLockRequest(
      scUid: json['scUID'] as String,
      ownerAddress: json['ownerAddress'] as String,
      amount: json['amount'] as String,
      evmDestination: json['evmDestination'] as String,
    );

Map<String, dynamic> _$$_BridgeLockRequestToJson(
        _$_BridgeLockRequest instance) =>
    <String, dynamic>{
      'scUID': instance.scUid,
      'ownerAddress': instance.ownerAddress,
      'amount': instance.amount,
      'evmDestination': instance.evmDestination,
    };
