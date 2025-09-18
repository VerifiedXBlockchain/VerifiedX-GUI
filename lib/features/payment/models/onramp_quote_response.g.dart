// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onramp_quote_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_OnrampQuoteResponse _$$_OnrampQuoteResponseFromJson(
        Map<String, dynamic> json) =>
    _$_OnrampQuoteResponse(
      purchaseUuid: json['purchase_uuid'] as String,
      stripeCheckoutUrl: json['stripe_checkout_url'] as String,
      cryptoDotComCheckoutUrl: json['crypto_dot_com_checkout_url'] as String,
      amountUsd: (json['amount_usd'] as num).toDouble(),
      amountVfx: (json['amount_vfx'] as num).toDouble(),
      vfxAddress: json['vfx_address'] as String,
      quoteValidUntil: DateTime.parse(json['quote_valid_until'] as String),
    );

Map<String, dynamic> _$$_OnrampQuoteResponseToJson(
        _$_OnrampQuoteResponse instance) =>
    <String, dynamic>{
      'purchase_uuid': instance.purchaseUuid,
      'stripe_checkout_url': instance.stripeCheckoutUrl,
      'crypto_dot_com_checkout_url': instance.cryptoDotComCheckoutUrl,
      'amount_usd': instance.amountUsd,
      'amount_vfx': instance.amountVfx,
      'vfx_address': instance.vfxAddress,
      'quote_valid_until': instance.quoteValidUntil.toIso8601String(),
    };
