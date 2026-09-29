import 'package:collection/collection.dart';

import 'encryption_service.dart';

/// Per-field encryption of the secret fields in a stored web account
/// (a `Storage.MULTIPLE_ACCOUNTS` entry, the JSON of a MultiAccountInstance).
///
/// Stored layout, per keypair object:
/// - The main private key (`private`, or `privateKey` for BTC) is encrypted
///   in place and flagged with `_isPrivateEncrypted`, as before.
/// - Every other secret field is encrypted into a companion key named
///   `<field>Enc`. The original key is kept with an empty value (null for
///   optional fields, an empty string for required ones), so builds that do
///   not know the companion keys still parse the record.
///
/// Reading prefers the companion key and otherwise uses the original key as
/// stored, so records written before the format covered every secret field
/// still load. A record from an interim layout, with the encrypted value in
/// the original key and a `_is<Field>Encrypted` marker, is also read and is
/// moved to the companion key on the next upgrade.
class MultiAccountEncryptionService {
  /// Secret fields per keypair object in the account JSON.
  static const Map<String, List<String>> secretFields = {
    'keypair': ['private', 'mneumonic', 'btcWif'],
    'raKeypair': ['private', 'recoveryPrivate', 'restoreCode'],
    'btcKeypair': ['privateKey', 'wif', 'mnemonic'],
  };

  /// Non-nullable model fields; their original key holds '' once encrypted.
  static const Set<String> _requiredFields = {
    'recoveryPrivate',
    'restoreCode',
    'wif',
  };

  static bool isMainKey(String field) =>
      field == 'private' || field == 'privateKey';

  /// The marker of an in-place encrypted field: `_isPrivateEncrypted` for the
  /// main private keys, `_is<Field>Encrypted` for the interim layout.
  static String markerFor(String field) {
    if (isMainKey(field)) {
      return '_isPrivateEncrypted';
    }
    return '_is${field[0].toUpperCase()}${field.substring(1)}Encrypted';
  }

  /// The companion key that holds [field] encrypted.
  static String encKeyFor(String field) => '${field}Enc';

  static Object? _emptyValueFor(String field) =>
      _requiredFields.contains(field) ? '' : null;

  /// The encrypted value of [field] in [keypair], or null when the field is
  /// not stored encrypted.
  static Map<String, dynamic>? _encryptedValue(
      Map<dynamic, dynamic> keypair, String field) {
    if (!isMainKey(field) && keypair[encKeyFor(field)] is Map) {
      return Map<String, dynamic>.from(keypair[encKeyFor(field)] as Map);
    }
    if (keypair[markerFor(field)] == true && keypair[field] is Map) {
      return Map<String, dynamic>.from(keypair[field] as Map);
    }
    return null;
  }

  /// Encrypts every secret field that is not encrypted yet and moves fields
  /// from the interim layout to their companion key.
  static Map<String, dynamic> encryptAccountPrivateKeys(
    Map<String, dynamic> accountJson,
    String password,
  ) {
    final result = Map<String, dynamic>.from(accountJson);

    secretFields.forEach((objectKey, fields) {
      if (result[objectKey] == null) {
        return;
      }
      final keypair = Map<String, dynamic>.from(result[objectKey]);
      for (final field in fields) {
        final encrypted = _encryptedValue(keypair, field);
        final value = keypair[field];

        if (isMainKey(field)) {
          if (encrypted != null || value == null) {
            continue;
          }
          keypair[field] =
              EncryptionService.encryptString(value as String, password);
          keypair[markerFor(field)] = true;
          continue;
        }

        if (encrypted != null) {
          keypair[encKeyFor(field)] = encrypted;
        } else if (value != null) {
          keypair[encKeyFor(field)] =
              EncryptionService.encryptString(value as String, password);
        } else {
          continue;
        }
        keypair[field] = _emptyValueFor(field);
        keypair.remove(markerFor(field));
      }
      result[objectKey] = keypair;
    });

    return result;
  }

