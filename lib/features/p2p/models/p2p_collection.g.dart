// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'p2p_collection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_P2pCollection _$$_P2pCollectionFromJson(Map<String, dynamic> json) =>
    _$_P2pCollection(
      id: json['id'] as int,
      shopUrl: json['shop_url'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      isLive: json['is_live'] as bool? ?? true,
      isDefault: json['is_default'] as bool? ?? false,
      listingCount: json['listing_count'] as int? ?? 0,
    );

Map<String, dynamic> _$$_P2pCollectionToJson(_$_P2pCollection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shop_url': instance.shopUrl,
      'name': instance.name,
      'description': instance.description,
      'is_live': instance.isLive,
      'is_default': instance.isDefault,
      'listing_count': instance.listingCount,
    };
