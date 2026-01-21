// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'butterfly_link.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ButterflyLink _$$_ButterflyLinkFromJson(Map<String, dynamic> json) =>
    _$_ButterflyLink(
      linkId: json['link_id'] as String,
      shortUrl: json['short_url'] as String,
      fullUrl: json['full_url'] as String,
      escrowAddress: json['escrow_address'] as String,
      amount: (json['amount'] as num).toDouble(),
      claimAmount: (json['claim_amount'] as num).toDouble(),
      message: json['message'] as String,
      icon: $enumDecode(_$ButterflyIconEnumMap, json['icon']),
      status: $enumDecode(_$ButterflyLinkStatusEnumMap, json['status']),
      senderAddress: json['sender_address'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      txHash: json['tx_hash'] as String?,
      claimedAt: json['claimed_at'] == null
          ? null
          : DateTime.parse(json['claimed_at'] as String),
    );

Map<String, dynamic> _$$_ButterflyLinkToJson(_$_ButterflyLink instance) =>
    <String, dynamic>{
      'link_id': instance.linkId,
      'short_url': instance.shortUrl,
      'full_url': instance.fullUrl,
      'escrow_address': instance.escrowAddress,
      'amount': instance.amount,
      'claim_amount': instance.claimAmount,
      'message': instance.message,
      'icon': _$ButterflyIconEnumMap[instance.icon]!,
      'status': _$ButterflyLinkStatusEnumMap[instance.status]!,
      'sender_address': instance.senderAddress,
      'created_at': instance.createdAt.toIso8601String(),
      'tx_hash': instance.txHash,
      'claimed_at': instance.claimedAt?.toIso8601String(),
    };

const _$ButterflyIconEnumMap = {
  ButterflyIcon.defaultIcon: 'default',
  ButterflyIcon.gift: 'gift',
  ButterflyIcon.money: 'money',
  ButterflyIcon.heart: 'heart',
  ButterflyIcon.party: 'party',
  ButterflyIcon.rocket: 'rocket',
  ButterflyIcon.star: 'star',
};

const _$ButterflyLinkStatusEnumMap = {
  ButterflyLinkStatus.pending: 'pending',
  ButterflyLinkStatus.readyForRedemption: 'ready_for_redemption',
  ButterflyLinkStatus.claiming: 'claiming',
  ButterflyLinkStatus.claimed: 'claimed',
};
