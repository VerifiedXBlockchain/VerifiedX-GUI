import 'dart:math';

import '../../../core/env.dart';
import '../../../core/services/base_service.dart';
import '../models/btc_recommended_fees.dart';

class BtcFeeRateService extends BaseService {
  BtcFeeRateService()
      : super(
          hostOverride: "${Env.btcExplorerApiBaseUrl}/",
        );

  Future<BtcRecommendedFees> recommended() async {
    try {
      final data = await getJson("/v1/fees/recommended");
      final fees = BtcRecommendedFees.fromJson(data);

      // Testnet estimators read 1-2 sat/vB, which left test transactions
      // unconfirmed for hours on testnet4 (2026-08-13: two withdrawals sat in
      // the mempool all day). Floor the testnet tiers so test transactions
      // clear promptly; mainnet estimates pass through untouched.
      if (Env.btcIsTestNet) {
        return fees.copyWith(
          fastestFee: max(fees.fastestFee, 10),
          halfHourFee: max(fees.halfHourFee, 8),
          hourFee: max(fees.hourFee, 5),
          economyFee: max(fees.economyFee, 5),
          minimumFee: max(fees.minimumFee, 2),
        );
      }
      return fees;
    } catch (e) {
      print(e);
      return BtcRecommendedFees.fallback();
    }
  }
}
