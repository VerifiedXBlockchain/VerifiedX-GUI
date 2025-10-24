import 'dart:convert';
import 'dart:typed_data';
import 'package:hex/hex.dart';
import 'package:pointycastle/export.dart';

class VfxShhDecryptionService {
  /// Decrypts a VFX-SHH encrypted message using ECIES/SECP256k1
  ///
  /// [encryptedBase64] - Base64-encoded encrypted message
  /// [privateKeyHex] - Private key as hex string (without 0x prefix)
  ///
  /// Returns the decrypted plaintext message or null if decryption fails
  static Future<String?> decrypt(
    String encryptedBase64,
    String privateKeyHex,
  ) async {
    try {
      // Remove 0x prefix if present
      privateKeyHex = privateKeyHex.replaceFirst('0x', '');

      // Decode base64 ciphertext to bytes
      final Uint8List ciphertext = base64.decode(encryptedBase64);

      // Convert hex private key to bytes
      final Uint8List privateKeyBytes = Uint8List.fromList(
        HEX.decode(privateKeyHex),
      );

      // Decrypt using ECIES with SECP256k1
      final Uint8List plaintext = _eciesDecrypt(privateKeyBytes, ciphertext);

      // Convert bytes to UTF-8 string
      return utf8.decode(plaintext);
    } catch (e) {
      print('VFX-SHH Decryption Error: $e');
      return null;
    }
  }

  /// Internal ECIES decryption implementation
  /// Compatible with Python ecies 0.4.4 (secp256k1 + AES-256-GCM)
  static Uint8List _eciesDecrypt(
    Uint8List privateKeyBytes,
    Uint8List ciphertext,
  ) {
    // Python ecies 0.4.4 format:
    // [ephemeral_public_key (65 bytes)] + [nonce (16 bytes)] + [tag (16 bytes)] + [ciphertext]

    if (ciphertext.length < 97) {
      throw Exception('Ciphertext too short (minimum 97 bytes required)');
    }

    // Extract components according to Python ecies format
    final ephemeralPublicKeyBytes = ciphertext.sublist(0, 65);
    final nonce = ciphertext.sublist(65, 81); // 16 bytes nonce
    final tag = ciphertext.sublist(81, 97); // 16 bytes authentication tag
    final encryptedData = ciphertext.sublist(97); // Remaining bytes

    print('Ephemeral key length: ${ephemeralPublicKeyBytes.length}');
    print('Nonce length: ${nonce.length}');
    print('Tag length: ${tag.length}');
    print('Encrypted data length: ${encryptedData.length}');

    // Get SECP256k1 curve parameters
    final params = ECDomainParameters('secp256k1');

    // Parse ephemeral public key (uncompressed format 0x04 + x + y)
    final ephemeralPublicKey = params.curve.decodePoint(ephemeralPublicKeyBytes);
    if (ephemeralPublicKey == null) {
      throw Exception('Invalid ephemeral public key');
    }

    // Compute shared secret using ECDH
    final privateKey = BigInt.parse(HEX.encode(privateKeyBytes), radix: 16);
    final sharedPoint = ephemeralPublicKey * privateKey;
    if (sharedPoint == null || sharedPoint.isInfinity) {
      throw Exception('Invalid shared secret');
    }

    // Get shared secret point as uncompressed public key (65 bytes)
    // Format: 0x04 + x (32 bytes) + y (32 bytes)
    final sharedPointBytes = sharedPoint.getEncoded(false); // false = uncompressed

    print('Shared secret point: ${HEX.encode(sharedPointBytes)}');

    // Python eciespy uses HKDF-SHA256 for key derivation
    // The input is: ephemeral_public_key (65 bytes) + shared_point (65 bytes) = 130 bytes
    // With default config: is_hkdf_key_compressed = False
    final hkdfInput = Uint8List.fromList([...ephemeralPublicKeyBytes, ...sharedPointBytes]);
    print('HKDF input length: ${hkdfInput.length} bytes');
    final derivedKey = _hkdfSha256(hkdfInput, 32);

    print('Derived key: ${HEX.encode(derivedKey)}');

    // Decrypt using AES-256-GCM with the nonce and tag from ciphertext
    final cipher = GCMBlockCipher(AESEngine());

    cipher.init(
      false, // false for decryption
      AEADParameters(
        KeyParameter(derivedKey),
        128, // 128-bit authentication tag
        nonce,
        Uint8List(0), // No additional authenticated data
      ),
    );

    // Combine encrypted data with tag for GCM decryption
    final dataWithTag = Uint8List.fromList([...encryptedData, ...tag]);
    final plaintext = Uint8List(dataWithTag.length);

    try {
      var offset = cipher.processBytes(dataWithTag, 0, dataWithTag.length, plaintext, 0);
      offset += cipher.doFinal(plaintext, offset);
      return plaintext.sublist(0, offset);
    } catch (e) {
      print('GCM decryption failed: $e');
      throw Exception('Authentication tag verification failed: $e');
    }
  }

  /// Key derivation function - HKDF-SHA256
  /// Compatible with Python eciespy which uses HKDF-SHA256 for key derivation
  static Uint8List _hkdfSha256(Uint8List sharedSecret, int keyLength) {
    // HKDF parameters matching Python eciespy defaults
    final hkdf = HKDFKeyDerivator(SHA256Digest());

    hkdf.init(HkdfParameters(
      sharedSecret,  // Input keying material (IKM)
      keyLength,     // Length of output key material
      null,          // Salt (null for no salt, as per eciespy default)
      Uint8List(0),  // Info (empty, as per eciespy default)
    ));

    final output = Uint8List(keyLength);
    hkdf.deriveKey(null, 0, output, 0);
    return output;
  }

  /// Convert BigInt to Uint8List with proper padding
  static Uint8List _bigIntToUint8List(BigInt bigInt) {
    final bytes = bigInt.toRadixString(16).padLeft(64, '0');
    return Uint8List.fromList(HEX.decode(bytes));
  }

  /// Validates that a private key is in valid hex format
  static bool isValidPrivateKey(String privateKeyHex) {
    if (privateKeyHex.isEmpty) return false;

    try {
      final decoded = HEX.decode(privateKeyHex);
      // SECP256k1 private keys should be 32 bytes
      return decoded.length == 32;
    } catch (e) {
      return false;
    }
  }

  /// Validates that encrypted data is in valid base64 format
  static bool isValidBase64(String encryptedBase64) {
    if (encryptedBase64.isEmpty) return false;

    try {
      base64.decode(encryptedBase64);
      return true;
    } catch (e) {
      return false;
    }
  }
}
