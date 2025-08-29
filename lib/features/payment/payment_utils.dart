import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/breakpoints.dart';
import '../../core/components/buttons.dart';
import '../../core/env.dart';
import 'components/onramp_iframe_container.dart'
    if (dart.library.io) 'components/onramp_iframe_container_mock.dart';

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

Future<void> showCryptoMerchantIframeEmbed(
    BuildContext context, String url, String callbackParam,
    [bool shouldPop = true]) async {
  final maxWidth = BreakPoints.useMobileLayout(context) ? 400.0 : 750.0;
  final maxHeight = BreakPoints.useMobileLayout(context) ? 500.0 : 700.0;
  double width = MediaQuery.of(context).size.width - 32;
  double height = MediaQuery.of(context).size.height - 64;

  if (width > maxWidth) {
    width = maxWidth;
  }

  if (height > maxHeight) {
    height = maxHeight;
  }
  final value = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          insetPadding: EdgeInsets.zero,
          actionsPadding: EdgeInsets.zero,
          buttonPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OnrampIframeContainer(
                url: url,
                width: width,
                height: height,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AppButton(
                  label: "Cancel",
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                ),
              )
            ],
          ),
        );
      });

  if (value != null && shouldPop) {
    Navigator.of(context).pop(callbackParam);
  }
}
