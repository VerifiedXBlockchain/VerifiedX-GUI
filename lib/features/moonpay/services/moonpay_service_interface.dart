abstract class MoonpayServiceInterface {
  Future<void> buy(String environment, String baseCurrencyCode, String baseCurrencyAmount, String walletAddress, bool popup);
}
