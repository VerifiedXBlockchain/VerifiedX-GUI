import 'package:freezed_annotation/freezed_annotation.dart';

part 'butterfly_status_response.freezed.dart';
part 'butterfly_status_response.g.dart';

@freezed
class ButterflyStatusResponse with _$ButterflyStatusResponse {
  const ButterflyStatusResponse._();

  const factory ButterflyStatusResponse({
    String? uuid,
    @JsonKey(name: 'link_id') String? linkId,
    required String status,
    String? amount,
    @JsonKey(name: 'claim_amount') String? claimAmount,
    @JsonKey(name: 'asset_type') String? assetType,
    String? chain,
    @JsonKey(name: 'token_symbol') String? tokenSymbol,
    @JsonKey(name: 'escrow_address') String? escrowAddress,
    @JsonKey(name: 'short_url') String? shortUrl,
    @JsonKey(name: 'full_url') String? fullUrl,
    @JsonKey(name: 'usd_value') String? usdValue,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    String? icon,
    String? message,
  }) = _ButterflyStatusResponse;

  factory ButterflyStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$ButterflyStatusResponseFromJson(json);

  bool get isPending => status == 'pending';
  bool get isReadyForRedemption => status == 'ready_for_redemption';
  bool get isClaiming => status == 'claiming';
  bool get isClaimed => status == 'claimed';

  double? get claimAmountDouble =>
      claimAmount != null ? double.tryParse(claimAmount!) : null;
}
