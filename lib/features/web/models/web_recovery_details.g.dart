// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_recovery_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_WebRecoveryDetails _$$_WebRecoveryDetailsFromJson(
        Map<String, dynamic> json) =>
    _$_WebRecoveryDetails(
      originalAddress: json['original_address'] as String,
      newAddress: json['new_address'] as String,
      amount: json['amount'] == null
          ? 0
          : const NumOrStringDoubleConverter()
              .fromJson(json['amount'] as Object),
      outstandingTransactions:
          (json['outstanding_transactions'] as List<dynamic>?)
              ?.map((e) => WebTransaction.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$$_WebRecoveryDetailsToJson(
        _$_WebRecoveryDetails instance) =>
    <String, dynamic>{
      'original_address': instance.originalAddress,
      'new_address': instance.newAddress,
      'amount': const NumOrStringDoubleConverter().toJson(instance.amount),
      'outstanding_transactions': instance.outstandingTransactions,
    };
