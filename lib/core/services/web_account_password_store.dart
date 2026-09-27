import 'dart:convert';

import 'package:collection/collection.dart';

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
/// decrypts the keys it encrypted.
class WebAccountPasswordStore {
  final Storage storage;

  const WebAccountPasswordStore(this.storage);

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
      return _decryptAccount(stored, password) != null;
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
      final account = _decryptAccount(stored, password);
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

  /// Decrypts a stored account, or returns null when [password] is wrong.
  MultiAccountInstance? _decryptAccount(
      Map<String, dynamic> stored, String password) {
    try {
      final decrypted = MultiAccountEncryptionService.decryptAccountPrivateKeys(
          stored, password);
      return MultiAccountInstance.fromJson(decrypted);
    } catch (e) {
      // A wrong password fails the GCM tag check; that is the expected path.
      return null;
    }
  }
}
