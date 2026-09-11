import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/explorer_service.dart';

import '../models/btc_web_vbtc_token.dart';

/// Family key format: "{scIdentifier}_{address}"
///
/// autoDispose so leaving the screen drops the cached token — otherwise
/// re-entering serves whatever balance was fetched on the first visit. While
/// the screen is open the web session loop invalidates this on every tick to
/// keep the balance live.
final btcWebVbtcTokenDetailProvider = FutureProvider.autoDispose.family<BtcWebVbtcToken?, String>((ref, arg) async {
  final scId = arg.split("_").first;
  return ExplorerService().getWebVbtcTokenDetail(scId, '');
});
