import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:rbx_wallet/features/web/providers/multi_account_provider.dart';

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
    _MemoryStorage storage, String tag, String password,
    {Keypair? vfx, BtcWebAccount? btc}) async {
  final vfxKeypair = vfx ?? _vfx(tag);
  storage.setString(
      Storage.STORED_PASSWORD_HASH, EncryptionService.hashPassword(password));
  storage.setString(Storage.WEB_PRIMARY_ADDRESS, vfxKeypair.address);
  await storage.setMap(Storage.WEB_KEYPAIR,
      EncryptionService.encrypt(vfxKeypair.toJson(), password));
  await storage.setMap(Storage.WEB_RA_KEYPAIR,
      EncryptionService.encrypt(_vault(tag).toJson(), password));
  await storage.setMap(Storage.WEB_BTC_KEYPAIR,
      EncryptionService.encrypt((btc ?? _btc(tag)).toJson(), password));
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

  group('upgrading older account records on unlock', () {
    test('an older record unlocks with the same keys', () {
      _addEarlierFormatAccount(storage, 1, 'one', 'pass-one');
      storage.setInt(Storage.MULTIPLE_ACCOUNT_SELECTED, 1);

      final unlocked = store.unlock('pass-one');

      expect(unlocked?.accountId, 1);
      expect(unlocked!.keypair, _fullVfx('one'));
      expect(unlocked.raKeypair, _vault('one'));
      expect(unlocked.btcKeypair, _fullBtc('one'));
    });

    test('unlock rewrites the record with every secret field encrypted', () {
      _addEarlierFormatAccount(storage, 1, 'one', 'pass-one');
      storage.setInt(Storage.MULTIPLE_ACCOUNT_SELECTED, 1);

      store.unlock('pass-one');

      final stored = store.storedAccount(1)!;
      _expectAllSecretFieldsEncrypted(stored);
      final raw = storage.values[Storage.MULTIPLE_ACCOUNTS] as String;
      for (final secret in _secretValues('one')) {
        expect(raw.contains(secret), isFalse, reason: secret);
      }
      expect(
          MultiAccountEncryptionService.decryptAccountPrivateKeys(
              stored, 'pass-one'),
          _fullAccount(1, 'one').toJson());
    });

    test('a wrong password upgrades nothing', () {
      _addEarlierFormatAccount(storage, 1, 'one', 'pass-one');
      storage.setInt(Storage.MULTIPLE_ACCOUNT_SELECTED, 1);
      final before = Map<String, Object?>.from(storage.values);

      expect(store.unlock('wrong'), isNull);
      expect(store.verifyAccountPassword(1, 'wrong'), isFalse);
      expect(store.decryptStoredAccount(1, 'wrong'), isNull);

      expect(storage.values, before);
    });

    test('a second unlock changes nothing', () {
      _addEarlierFormatAccount(storage, 1, 'one', 'pass-one');
      storage.setInt(Storage.MULTIPLE_ACCOUNT_SELECTED, 1);

      store.unlock('pass-one');
      final afterFirst = Map<String, Object?>.from(storage.values);
      final second = store.unlock('pass-one');

      expect(storage.values, afterFirst);
      expect(second!.keypair, _fullVfx('one'));
    });

    test('a record that does not round-trip is kept as it was', () {
      _addEarlierFormatAccount(storage, 1, 'one', 'pass-one');
      storage.setInt(Storage.MULTIPLE_ACCOUNT_SELECTED, 1);
      final before = Map<String, Object?>.from(storage.values);

      Map<String, dynamic> alteringEncrypt(
          Map<String, dynamic> json, String password) {
        final result = MultiAccountEncryptionService.encryptAccountPrivateKeys(
            json, password);
        final keypair = Map<String, dynamic>.from(result['keypair']);
        keypair['mneumonicEnc'] =
            EncryptionService.encryptString('different words', password);
        result['keypair'] = keypair;
        return result;
      }

      final failingStore =
          WebAccountPasswordStore(storage, encryptAccount: alteringEncrypt);
      final unlocked = failingStore.unlock('pass-one');

      expect(unlocked!.keypair, _fullVfx('one'));
      expect(storage.values, before);
    });

    test('a record encrypted under another password is kept as it was', () {
      _addEarlierFormatAccount(storage, 1, 'one', 'pass-one');
      storage.setInt(Storage.MULTIPLE_ACCOUNT_SELECTED, 1);
      final before = Map<String, Object?>.from(storage.values);

      final failingStore = WebAccountPasswordStore(storage,
          encryptAccount: (json, _) =>
              MultiAccountEncryptionService.encryptAccountPrivateKeys(
                  json, 'other-password'));

      expect(failingStore.unlock('pass-one'), isNotNull);
      expect(storage.values, before);
    });

    test('only the account whose password was used is upgraded', () {
      _addEarlierFormatAccount(storage, 1, 'one', 'pass-one');
      _addEarlierFormatAccount(storage, 2, 'two', 'pass-two');
      storage.setInt(Storage.MULTIPLE_ACCOUNT_SELECTED, 1);
      final accountTwoBefore = _rawEntry(storage, 1);

      store.unlock('pass-one');

      _expectAllSecretFieldsEncrypted(store.storedAccount(1)!);
      expect(_rawEntry(storage, 1), accountTwoBefore);
      expect(
          MultiAccountEncryptionService.needsUpgrade(
              store.storedAccount(2)!),
          isTrue);
    });

    test('switching to an account or revealing its keys upgrades it', () {
      _addEarlierFormatAccount(storage, 1, 'one', 'pass-one');
      _addEarlierFormatAccount(storage, 2, 'two', 'pass-two');

      final account = store.decryptStoredAccount(2, 'pass-two');

      expect(account!.toJson(), _fullAccount(2, 'two').toJson());
      _expectAllSecretFieldsEncrypted(store.storedAccount(2)!);
      expect(
          MultiAccountEncryptionService.needsUpgrade(
              store.storedAccount(1)!),
          isTrue);
    });

    test('a password check on the active account upgrades it', () {
      _addEarlierFormatAccount(storage, 1, 'one', 'pass-one');
      storage.setInt(Storage.MULTIPLE_ACCOUNT_SELECTED, 1);

      expect(store.verifyActiveAccountPassword('pass-one'), isTrue);

      _expectAllSecretFieldsEncrypted(store.storedAccount(1)!);
    });

    test('a record in the interim layout moves to the companion keys', () {
      final json = _fullAccount(1, 'one').toJson();
      final interim = MultiAccountEncryptionService.encryptAccountPrivateKeys(
          json, 'pass-one');
      // Put each companion value back in its original key with a marker.
      for (final keypairKey in ['keypair', 'raKeypair', 'btcKeypair']) {
        final keypair = Map<String, dynamic>.from(interim[keypairKey]);
        for (final key in keypair.keys.toList()) {
          if (key.endsWith('Enc')) {
            final field = key.substring(0, key.length - 3);
            keypair[field] = keypair.remove(key);
            keypair[MultiAccountEncryptionService.markerFor(field)] = true;
          }
        }
        interim[keypairKey] = keypair;
      }
      storage.setList(Storage.MULTIPLE_ACCOUNTS, [jsonEncode(interim)]);
      storage.setInt(Storage.MULTIPLE_ACCOUNT_SELECTED, 1);

      expect(store.unlock('pass-one')!.keypair, _fullVfx('one'));

      _expectAllSecretFieldsEncrypted(store.storedAccount(1)!);
      expect(store.decryptStoredAccount(1, 'pass-one')!.toJson(), json);
    });
  });

  group('entries saved before per-account encryption', () {
    Future<void> writeWallet() async {
      await _writeLegacySlot(storage, 'one', 'pass-one',
          vfx: _fullVfx('one'), btc: _fullBtc('one'));
      storage.setList(Storage.MULTIPLE_ACCOUNTS, [
        jsonEncode(_fullAccount(1, 'one').toJson()),
        jsonEncode(_fullAccount(2, 'two').toJson()),
      ]);
      storage.setInt(Storage.MULTIPLE_ACCOUNT_SELECTED, 1);
    }

    test('the entry matching the slot is encrypted with the slot password',
        () async {
      await writeWallet();
      final otherBefore = _rawEntry(storage, 1);

      expect(store.unlock('pass-one')?.accountId, 1);

      final stored = store.storedAccount(1)!;
      _expectAllSecretFieldsEncrypted(stored);
      expect(
          MultiAccountEncryptionService.decryptAccountPrivateKeys(
              stored, 'pass-one'),
          _fullAccount(1, 'one').toJson());
      // Other entries are not the slot's account and stay as they were.
      expect(_rawEntry(storage, 1), otherBefore);
    });

    test('afterwards the account opens with the same password', () async {
      await writeWallet();

      store.unlock('pass-one');
      final before = Map<String, Object?>.from(storage.values);

      final again = store.unlock('pass-one');
      expect(again?.accountId, 1);
      expect(again!.raKeypair, _vault('one'));
      expect(store.verifyAccountPassword(1, 'pass-one'), isTrue);
      expect(store.verifyAccountPassword(1, 'wrong'), isFalse);
      expect(storage.values, before);
    });

    test('a wrong password encrypts nothing', () async {
      await writeWallet();
      final before = Map<String, Object?>.from(storage.values);

      expect(store.unlock('wrong'), isNull);
      expect(storage.values, before);
    });

    test('a failed round-trip keeps the entry as it was', () async {
      await writeWallet();
      final before = Map<String, Object?>.from(storage.values);

      final failingStore = WebAccountPasswordStore(storage,
          encryptAccount: (json, _) =>
              MultiAccountEncryptionService.encryptAccountPrivateKeys(
                  json, 'other-password'));

      expect(failingStore.unlock('pass-one')?.accountId, 1);
      expect(storage.values, before);
    });
  });

  group('legacy wallet-wide slot', () {
    test('holds every secret field inside its encrypted values', () async {
      await _writeLegacySlot(storage, 'one', 'pass-one',
          vfx: _fullVfx('one'), btc: _fullBtc('one'));

      for (final key in [
        Storage.WEB_KEYPAIR,
        Storage.WEB_RA_KEYPAIR,
        Storage.WEB_BTC_KEYPAIR,
      ]) {
        expect(EncryptionService.isEncrypted(storage.getMap(key)), isTrue);
        for (final secret in _secretValues('one')) {
          expect((storage.values[key] as String).contains(secret), isFalse);
        }
      }
    });

    test('unlocking through it changes nothing in the slot', () async {
      await _writeLegacySlot(storage, 'one', 'pass-one',
          vfx: _fullVfx('one'), btc: _fullBtc('one'));
      final before = Map<String, Object?>.from(storage.values);

      final unlocked = store.unlock('pass-one');

      expect(unlocked!.keypair, _fullVfx('one'));
      expect(unlocked.btcKeypair, _fullBtc('one'));
      expect(storage.values, before);
    });

    test('its password upgrades the matching entry when it is that entry\'s own',
        () async {
      // Account 1 is active under pass-one; the slot holds account 2.
      _addEarlierFormatAccount(storage, 1, 'one', 'pass-one');
      await _writeLegacySlot(storage, 'two', 'pass-two',
          vfx: _fullVfx('two'), btc: _fullBtc('two'));
      _addEarlierFormatAccount(storage, 2, 'two', 'pass-two');
      storage.setInt(Storage.MULTIPLE_ACCOUNT_SELECTED, 1);
      final accountOneBefore = _rawEntry(storage, 0);

      expect(store.unlock('pass-two')?.accountId, 2);

      _expectAllSecretFieldsEncrypted(store.storedAccount(2)!);
      expect(_rawEntry(storage, 0), accountOneBefore);
    });
  });

  group('MultiAccountProvider', () {
    late ProviderContainer container;

    setUp(() {
      singleton.registerSingleton<Storage>(storage);
    });

    tearDown(() async {
      container.dispose();
      await singleton.unregister<Storage>();
    });

    test('a new account is written with every secret field encrypted', () {
      container = ProviderContainer();

      container.read(multiAccountProvider.notifier).add(
            keypair: _fullVfx('one'),
            raKeypair: _vault('one'),
            btcKeypair: _fullBtc('one'),
            encryptionPassword: 'pass-one',
          );

      final stored = store.storedAccount(1)!;
      _expectAllSecretFieldsEncrypted(stored);
      expect(
          MultiAccountEncryptionService.decryptAccountPrivateKeys(
              stored, 'pass-one'),
          _fullAccount(1, 'one').toJson());
    });

    test('renaming keeps an upgraded record fully encrypted', () {
      _addEarlierFormatAccount(storage, 1, 'one', 'pass-one');
      container = ProviderContainer();
      // Loaded before the upgrade, as at app start.
      container.read(multiAccountProvider);
      storage.setInt(Storage.MULTIPLE_ACCOUNT_SELECTED, 1);
      store.unlock('pass-one');

      container.read(multiAccountProvider.notifier).rename(1, 'Renamed');

      final stored = store.storedAccount(1)!;
      expect(stored['name'], 'Renamed');
      _expectAllSecretFieldsEncrypted(stored);
      expect(
          MultiAccountEncryptionService.decryptAccountPrivateKeys(
              stored, 'pass-one')['raKeypair'],
          _vault('one').toJson());
    });

    test('lists an upgraded account with blank secret fields', () {
      _addEarlierFormatAccount(storage, 1, 'one', 'pass-one');
      storage.setInt(Storage.MULTIPLE_ACCOUNT_SELECTED, 1);
      store.unlock('pass-one');
      container = ProviderContainer();

      final listed = container.read(multiAccountProvider).single;

      expect(listed.keypair!.address, _fullVfx('one').address);
      expect(listed.keypair!.mneumonic, '');
      expect(listed.raKeypair!.restoreCode, '');
      expect(listed.btcKeypair!.wif, '');
    });
  });
}

