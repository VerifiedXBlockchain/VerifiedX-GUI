// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shielded_address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ShieldedAddress _$$_ShieldedAddressFromJson(Map<String, dynamic> json) =>
    _$_ShieldedAddress(
      zfxAddress: json['ZfxAddress'] as String,
      derivationPath: json['DerivationPath'] as String,
      coinType: json['CoinType'] as int? ?? 889,
      addressIndex: json['AddressIndex'] as int? ?? 0,
    );

Map<String, dynamic> _$$_ShieldedAddressToJson(_$_ShieldedAddress instance) =>
    <String, dynamic>{
      'ZfxAddress': instance.zfxAddress,
      'DerivationPath': instance.derivationPath,
      'CoinType': instance.coinType,
      'AddressIndex': instance.addressIndex,
    };
