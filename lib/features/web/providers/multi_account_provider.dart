import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/core/providers/web_session_provider.dart';
import 'package:rbx_wallet/features/btc_web/models/btc_web_account.dart';
import 'package:rbx_wallet/features/keygen/models/ra_keypair.dart';

import '../../../core/singletons.dart';
import '../../../core/storage.dart';
import '../../../core/services/multi_account_encryption_service.dart';
import '../../keygen/models/keypair.dart';
import '../models/multi_account_instance.dart';
import "package:collection/collection.dart";

class MultiAccountProvider extends StateNotifier<List<MultiAccountInstance>> {
  final Ref ref;
  MultiAccountProvider(this.ref,
      [List<MultiAccountInstance> initialState = const []])
      : super(initialState);

  set(List<MultiAccountInstance> accounts) {
    state = accounts;
    syncWithStorage();
  }

  add({
    required Keypair? keypair,
    required RaKeypair? raKeypair,
    required BtcWebAccount? btcKeypair,
    bool setAsCurrent = false,
    String? encryptionPassword,
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

    // Create account
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

    syncWithStorage(encryptionPassword);
  }

  remove(int id) {
    state = [...state]..removeWhere((element) => element.id == id);
    syncWithStorage();
  }

  rename(int id, String name) {
    final index = state.indexWhere((element) => element.id == id);
    if (index < 0) {
      return;
    }

    final item = state.firstWhereOrNull((element) => element.id == id);
    if (item == null) {
      return;
    }

    final newItem = item.rename(name);

    state = [...state]
      ..removeAt(index)
      ..insert(index, newItem);

    syncWithStorage();
  }

  clear() {
    state = [];
    syncWithStorage();
  }

  syncWithStorage([String? encryptionPassword]) {
    if (state.isEmpty) {
      singleton<Storage>().remove(Storage.MULTIPLE_ACCOUNTS);
      return;
    }

    final storedAccountsMap = _getStoredAccountsMap();
    final data = state
        .map((account) => _prepareAccountForStorage(
            account, storedAccountsMap[account.id], encryptionPassword))
        .toList();

    singleton<Storage>().setList(Storage.MULTIPLE_ACCOUNTS, data);
  }

  /// Retrieves stored accounts as a map of ID -> JSON
  Map<int, Map<String, dynamic>> _getStoredAccountsMap() {
    final storedData = singleton<Storage>().getList(Storage.MULTIPLE_ACCOUNTS);
    final storedAccountsMap = <int, Map<String, dynamic>>{};

    if (storedData != null) {
      for (var stored in storedData) {
        final json = jsonDecode(stored) as Map<String, dynamic>;
        storedAccountsMap[json['id'] as int] = json;
      }
    }

    return storedAccountsMap;
  }

  /// Prepares an account for storage, handling encryption appropriately
  String _prepareAccountForStorage(
    MultiAccountInstance account,
    Map<String, dynamic>? storedAccount,
    String? encryptionPassword,
  ) {
    var accountJson = account.toJson();

    // Case 1: Account already exists with encryption - preserve encrypted keys
    if (storedAccount != null &&
        MultiAccountEncryptionService.hasEncryptedPrivateKeys(storedAccount)) {
      return jsonEncode(_mergeWithEncryptedKeys(accountJson, storedAccount));
    }

    // Case 2: New account being added with encryption
    if (encryptionPassword != null && storedAccount == null) {
      accountJson = MultiAccountEncryptionService.encryptAccountPrivateKeys(
          accountJson, encryptionPassword);
    }

    // Case 3: No encryption needed or account is unencrypted
    return jsonEncode(accountJson);
  }

  /// Merges current account data with encrypted keys from storage
  Map<String, dynamic> _mergeWithEncryptedKeys(
    Map<String, dynamic> currentAccountJson,
    Map<String, dynamic> storedAccount,
  ) {
    final merged = Map<String, dynamic>.from(currentAccountJson);

    // Preserve each encrypted keypair from storage
    _preserveEncryptedKeypair(merged, storedAccount, 'keypair', 'private');
    _preserveEncryptedKeypair(merged, storedAccount, 'raKeypair', 'private');
    _preserveEncryptedKeypair(
        merged, storedAccount, 'btcKeypair', 'privateKey');

    return merged;
  }

  /// Preserves an encrypted keypair field from stored account
  void _preserveEncryptedKeypair(
    Map<String, dynamic> merged,
    Map<String, dynamic> storedAccount,
    String keypairKey,
    String privateKeyField,
  ) {
    if (storedAccount[keypairKey]?['_isPrivateEncrypted'] == true) {
      merged[keypairKey] = storedAccount[keypairKey];
    }
  }
}

/// Creates a MultiAccountInstance that can handle encrypted private keys
MultiAccountInstance _createAccountFromStoredJson(Map<String, dynamic> json) {
  // Check if any private keys are encrypted
  final hasEncryptedKeys =
      MultiAccountEncryptionService.hasEncryptedPrivateKeys(json);

  if (!hasEncryptedKeys) {
    // No encryption, create normally
    return MultiAccountInstance.fromJson(json);
  }

  // Has encrypted keys - we need to create the account with placeholder/null private keys
  // The actual decryption will happen when the user switches to this account and enters password

  // Create a copy of the JSON with placeholder private keys
  final modifiedJson = Map<String, dynamic>.from(json);

  if (modifiedJson['keypair'] != null) {
    final keypairJson = Map<String, dynamic>.from(modifiedJson['keypair']);
    if (keypairJson['_isPrivateEncrypted'] == true) {
      keypairJson['private'] =
          ''; // Placeholder - will be decrypted when needed
    }
    modifiedJson['keypair'] = keypairJson;
  }

  if (modifiedJson['raKeypair'] != null) {
    final raKeypairJson = Map<String, dynamic>.from(modifiedJson['raKeypair']);
    if (raKeypairJson['_isPrivateEncrypted'] == true) {
      raKeypairJson['private'] =
          ''; // Placeholder - will be decrypted when needed
    }
    modifiedJson['raKeypair'] = raKeypairJson;
  }

  if (modifiedJson['btcKeypair'] != null) {
    final btcKeypairJson =
        Map<String, dynamic>.from(modifiedJson['btcKeypair']);
    if (btcKeypairJson['_isPrivateEncrypted'] == true) {
      btcKeypairJson['privateKey'] =
          ''; // Placeholder - will be decrypted when needed
    }
    modifiedJson['btcKeypair'] = btcKeypairJson;
  }

  return MultiAccountInstance.fromJson(modifiedJson);
}

final multiAccountProvider =
    StateNotifierProvider<MultiAccountProvider, List<MultiAccountInstance>>(
        (ref) {
  final savedData = singleton<Storage>().getList(Storage.MULTIPLE_ACCOUNTS);
  if (savedData != null) {
    final initialState = savedData
        .map((e) =>
            _createAccountFromStoredJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();

    return MultiAccountProvider(ref, initialState);
  }

  return MultiAccountProvider(ref);
});

class SelectedMultiAccountProvider extends StateNotifier<int> {
  final Ref ref;
  SelectedMultiAccountProvider(this.ref, int initialState)
      : super(initialState);

  Future<void> set(MultiAccountInstance account, [String? password]) async {
    var accountToUse = account;

    // Need to check if the stored version has encrypted keys by looking at storage
    final storage = singleton<Storage>();
    final savedData = storage.getList(Storage.MULTIPLE_ACCOUNTS);

    if (savedData != null) {
      // Find the stored JSON for this account
      final storedAccountJson = savedData
          .map((e) => jsonDecode(e) as Map<String, dynamic>)
          .where((json) => json['id'] == account.id)
          .firstOrNull;

      if (storedAccountJson != null &&
          MultiAccountEncryptionService.hasEncryptedPrivateKeys(
              storedAccountJson)) {
        if (password == null) {
          throw Exception("Password required for encrypted account");
        }

        // Decrypt private keys from the stored JSON
        final decryptedJson =
            MultiAccountEncryptionService.decryptAccountPrivateKeys(
                storedAccountJson, password);
        accountToUse = MultiAccountInstance.fromJson(decryptedJson);
      }
    }

    state = accountToUse.id;
    ref.read(webSessionProvider.notifier).setMultiAccountInstance(accountToUse);
    if (accountToUse.keypair != null) {
      storage.setString(
          Storage.WEB_PRIMARY_ADDRESS, accountToUse.keypair!.address);
    }
    syncWithStorage();
  }

  Future<void> setFromId(int id, [String? password]) async {
    if (state == id) {
      return;
    }

    final account =
        ref.read(multiAccountProvider).firstWhereOrNull((a) => a.id == id);

    if (account != null) {
      await set(account, password);
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

    singleton<Storage>().setInt(Storage.MULTIPLE_ACCOUNT_SELECTED, state);
  }
}

final selectedMultiAccountProvider =
    StateNotifierProvider<SelectedMultiAccountProvider, int?>((ref) {
  final initialState =
      singleton<Storage>().getInt(Storage.MULTIPLE_ACCOUNT_SELECTED);
  return SelectedMultiAccountProvider(ref, initialState ?? 1);
});
