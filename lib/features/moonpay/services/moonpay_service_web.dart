// ignore_for_file: avoid_web_libraries_in_flutter

@JS()
library vfx_moonpay;

import 'package:rbx_wallet/features/moonpay/services/moonpay_service_interface.dart';
import 'package:js/js.dart';
import 'dart:js' as js;
import 'dart:js_util' as js_util;

import '../../../core/env.dart';

@JS()
external moonPayBuy(String environment, String baseCurrencyCode,
    String baseCurrencyAmount, String walletAddress, bool popup);

class MoonpayServiceImpl extends MoonpayServiceInterface {
  @override
  Future<void> buy(String environment, String baseCurrencyCode,
      String baseCurrencyAmount, String walletAddress, bool popup) async {
    js.context.callMethod('moonPayBuy', [
      environment,
      baseCurrencyCode,
      baseCurrencyAmount,
      walletAddress,
      popup
    ]);
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
    print("MoonpayService.sell called");
    print("onDeposit callback provided: ${onDeposit != null}");

    // Register callback if provided
    if (onDeposit != null) {
      print("Registering flutterMoonPayDepositCallback on window");
      js.context['flutterMoonPayDepositCallback'] = js.allowInterop(
        (
          cryptoCurrency,
          cryptoCurrencyAmountStr,
          depositWalletAddress,
          jsResolve,
          jsReject,
        ) {
          print("🔔 Flutter callback invoked from JS!");
          print("  cryptoCurrency: $cryptoCurrency (type: ${cryptoCurrency.runtimeType})");
          print("  cryptoCurrencyAmount: $cryptoCurrencyAmountStr (type: ${cryptoCurrencyAmountStr.runtimeType})");
          print("  depositWalletAddress: $depositWalletAddress (type: ${depositWalletAddress.runtimeType})");
          print("  jsResolve: $jsResolve (type: ${jsResolve.runtimeType})");
          print("  jsReject: $jsReject (type: ${jsReject.runtimeType})");

          // Handle async work without blocking
          () async {
            try {
              final currencyStr = cryptoCurrency.toString();
              final amountStr = cryptoCurrencyAmountStr.toString();
              final addressStr = depositWalletAddress.toString();
              final amount = double.parse(amountStr);

              print("Parsed values:");
              print("  currency: $currencyStr");
              print("  amount: $amount");
              print("  address: $addressStr");
              print("Calling onDeposit callback...");

              final txHash = await onDeposit(
                currencyStr,
                amount,
                addressStr,
              );

              print("onDeposit returned txHash: $txHash");

              if (txHash != null) {
                print("Resolving JS promise with txHash");
                js_util.callMethod(jsResolve, 'call', [null, txHash]);
              } else {
                print("Rejecting JS promise - txHash is null");
                js_util.callMethod(jsReject, 'call', [null, 'Transaction cancelled or failed']);
              }
            } catch (e, st) {
              print("Error in Flutter callback: $e");
              print("Stack trace: $st");
              try {
                js_util.callMethod(jsReject, 'call', [null, e.toString()]);
              } catch (e2) {
                print("Failed to call jsReject: $e2");
              }
            }
          }();
        },
      );
      print("flutterMoonPayDepositCallback registered successfully");
    }

    print("Calling moonPaySell JS function");
    js.context.callMethod('moonPaySell', [
      environment,
      baseCurrencyCode,
      baseCurrencyAmount,
      walletAddress,
      popup
    ]);
  }
}
