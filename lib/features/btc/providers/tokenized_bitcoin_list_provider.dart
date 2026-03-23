import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tokenized_bitcoin.dart';
import '../services/btc_service.dart';
import '../services/vbtc_v2_service.dart';

class TokenizedBitcoinListProvider extends StateNotifier<List<TokenizedBitcoin>> {
  final Ref ref;

  TokenizedBitcoinListProvider(this.ref) : super([]) {
    load();
  }

  Future<void> load() async {
    final results = await Future.wait([
      BtcService().listTokenizedBitcoins(),
      VbtcV2Service().getContractList(),
    ]);

    state = [...results[0], ...results[1]];
  }

  void refresh() {
    load();
  }
}

final tokenizedBitcoinListProvider = StateNotifierProvider<TokenizedBitcoinListProvider, List<TokenizedBitcoin>>(
  (ref) => TokenizedBitcoinListProvider(ref),
);
