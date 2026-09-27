import 'package:collection/collection.dart';

import 'encryption_service.dart';

/// Per-field encryption of the secret fields in a stored web account
/// (a `Storage.MULTIPLE_ACCOUNTS` entry, the JSON of a MultiAccountInstance).
///
/// Each secret field is encrypted on its own with [EncryptionService] under
/// the account's password and flagged with a marker key in the same object.
/// The main private keys use the original `_isPrivateEncrypted` marker; the
/// other secret fields use `_is<Field>Encrypted`. A field without its marker
/// is read as is, so records written before the format covered every secret
/// field still load.
class MultiAccountEncryptionService {
  /// Secret fields per keypair object in the account JSON.
  static const Map<String, List<String>> secretFields = {
    'keypair': ['private', 'mneumonic', 'btcWif'],
    'raKeypair': ['private', 'recoveryPrivate', 'restoreCode'],
    'btcKeypair': ['privateKey', 'wif', 'mnemonic'],
  };

  /// The marker stored next to [field] once it is encrypted.
  static String markerFor(String field) {
    if (field == 'private' || field == 'privateKey') {
      return '_isPrivateEncrypted';
    }
    return '_is${field[0].toUpperCase()}${field.substring(1)}Encrypted';
  }

  /// Encrypts every secret field that is not encrypted yet.
  ///
  /// Fields that already carry their marker are left untouched, so this also
  /// completes a record that only has some fields encrypted.
  static Map<String, dynamic> encryptAccountPrivateKeys(
    Map<String, dynamic> accountJson,
    String password,
  ) {
    final result = Map<String, dynamic>.from(accountJson);

    secretFields.forEach((objectKey, fields) {
      if (result[objectKey] == null) {
        return;
      }
      final objectJson = Map<String, dynamic>.from(result[objectKey]);
      for (final field in fields) {
        final marker = markerFor(field);
        final value = objectJson[field];
        if (objectJson[marker] == true || value == null) {
          continue;
        }
        objectJson[field] =
            EncryptionService.encryptString(value as String, password);
        objectJson[marker] = true;
      }
      result[objectKey] = objectJson;
    });

    return result;
  }

  /// Decrypts every marked secret field and drops the markers. Unmarked fields
  /// are returned as stored. Throws when [password] does not open a field.
  static Map<String, dynamic> decryptAccountPrivateKeys(
    Map<String, dynamic> accountJson,
    String password,
  ) {
    final result = Map<String, dynamic>.from(accountJson);

    secretFields.forEach((objectKey, fields) {
      if (result[objectKey] == null) {
        return;
      }
      final objectJson = Map<String, dynamic>.from(result[objectKey]);
      for (final field in fields) {
        final marker = markerFor(field);
        if (objectJson[marker] != true) {
          continue;
        }
        final value = objectJson[field];
        if (value != null) {
          objectJson[field] = EncryptionService.decryptString(
              Map<String, dynamic>.from(value as Map), password);
        }
        objectJson.remove(marker);
      }
      result[objectKey] = objectJson;
    });

    return result;
  }

  /// Whether any secret field of the account is encrypted, meaning the
  /// account has a password of its own.
  static bool hasEncryptedPrivateKeys(Map<String, dynamic> accountJson) {
    for (final entry in secretFields.entries) {
      final objectJson = accountJson[entry.key];
      if (objectJson is! Map) {
        continue;
      }
      if (entry.value.any((field) => objectJson[markerFor(field)] == true)) {
        return true;
      }
    }
    return false;
  }

  /// Whether any secret field still holds a value without its marker.
  static bool hasUnencryptedSecretFields(Map<String, dynamic> accountJson) {
    for (final entry in secretFields.entries) {
      final objectJson = accountJson[entry.key];
      if (objectJson is! Map) {
        continue;
      }
      for (final field in entry.value) {
        if (objectJson[field] != null &&
            objectJson[markerFor(field)] != true) {
          return true;
        }
      }
    }
    return false;
  }

  /// Copy of the account JSON with each encrypted field replaced by an empty
  /// placeholder, for listing accounts whose password has not been entered.
  static Map<String, dynamic> withEncryptedFieldsBlank(
      Map<String, dynamic> accountJson) {
    final result = Map<String, dynamic>.from(accountJson);

    secretFields.forEach((objectKey, fields) {
      if (result[objectKey] == null) {
        return;
      }
      final objectJson = Map<String, dynamic>.from(result[objectKey]);
      for (final field in fields) {
        if (objectJson[markerFor(field)] == true) {
          objectJson[field] = '';
        }
      }
      result[objectKey] = objectJson;
    });

    return result;
  }

  /// Returns the account record with every secret field encrypted under
  /// [password], or null when the record already is, or when it has no
  /// encrypted field (no password of its own that [password] could be checked
  /// against).
  ///
  /// The new record is decrypted in memory and compared with the stored one
  /// before it is returned. Throws when [password] does not open the stored
  /// record or when the new record does not round-trip to the same values.
  /// [encrypt] is replaceable for tests.
  static Map<String, dynamic>? upgradeAccountRecord(
    Map<String, dynamic> storedJson,
    String password, {
    Map<String, dynamic> Function(Map<String, dynamic>, String) encrypt =
        encryptAccountPrivateKeys,
  }) {
    if (!hasEncryptedPrivateKeys(storedJson) ||
        !hasUnencryptedSecretFields(storedJson)) {
      return null;
    }

    final expected = decryptAccountPrivateKeys(storedJson, password);
    final upgraded = encrypt(storedJson, password);

    if (hasUnencryptedSecretFields(upgraded)) {
      throw StateError('Upgraded account record still has unmarked fields');
    }
    final roundTrip = decryptAccountPrivateKeys(upgraded, password);
    if (!const DeepCollectionEquality().equals(roundTrip, expected)) {
      throw StateError('Upgraded account record does not round-trip');
    }

    return upgraded;
  }
}
