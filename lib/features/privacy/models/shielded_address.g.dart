// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shielded_address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ShieldedAddress _$$_ShieldedAddressFromJson(Map<String, dynamic> json) =>
    _$_ShieldedAddress(
      zfxAddress: json['ZfxAddress'] as String,
      transparentSourceAddress:
          json['TransparentSourceAddress'] as String? ?? "",
    );

Map<String, dynamic> _$$_ShieldedAddressToJson(_$_ShieldedAddress instance) =>
    <String, dynamic>{
      'ZfxAddress': instance.zfxAddress,
      'TransparentSourceAddress': instance.transparentSourceAddress,
    };
