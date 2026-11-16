import 'package:freezed_annotation/freezed_annotation.dart';

part 'p2p_bid_summary.freezed.dart';
part 'p2p_bid_summary.g.dart';

/// `winning`: the high bid with the reserve met; `accepted`: the high bid
/// under the reserve; `outbid`; then `won` or `lost` once the listing is over.
enum P2pBidStatus {
  @JsonValue('winning')
  winning,
  @JsonValue('accepted')
  accepted,
  @JsonValue('outbid')
  outbid,
  @JsonValue('won')
  won,
  @JsonValue('lost')
  lost,
  unknown,
}

/// A bid as anyone may see it. No public payload carries a bid's signature.
@freezed
class P2pBidSummary with _$P2pBidSummary {
  const P2pBidSummary._();

  factory P2pBidSummary({
    required int id,
    required String address,
    // A decimal string with up to 8 places.
    required String amount,
    @JsonKey(name: 'is_buy_now') @Default(false) bool isBuyNow,
    @JsonKey(unknownEnumValue: P2pBidStatus.unknown) @Default(P2pBidStatus.unknown) P2pBidStatus status,
    DateTime? at,
  }) = _P2pBidSummary;

  factory P2pBidSummary.fromJson(Map<String, dynamic> json) => _$P2pBidSummaryFromJson(json);
}
