import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/utils/html_helpers.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../core/providers/web_session_provider.dart';
import '../models/btc_web_transaction.dart';
import '../services/btc_web_service.dart';
import 'btc_web_vbtc_token_list_provider.dart';
import 'package:collection/collection.dart';

class BtcWebTransactionListProvider extends StateNotifier<List<BtcWebTransaction>> {
  final Ref ref;
  final String address;

  BtcWebTransactionListProvider(this.ref, this.address) : super([]) {
    load();
  }

  Future<void> load() async {
    final transactions = await BtcWebService().listTransactions(address);

    if (transactions.isEmpty) {
      print("TXS were empty!");
      return;
    }

    transactions.sort((a, b) {
      if (a.status.blockHeight == null && b.status.blockHeight != null) {
        return -1; // Null first
      }
      if (a.status.blockHeight != null && b.status.blockHeight == null) {
        return 1; // Non-null after null
      }
      if (a.status.blockHeight != null && b.status.blockHeight != null) {
        return b.status.blockHeight!.compareTo(a.status.blockHeight!); // Sort highest first
      }
      return 0;
    });

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

  List<BtcWebTransaction> allTxs = [...mainTxs];

  final vbtcTokenAddresses = ref.watch(btcWebVbtcTokenListProvider).map((v) => v.depositAddress).toList();

  for (final a in vbtcTokenAddresses) {
    allTxs.addAll(ref.watch(btcWebTransactionListProvider(a)));
  }

  final groups = groupBy(allTxs, (BtcWebTransaction tx) => tx.txid);

  List<BtcWebTransaction> uniqueTxs = groups.values.map((list) => list.first).toList();

  uniqueTxs.sort((a, b) {
    final timestampA = a.status.blockTime == null ? DateTime.now().add(Duration(minutes: 20)).millisecondsSinceEpoch : a.status.blockTime! * 1000;
    final timestampB = b.status.blockTime == null ? DateTime.now().add(Duration(minutes: 20)).millisecondsSinceEpoch : b.status.blockTime! * 1000;

    return timestampA > timestampB ? -1 : 1;
  });

  return uniqueTxs;
});

final vbtcWebCombinedTransactionListProvider = Provider((ref) {
  final vbtcTokenAddresses = ref.watch(btcWebVbtcTokenListProvider).map((v) => v.depositAddress).toList();

  final List<BtcWebTransaction> allTxs = [];

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
