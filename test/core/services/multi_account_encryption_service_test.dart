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

const _mainKeys = {
  'keypair': 'private',
  'raKeypair': 'private',
  'btcKeypair': 'privateKey',
};

/// An account record as earlier versions wrote it: only the main private key
/// of each keypair encrypted.
Map<String, dynamic> _earlierFormat(Map<String, dynamic> json, String password) {
  final result = Map<String, dynamic>.from(json);
  for (final entry in _mainKeys.entries) {
    final keypair = Map<String, dynamic>.from(result[entry.key]);
    keypair[entry.value] =
        EncryptionService.encryptString(keypair[entry.value], password);
    keypair['_isPrivateEncrypted'] = true;
    result[entry.key] = keypair;
  }
  return result;
}

/// An account record in the interim layout: every secret field encrypted in
/// its original key with a `_is<Field>Encrypted` marker.
Map<String, dynamic> _interimFormat(Map<String, dynamic> json, String password) {
  final result = _earlierFormat(json, password);
  MultiAccountEncryptionService.secretFields.forEach((keypairKey, fields) {
    final keypair = Map<String, dynamic>.from(result[keypairKey]);
    for (final field in fields.where((f) => f != _mainKeys[keypairKey])) {
      keypair[field] = EncryptionService.encryptString(keypair[field], password);
      keypair[MultiAccountEncryptionService.markerFor(field)] = true;
    }
    result[keypairKey] = keypair;
  });
  return result;
}

/// Loads a stored record the way the previous release does: the account list
/// blanks the main private keys, and switching decrypts only those.
void _loadAsPreviousRelease(Map<String, dynamic> stored) {
  final listed = Map<String, dynamic>.from(stored);
  final decrypted = Map<String, dynamic>.from(stored);
  for (final entry in _mainKeys.entries) {
    final keypair = Map<String, dynamic>.from(stored[entry.key]);
    listed[entry.key] = {...keypair, entry.value: ''};
    decrypted[entry.key] = {
      ...keypair,
      entry.value: EncryptionService.decryptString(
          Map<String, dynamic>.from(keypair[entry.value]), _password),
    };
  }
  MultiAccountInstance.fromJson(listed);
  MultiAccountInstance.fromJson(decrypted);
}

void _expectCurrentLayout(Map<String, dynamic> stored) {
  MultiAccountEncryptionService.secretFields.forEach((keypairKey, fields) {
    final keypair = stored[keypairKey] as Map<String, dynamic>;
    for (final field in fields) {
      final reason = '$keypairKey.$field';
      if (field == _mainKeys[keypairKey]) {
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
        expect(
            keypair.containsKey(MultiAccountEncryptionService.markerFor(field)),
            isFalse,
            reason: reason);
      }
    }
  });
  expect(MultiAccountEncryptionService.needsUpgrade(stored), isFalse);
}

