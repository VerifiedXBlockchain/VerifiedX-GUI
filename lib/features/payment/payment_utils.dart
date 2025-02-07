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
