import 'dart:math';

import '../../../core/env.dart';
import '../../../core/services/base_service.dart';
import '../models/btc_recommended_fees.dart';

class BtcFeeRateService extends BaseService {
  BtcFeeRateService()
      : super(
          hostOverride: "https://mempool.space/",
        );

  Future<BtcRecommendedFees> recommended() async {
    try {
      final data = await getJson("${Env.btcIsTestNet ? '/testnet4' : ''}/api/v1/fees/recommended");
      final fees = BtcRecommendedFees.fromJson(data);

      // Testnet4's estimator reads 1-2 sat/vB, but spam waves plus miners
      // producing near-empty blocks leave those rates unconfirmed for hours
      // (2026-08-13: two withdrawals sat in the mempool all day). Floor the
      // testnet tiers so test transactions actually clear; mainnet estimates
      // pass through untouched.
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
