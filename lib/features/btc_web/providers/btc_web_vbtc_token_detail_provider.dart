import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/explorer_service.dart';

import '../models/btc_web_vbtc_token.dart';
import 'btc_web_vbtc_token_list_provider.dart';

/// Family key format: "{scIdentifier}_{address}"
/// Version is determined by checking the token list state.
final btcWebVbtcTokenDetailProvider = FutureProvider.family<BtcWebVbtcToken?, String>((ref, arg) async {
  final scId = arg.split("_").first;
  final address = arg.split("_").last;

  // Check if this is a V2 token by looking at the loaded token list
  final tokenList = ref.read(btcWebVbtcTokenListProvider);
  final matching = tokenList.where((t) => t.scIdentifier == scId);
  final version = matching.isNotEmpty ? matching.first.version : 1;

  if (version >= 2) {
    return ExplorerService().getWebVbtcV2TokenDetail(scId);
  }

  return ExplorerService().getWebVbtcTokenDetail(scId, address);
});
