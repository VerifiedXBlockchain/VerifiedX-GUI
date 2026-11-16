// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'p2p_bid_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_P2pBidSummary _$$_P2pBidSummaryFromJson(Map<String, dynamic> json) =>
    _$_P2pBidSummary(
      id: json['id'] as int,
      address: json['address'] as String,
      amount: json['amount'] as String,
      isBuyNow: json['is_buy_now'] as bool? ?? false,
      status: $enumDecodeNullable(_$P2pBidStatusEnumMap, json['status'],
              unknownValue: P2pBidStatus.unknown) ??
          P2pBidStatus.unknown,
      at: json['at'] == null ? null : DateTime.parse(json['at'] as String),
    );

Map<String, dynamic> _$$_P2pBidSummaryToJson(_$_P2pBidSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'address': instance.address,
      'amount': instance.amount,
      'is_buy_now': instance.isBuyNow,
      'status': _$P2pBidStatusEnumMap[instance.status]!,
      'at': instance.at?.toIso8601String(),
    };

const _$P2pBidStatusEnumMap = {
  P2pBidStatus.winning: 'winning',
  P2pBidStatus.accepted: 'accepted',
  P2pBidStatus.outbid: 'outbid',
  P2pBidStatus.won: 'won',
  P2pBidStatus.lost: 'lost',
  P2pBidStatus.unknown: 'unknown',
};
