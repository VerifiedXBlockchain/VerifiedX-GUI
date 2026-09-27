import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import '../../features/btc_web/models/btc_web_account.dart';
import '../../features/keygen/models/keypair.dart';
import '../../features/keygen/models/ra_keypair.dart';
import '../../features/web/models/multi_account_instance.dart';
import '../storage.dart';
import 'encryption_service.dart';
import 'multi_account_encryption_service.dart';

/// Keys decrypted by [WebAccountPasswordStore.unlock].
class UnlockedWebAccount {
  /// Id of the matching entry in [Storage.MULTIPLE_ACCOUNTS], or null when
  /// the keys came from the legacy slot and no entry holds the same address.
  final int? accountId;
  final Keypair keypair;
  final RaKeypair? raKeypair;
  final BtcWebAccount? btcKeypair;

  const UnlockedWebAccount({
    required this.accountId,
    required this.keypair,
    required this.raKeypair,
    required this.btcKeypair,
  });
}

/// Per-account passwords for the web wallet.
///
/// Every web account is stored in [Storage.MULTIPLE_ACCOUNTS] with its private
/// keys encrypted (AES-256-GCM, PBKDF2) under the password chosen when that
/// account was added. The GCM tag authenticates the password, so an account's
/// password is checked by decrypting that account's own keys. No separate
/// per-account hash is stored, so the storage shape is unchanged.
///
/// The active account is the one in [Storage.MULTIPLE_ACCOUNT_SELECTED]: the
/// account the session holds, and after a reload the last one that was active.
/// Unlock targets it.
///
/// Legacy fallback: wallets also keep a wallet-wide slot
/// ([Storage.STORED_PASSWORD_HASH] with [Storage.WEB_KEYPAIR],
/// [Storage.WEB_RA_KEYPAIR] and [Storage.WEB_BTC_KEYPAIR]) that holds the most
/// recently added account under that account's password. It is used when the
/// target account has no encrypted entry (wallets saved before multi-account
/// encryption), and so that a wallet saved before per-account passwords still
/// opens with the password that opened it before. That password only ever
/// decrypts the keys it encrypted. The slot encrypts each keypair as a whole,
/// so every secret field in it is already covered.
///
/// Whenever an account's password is confirmed by decrypting its entry, any
/// secret field of that entry still stored in the earlier format (only the
/// main private keys were encrypted) is encrypted under the same password and
/// the entry is rewritten. An entry saved before per-account encryption is
/// encrypted with the slot's password when that password unlocks the slot
/// holding the same address. See [MultiAccountEncryptionService].
class WebAccountPasswordStore {
  final Storage storage;

  /// Encrypts an account record when upgrading it. Replaceable for tests.
  final Map<String, dynamic> Function(Map<String, dynamic>, String)
      encryptAccount;

  const WebAccountPasswordStore(
    this.storage, {
    @visibleForTesting this.encryptAccount =
        MultiAccountEncryptionService.encryptAccountPrivateKeys,
  });

  int? get activeAccountId => storage.getInt(Storage.MULTIPLE_ACCOUNT_SELECTED);

  List<Map<String, dynamic>> storedAccounts() {
    final savedData = storage.getList(Storage.MULTIPLE_ACCOUNTS);
    if (savedData == null) {
      return [];
    }
    return savedData
        .map((e) => jsonDecode(e as String) as Map<String, dynamic>)
        .toList();
  }

  Map<String, dynamic>? storedAccount(int id) =>
      storedAccounts().firstWhereOrNull((json) => json['id'] == id);

  /// Whether [password] belongs to the account with [accountId].
  ///
  /// An account without encrypted keys has no password of its own, so the
  /// wallet-wide legacy hash decides.
  bool verifyAccountPassword(int? accountId, String password) {
    final stored = accountId != null ? storedAccount(accountId) : null;
    if (stored != null &&
        MultiAccountEncryptionService.hasEncryptedPrivateKeys(stored)) {
      return _decryptAndUpgrade(stored, password) != null;
    }
    return verifyLegacyPassword(password);
  }

  /// Whether [password] belongs to the active account.
  bool verifyActiveAccountPassword(String password) =>
      verifyAccountPassword(activeAccountId, password);

  /// Checks [password] against the wallet-wide hash written before passwords
  /// were per account.
  bool verifyLegacyPassword(String password) {
    final storedHash = storage.getString(Storage.STORED_PASSWORD_HASH);
    if (storedHash == null) {
      return false;
    }
    return EncryptionService.verifyPassword(password, storedHash);
  }

  /// The VFX address shown on the unlock screen: the account unlock targets.
  String? unlockTargetAddress() {
    final id = activeAccountId;
    final stored = id != null ? storedAccount(id) : null;
    final address = stored?['keypair']?['address'];
    if (address is String && address.isNotEmpty) {
      return address;
    }
    return storage.getString(Storage.WEB_PRIMARY_ADDRESS);
  }

