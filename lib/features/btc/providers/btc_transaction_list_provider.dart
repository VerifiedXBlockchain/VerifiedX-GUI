import '../models/btc_transaction.dart';
import '../models/btc_utxo.dart';
import '../services/btc_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'btc_transaction_list_provider.g.dart';

@Riverpod(keepAlive: true)
class BtcTransactionList extends _$BtcTransactionList {
  @override
  List<BtcTransaction> build(String address) {
    return [];
  }

  load() async {
    state = await BtcService().listTransactions(address);
  }
}