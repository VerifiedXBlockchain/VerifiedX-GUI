import "../models/btc_account.dart";
import "../models/btc_address_type.dart";
import "../services/btc_service.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

import "btc_transaction_list_provider.dart";
import "btc_utxo_list_provider.dart";
import 'package:collection/collection.dart';

part 'btc_account_list_provider.g.dart';

@Riverpod(keepAlive: true)
class BtcAccountList extends _$BtcAccountList {
  @override
  List<BtcAccount> build() {
    return [];
  }

  Future<void> load() async {
    state = await BtcService().listAccounts();
    _updateTransactions();
  }

  void _updateTransactions() {
    for (final account in state) {
      ref.read(btcUtxoListProvider(account.address).notifier).load();
    }
    ref.read(btcTransactionListProvider.notifier).load();
  }

  Future<BtcAccount?> create() async {
    final created = await BtcService().createAccount();
    if (created == null) {
      return null;
    }
    await load();
    // The node returns the private key only in the create reply (Core
    // VX-13); a re-fetch would come back without it. Carry the keys onto
    // the listed record so the "account created" dialog can show them.
    final listed = getAccount(created.address);
    if (listed == null) {
      return created;
    }
    return listed.copyWith(privateKey: created.privateKey, wifKey: created.wifKey);
  }

  Future<bool> importPrivateKey(String privateKey, BtcAddressType addressType) async {
    final success = await BtcService().importPrivateKey(privateKey, addressType);
    if (success) {
      await load();
      return true;
    }

    return false;
  }

  BtcAccount? getAccount(String address) {
    return state.firstWhereOrNull((element) => element.address == address);
  }
}
