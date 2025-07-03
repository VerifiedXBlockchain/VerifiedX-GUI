import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/env.dart';

String? banxaPaymentUrl({
  String fiatType = "USD",
  required double amount,
  required String walletAddress,
  required String currency,
}) {
  final domain = Env.banxaPaymentDomain;

  if (domain == null) {
    print("Payment not available in this environment");
    return null;
  }

  final url =
      "$domain/?coinType=${currency.toUpperCase()}&fiatType=$fiatType&coinAmount=$amount&blockchain=${currency.toUpperCase()}&walletAddress=$walletAddress";
  print(url);
  return url;
}

Future<String?> getCryptoDotComBtcOnRampUrl({
  required String walletAddress,
  double? amountFiat,
  double? amountBtc,
}) async {
  try {
    Map<String, dynamic> params = {'wallet_address': walletAddress};

    if (amountBtc != null) {
      params['crypto_amount'] = amountBtc;
    } else if (amountFiat != null) {
      params['fiat_amount'] = amountFiat;
    } else {
      print("Fiat or Btc required");
      return null;
    }

    final result = await Dio(BaseOptions(
        baseUrl: Env.explorerApiBaseUrl.replaceAll("/api", ""),
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.acceptHeader: "application/json",
        })).get("/payment/crypto-dot-com-on-ramp", queryParameters: params);

    final data = result.data;

    if (data['success'] == true) {
      return data['url'];
    }

    print(data);
    return null;
  } catch (e) {
    print(e);
    return null;
  }
}
