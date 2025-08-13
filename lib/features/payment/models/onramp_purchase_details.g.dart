// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onramp_purchase_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_OnrampPurchaseDetails _$$_OnrampPurchaseDetailsFromJson(
        Map<String, dynamic> json) =>
    _$_OnrampPurchaseDetails(
      uuid: json['uuid'] as String,
      provider: $enumDecodeNullable(
          _$OnrampPurchaseProviderEnumMap, json['provider']),
      vfxAddress: json['vfx_address'] as String,
      vfxTransactionHash: json['vfx_transaction_hash'] as String?,
      status: $enumDecode(_$OnrampPurchaseStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$_OnrampPurchaseDetailsToJson(
        _$_OnrampPurchaseDetails instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'provider': _$OnrampPurchaseProviderEnumMap[instance.provider],
      'vfx_address': instance.vfxAddress,
      'vfx_transaction_hash': instance.vfxTransactionHash,
      'status': _$OnrampPurchaseStatusEnumMap[instance.status]!,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$OnrampPurchaseProviderEnumMap = {
  OnrampPurchaseProvider.none: null,
  OnrampPurchaseProvider.stripe: 'stripe',
  OnrampPurchaseProvider.cryptoDotCom: 'crypto_dot_com',
};

const _$OnrampPurchaseStatusEnumMap = {
  OnrampPurchaseStatus.initialized: 'initialized',
  OnrampPurchaseStatus.canceled: 'canceled',
  OnrampPurchaseStatus.quoted: 'quoted',
  OnrampPurchaseStatus.paymentIntended: 'payment_intended',
  OnrampPurchaseStatus.paymentProcessed: 'payment_processed',
  OnrampPurchaseStatus.paymentCaptured: 'payment_captured',
  OnrampPurchaseStatus.transactionSent: 'transaction_sent',
  OnrampPurchaseStatus.transactionSettled: 'transaction_settled',
};
