import 'package:freezed_annotation/freezed_annotation.dart';

part 'onramp_quote_response.freezed.dart';
part 'onramp_quote_response.g.dart';

@freezed
class OnrampQuoteResponse with _$OnrampQuoteResponse {
  const OnrampQuoteResponse._();

  const factory OnrampQuoteResponse({
    @JsonKey(name: "purchase_uuid") required String purchaseUuid,
    @JsonKey(name: 'stripe_checkout_url') required String stripeCheckoutUrl,
    @JsonKey(name: 'crypto_dot_com_checkout_url')
        required String cryptoDotComCheckoutUrl,
    @JsonKey(name: 'amount_usd') required double amountUsd,
    @JsonKey(name: 'amount_vfx') required double amountVfx,
    @JsonKey(name: 'vfx_address') required String vfxAddress,
    @JsonKey(name: 'quote_valid_until') required DateTime quoteValidUntil,
  }) = _OnrampQuoteResponse;

  factory OnrampQuoteResponse.fromJson(Map<String, dynamic> json) =>
      _$OnrampQuoteResponseFromJson(json);
}
