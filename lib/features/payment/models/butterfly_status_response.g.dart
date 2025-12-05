// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'butterfly_status_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ButterflyStatusResponse _$$_ButterflyStatusResponseFromJson(
        Map<String, dynamic> json) =>
    _$_ButterflyStatusResponse(
      uuid: json['uuid'] as String?,
      linkId: json['link_id'] as String?,
      status: json['status'] as String,
      amount: json['amount'] as String?,
      claimAmount: json['claim_amount'] as String?,
      assetType: json['asset_type'] as String?,
      chain: json['chain'] as String?,
      tokenSymbol: json['token_symbol'] as String?,
      escrowAddress: json['escrow_address'] as String?,
      shortUrl: json['short_url'] as String?,
      fullUrl: json['full_url'] as String?,
      usdValue: json['usd_value'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      icon: json['icon'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$_ButterflyStatusResponseToJson(
        _$_ButterflyStatusResponse instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'link_id': instance.linkId,
      'status': instance.status,
      'amount': instance.amount,
      'claim_amount': instance.claimAmount,
      'asset_type': instance.assetType,
      'chain': instance.chain,
      'token_symbol': instance.tokenSymbol,
      'escrow_address': instance.escrowAddress,
      'short_url': instance.shortUrl,
      'full_url': instance.fullUrl,
      'usd_value': instance.usdValue,
      'created_at': instance.createdAt?.toIso8601String(),
      'icon': instance.icon,
      'message': instance.message,
    };
