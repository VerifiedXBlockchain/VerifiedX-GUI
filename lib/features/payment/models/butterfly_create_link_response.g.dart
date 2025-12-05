// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'butterfly_create_link_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ButterflyCreateLinkResponse _$$_ButterflyCreateLinkResponseFromJson(
        Map<String, dynamic> json) =>
    _$_ButterflyCreateLinkResponse(
      linkId: json['link_id'] as String,
      uuid: json['uuid'] as String?,
      shortUrl: json['short_url'] as String,
      fullUrl: json['full_url'] as String,
      status: json['status'] as String,
      escrowAddress: json['escrow_address'] as String,
      rawTransaction: json['raw_transaction'] as Map<String, dynamic>?,
      amount: (json['amount'] as num).toDouble(),
      tokenSymbol: json['token_symbol'] as String?,
      chain: json['chain'] as String?,
    );

Map<String, dynamic> _$$_ButterflyCreateLinkResponseToJson(
        _$_ButterflyCreateLinkResponse instance) =>
    <String, dynamic>{
      'link_id': instance.linkId,
      'uuid': instance.uuid,
      'short_url': instance.shortUrl,
      'full_url': instance.fullUrl,
      'status': instance.status,
      'escrow_address': instance.escrowAddress,
      'raw_transaction': instance.rawTransaction,
      'amount': instance.amount,
      'token_symbol': instance.tokenSymbol,
      'chain': instance.chain,
    };
