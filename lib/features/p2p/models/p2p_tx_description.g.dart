// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'p2p_tx_description.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_P2pTxDescription _$$_P2pTxDescriptionFromJson(Map<String, dynamic> json) =>
    _$_P2pTxDescription(
      type: json['type'] as int,
      function: json['function'] as String,
      fromAddress: json['from_address'] as String,
      toAddress: json['to_address'] as String,
      amount: json['amount'] as String?,
      fee: json['fee'] as String?,
      timestamp: json['timestamp'] as int?,
      data: json['data'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      hash: json['hash'] as String?,
      height: json['height'] as int?,
    );

Map<String, dynamic> _$$_P2pTxDescriptionToJson(_$_P2pTxDescription instance) =>
    <String, dynamic>{
      'type': instance.type,
      'function': instance.function,
      'from_address': instance.fromAddress,
      'to_address': instance.toAddress,
      'amount': instance.amount,
      'fee': instance.fee,
      'timestamp': instance.timestamp,
      'data': instance.data,
      'hash': instance.hash,
      'height': instance.height,
    };
