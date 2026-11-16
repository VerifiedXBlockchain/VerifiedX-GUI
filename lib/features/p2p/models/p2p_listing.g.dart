// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'p2p_listing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_P2pRoyalty _$$_P2pRoyaltyFromJson(Map<String, dynamic> json) =>
    _$_P2pRoyalty(
      amount: json['amount'] as String,
      payTo: json['pay_to'] as String,
    );

Map<String, dynamic> _$$_P2pRoyaltyToJson(_$_P2pRoyalty instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'pay_to': instance.payTo,
    };

_$_P2pListingNft _$$_P2pListingNftFromJson(Map<String, dynamic> json) =>
    _$_P2pListingNft(
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      minterName: json['minter_name'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String?,
      assetUrl: json['asset_url'] as String?,
      royalty: json['royalty'] == null
          ? null
          : P2pRoyalty.fromJson(json['royalty'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_P2pListingNftToJson(_$_P2pListingNft instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'minter_name': instance.minterName,
      'thumbnail_url': instance.thumbnailUrl,
      'asset_url': instance.assetUrl,
      'royalty': instance.royalty,
    };

_$_P2pHighBid _$$_P2pHighBidFromJson(Map<String, dynamic> json) =>
    _$_P2pHighBid(
      amount: json['amount'] as String,
      address: json['address'] as String,
      at: json['at'] == null ? null : DateTime.parse(json['at'] as String),
    );

Map<String, dynamic> _$$_P2pHighBidToJson(_$_P2pHighBid instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'address': instance.address,
      'at': instance.at?.toIso8601String(),
    };

_$_P2pSale _$$_P2pSaleFromJson(Map<String, dynamic> json) => _$_P2pSale(
      start: json['start'] == null
          ? null
          : P2pTxDescription.fromJson(json['start'] as Map<String, dynamic>),
      complete: json['complete'] == null
          ? null
          : P2pTxDescription.fromJson(json['complete'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_P2pSaleToJson(_$_P2pSale instance) =>
    <String, dynamic>{
      'start': instance.start,
      'complete': instance.complete,
    };

_$_P2pListing _$$_P2pListingFromJson(Map<String, dynamic> json) =>
    _$_P2pListing(
      id: json['id'] as int,
      shopUrl: json['shop_url'] as String,
      collectionId: json['collection_id'] as int?,
      state: $enumDecodeNullable(_$P2pListingStateEnumMap, json['state'],
              unknownValue: P2pListingState.unknown) ??
          P2pListingState.unknown,
      smartContractUid: json['smart_contract_uid'] as String,
      nft: json['nft'] == null
          ? null
          : P2pListingNft.fromJson(json['nft'] as Map<String, dynamic>),
      sellerAddress: json['seller_address'] as String,
      buyNowPrice: json['buy_now_price'] as String?,
      floorPrice: json['floor_price'] as String?,
      reservePrice: json['reserve_price'] as String?,
      reserveMet: json['reserve_met'] as bool? ?? false,
      startsAt: json['starts_at'] == null
          ? null
          : DateTime.parse(json['starts_at'] as String),
      endsAt: json['ends_at'] == null
          ? null
          : DateTime.parse(json['ends_at'] as String),
      purchaseKey: json['purchase_key'] as String,
      highBid: json['high_bid'] == null
          ? null
          : P2pHighBid.fromJson(json['high_bid'] as Map<String, dynamic>),
      bidCount: json['bid_count'] as int? ?? 0,
      nextMinBid: json['next_min_bid'] as String?,
      winnerAddress: json['winner_address'] as String?,
      saleStartDeadline: json['sale_start_deadline'] == null
          ? null
          : DateTime.parse(json['sale_start_deadline'] as String),
      soldPrice: json['sold_price'] as String?,
      chainState: $enumDecodeNullable(
              _$P2pListingChainStateEnumMap, json['chain_state'],
              unknownValue: P2pListingChainState.unknown) ??
          P2pListingChainState.unknown,
      sale: json['sale'] == null
          ? null
          : P2pSale.fromJson(json['sale'] as Map<String, dynamic>),
      royaltyEnforced: json['royalty_enforced'] as bool? ?? true,
      endReason: json['end_reason'] as String?,
      bids: (json['bids'] as List<dynamic>?)
          ?.map((e) => P2pBidSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$_P2pListingToJson(_$_P2pListing instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shop_url': instance.shopUrl,
      'collection_id': instance.collectionId,
      'state': _$P2pListingStateEnumMap[instance.state]!,
      'smart_contract_uid': instance.smartContractUid,
      'nft': instance.nft,
      'seller_address': instance.sellerAddress,
      'buy_now_price': instance.buyNowPrice,
      'floor_price': instance.floorPrice,
      'reserve_price': instance.reservePrice,
      'reserve_met': instance.reserveMet,
      'starts_at': instance.startsAt?.toIso8601String(),
      'ends_at': instance.endsAt?.toIso8601String(),
      'purchase_key': instance.purchaseKey,
      'high_bid': instance.highBid,
      'bid_count': instance.bidCount,
      'next_min_bid': instance.nextMinBid,
      'winner_address': instance.winnerAddress,
      'sale_start_deadline': instance.saleStartDeadline?.toIso8601String(),
      'sold_price': instance.soldPrice,
      'chain_state': _$P2pListingChainStateEnumMap[instance.chainState]!,
      'sale': instance.sale,
      'royalty_enforced': instance.royaltyEnforced,
      'end_reason': instance.endReason,
      'bids': instance.bids,
    };

const _$P2pListingStateEnumMap = {
  P2pListingState.live: 'live',
  P2pListingState.awaitingSaleStart: 'awaiting_sale_start',
  P2pListingState.salePending: 'sale_pending',
  P2pListingState.sold: 'sold',
  P2pListingState.cancelled: 'cancelled',
  P2pListingState.expired: 'expired',
  P2pListingState.unfulfilled: 'unfulfilled',
  P2pListingState.ended: 'ended',
  P2pListingState.unknown: 'unknown',
};

const _$P2pListingChainStateEnumMap = {
  P2pListingChainState.dryRun: 'dry_run',
  P2pListingChainState.live: 'live',
  P2pListingChainState.unknown: 'unknown',
};

_$_P2pBidResult _$$_P2pBidResultFromJson(Map<String, dynamic> json) =>
    _$_P2pBidResult(
      bid: P2pBidSummary.fromJson(json['bid'] as Map<String, dynamic>),
      listing: P2pListing.fromJson(json['listing'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_P2pBidResultToJson(_$_P2pBidResult instance) =>
    <String, dynamic>{
      'bid': instance.bid,
      'listing': instance.listing,
    };
