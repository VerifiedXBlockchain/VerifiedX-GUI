import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

class EncryptionService {
  static const int _saltLength = 32;
  static const int _ivLength = 16;
  static const int _keyLength = 32; // 256 bits
  static const int _pbkdf2Iterations = 1000;

  /// Encrypts data with password using AES-256-GCM
  static Map<String, dynamic> encrypt(Map<String, dynamic> data, String password) {
    final salt = _generateRandomBytes(_saltLength);
    final iv = _generateRandomBytes(_ivLength);
    
    // Derive key from password using PBKDF2
    final key = _deriveKey(password, salt);
    
    // Convert data to JSON string then to bytes
    final plaintext = Uint8List.fromList(utf8.encode(json.encode(data)));
    
    // Encrypt using AES-GCM
    final cipher = GCMBlockCipher(AESEngine());
    final keyParam = KeyParameter(key);
    final params = AEADParameters(keyParam, 128, iv, Uint8List(0));
    
    cipher.init(true, params);
    final ciphertext = cipher.process(plaintext);
    
    return {
      'encrypted_data': base64.encode(ciphertext),
      'salt': base64.encode(salt),
      'iv': base64.encode(iv),
      'iterations': _pbkdf2Iterations,
    };
  }

  /// Decrypts data with password
  static Map<String, dynamic> decrypt(Map<String, dynamic> encryptedData, String password) {
    print("🔓 Decrypting data...");
    print("🔓 Encrypted data structure: $encryptedData");
    print("🔓 encrypted_data field: ${encryptedData['encrypted_data']}");
    final encryptedBytes = base64.decode(encryptedData['encrypted_data']);
    final salt = base64.decode(encryptedData['salt']);
    final iv = base64.decode(encryptedData['iv']);
    final iterations = encryptedData['iterations'] ?? _pbkdf2Iterations;
    print("🔓 Using $iterations iterations for decryption");
    
    // Derive key from password
    print("🔓 Deriving key from password...");
    final key = _deriveKey(password, salt, iterations);
    print("🔓 Key derived successfully");
    
    // Decrypt using AES-GCM
    final cipher = GCMBlockCipher(AESEngine());
    final keyParam = KeyParameter(key);
    final params = AEADParameters(keyParam, 128, iv, Uint8List(0));
    
    cipher.init(false, params);
    final decryptedBytes = cipher.process(Uint8List.fromList(encryptedBytes));
    
    // Convert back to JSON
    final jsonString = utf8.decode(decryptedBytes);
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  /// Generates a hash of the password for storage/verification
  static String hashPassword(String password) {
    final salt = _generateRandomBytes(_saltLength);
    final key = _deriveKey(password, salt);
    
    // Store salt + hash for verification
    final combined = [...salt, ...key];
    return base64.encode(combined);
  }

  /// Verifies password against stored hash
  static bool verifyPassword(String password, String storedHash) {
    try {
      final combined = base64.decode(storedHash);
      final salt = combined.take(_saltLength).toList();
      final storedKey = combined.skip(_saltLength).toList();
      
      final derivedKey = _deriveKey(password, Uint8List.fromList(salt));
      
      // Constant time comparison
      return _constantTimeEquals(derivedKey, Uint8List.fromList(storedKey));
    } catch (e) {
      return false;
    }
  }

  /// Derives encryption key from password using PBKDF2
  static Uint8List _deriveKey(String password, Uint8List salt, [int? iterations]) {
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    pbkdf2.init(Pbkdf2Parameters(salt, iterations ?? _pbkdf2Iterations, _keyLength));
    return pbkdf2.process(Uint8List.fromList(utf8.encode(password)));
  }

  /// Generates cryptographically secure random bytes
  static Uint8List _generateRandomBytes(int length) {
    final random = Random.secure();
    final bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      bytes[i] = random.nextInt(256);
    }
    return bytes;
  }

  /// Constant time comparison to prevent timing attacks
  static bool _constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }

  /// Checks if data appears to be encrypted (has our expected structure)
  static bool isEncrypted(dynamic data) {
    if (data is! Map<String, dynamic>) return false;
    
    return data.containsKey('encrypted_data') &&
           data.containsKey('salt') &&
           data.containsKey('iv') &&
           data.containsKey('iterations');
  }
}