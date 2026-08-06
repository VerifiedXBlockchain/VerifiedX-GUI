import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../../../core/components/buttons.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/singletons.dart';
import '../../../core/storage.dart';
import '../../../utils/guards.dart';
import '../../../utils/toast.dart';
import '../../bridge/providers/wallet_info_provider.dart';
import '../../bridge/services/bridge_service.dart';
import '../../../l10n/l10n_helper.dart';
import '../models/wallet.dart';

class WalletListProvider extends StateNotifier<List<Wallet>> {
  final Ref ref;

  WalletListProvider(this.ref, [List<Wallet> wallets = const []]) : super(wallets);

  void set(List<Wallet> wallets) {
    state = wallets;
  }

  Future<Wallet?> import(String privateKey, [bool showDetails = false, bool rescan = false]) async {
    // if (!guardWalletIsNotResyncing(read)) return;

    final data = await BridgeService().importPrivateKey(privateKey, rescan);

    if (data == null) {
      Toast.error(globalL10n.txpNoAccountFound);
      return null;
    }

    final wallet = Wallet.fromJson(data);
    List<dynamic>? updatedList = (singleton<Storage>().getList(Storage.DELETED_WALLETS_KEY) ?? [])..removeWhere((a) => a == wallet.address);
    singleton<Storage>().setList(Storage.DELETED_WALLETS_KEY, updatedList);
    state = [...state, wallet];
    ref.read(sessionProvider.notifier).setCurrentWallet(wallet);
    // ref.read(sessionProvider.notifier).load();
    ref.read(walletInfoProvider.notifier).infoLoop(false);

    if (showDetails) {
      final context = rootScaffoldKey.currentContext!;

      return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(globalL10n.txpAccountCreated),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(globalL10n.txpWalletDetailsBackup),
                ),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet),
                  title: TextFormField(
                    initialValue: wallet.address,
                    decoration: InputDecoration(label: Text(globalL10n.walletAddressLabel)),
                    readOnly: true,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: TextFormField(
                    initialValue: wallet.privateKey,
                    decoration: InputDecoration(
                      label: Text(globalL10n.walletPrivateKeyLabel),
                    ),
                    style: const TextStyle(fontSize: 13),
                    readOnly: true,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: wallet.privateKey));
                      Toast.message(globalL10n.walletPrivateKeyCopiedToast);
                    },
                  ),
                ),
                const Divider(),
                AppButton(
                  label: globalL10n.walletDoneLabel,
                  onPressed: () {
                    Navigator.of(context).pop(wallet);
                  },
                )
              ],
            ),
          );
        },
      );
    } else {
      return wallet;
    }
  }

  Future<Wallet?> create() async {
    if (!guardWalletIsNotResyncing(ref)) return null;

    final data = await BridgeService().newAddress();

    if (data == null) {
      Toast.error(globalL10n.txpErrorOccurred);
      return null;
    }
    final json = jsonDecode(data);
    final privateKey = json[0]['PrivateKey'];

    return await import(privateKey, true);
  }

  // void saveAll() {
  //   final items = [];
  //   for (final wallet in state) {
  //     items.add(wallet.toJson());
  //   }

  //   singleton<Storage>().setList(Storage.WALLETS_KEY, items);
  // }

  void rename(Wallet wallet, String name) {
    final index = state.indexWhere((element) => element.address == wallet.address);

    final w = state[index];
    final updatedWallet = Wallet(
      id: w.id,
      publicKey: w.publicKey,
      privateKey: w.privateKey,
      address: w.address,
      balance: w.balance,
      isValidating: w.isValidating,
      // isEncrypted: w.isEncrypted,
      friendlyName: name == "" ? null : name,
    );

    final newState = [...state];
    newState.removeAt(index);
    newState.insert(index, updatedWallet);

    state = newState;

    Map<String, dynamic>? names = singleton<Storage>().getMap(Storage.RENAMED_WALLETS_KEY);

    names ??= {};

    names[w.address] = name;

    singleton<Storage>().setMap(Storage.RENAMED_WALLETS_KEY, names);
  }

  void delete(Wallet wallet) {
    final index = state.indexWhere((element) => element.address == wallet.address);
    final newState = [...state];
    newState.removeAt(index);
    state = newState;
  }

  Wallet? getWallet(String address) {
    return state.firstWhereOrNull((element) => element.address == address);
  }
}

final walletListProvider = StateNotifierProvider<WalletListProvider, List<Wallet>>((ref) {
  return WalletListProvider(ref);
});
