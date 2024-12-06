import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/explorer_service.dart';

import '../models/btc_web_vbtc_token.dart';

final btcWebVbtcTokenDetailProvider = FutureProvider.family<BtcWebVbtcToken?, String>((ref, arg) async {
  final scId = arg.split("_").first;
  final address = arg.split("_").last;

  return ExplorerService().getWebVbtcTokenDetail(scId, address);
});
