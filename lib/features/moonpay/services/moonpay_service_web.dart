// ignore_for_file: avoid_web_libraries_in_flutter

@JS()
library vfx_moonpay;

import 'package:rbx_wallet/features/moonpay/services/moonpay_service_interface.dart';
import 'package:js/js.dart';
import 'dart:js' as js;
import 'dart:js_util';

@JS()
external moonPayBuy(String environment, String baseCurrencyCode, String baseCurrencyAmount, String walletAddress, bool popup);

class MoonpayServiceImpl extends MoonpayServiceInterface {
  @override
  Future<void> buy(String environment, String baseCurrencyCode, String baseCurrencyAmount, String walletAddress, bool popup) async {
    js.context.callMethod('moonPayBuy', [environment, baseCurrencyCode, baseCurrencyAmount, walletAddress, popup]);
  }
}