void main() {
  test('main keys keep their marker; other fields use a companion key', () {
    expect(MultiAccountEncryptionService.markerFor('private'),
        '_isPrivateEncrypted');
    expect(MultiAccountEncryptionService.markerFor('privateKey'),
        '_isPrivateEncrypted');
    expect(MultiAccountEncryptionService.encKeyFor('restoreCode'),
        'restoreCodeEnc');
    expect(
        MultiAccountEncryptionService.encKeyFor('mneumonic'), 'mneumonicEnc');
  });

  test('new records have every secret field encrypted', () {
    final encrypted = MultiAccountEncryptionService.encryptAccountPrivateKeys(
        _account().toJson(), _password);

    _expectCurrentLayout(encrypted);
    expect(encrypted['keypair']['mneumonic'], isNull);
    expect(encrypted['raKeypair']['restoreCode'], '');
    expect(encrypted['btcKeypair']['wif'], '');
    expect(encrypted['keypair']['address'], 'Rvfx');
    expect(encrypted['name'], 'Main');
  });

  test('new records still parse in the previous release', () {
    final encrypted = MultiAccountEncryptionService.encryptAccountPrivateKeys(
        _account().toJson(), _password);

    expect(() => _loadAsPreviousRelease(encrypted), returnsNormally);
  });

  test('all secret fields round-trip', () {
    final encrypted = MultiAccountEncryptionService.encryptAccountPrivateKeys(
        _account().toJson(), _password);

    final decrypted = MultiAccountEncryptionService.decryptAccountPrivateKeys(
        encrypted, _password);

    expect(decrypted, _account().toJson());
  });

  test('null secret fields stay null with no companion key', () {
    final json = MultiAccountInstance(
      id: 1,
      keypair: Keypair(private: '00p', address: 'R', public: 'pub'),
      raKeypair: null,
      btcKeypair: null,
    ).toJson();

    final encrypted =
        MultiAccountEncryptionService.encryptAccountPrivateKeys(json, _password);

    expect(encrypted['keypair']['mneumonic'], isNull);
    expect(encrypted['keypair'].containsKey('mneumonicEnc'), isFalse);
    expect(
        MultiAccountEncryptionService.decryptAccountPrivateKeys(
            encrypted, _password),
        json);
  });

  test('the account list blanks a secret field that holds a map', () {
    final json = _account().toJson();
    json['keypair'] = {
      ...json['keypair'],
      'btcWif': {'unexpected': 'value'},
    };

    final listed = MultiAccountInstance.fromJson(
        MultiAccountEncryptionService.withEncryptedFieldsBlank(json));

    expect(listed.keypair!.btcWif, '');
  });

  group('earlier account format', () {
    late Map<String, dynamic> earlier;

    setUp(() {
      earlier = _earlierFormat(_account().toJson(), _password);
    });

    test('loads unchanged: encrypted fields decrypt, others are used as is',
        () {
      expect(MultiAccountEncryptionService.hasEncryptedPrivateKeys(earlier),
          isTrue);
      expect(MultiAccountEncryptionService.needsUpgrade(earlier), isTrue);

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

      _expectCurrentLayout(upgraded);
      // The fields that were already encrypted are carried over untouched.
      expect(upgraded['keypair']['private'], earlier['keypair']['private']);
      expect(
          MultiAccountEncryptionService.decryptAccountPrivateKeys(
              upgraded, _password),
          _account().toJson());
      expect(() => _loadAsPreviousRelease(upgraded), returnsNormally);
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
        vault['restoreCodeEnc'] =
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

    test('upgradeAccountRecord rejects a record that keeps a plain value', () {
      Map<String, dynamic> leakyEncrypt(
          Map<String, dynamic> json, String password) {
        final result =
            MultiAccountEncryptionService.encryptAccountPrivateKeys(json, password);
        final vault = Map<String, dynamic>.from(result['raKeypair']);
        vault['restoreCode'] = 'restoreCode';
        result['raKeypair'] = vault;
        return result;
      }

      expect(
          () => MultiAccountEncryptionService.upgradeAccountRecord(
              earlier, _password,
              encrypt: leakyEncrypt),
          throwsStateError);
    });

    test('upgradeAccountRecord checks against the given decrypted values', () {
      final decrypted = MultiAccountEncryptionService.decryptAccountPrivateKeys(
          earlier, _password);

      expect(
          MultiAccountEncryptionService.upgradeAccountRecord(earlier, _password,
              expected: decrypted),
          isNotNull);
      expect(
          () => MultiAccountEncryptionService.upgradeAccountRecord(
              earlier, _password,
              expected: {...decrypted, 'name': 'Other'}),
          throwsStateError);
    });
  });

  group('interim layout (encrypted value in the original key)', () {
    late Map<String, dynamic> interim;

    setUp(() {
      interim = _interimFormat(_account().toJson(), _password);
    });

    test('is read as encrypted', () {
      expect(MultiAccountEncryptionService.hasEncryptedPrivateKeys(interim),
          isTrue);
      expect(
          MultiAccountEncryptionService.decryptAccountPrivateKeys(
              interim, _password),
          _account().toJson());
    });

    test('lists with blank secret fields', () {
      final listed = MultiAccountInstance.fromJson(
          MultiAccountEncryptionService.withEncryptedFieldsBlank(interim));

      expect(listed.keypair!.mneumonic, '');
      expect(listed.raKeypair!.restoreCode, '');
      expect(listed.btcKeypair!.wif, '');
    });

    test('is moved to the companion keys without re-encrypting', () {
      final upgraded =
          MultiAccountEncryptionService.upgradeAccountRecord(interim, _password)!;

      _expectCurrentLayout(upgraded);
      expect(upgraded['raKeypair']['restoreCodeEnc'],
          interim['raKeypair']['restoreCode']);
      expect(
          MultiAccountEncryptionService.decryptAccountPrivateKeys(
              upgraded, _password),
          _account().toJson());
    });
  });

  test('a record without any encrypted field is not upgraded on its own', () {
    expect(
        MultiAccountEncryptionService.upgradeAccountRecord(
            _account().toJson(), _password),
        isNull);
  });

  test('a record without any encrypted field is encrypted when vouched for',
      () {
    final plain = _account().toJson();

    final upgraded = MultiAccountEncryptionService.upgradeAccountRecord(
        plain, _password,
        expected: plain)!;

    _expectCurrentLayout(upgraded);
    expect(
        MultiAccountEncryptionService.decryptAccountPrivateKeys(
            upgraded, _password),
        plain);
  });
}
