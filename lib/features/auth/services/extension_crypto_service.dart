import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

/// Service for decrypting private keys from the VFX browser extension.
/// Uses PBKDF2 (10,000 iterations) + AES-256-GCM encryption format
/// for key export (different from extension's internal 100k storage encryption).
class ExtensionCryptoService {
  // Extension uses 10,000 PBKDF2 iterations for key export encryption
  static const int _pbkdf2Iterations = 10000;
  static const int _keyLength = 32; // 256 bits

  /// Decrypt a private key that was encrypted by the VFX browser extension.
  ///
  /// [salt] - 16 bytes PBKDF2 salt from extension
  /// [iv] - 12 bytes AES-GCM initialization vector from extension
  /// [cipherText] - Encrypted private key bytes from extension
  /// [password] - User's wallet password
  ///
  /// Returns the decrypted private key as a string
  static String decryptPrivateKey({
    required List<int> salt,
    required List<int> iv,
    required List<int> cipherText,
    required String password,
  }) {
    // Derive key from password using PBKDF2 with SHA-256
    final saltBytes = Uint8List.fromList(salt);
    final ivBytes = Uint8List.fromList(iv);
    final cipherBytes = Uint8List.fromList(cipherText);

    final key = _deriveKey(password, saltBytes);

    // Decrypt using AES-GCM
    final cipher = GCMBlockCipher(AESEngine());
    final keyParam = KeyParameter(key);
    // Extension uses 128-bit auth tag (standard for AES-GCM)
    final params = AEADParameters(keyParam, 128, ivBytes, Uint8List(0));

    cipher.init(false, params);
    final decryptedBytes = cipher.process(cipherBytes);

    // Convert back to string (the private key)
    return utf8.decode(decryptedBytes);
  }

  /// Derives encryption key from password using PBKDF2 with SHA-256
  static Uint8List _deriveKey(String password, Uint8List salt) {
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    pbkdf2.init(Pbkdf2Parameters(salt, _pbkdf2Iterations, _keyLength));
    return pbkdf2.process(Uint8List.fromList(utf8.encode(password)));
  }
}
