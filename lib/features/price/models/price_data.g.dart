// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_PriceData _$$_PriceDataFromJson(Map<String, dynamic> json) => _$_PriceData(
      coinType: json['coin_type'] as String,
      usdtPrice: (json['usdt_price'] as num).toDouble(),
      volume24h: (json['volume_24h'] as num).toDouble(),
      percentChange24h: (json['percent_change_24h'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );

Map<String, dynamic> _$$_PriceDataToJson(_$_PriceData instance) =>
    <String, dynamic>{
      'coin_type': instance.coinType,
      'usdt_price': instance.usdtPrice,
      'volume_24h': instance.volume24h,
      'percent_change_24h': instance.percentChange24h,
      'last_updated': instance.lastUpdated.toIso8601String(),
    };
