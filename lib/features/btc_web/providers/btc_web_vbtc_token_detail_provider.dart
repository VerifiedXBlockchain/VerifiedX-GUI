import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/explorer_service.dart';

import '../models/btc_web_vbtc_token.dart';

/// Family key format: "{scIdentifier}_{address}"
final btcWebVbtcTokenDetailProvider = FutureProvider.family<BtcWebVbtcToken?, String>((ref, arg) async {
  final scId = arg.split("_").first;
  return ExplorerService().getWebVbtcTokenDetail(scId, '');
});
