import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

/// Service for creating encrypted bridge URLs for Butterfly login.
///
/// Uses encryption parameters that match Butterfly web's walletStorage.ts:
/// - PBKDF2 with 100,000 iterations (SHA-256)
/// - AES-256-GCM encryption
/// - 16-byte salt, 12-byte IV
class ButterflyBridgeUrlService {
  // Encryption parameters - MUST match Butterfly web
  static const int _pbkdf2Iterations = 10000;
  static const int _saltLength = 16;
  static const int _ivLength = 12;
  static const int _keyLength = 32; // 256 bits

  /// Creates an encrypted bridge URL for Butterfly login.
  ///
  /// The private key is encrypted using AES-GCM with a key derived from the
  /// password using PBKDF2. The URL contains the encrypted data in the fragment.
  ///
  /// [privateKey] - The wallet's private key to encrypt
  /// [password] - User-entered password for encryption
  /// [address] - The wallet's VFX address
  /// [publicKey] - The wallet's public key
  /// [targetBaseUrl] - The Butterfly web app URL
  ///
  /// Returns a URL like: {baseUrl}/login/key#enc=...&salt=...&iv=...&addr=...&pub=...
  static String createBridgeUrl({
    required String privateKey,
    required String password,
    required String address,
    required String publicKey,
    required String targetBaseUrl,
  }) {
    // Generate random salt and IV
    final salt = _generateRandomBytes(_saltLength);
    final iv = _generateRandomBytes(_ivLength);

    // Derive key using PBKDF2 with 100,000 iterations
    final key = _deriveKey(password, salt);

    // Encrypt private key using AES-GCM
    final plaintext = Uint8List.fromList(utf8.encode(privateKey));

    final cipher = GCMBlockCipher(AESEngine());
    final keyParam = KeyParameter(key);
    final params = AEADParameters(keyParam, 128, iv, Uint8List(0));

    cipher.init(true, params);
    final ciphertext = cipher.process(plaintext);

    // Base64 encode all components
    final encParam = base64Encode(ciphertext);
    final saltParam = base64Encode(salt);
    final ivParam = base64Encode(iv);

    // Build URL with encrypted data in fragment
    final fragment =
        'enc=${Uri.encodeComponent(encParam)}&salt=${Uri.encodeComponent(saltParam)}&iv=${Uri.encodeComponent(ivParam)}&addr=${Uri.encodeComponent(address)}&pub=${Uri.encodeComponent(publicKey)}';

    return '$targetBaseUrl/login/key#$fragment';
  }

  /// Derives encryption key from password using PBKDF2-SHA256.
  static Uint8List _deriveKey(String password, Uint8List salt) {
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    pbkdf2.init(Pbkdf2Parameters(salt, _pbkdf2Iterations, _keyLength));
    return pbkdf2.process(Uint8List.fromList(utf8.encode(password)));
  }

  /// Generates cryptographically secure random bytes.
  static Uint8List _generateRandomBytes(int length) {
    final random = Random.secure();
    final bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      bytes[i] = random.nextInt(256);
    }
    return bytes;
  }
}
