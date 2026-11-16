import 'package:freezed_annotation/freezed_annotation.dart';

import 'p2p_bid_summary.dart';
import 'p2p_tx_description.dart';

part 'p2p_listing.freezed.dart';
part 'p2p_listing.g.dart';

/// `live` → `awaitingSaleStart` (a buy-now bid, or an auction won with its
/// reserve met; the seller has 48 hours) → `salePending` (`Sale_Start()`) →
/// `sold` (`Sale_Complete()`). Side exits: `cancelled`, `expired`,
/// `unfulfilled`, `ended`. The server owns the state; the GUI never works it
/// out from dates or bids.
enum P2pListingState {
  @JsonValue('live')
  live,
  @JsonValue('awaiting_sale_start')
  awaitingSaleStart,
  @JsonValue('sale_pending')
  salePending,
  @JsonValue('sold')
  sold,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('expired')
  expired,
  @JsonValue('unfulfilled')
  unfulfilled,
  @JsonValue('ended')
  ended,

  /// A state this build does not know, or none at all: read as closed,
  /// never as live.
  unknown,
}

extension P2pListingStateWire on P2pListingState {
  /// The state as the API writes it (`awaiting_sale_start`), for `?state=`.
  String get wire => _$P2pListingStateEnumMap[this]!;
}

/// Whether a listing's sale steps are dry runs or real transactions.
enum P2pListingChainState {
  @JsonValue('dry_run')
  dryRun,
  @JsonValue('live')
  live,
  unknown,
}

/// The NFT's royalty as its contract states it: [amount] is a fraction of the
/// price (0.02 is 2%) or a fixed VFX amount, as Core reads the contract.
@freezed
class P2pRoyalty with _$P2pRoyalty {
  factory P2pRoyalty({
    required String amount,
    @JsonKey(name: 'pay_to') required String payTo,
  }) = _P2pRoyalty;

  factory P2pRoyalty.fromJson(Map<String, dynamic> json) => _$P2pRoyaltyFromJson(json);
}

/// What a listing says about its NFT. [thumbnailUrl] and [assetUrl] are null
/// when Spyglass holds no media for it.
@freezed
class P2pListingNft with _$P2pListingNft {
  factory P2pListingNft({
    @Default('') String name,
    @Default('') String description,
    @JsonKey(name: 'minter_name') @Default('') String minterName,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    @JsonKey(name: 'asset_url') String? assetUrl,
    P2pRoyalty? royalty,
  }) = _P2pListingNft;

  factory P2pListingNft.fromJson(Map<String, dynamic> json) => _$P2pListingNftFromJson(json);
}

@freezed
class P2pHighBid with _$P2pHighBid {
  factory P2pHighBid({
    required String amount,
    required String address,
    DateTime? at,
  }) = _P2pHighBid;

  factory P2pHighBid.fromJson(Map<String, dynamic> json) => _$P2pHighBidFromJson(json);
}

/// The sale's chain steps, each null until it happens.
@freezed
class P2pSale with _$P2pSale {
  factory P2pSale({
    P2pTxDescription? start,
    P2pTxDescription? complete,
  }) = _P2pSale;

  factory P2pSale.fromJson(Map<String, dynamic> json) => _$P2pSaleFromJson(json);
}

/// A listing in the P2P registry (`GET /p2p/shops/{url}/listings/`,
/// `GET /p2p/listings/{id}/`). Amounts are decimal strings with up to 8
/// places (`P2pAmount` reads them exactly); times are UTC.
@freezed
class P2pListing with _$P2pListing {
  const P2pListing._();

  factory P2pListing({
    required int id,
    @JsonKey(name: 'shop_url') required String shopUrl,
    @JsonKey(name: 'collection_id') int? collectionId,
    @JsonKey(unknownEnumValue: P2pListingState.unknown) @Default(P2pListingState.unknown) P2pListingState state,
    @JsonKey(name: 'smart_contract_uid') required String smartContractUid,
    P2pListingNft? nft,
    @JsonKey(name: 'seller_address') required String sellerAddress,
    @JsonKey(name: 'buy_now_price') String? buyNowPrice,
    // An auction's opening price; null for a buy-now-only listing.
    @JsonKey(name: 'floor_price') String? floorPrice,
    @JsonKey(name: 'reserve_price') String? reservePrice,
    @JsonKey(name: 'reserve_met') @Default(false) bool reserveMet,
    @JsonKey(name: 'starts_at') DateTime? startsAt,
    @JsonKey(name: 'ends_at') DateTime? endsAt,
    // Core's KeySign: signed into every bid. New for every listing.
    @JsonKey(name: 'purchase_key') required String purchaseKey,
    @JsonKey(name: 'high_bid') P2pHighBid? highBid,
    @JsonKey(name: 'bid_count') @Default(0) int bidCount,
    // What the next auction bid must at least be; null for buy-now only.
    @JsonKey(name: 'next_min_bid') String? nextMinBid,
    @JsonKey(name: 'winner_address') String? winnerAddress,
    // When `awaitingSaleStart` turns `unfulfilled`: 48 hours after the win.
    @JsonKey(name: 'sale_start_deadline') DateTime? saleStartDeadline,
    @JsonKey(name: 'sold_price') String? soldPrice,
    @JsonKey(name: 'chain_state', unknownEnumValue: P2pListingChainState.unknown) @Default(P2pListingChainState.unknown) P2pListingChainState chainState,
    P2pSale? sale,
    @JsonKey(name: 'royalty_enforced') @Default(true) bool royaltyEnforced,
    // Why it closed without a sale (`nft_moved`, `shop_deleted`, ...), or
    // null. An open set: shown as detail beside the state.
    @JsonKey(name: 'end_reason') String? endReason,
    // On the listing's own page only: its newest 100 bids, newest first.
    List<P2pBidSummary>? bids,
  }) = _P2pListing;

  factory P2pListing.fromJson(Map<String, dynamic> json) => _$P2pListingFromJson(json);

  bool get isLive => state == P2pListingState.live;

  /// An auction takes bids; a listing with only a buy-now price does not.
  bool get isAuction => floorPrice != null;

  bool get hasBuyNow => buyNowPrice != null;

  bool get isDryRun => chainState == P2pListingChainState.dryRun;

  /// The NFT's name, or its contract id when the registry has no NFT record.
  String get title {
    final name = nft?.name ?? '';
    return name.isNotEmpty ? name : smartContractUid;
  }
}

/// What `POST /p2p/listings/{id}/bids/` returns (201): the new bid and the
/// listing as it now stands.
@freezed
class P2pBidResult with _$P2pBidResult {
  factory P2pBidResult({
    required P2pBidSummary bid,
    required P2pListing listing,
  }) = _P2pBidResult;

  factory P2pBidResult.fromJson(Map<String, dynamic> json) => _$P2pBidResultFromJson(json);
}
