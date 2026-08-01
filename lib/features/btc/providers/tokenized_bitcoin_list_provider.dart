import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/session_provider.dart';
import '../models/tokenized_bitcoin.dart';
import '../services/btc_service.dart';
import '../services/vbtc_v2_service.dart';

class TokenizedBitcoinListProvider extends StateNotifier<List<TokenizedBitcoin>> {
  final Ref ref;

  TokenizedBitcoinListProvider(this.ref) : super([]) {
    load();
  }

  Future<void> load() async {
    // The active wallet, not the contract owner: `myBalance` is this wallet's
    // spendable figure, and V2 contracts are routinely held by non-owners.
    final address = ref.read(sessionProvider).currentWallet?.address;

    final results = await Future.wait([
      BtcService().listTokenizedBitcoins(),
      VbtcV2Service().getContractList(address: address),
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
