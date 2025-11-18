typedef MoonPayDepositCallback = Future<String?> Function(
  String cryptoCurrency,
  double cryptoCurrencyAmount,
  String depositWalletAddress,
);

abstract class MoonpayServiceInterface {
  Future<void> buy(String environment, String baseCurrencyCode, String baseCurrencyAmount, String walletAddress, bool popup);
  Future<void> sell(
    String environment,
    String baseCurrencyCode,
    String baseCurrencyAmount,
    String walletAddress,
    bool popup, {
    MoonPayDepositCallback? onDeposit,
  });
}
