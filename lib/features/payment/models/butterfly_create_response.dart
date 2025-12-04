import 'package:freezed_annotation/freezed_annotation.dart';

part 'butterfly_create_response.freezed.dart';
part 'butterfly_create_response.g.dart';

@freezed
class ButterflyCreateResponse with _$ButterflyCreateResponse {
  const ButterflyCreateResponse._();

  const factory ButterflyCreateResponse({
    @JsonKey(name: 'link_id') required String linkId,
    String? uuid,
    @JsonKey(name: 'short_url') required String shortUrl,
    @JsonKey(name: 'full_url') required String fullUrl,
    required String status,
    @JsonKey(name: 'escrow_address') required String escrowAddress,
    @JsonKey(name: 'raw_transaction') Map<String, dynamic>? rawTransaction,
    required double amount,
    @JsonKey(name: 'token_symbol') String? tokenSymbol,
    String? chain,
  }) = _ButterflyCreateResponse;

  factory ButterflyCreateResponse.fromJson(Map<String, dynamic> json) =>
      _$ButterflyCreateResponseFromJson(json);

  double get amountDouble => amount;
}