  /// Decrypts the keys [password] opens, or returns null when it opens none.
  ///
  /// Tries the active account first, then the legacy wallet-wide slot.
  UnlockedWebAccount? unlock(String password) {
    final id = activeAccountId;
    final stored = id != null ? storedAccount(id) : null;
    if (stored != null &&
        stored['keypair'] != null &&
        MultiAccountEncryptionService.hasEncryptedPrivateKeys(stored)) {
      final account = _decryptAndUpgrade(stored, password);
      if (account != null && account.keypair != null) {
        return UnlockedWebAccount(
          accountId: account.id,
          keypair: account.keypair!,
          raKeypair: account.raKeypair,
          btcKeypair: account.btcKeypair,
        );
      }
    }

    return _unlockLegacySlot(password);
  }

  UnlockedWebAccount? _unlockLegacySlot(String password) {
    if (!verifyLegacyPassword(password)) {
      return null;
    }

    final encryptedVfx = storage.getMap(Storage.WEB_KEYPAIR);
    if (encryptedVfx == null || !EncryptionService.isEncrypted(encryptedVfx)) {
      return null;
    }

    try {
      final keypair =
          Keypair.fromJson(EncryptionService.decrypt(encryptedVfx, password));

      final encryptedRa = storage.getMap(Storage.WEB_RA_KEYPAIR);
      final raKeypair = encryptedRa != null
          ? RaKeypair.fromJson(EncryptionService.decrypt(encryptedRa, password))
          : null;

      final encryptedBtc = storage.getMap(Storage.WEB_BTC_KEYPAIR);
      final btcKeypair = encryptedBtc != null
          ? BtcWebAccount.fromJson(
              EncryptionService.decrypt(encryptedBtc, password))
          : null;

      final matchingEntry = storedAccounts().firstWhereOrNull(
          (json) => json['keypair']?['address'] == keypair.address);
      if (matchingEntry != null) {
        if (MultiAccountEncryptionService.hasEncryptedPrivateKeys(
            matchingEntry)) {
          // Upgrades the entry only when this password is also its own.
          _decryptAndUpgrade(matchingEntry, password);
        } else {
          // An entry saved before per-account encryption has no password of
          // its own; the slot's password, just confirmed, is the one that
          // opens this account, so the entry is encrypted with it.
          _upgradeStoredAccount(matchingEntry, password,
              expected: matchingEntry);
        }
      }

      return UnlockedWebAccount(
        accountId: matchingEntry?['id'] as int?,
        keypair: keypair,
        raKeypair: raKeypair,
        btcKeypair: btcKeypair,
      );
    } catch (e) {
      print("Failed to decrypt the legacy web wallet keys: $e");
      return null;
    }
  }

  /// Decrypts the stored account with [id] under [password], for switching to
  /// it or revealing its keys. Returns null when the account is missing, has
  /// no encrypted keys, or [password] is not its own.
  MultiAccountInstance? decryptStoredAccount(int id, String password) {
    final stored = storedAccount(id);
    if (stored == null ||
        !MultiAccountEncryptionService.hasEncryptedPrivateKeys(stored)) {
      return null;
    }
    return _decryptAndUpgrade(stored, password);
  }

  /// Decrypts [stored] and, when [password] opens it, upgrades the stored
  /// entry to the current account format.
  MultiAccountInstance? _decryptAndUpgrade(
      Map<String, dynamic> stored, String password) {
    final Map<String, dynamic> decrypted;
    final MultiAccountInstance account;
    try {
      decrypted = MultiAccountEncryptionService.decryptAccountPrivateKeys(
          stored, password);
      account = MultiAccountInstance.fromJson(decrypted);
    } catch (e) {
      // A wrong password fails the GCM tag check; that is the expected path.
      return null;
    }
    _upgradeStoredAccount(stored, password, expected: decrypted);
    return account;
  }

  /// Rewrites the entry [stored] with every secret field encrypted under
  /// [password], checked against [expected], its decrypted content. Nothing
  /// is written when the entry is already in that format, when the new record
  /// does not decrypt to the same values, or when the stored entry changed in
  /// the meantime; the old entry is kept.
  void _upgradeStoredAccount(Map<String, dynamic> stored, String password,
      {required Map<String, dynamic> expected}) {
    final Map<String, dynamic>? upgraded;
    try {
      upgraded = MultiAccountEncryptionService.upgradeAccountRecord(
          stored, password,
          expected: expected, encrypt: encryptAccount);
    } catch (e) {
      print("Kept the stored format of web account ${stored['id']}: $e");
      return;
    }
    if (upgraded == null) {
      return;
    }

    final savedData = storage.getList(Storage.MULTIPLE_ACCOUNTS);
    if (savedData == null) {
      return;
    }
    final index = savedData.indexWhere((entry) => const DeepCollectionEquality()
        .equals(jsonDecode(entry as String), stored));
    if (index < 0) {
      print("Kept the stored format of web account ${stored['id']}: "
          "the stored entry changed before it could be rewritten");
      return;
    }

    final updated = [...savedData];
    updated[index] = jsonEncode(upgraded);
    storage.setList(Storage.MULTIPLE_ACCOUNTS, updated);
  }
}
