import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/services/encryption_service.dart';
import 'package:rbx_wallet/core/services/multi_account_encryption_service.dart';
import 'package:rbx_wallet/core/services/password_verification_service.dart';
import 'package:rbx_wallet/core/services/web_account_password_store.dart';
import 'package:rbx_wallet/core/singletons.dart';
import 'package:rbx_wallet/core/storage.dart';
import 'package:rbx_wallet/features/btc_web/models/btc_web_account.dart';
import 'package:rbx_wallet/features/keygen/models/keypair.dart';
import 'package:rbx_wallet/features/keygen/models/ra_keypair.dart';
import 'package:rbx_wallet/features/web/models/multi_account_instance.dart';

/// Storage kept in memory, round-tripping values through JSON like the real
/// backends do.
class _MemoryStorage extends Storage {
  final Map<String, Object?> values = {};

  @override
  Future<void> init() async {
    isInitialized = true;
  }

  @override
  void remove(String key) => values.remove(key);

  @override
  String? getString(String key) => values[key] as String?;
  @override
  void setString(String key, String value) => values[key] = value;

  @override
  bool? getBool(String key) => values[key] as bool?;
  @override
  void setBool(String key, bool value) => values[key] = value;

  @override
  int? getInt(String key) => values[key] as int?;
  @override
  void setInt(String key, int value) => values[key] = value;

  @override
  Map<String, dynamic>? getMap(String key) {
    final raw = values[key] as String?;
    return raw == null ? null : jsonDecode(raw) as Map<String, dynamic>;
  }

  @override
  Future<void> setMap(String key, Map<String, dynamic> value) async {
    values[key] = jsonEncode(value);
  }

  @override
  List<dynamic>? getList(String key) {
    final raw = values[key] as String?;
    return raw == null ? null : jsonDecode(raw) as List<dynamic>;
  }

  @override
  void setList(String key, List<dynamic> value) =>
      values[key] = jsonEncode(value);

  @override
  List<String>? getStringList(String key) =>
      getList(key)?.map((e) => e.toString()).toList();

  @override
  void setStringList(String key, List<dynamic> value) =>
      values[key] = jsonEncode(value);
}

Keypair _vfx(String tag) => Keypair(
      private: '00${tag}private',
      address: 'R$tag',
      public: '${tag}public',
    );

RaKeypair _vault(String tag) => RaKeypair(
      private: '${tag}raPrivate',
      address: 'xRBX$tag',
      public: '${tag}raPublic',
      recoveryPrivate: '${tag}recoveryPrivate',
      recoveryAddress: '${tag}recoveryAddress',
      recoveryPublic: '${tag}recoveryPublic',
      restoreCode: '${tag}restore',
    );

BtcWebAccount _btc(String tag) => BtcWebAccount(
      address: 'bc1$tag',
      wif: '${tag}wif',
      privateKey: '${tag}btcPrivate',
      publicKey: '${tag}btcPublic',
    );

/// Adds an account entry encrypted with [password], as
/// MultiAccountProvider.add does.
void _addAccount(_MemoryStorage storage, int id, String tag, String password) {
  final json = MultiAccountInstance(
    id: id,
    keypair: _vfx(tag),
    raKeypair: _vault(tag),
    btcKeypair: _btc(tag),
  ).toJson();
  final encrypted =
      MultiAccountEncryptionService.encryptAccountPrivateKeys(json, password);
  final list = storage.getList(Storage.MULTIPLE_ACCOUNTS) ?? [];
  storage.setList(Storage.MULTIPLE_ACCOUNTS, [...list, jsonEncode(encrypted)]);
}

/// Writes the wallet-wide slot as encryptAndSaveKeys does (the only shape a
/// wallet had before passwords were per account).
Future<void> _writeLegacySlot(
    _MemoryStorage storage, String tag, String password) async {
  storage.setString(
      Storage.STORED_PASSWORD_HASH, EncryptionService.hashPassword(password));
  storage.setString(Storage.WEB_PRIMARY_ADDRESS, _vfx(tag).address);
  await storage.setMap(
      Storage.WEB_KEYPAIR, EncryptionService.encrypt(_vfx(tag).toJson(), password));
  await storage.setMap(Storage.WEB_RA_KEYPAIR,
      EncryptionService.encrypt(_vault(tag).toJson(), password));
  await storage.setMap(Storage.WEB_BTC_KEYPAIR,
      EncryptionService.encrypt(_btc(tag).toJson(), password));
  storage.setBool(Storage.ENCRYPTION_ENABLED, true);
  storage.setInt(Storage.ENCRYPTION_VERSION, 1);
}

