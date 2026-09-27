import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/services/encryption_service.dart';
import 'package:rbx_wallet/core/services/multi_account_encryption_service.dart';
import 'package:rbx_wallet/features/btc_web/models/btc_web_account.dart';
import 'package:rbx_wallet/features/keygen/models/keypair.dart';
import 'package:rbx_wallet/features/keygen/models/ra_keypair.dart';
import 'package:rbx_wallet/features/web/models/multi_account_instance.dart';

const _password = 'account-password';

MultiAccountInstance _account() => MultiAccountInstance(
      id: 1,
      name: 'Main',
      keypair: Keypair(
        private: '00vfxPrivate',
        address: 'Rvfx',
        public: 'vfxPublic',
        mneumonic: 'alpha bravo charlie delta',
        btcWif: 'vfxBtcWif',
      ),
      raKeypair: RaKeypair(
        private: 'raPrivate',
        address: 'xRBXvault',
        public: 'raPublic',
        recoveryPrivate: 'recoveryPrivate',
        recoveryAddress: 'recoveryAddress',
        recoveryPublic: 'recoveryPublic',
        restoreCode: 'restoreCode',
      ),
      btcKeypair: BtcWebAccount(
        address: 'bc1btc',
        wif: 'btcWif',
        privateKey: 'btcPrivate',
        publicKey: 'btcPublic',
        mnemonic: 'echo foxtrot golf hotel',
      ),
    );

/// An account record as earlier versions wrote it: only the main private key
/// of each keypair encrypted.
Map<String, dynamic> _earlierFormat(Map<String, dynamic> json, String password) {
  final result = Map<String, dynamic>.from(json);
  for (final entry in {
    'keypair': 'private',
    'raKeypair': 'private',
    'btcKeypair': 'privateKey',
  }.entries) {
    final keypair = Map<String, dynamic>.from(result[entry.key]);
    keypair[entry.value] =
        EncryptionService.encryptString(keypair[entry.value], password);
    keypair['_isPrivateEncrypted'] = true;
    result[entry.key] = keypair;
  }
  return result;
}

void main() {
  test('markers keep the original name for the main private keys', () {
    expect(MultiAccountEncryptionService.markerFor('private'),
        '_isPrivateEncrypted');
    expect(MultiAccountEncryptionService.markerFor('privateKey'),
        '_isPrivateEncrypted');
    expect(MultiAccountEncryptionService.markerFor('restoreCode'),
        '_isRestoreCodeEncrypted');
    expect(MultiAccountEncryptionService.markerFor('mneumonic'),
        '_isMneumonicEncrypted');
  });

  test('new records have every secret field encrypted and marked', () {
    final encrypted = MultiAccountEncryptionService.encryptAccountPrivateKeys(
        _account().toJson(), _password);

    MultiAccountEncryptionService.secretFields.forEach((keypairKey, fields) {
      final keypair = encrypted[keypairKey] as Map<String, dynamic>;
      for (final field in fields) {
        expect(EncryptionService.isEncrypted(keypair[field]), isTrue,
            reason: '$keypairKey.$field');
        expect(keypair[MultiAccountEncryptionService.markerFor(field)], isTrue,
            reason: '$keypairKey.$field');
      }
    });
    expect(MultiAccountEncryptionService.hasUnencryptedSecretFields(encrypted),
        isFalse);
    expect(encrypted['keypair']['address'], 'Rvfx');
    expect(encrypted['name'], 'Main');
  });

  test('all secret fields round-trip', () {
    final encrypted = MultiAccountEncryptionService.encryptAccountPrivateKeys(
        _account().toJson(), _password);

    final decrypted = MultiAccountEncryptionService.decryptAccountPrivateKeys(
        encrypted, _password);

    expect(decrypted, _account().toJson());
  });

  test('null secret fields stay null and unmarked', () {
    final json = MultiAccountInstance(
      id: 1,
      keypair: Keypair(private: '00p', address: 'R', public: 'pub'),
      raKeypair: null,
      btcKeypair: null,
    ).toJson();

    final encrypted =
        MultiAccountEncryptionService.encryptAccountPrivateKeys(json, _password);

    expect(encrypted['keypair']['mneumonic'], isNull);
    expect(encrypted['keypair'].containsKey('_isMneumonicEncrypted'), isFalse);
    expect(MultiAccountEncryptionService.decryptAccountPrivateKeys(
            encrypted, _password),
        json);
  });

  group('earlier account format', () {
    late Map<String, dynamic> earlier;

    setUp(() {
      earlier = _earlierFormat(_account().toJson(), _password);
    });

    test('loads unchanged: marked fields decrypt, unmarked are used as is', () {
      expect(MultiAccountEncryptionService.hasEncryptedPrivateKeys(earlier),
          isTrue);
      expect(MultiAccountEncryptionService.hasUnencryptedSecretFields(earlier),
          isTrue);

      final decrypted = MultiAccountEncryptionService.decryptAccountPrivateKeys(
          earlier, _password);

      expect(MultiAccountInstance.fromJson(decrypted).toJson(),
          _account().toJson());
    });

    test('the account list blanks only the encrypted fields', () {
      final listed = MultiAccountInstance.fromJson(
          MultiAccountEncryptionService.withEncryptedFieldsBlank(earlier));

      expect(listed.keypair!.private, '');
      expect(listed.keypair!.address, 'Rvfx');
      expect(listed.keypair!.mneumonic, 'alpha bravo charlie delta');
      expect(listed.raKeypair!.restoreCode, 'restoreCode');
    });

    test('upgradeAccountRecord encrypts the remaining fields', () {
      final upgraded =
          MultiAccountEncryptionService.upgradeAccountRecord(earlier, _password)!;

      expect(MultiAccountEncryptionService.hasUnencryptedSecretFields(upgraded),
          isFalse);
      // The fields that were already encrypted are carried over untouched.
      expect(upgraded['keypair']['private'], earlier['keypair']['private']);
      expect(
          MultiAccountEncryptionService.decryptAccountPrivateKeys(
              upgraded, _password),
          _account().toJson());
    });

    test('upgradeAccountRecord leaves a current record alone', () {
      final upgraded =
          MultiAccountEncryptionService.upgradeAccountRecord(earlier, _password)!;

      expect(
          MultiAccountEncryptionService.upgradeAccountRecord(
              upgraded, _password),
          isNull);
    });

    test('upgradeAccountRecord rejects a wrong password', () {
      expect(
          () => MultiAccountEncryptionService.upgradeAccountRecord(
              earlier, 'wrong'),
          throwsA(anything));
    });

    test('upgradeAccountRecord rejects a record that does not round-trip', () {
      Map<String, dynamic> alteringEncrypt(
          Map<String, dynamic> json, String password) {
        final result =
            MultiAccountEncryptionService.encryptAccountPrivateKeys(json, password);
        final vault = Map<String, dynamic>.from(result['raKeypair']);
        vault['restoreCode'] =
            EncryptionService.encryptString('something else', password);
        result['raKeypair'] = vault;
        return result;
      }

      expect(
          () => MultiAccountEncryptionService.upgradeAccountRecord(
              earlier, _password,
              encrypt: alteringEncrypt),
          throwsStateError);
    });
  });

  test('a record without any encrypted field is not upgraded', () {
    expect(
        MultiAccountEncryptionService.upgradeAccountRecord(
            _account().toJson(), _password),
        isNull);
  });
}
