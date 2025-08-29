import 'package:flutter/foundation.dart';
import 'package:rbx_wallet/utils/html_helpers.dart';

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
    final redirect = kIsWeb
        ? "${Env.onrampApiBaseUrl}/web-wallet-success/"
        : "${Env.onrampApiBaseUrl}/open-gui";

    final params = {
      "amount_vfx": amount,
      "vfx_address": vfxAddress,
      "success_url": redirect,
      "cancel_url": redirect,
      "error_url": redirect
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
