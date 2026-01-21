/// Stub implementation for non-web platforms
/// The VFX extension is only available in web browsers

class ExtensionEncryptedKeyData {
  final List<int> salt;
  final List<int> iv;
  final List<int> cipherText;
  final String address;
  final String publicKey;

  ExtensionEncryptedKeyData({
    required this.salt,
    required this.iv,
    required this.cipherText,
    required this.address,
    required this.publicKey,
  });
}

class VerifiedXExtensionService {
  static bool isExtensionInstalled() => false;

  static void onExtensionInitialized(void Function() callback) {
    // No-op on non-web platforms
  }

  static Future<ExtensionEncryptedKeyData> requestKey() {
    throw UnsupportedError('VFX Extension is only available on web');
  }
}
