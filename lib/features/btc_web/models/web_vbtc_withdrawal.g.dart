// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_vbtc_withdrawal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_WebVbtcWithdrawal _$$_WebVbtcWithdrawalFromJson(Map<String, dynamic> json) =>
    _$_WebVbtcWithdrawal(
      requestorAddress: json['requestor_address'] as String,
      btcAddress: json['btc_address'] as String,
      amount: json['amount'] as String,
      feeRate: json['fee_rate'] as String,
      btcTransactionHash: json['btc_transaction_hash'] as String?,
      status: json['status'] as String,
      requestTransactionHash: json['request_transaction_hash'] as String,
      completionTransactionHash: json['completion_transaction_hash'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
    );

Map<String, dynamic> _$$_WebVbtcWithdrawalToJson(
        _$_WebVbtcWithdrawal instance) =>
    <String, dynamic>{
      'requestor_address': instance.requestorAddress,
      'btc_address': instance.btcAddress,
      'amount': instance.amount,
      'fee_rate': instance.feeRate,
      'btc_transaction_hash': instance.btcTransactionHash,
      'status': instance.status,
      'request_transaction_hash': instance.requestTransactionHash,
      'completion_transaction_hash': instance.completionTransactionHash,
      'created_at': instance.createdAt.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
    };
