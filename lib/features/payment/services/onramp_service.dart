import '../../../core/env.dart';
import '../../../core/services/base_service.dart';
import '../models/onramp_quote_response.dart';

class OnrampService extends BaseService {
  OnrampService()
      : super(
          hostOverride: Env.onrampApiBaseUrl,
        );

  Future<OnrampQuoteResponse> getQuote({
    required String vfxAddress,
    required double amount,
  }) async {
    final params = {
      "amount_vfx": amount,
      "vfx_address": vfxAddress,
      "success_url": "rbx://wallet",
      "cancel_url": "rbx://wallet",
      "error_url": "rbx://wallet"
    };
    final result = await postJson("/on-ramp/get-quote/", params: params);

    return OnrampQuoteResponse.fromJson(result['data']);
  }
}
