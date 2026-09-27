// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_WebAddress _$$_WebAddressFromJson(Map<String, dynamic> json) =>
    _$_WebAddress(
      address: json['address'] as String,
      balance: const NumOrStringDoubleConverter()
          .fromJson(json['balance'] as Object),
      balanceTotal: json['balance_total'] == null
          ? 0
          : const NumOrStringDoubleConverter()
              .fromJson(json['balance_total'] as Object),
      balanceLocked: json['balance_locked'] == null
          ? 0
          : const NumOrStringDoubleConverter()
              .fromJson(json['balance_locked'] as Object),
      adnr: json['adnr'] as String?,
      activated: json['activated'] as bool? ?? false,
      deactivated: json['deactivated'] as bool? ?? false,
    );

Map<String, dynamic> _$$_WebAddressToJson(_$_WebAddress instance) =>
    <String, dynamic>{
      'address': instance.address,
      'balance': const NumOrStringDoubleConverter().toJson(instance.balance),
      'balance_total':
          const NumOrStringDoubleConverter().toJson(instance.balanceTotal),
      'balance_locked':
          const NumOrStringDoubleConverter().toJson(instance.balanceLocked),
      'adnr': instance.adnr,
      'activated': instance.activated,
      'deactivated': instance.deactivated,
    };
