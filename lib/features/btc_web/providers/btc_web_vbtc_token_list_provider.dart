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

    final tokens = await ExplorerService().getWebVbtcTokens(vfxAddress);
    results = [...tokens];

    if (raAddress != null) {
      final raTokens = await ExplorerService().getWebVbtcTokens(raAddress);
      results = [...tokens, ...raTokens];
    }

    state = results;
  }

  Future<void> reload(String vfxAddress) async {
    await load(vfxAddress);
  }
}

final btcWebVbtcTokenListProvider = StateNotifierProvider<BtcWebVbtcTokenListProvider, List<BtcWebVbtcToken>>((ref) {
  return BtcWebVbtcTokenListProvider(ref);
});
