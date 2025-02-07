import 'package:rbx_wallet/features/moonpay/services/moonpay_service_interface.dart';

class MoonpayServiceImpl extends MoonpayServiceInterface {
  @override
  Future<void> buy(String environment, String baseCurrencyCode, String baseCurrencyAmount, String walletAddress, bool popup) {
    throw UnimplementedError();
  }
}
