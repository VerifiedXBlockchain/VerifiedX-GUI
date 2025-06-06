// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'btc_web_vbtc_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_BtcWebVbtcToken _$$_BtcWebVbtcTokenFromJson(Map<String, dynamic> json) =>
    _$_BtcWebVbtcToken(
      name: json['name'] as String,
      description: json['description'] as String,
      addresses: json['addresses'] as Map<String, dynamic>,
      address: json['address'] as String,
      scIdentifier: json['sc_identifier'] as String,
      ownerAddress: json['owner_address'] as String,
      imageUrl: json['image_url'] as String,
      depositAddress: json['deposit_address'] as String,
      publicKeyProofs: json['public_key_proofs'] as String,
      globalBalance: (json['global_balance'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      nft: WebNft.fromJson(json['nft'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_BtcWebVbtcTokenToJson(_$_BtcWebVbtcToken instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'addresses': instance.addresses,
      'address': instance.address,
      'sc_identifier': instance.scIdentifier,
      'owner_address': instance.ownerAddress,
      'image_url': instance.imageUrl,
      'deposit_address': instance.depositAddress,
      'public_key_proofs': instance.publicKeyProofs,
      'global_balance': instance.globalBalance,
      'created_at': instance.createdAt.toIso8601String(),
      'nft': instance.nft,
    };
