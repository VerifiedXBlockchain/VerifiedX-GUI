import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/explorer_service.dart';

import '../models/btc_web_vbtc_token.dart';

class BtcWebVbtcTokenListProvider extends StateNotifier<List<BtcWebVbtcToken>> {
  final Ref ref;

  BtcWebVbtcTokenListProvider(this.ref) : super([]) {
    // load();
  }

  Future<void> load(String vfxAddress, {String? raAddress}) async {
    List<BtcWebVbtcToken> results = [];

    final explorer = ExplorerService();

    // Fetch V1 tokens
    final v1Tokens = await explorer.getWebVbtcTokens(vfxAddress);
    results = [...v1Tokens];

    if (raAddress != null) {
      final raV1Tokens = await explorer.getWebVbtcTokens(raAddress);
      results = [...results, ...raV1Tokens];
    }

    // Fetch V2 tokens
    final v2Tokens = await explorer.getWebVbtcV2Tokens(vfxAddress);
    results = [...results, ...v2Tokens];

    if (raAddress != null) {
      final raV2Tokens = await explorer.getWebVbtcV2Tokens(raAddress);
      results = [...results, ...raV2Tokens];
    }

    // Sort by createdAt descending (newest first)
    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    state = results;
  }

  Future<void> reload(String vfxAddress, {String? raAddress}) async {
    await load(vfxAddress, raAddress: raAddress);
  }
}

final btcWebVbtcTokenListProvider = StateNotifierProvider<BtcWebVbtcTokenListProvider, List<BtcWebVbtcToken>>((ref) {
  return BtcWebVbtcTokenListProvider(ref);
});
