import '../../../core/env.dart';
import '../../../core/services/base_service.dart';
import '../models/onramp_purchase_details.dart';
import '../models/onramp_quote_response.dart';

class OnrampService extends BaseService {
  OnrampService()
      : super(
          hostOverride: Env.onrampApiBaseUrl,
        );

  Future<OnrampQuoteResponse?> getQuote({
    required String vfxAddress,
    required double amount,
  }) async {
    final params = {
      "amount_vfx": amount,
      "vfx_address": vfxAddress,
      "success_url": "${Env.onrampApiBaseUrl}/open-gui",
      "cancel_url": "${Env.onrampApiBaseUrl}/open-gui",
      "error_url": "${Env.onrampApiBaseUrl}/open-gui"
    };

    try {
      final result = await postJson("/api/on-ramp/get-quote/", params: params);

      return OnrampQuoteResponse.fromJson(result['data']);
    } catch (e) {
      return null;
    }
  }

  Future<OnrampPurchaseDetails?> retrievePurchaseDetails(String uuid) async {
    try {
      final result = await getJson("/api/on-ramp/purchase/$uuid/");
      return OnrampPurchaseDetails.fromJson(result);
    } catch (e) {
      print(e);
      return null;
    }
  }
}
