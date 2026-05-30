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

    final tokens = await explorer.getWebVbtcTokens(vfxAddress);
    results = [...tokens];

    if (raAddress != null) {
      final raTokens = await explorer.getWebVbtcTokens(raAddress);
      results = [...results, ...raTokens];
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
