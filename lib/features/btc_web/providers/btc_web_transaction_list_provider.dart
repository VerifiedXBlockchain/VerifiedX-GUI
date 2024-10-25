import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/web_session_provider.dart';
import '../models/btc_web_transaction.dart';
import '../services/btc_web_service.dart';
import 'btc_web_vbtc_token_list_provider.dart';

class BtcWebTransactionListProvider extends StateNotifier<List<BtcWebTransaction>> {
  final Ref ref;
  final String address;

  BtcWebTransactionListProvider(this.ref, this.address) : super([]) {
    load();
  }

  Future<void> load() async {
    final transactions = await BtcWebService().listTransactions(address);
    state = transactions;
  }

  Future<void> reload() async {
    await load();
  }
}

final btcWebTransactionListProvider = StateNotifierProvider.family<BtcWebTransactionListProvider, List<BtcWebTransaction>, String>((ref, address) {
  return BtcWebTransactionListProvider(ref, address);
});

final btcWebCombinedTransactionListProvider = Provider((ref) {
  final mainAddress = ref.watch(webSessionProvider.select((v) => v.btcKeypair?.address));

  final List<BtcWebTransaction> mainTxs = mainAddress != null ? ref.watch(btcWebTransactionListProvider(mainAddress)) : [];

  final List<BtcWebTransaction> allTxs = [...mainTxs];

  final vbtcTokenAddresses = ref.watch(btcWebVbtcTokenListProvider).map((v) => v.depositAddress).toList();

  for (final a in vbtcTokenAddresses) {
    allTxs.addAll(ref.watch(btcWebTransactionListProvider(a)));
  }

  allTxs.sort((a, b) {
    final timestampA = a.status.blockTime == null ? DateTime.now().add(Duration(minutes: 20)).millisecondsSinceEpoch : a.status.blockTime! * 1000;
    final timestampB = b.status.blockTime == null ? DateTime.now().add(Duration(minutes: 20)).millisecondsSinceEpoch : b.status.blockTime! * 1000;

    return timestampA > timestampB ? -1 : 1;
  });

  return allTxs;
});
