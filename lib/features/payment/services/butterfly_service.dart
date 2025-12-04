import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/env.dart';
import '../../../core/services/base_service.dart';
import '../models/butterfly_create_link_response.dart';
import '../models/butterfly_link.dart';
import '../models/butterfly_status_response.dart';
import '../models/onramp_purchase_details.dart';
import '../models/onramp_quote_response.dart';

class ButterflyService extends BaseService {
  ButterflyService()
      : super(
          hostOverride: Env.onrampApiBaseUrl,
        );

  // ==================== EXISTING ONRAMP METHODS ====================

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
      "error_url": redirect,
      "is_testnet": Env.isTestNet,
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

  // ==================== NEW BUTTERFLY METHODS ====================

  String _iconToString(ButterflyIcon icon) {
    switch (icon) {
      case ButterflyIcon.defaultIcon:
        return 'default';
      case ButterflyIcon.gift:
        return 'gift';
      case ButterflyIcon.money:
        return 'money';
      case ButterflyIcon.heart:
        return 'heart';
      case ButterflyIcon.party:
        return 'party';
      case ButterflyIcon.rocket:
        return 'rocket';
      case ButterflyIcon.star:
        return 'star';
    }
  }

  /// Creates a new Butterfly payment link
  Future<ButterflyCreateLinkResponse?> createButterflyLink({
    required double amount,
    String message = 'Payment from VFX Wallet',
    ButterflyIcon icon = ButterflyIcon.defaultIcon,
  }) async {
    try {
      final dio = Dio(BaseOptions(
        baseUrl: Env.butterflyApiBaseUrl,
        headers: {'Content-Type': 'application/json'},
      ));
      final response = await dio.post('/api/butterfly/create/', data: {
        'is_testnet': Env.isTestNet,
        'amount': amount.toString(),
        'asset_type': 'vfx',
        'token_symbol': 'VFX',
        'chain': 'vfx',
        'icon': _iconToString(icon),
        'message': message,
      });
      return ButterflyCreateLinkResponse.fromJson(response.data);
    } catch (e) {
      print('Error creating Butterfly link: $e');
      return null;
    }
  }

  /// Polls the status of a Butterfly link
  Future<ButterflyStatusResponse?> getButterflyStatus(String linkId) async {
    try {
      final dio = Dio(BaseOptions(
        baseUrl: Env.butterflyApiBaseUrl,
        headers: {'Content-Type': 'application/json'},
      ));
      final response = await dio.get('/api/butterfly/status/$linkId/');
      return ButterflyStatusResponse.fromJson(response.data);
    } catch (e) {
      print('Error getting Butterfly status: $e');
      return null;
    }
  }
}
