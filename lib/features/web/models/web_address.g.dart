// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_WebAddress _$$_WebAddressFromJson(Map<String, dynamic> json) =>
    _$_WebAddress(
      address: json['address'] as String,
      balance: (json['balance'] as num).toDouble(),
      adnr: json['adnr'] as String?,
    );

Map<String, dynamic> _$$_WebAddressToJson(_$_WebAddress instance) =>
    <String, dynamic>{
      'address': instance.address,
      'balance': instance.balance,
      'adnr': instance.adnr,
    };