import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'moonpay_service_interface.dart';

class MoonpayServiceImpl extends MoonpayServiceInterface {
  static const _keys = {
    'sandbox': 'pk_test_jV5Sx41ah71d30jfIoXvWq3QLlPBilV',
    'production': 'pk_live_ITSKGCf8pIJnaiQme4AAQ6NbqdRQt0c',
  };

  static const _buyHosts = {
    'sandbox': 'https://buy-sandbox.moonpay.com',
    'production': 'https://buy.moonpay.com',
  };

  static const _sellHosts = {
    'sandbox': 'https://sell-sandbox.moonpay.com',
    'production': 'https://sell.moonpay.com',
  };

  static const _signingHosts = {
    'sandbox': 'https://data-testnet.verifiedx.io',
    'production': 'https://data.verifiedx.io',
  };

  /// Builds a MoonPay URL, signs it server-side, and launches it in the browser.
  Future<void> _launchSignedUrl(String baseUrl, String environment,
      Map<String, String> params) async {
    final apiKey = _keys[environment];
    if (apiKey == null) return;

    final query = {
      'apiKey': apiKey,
      'theme': 'dark',
      ...params,
    };

    final uri =
        Uri.parse(baseUrl).replace(queryParameters: query).toString();

    // Sign the URL via the server
    final signingHost = _signingHosts[environment];
    if (signingHost == null) {
      // Fallback: launch unsigned
      await launchUrlString(uri);
      return;
    }

    try {
      final response = await Dio().post(
        '$signingHost/payment/sign-url-for-moonpay/',
        data: jsonEncode({'url_for_signature': uri}),
      );

      final result = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      if (result['success'] == true && result['url'] != null) {
        await launchUrlString(result['url']);
      } else {
        // Signing failed — launch unsigned URL as fallback
        await launchUrlString(uri);
      }
    } catch (e) {
      print('[MoonPay] Signing failed: $e — launching unsigned URL');
      await launchUrlString(uri);
    }
  }

  @override
  Future<void> buy(String environment, String baseCurrencyCode,
      String baseCurrencyAmount, String walletAddress, bool popup) async {
    final host = _buyHosts[environment];
    if (host == null) return;

    await _launchSignedUrl(host, environment, {
      'currencyCode': baseCurrencyCode,
      'baseCurrencyCode': 'usd',
      'baseCurrencyAmount': baseCurrencyAmount,
      'walletAddress': walletAddress,
    });
  }

  @override
  Future<void> sell(
    String environment,
    String baseCurrencyCode,
    String baseCurrencyAmount,
    String walletAddress,
    bool popup, {
    MoonPayDepositCallback? onDeposit,
  }) async {
    final host = _sellHosts[environment];
    if (host == null) return;

    // Note: sell on desktop opens the browser — the onDeposit callback
    // can't work without JS interop, so the user completes the flow
    // in-browser and sends manually if needed.
    await _launchSignedUrl(host, environment, {
      'baseCurrencyCode': baseCurrencyCode,
      'defaultCurrencyCode': baseCurrencyCode,
      'baseCurrencyAmount': baseCurrencyAmount,
      'walletAddress': walletAddress,
    });
  }
}
