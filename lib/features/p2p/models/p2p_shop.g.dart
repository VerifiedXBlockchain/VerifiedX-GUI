// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'p2p_shop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_P2pShop _$$_P2pShopFromJson(Map<String, dynamic> json) => _$_P2pShop(
      id: json['id'] as int,
      uniqueId: json['unique_id'] as String,
      url: json['url'] as String,
      displayUrl: json['display_url'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      ownerAddress: json['owner_address'] as String,
      chainState: $enumDecodeNullable(
              _$P2pShopChainStateEnumMap, json['chain_state'],
              unknownValue: P2pShopChainState.unknown) ??
          P2pShopChainState.unknown,
      registeredAt: json['registered_at'] == null
          ? null
          : DateTime.parse(json['registered_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      collectionCount: json['collection_count'] as int? ?? 0,
      liveListingCount: json['live_listing_count'] as int? ?? 0,
      collections: (json['collections'] as List<dynamic>?)
          ?.map((e) => P2pCollection.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$_P2pShopToJson(_$_P2pShop instance) =>
    <String, dynamic>{
      'id': instance.id,
      'unique_id': instance.uniqueId,
      'url': instance.url,
      'display_url': instance.displayUrl,
      'name': instance.name,
      'description': instance.description,
      'owner_address': instance.ownerAddress,
      'chain_state': _$P2pShopChainStateEnumMap[instance.chainState]!,
      'registered_at': instance.registeredAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'collection_count': instance.collectionCount,
      'live_listing_count': instance.liveListingCount,
      'collections': instance.collections,
    };

const _$P2pShopChainStateEnumMap = {
  P2pShopChainState.dryRun: 'dry_run',
  P2pShopChainState.registered: 'registered',
  P2pShopChainState.deleted: 'deleted',
  P2pShopChainState.unknown: 'unknown',
};

_$_P2pUrlAvailability _$$_P2pUrlAvailabilityFromJson(
        Map<String, dynamic> json) =>
    _$_P2pUrlAvailability(
      url: json['url'] as String,
      normalized: json['normalized'] as String,
      available: json['available'] as bool,
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$$_P2pUrlAvailabilityToJson(
        _$_P2pUrlAvailability instance) =>
    <String, dynamic>{
      'url': instance.url,
      'normalized': instance.normalized,
      'available': instance.available,
      'reason': instance.reason,
    };