Keypair _fullVfx(String tag) => _vfx(tag).copyWith(
      mneumonic: '$tag mnemonic words',
      btcWif: '${tag}vfxBtcWif',
    );

BtcWebAccount _fullBtc(String tag) =>
    _btc(tag).copyWith(mnemonic: '$tag btc mnemonic words');

MultiAccountInstance _fullAccount(int id, String tag) => MultiAccountInstance(
      id: id,
      keypair: _fullVfx(tag),
      raKeypair: _vault(tag),
      btcKeypair: _fullBtc(tag),
    );

/// Every secret value of [_fullAccount] for [tag].
List<String> _secretValues(String tag) => [
      _fullVfx(tag).private,
      _fullVfx(tag).mneumonic!,
      _fullVfx(tag).btcWif!,
      _vault(tag).private,
      _vault(tag).recoveryPrivate,
      _vault(tag).restoreCode,
      _fullBtc(tag).privateKey,
      _fullBtc(tag).wif,
      _fullBtc(tag).mnemonic!,
    ];

/// Adds an account entry as earlier versions wrote it: only the main private
/// key of each keypair encrypted.
void _addEarlierFormatAccount(
    _MemoryStorage storage, int id, String tag, String password) {
  final json = _fullAccount(id, tag).toJson();
  for (final entry in {
    'keypair': 'private',
    'raKeypair': 'private',
    'btcKeypair': 'privateKey',
  }.entries) {
    final keypair = Map<String, dynamic>.from(json[entry.key]);
    keypair[entry.value] =
        EncryptionService.encryptString(keypair[entry.value], password);
    keypair['_isPrivateEncrypted'] = true;
    json[entry.key] = keypair;
  }
  final list = storage.getList(Storage.MULTIPLE_ACCOUNTS) ?? [];
  storage.setList(Storage.MULTIPLE_ACCOUNTS, [...list, jsonEncode(json)]);
}

String _rawEntry(_MemoryStorage storage, int index) =>
    storage.getList(Storage.MULTIPLE_ACCOUNTS)![index] as String;

/// The current layout: main private keys encrypted in place with
/// `_isPrivateEncrypted`, every other secret field in its `<field>Enc` key
/// with the original key emptied.
void _expectAllSecretFieldsEncrypted(Map<String, dynamic> stored) {
  MultiAccountEncryptionService.secretFields.forEach((keypairKey, fields) {
    final keypair = stored[keypairKey] as Map<String, dynamic>;
    for (final field in fields) {
      final reason = '$keypairKey.$field';
      if (MultiAccountEncryptionService.isMainKey(field)) {
        expect(EncryptionService.isEncrypted(keypair[field]), isTrue,
            reason: reason);
        expect(keypair['_isPrivateEncrypted'], isTrue, reason: reason);
      } else {
        expect(
            EncryptionService.isEncrypted(
                keypair[MultiAccountEncryptionService.encKeyFor(field)]),
            isTrue,
            reason: reason);
        expect(keypair[field], anyOf(isNull, ''), reason: reason);
      }
    }
  });
  expect(MultiAccountEncryptionService.needsUpgrade(stored), isFalse);
}
