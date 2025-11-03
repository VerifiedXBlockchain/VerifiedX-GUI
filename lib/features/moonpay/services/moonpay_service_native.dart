import 'package:rbx_wallet/features/moonpay/services/moonpay_service_interface.dart';

class MoonpayServiceImpl extends MoonpayServiceInterface {
  @override
  Future<void> buy(String environment, String baseCurrencyCode, String baseCurrencyAmount, String walletAddress, bool popup) {
    throw UnimplementedError();
  }

  @override
  Future<void> sell(
    String environment,
    String baseCurrencyCode,
    String baseCurrencyAmount,
    String walletAddress,
    bool popup, {
    MoonPayDepositCallback? onDeposit,
  }) {
    throw UnimplementedError();
  }
}