void main() {
  late _MemoryStorage storage;
  late WebAccountPasswordStore store;

  setUp(() {
    storage = _MemoryStorage();
    store = WebAccountPasswordStore(storage);
  });

  group('two accounts with different passwords', () {
    setUp(() async {
      // Account 1 added first, then account 2 overwrote the wallet-wide slot.
      await _writeLegacySlot(storage, 'one', 'pass-one');
      _addAccount(storage, 1, 'one', 'pass-one');
      await _writeLegacySlot(storage, 'two', 'pass-two');
      _addAccount(storage, 2, 'two', 'pass-two');
    });

    test('each account accepts only its own password', () {
      expect(store.verifyAccountPassword(1, 'pass-one'), isTrue);
      expect(store.verifyAccountPassword(1, 'pass-two'), isFalse);
      expect(store.verifyAccountPassword(2, 'pass-two'), isTrue);
      expect(store.verifyAccountPassword(2, 'pass-one'), isFalse);
    });

    test('reveal prompts check the active account', () {
      storage.setInt(Storage.MULTIPLE_ACCOUNT_SELECTED, 1);
      expect(store.verifyActiveAccountPassword('pass-one'), isTrue);
      expect(store.verifyActiveAccountPassword('pass-two'), isFalse);

      storage.setInt(Storage.MULTIPLE_ACCOUNT_SELECTED, 2);
      expect(store.verifyActiveAccountPassword('pass-two'), isTrue);
      expect(store.verifyActiveAccountPassword('pass-one'), isFalse);
    });

    test('unlock opens the last active account with its own password', () {
      storage.setInt(Storage.MULTIPLE_ACCOUNT_SELECTED, 1);

      final unlocked = store.unlock('pass-one');

      expect(unlocked, isNotNull);
      expect(unlocked!.accountId, 1);
      expect(unlocked.keypair, _vfx('one'));
      expect(unlocked.raKeypair, _vault('one'));
      expect(unlocked.btcKeypair, _btc('one'));
      expect(store.unlockTargetAddress(), _vfx('one').address);
    });

    test('the wallet-wide slot password still opens only its own account', () {
      storage.setInt(Storage.MULTIPLE_ACCOUNT_SELECTED, 1);

      final unlocked = store.unlock('pass-two');

      expect(unlocked, isNotNull);
      expect(unlocked!.accountId, 2);
      expect(unlocked.keypair, _vfx('two'));
    });

    test('a password that belongs to no account unlocks nothing', () {
      storage.setInt(Storage.MULTIPLE_ACCOUNT_SELECTED, 1);
      expect(store.unlock('wrong'), isNull);
    });

    test('unlocking does not change stored keys', () {
      storage.setInt(Storage.MULTIPLE_ACCOUNT_SELECTED, 1);
      final before = Map<String, Object?>.from(storage.values);

      store.unlock('pass-one');
      store.unlock('pass-two');
      store.unlock('wrong');

      expect(storage.values, before);
    });
  });

  group('legacy wallets', () {
    test('a single-account wallet unlocks with its current password', () async {
      await _writeLegacySlot(storage, 'one', 'pass-one');
      _addAccount(storage, 1, 'one', 'pass-one');
      storage.setInt(Storage.MULTIPLE_ACCOUNT_SELECTED, 1);

      final unlocked = store.unlock('pass-one');

      expect(unlocked?.accountId, 1);
      expect(unlocked?.keypair, _vfx('one'));
      expect(store.verifyActiveAccountPassword('pass-one'), isTrue);
      expect(store.unlock('wrong'), isNull);
    });

    test('a wallet with only the wallet-wide hash and slot still unlocks',
        () async {
      await _writeLegacySlot(storage, 'one', 'pass-one');

      final unlocked = store.unlock('pass-one');

      expect(unlocked, isNotNull);
      expect(unlocked!.accountId, isNull);
      expect(unlocked.keypair, _vfx('one'));
      expect(unlocked.raKeypair, _vault('one'));
      expect(unlocked.btcKeypair, _btc('one'));
      expect(store.verifyActiveAccountPassword('pass-one'), isTrue);
      expect(store.verifyActiveAccountPassword('wrong'), isFalse);
      expect(store.unlock('wrong'), isNull);
      expect(store.unlockTargetAddress(), _vfx('one').address);
    });

    test('an account stored without encrypted keys uses the wallet-wide hash',
        () async {
      await _writeLegacySlot(storage, 'one', 'pass-one');
      storage.setList(Storage.MULTIPLE_ACCOUNTS, [
        jsonEncode(MultiAccountInstance(
          id: 1,
          keypair: _vfx('one'),
          raKeypair: null,
          btcKeypair: null,
        ).toJson()),
      ]);
      storage.setInt(Storage.MULTIPLE_ACCOUNT_SELECTED, 1);

      expect(store.verifyAccountPassword(1, 'pass-one'), isTrue);
      expect(store.verifyAccountPassword(1, 'wrong'), isFalse);
      expect(store.unlock('pass-one')?.accountId, 1);
    });

    test('with no stored password nothing verifies', () {
      expect(store.verifyActiveAccountPassword('anything'), isFalse);
      expect(store.unlock('anything'), isNull);
    });
  });

  group('PasswordVerificationService', () {
    setUp(() {
      singleton.registerSingleton<Storage>(storage);
    });

    tearDown(() async {
      await singleton.unregister<Storage>();
    });

    test('verifies against the active account', () async {
      await _writeLegacySlot(storage, 'one', 'pass-one');
      _addAccount(storage, 1, 'one', 'pass-one');
      await _writeLegacySlot(storage, 'two', 'pass-two');
      _addAccount(storage, 2, 'two', 'pass-two');
      storage.setInt(Storage.MULTIPLE_ACCOUNT_SELECTED, 1);

      expect(PasswordVerificationService.verifyPassword('pass-one'), isTrue);
      expect(PasswordVerificationService.verifyPassword('pass-two'), isFalse);
    });
  });
}
