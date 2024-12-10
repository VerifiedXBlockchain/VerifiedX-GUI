import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/price_data.dart';

import '../../../core/services/explorer_service.dart';

final vfxPriceDataDetailProvider = FutureProvider<PriceData?>((ref) async {
  return ExplorerService().retrievePriceData('vfx');
});

final btcPriceDataDetailProvider = FutureProvider<PriceData?>((ref) async {
  return ExplorerService().retrievePriceData('btc');
});

final vfxCurrentPriceDataDetailProvider = Provider<double?>((ref) {
  final value = ref.watch(vfxPriceDataDetailProvider);
  return value.when(
    data: (data) => data?.usdtPrice,
    loading: () => null,
    error: (_, __) => null,
  );
});

final btcCurrentPriceDataDetailProvider = Provider<double?>((ref) {
  final value = ref.watch(btcPriceDataDetailProvider);
  return value.when(
    data: (data) => data?.usdtPrice,
    loading: () => null,
    error: (_, __) => null,
  );
});