  /// Decrypts every encrypted secret field into its original key and drops
  /// markers and companion keys. Fields that are not encrypted are returned as
  /// stored. Throws when [password] does not open a field.
  static Map<String, dynamic> decryptAccountPrivateKeys(
    Map<String, dynamic> accountJson,
    String password,
  ) {
    final result = Map<String, dynamic>.from(accountJson);

    secretFields.forEach((objectKey, fields) {
      if (result[objectKey] == null) {
        return;
      }
      final keypair = Map<String, dynamic>.from(result[objectKey]);
      for (final field in fields) {
        final encrypted = _encryptedValue(keypair, field);
        if (encrypted != null) {
          keypair[field] = EncryptionService.decryptString(encrypted, password);
        }
        keypair.remove(markerFor(field));
        if (!isMainKey(field)) {
          keypair.remove(encKeyFor(field));
        }
      }
      result[objectKey] = keypair;
    });

    return result;
  }

  /// Whether any secret field of the account is encrypted, meaning the
  /// account has a password of its own.
  static bool hasEncryptedPrivateKeys(Map<String, dynamic> accountJson) {
    for (final entry in secretFields.entries) {
      final keypair = accountJson[entry.key];
      if (keypair is! Map) {
        continue;
      }
      if (entry.value.any((field) => _encryptedValue(keypair, field) != null)) {
        return true;
      }
    }
    return false;
  }

  /// Whether the record differs from the current layout: a secret field with
  /// a value that is not encrypted, or a field still in the interim layout.
  static bool needsUpgrade(Map<String, dynamic> accountJson) {
    for (final entry in secretFields.entries) {
      final keypair = accountJson[entry.key];
      if (keypair is! Map) {
        continue;
      }
      for (final field in entry.value) {
        final value = keypair[field];
        if (isMainKey(field)) {
          if (value != null && _encryptedValue(keypair, field) == null) {
            return true;
          }
        } else if (keypair[encKeyFor(field)] is Map) {
          if (value != null && value != '') {
            return true;
          }
        } else if (value != null) {
          return true;
        }
      }
    }
    return false;
  }

  /// Copy of the account JSON for listing accounts whose password has not
  /// been entered: every encrypted field, and any secret field holding a map,
  /// becomes an empty string.
  static Map<String, dynamic> withEncryptedFieldsBlank(
      Map<String, dynamic> accountJson) {
    final result = Map<String, dynamic>.from(accountJson);

    secretFields.forEach((objectKey, fields) {
      if (result[objectKey] == null) {
        return;
      }
      final keypair = Map<String, dynamic>.from(result[objectKey]);
      for (final field in fields) {
        if (_encryptedValue(keypair, field) != null || keypair[field] is Map) {
          keypair[field] = '';
        }
      }
      result[objectKey] = keypair;
    });

    return result;
  }

  /// Returns the account record in the current layout with every secret
  /// field encrypted under [password], or null when it already is.
  ///
  /// [expected] is the record's decrypted content when the caller already
  /// has it; it is also how a caller that confirmed [password] elsewhere
  /// (the legacy wallet-wide slot) encrypts a record that has no encrypted
  /// field yet. Without it, a record with no encrypted field is left alone,
  /// since [password] cannot be checked against it.
  ///
  /// The new record is decrypted in memory and compared with [expected]
  /// before it is returned. Throws when [password] does not open the stored
  /// record or when the new record does not round-trip to the same values.
  /// [encrypt] is replaceable for tests.
  static Map<String, dynamic>? upgradeAccountRecord(
    Map<String, dynamic> storedJson,
    String password, {
    Map<String, dynamic>? expected,
    Map<String, dynamic> Function(Map<String, dynamic>, String) encrypt =
        encryptAccountPrivateKeys,
  }) {
    if (!needsUpgrade(storedJson)) {
      return null;
    }
    if (expected == null && !hasEncryptedPrivateKeys(storedJson)) {
      return null;
    }

    final expectedValues =
        expected ?? decryptAccountPrivateKeys(storedJson, password);
    final upgraded = encrypt(storedJson, password);

    if (needsUpgrade(upgraded)) {
      throw StateError('Upgraded account record is not fully encrypted');
    }
    final roundTrip = decryptAccountPrivateKeys(upgraded, password);
    if (!const DeepCollectionEquality().equals(roundTrip, expectedValues)) {
      throw StateError('Upgraded account record does not round-trip');
    }

    return upgraded;
  }
}
