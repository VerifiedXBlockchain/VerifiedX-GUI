import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/core/providers/web_session_provider.dart';
import 'package:rbx_wallet/features/btc_web/models/btc_web_account.dart';
import 'package:rbx_wallet/features/keygen/models/ra_keypair.dart';

import '../../../core/singletons.dart';
import '../../../core/storage.dart';
import '../../keygen/models/keypair.dart';
import '../models/multi_account_instance.dart';
import "package:collection/collection.dart";

class MultiAccountProvider extends StateNotifier<List<MultiAccountInstance>> {
  final Ref ref;
  MultiAccountProvider(this.ref, [List<MultiAccountInstance> initialState = const []]) : super(initialState);

  set(List<MultiAccountInstance> accounts) {
    state = accounts;
    syncWithStorage();
  }

  add({
    required Keypair? keypair,
    required RaKeypair? raKeypair,
    required BtcWebAccount? btcKeypair,
    bool setAsCurrent = false,
  }) {
    final existsAlready = state.isNotEmpty
        ? (state.where((element) =>
            element.keypair?.address == keypair?.address &&
            element.raKeypair?.address == raKeypair?.address &&
            element.btcKeypair?.address == btcKeypair?.address)).isNotEmpty
        : false;

    if (existsAlready) {
      return;
    }

    final id = state.isNotEmpty ? state.last.id + 1 : 1;

    final account = MultiAccountInstance(
      id: id,
      keypair: keypair,
      raKeypair: raKeypair,
      btcKeypair: btcKeypair,
    );

    state = [...state, account];

    if (setAsCurrent) {
      ref.read(selectedMultiAccountProvider.notifier).set(account);
    }

    syncWithStorage();
  }

  remove(int id) {
    state = [...state]..removeWhere((element) => element.id == id);
    syncWithStorage();
  }

  clear() {
    state = [];
    syncWithStorage();
  }

  syncWithStorage() {
    if (state.isEmpty) {
      singleton<Storage>().remove(Storage.MULTIPLE_ACCOUNTS);
      return;
    }

    final rememberMe = singleton<Storage>().getBool(Storage.REMEMBER_ME) ?? false;
    if (rememberMe) {
      final data = state.map((e) => jsonEncode(e.toJson())).toList();
      singleton<Storage>().setList(Storage.MULTIPLE_ACCOUNTS, data);
    }
  }
}

final multiAccountProvider = StateNotifierProvider<MultiAccountProvider, List<MultiAccountInstance>>((ref) {
  final savedData = singleton<Storage>().getList(Storage.MULTIPLE_ACCOUNTS);
  if (savedData != null) {
    print("*********");
    print("SAVED DATA $savedData");

    print("----------");
    final initialState = savedData.map((e) => MultiAccountInstance.fromJson(jsonDecode(e) as Map<String, dynamic>)).toList();

    return MultiAccountProvider(ref, initialState);
  }

  return MultiAccountProvider(ref);
});

class SelectedMultiAccountProvider extends StateNotifier<int> {
  final Ref ref;
  SelectedMultiAccountProvider(this.ref, int initialState) : super(initialState);

  set(MultiAccountInstance account) {
    state = account.id;
    ref.read(webSessionProvider.notifier).setMultiAccountInstance(account);
    print(account);
  }

  setFromId(int id) {
    if (state == id) {
      return;
    }

    final account = ref.read(multiAccountProvider).firstWhereOrNull((a) => a.id == id);

    if (account != null) {
      set(account);
    }
  }

  clear() {
    state = 0;
    syncWithStorage();
  }

  syncWithStorage() {
    if (state == 0) {
      singleton<Storage>().remove(Storage.MULTIPLE_ACCOUNT_SELECTED);
      return;
    }

    final rememberMe = singleton<Storage>().getBool(Storage.REMEMBER_ME) ?? false;
    if (rememberMe) {
      singleton<Storage>().setInt(Storage.MULTIPLE_ACCOUNT_SELECTED, state!);
    }
  }
}

final selectedMultiAccountProvider = StateNotifierProvider<SelectedMultiAccountProvider, int?>((ref) {
  final initialState = singleton<Storage>().getInt(Storage.MULTIPLE_ACCOUNT_SELECTED);
  return SelectedMultiAccountProvider(ref, initialState ?? 1);
});
