import 'encryption_service.dart';

class MultiAccountEncryptionService {
  /// Encrypts individual private key fields in a MultiAccountInstance JSON
  static Map<String, dynamic> encryptAccountPrivateKeys(
    Map<String, dynamic> accountJson,
    String password,
  ) {
    final result = Map<String, dynamic>.from(accountJson);
    
    // Encrypt VFX keypair private key if exists
    if (result['keypair'] != null) {
      final keypairJson = Map<String, dynamic>.from(result['keypair']);
      if (keypairJson['private'] != null) {
        final privateKey = keypairJson['private'] as String;
        final encryptedPrivate = EncryptionService.encryptString(privateKey, password);
        keypairJson['private'] = encryptedPrivate;
        keypairJson['_isPrivateEncrypted'] = true;
      }
      result['keypair'] = keypairJson;
    }
    
    // Encrypt RA keypair private key if exists
    if (result['raKeypair'] != null) {
      final raKeypairJson = Map<String, dynamic>.from(result['raKeypair']);
      if (raKeypairJson['private'] != null) {
        final privateKey = raKeypairJson['private'] as String;
        final encryptedPrivate = EncryptionService.encryptString(privateKey, password);
        raKeypairJson['private'] = encryptedPrivate;
        raKeypairJson['_isPrivateEncrypted'] = true;
      }
      result['raKeypair'] = raKeypairJson;
    }
    
    // Encrypt BTC keypair private key if exists
    if (result['btcKeypair'] != null) {
      final btcKeypairJson = Map<String, dynamic>.from(result['btcKeypair']);
      if (btcKeypairJson['privateKey'] != null) {
        final privateKey = btcKeypairJson['privateKey'] as String;
        final encryptedPrivate = EncryptionService.encryptString(privateKey, password);
        btcKeypairJson['privateKey'] = encryptedPrivate;
        btcKeypairJson['_isPrivateEncrypted'] = true;
      }
      result['btcKeypair'] = btcKeypairJson;
    }
    
    return result;
  }
  
  /// Decrypts individual private key fields in a MultiAccountInstance JSON
  static Map<String, dynamic> decryptAccountPrivateKeys(
    Map<String, dynamic> accountJson,
    String password,
  ) {
    final result = Map<String, dynamic>.from(accountJson);
    
    // Decrypt VFX keypair private key if encrypted
    if (result['keypair'] != null) {
      final keypairJson = Map<String, dynamic>.from(result['keypair']);
      if (keypairJson['_isPrivateEncrypted'] == true && keypairJson['private'] != null) {
        final encryptedPrivate = keypairJson['private'] as Map<String, dynamic>;
        final decryptedPrivate = EncryptionService.decryptString(encryptedPrivate, password);
        keypairJson['private'] = decryptedPrivate;
        keypairJson.remove('_isPrivateEncrypted');
      }
      result['keypair'] = keypairJson;
    }
    
    // Decrypt RA keypair private key if encrypted
    if (result['raKeypair'] != null) {
      final raKeypairJson = Map<String, dynamic>.from(result['raKeypair']);
      if (raKeypairJson['_isPrivateEncrypted'] == true && raKeypairJson['private'] != null) {
        final encryptedPrivate = raKeypairJson['private'] as Map<String, dynamic>;
        final decryptedPrivate = EncryptionService.decryptString(encryptedPrivate, password);
        raKeypairJson['private'] = decryptedPrivate;
        raKeypairJson.remove('_isPrivateEncrypted');
      }
      result['raKeypair'] = raKeypairJson;
    }
    
    // Decrypt BTC keypair private key if encrypted
    if (result['btcKeypair'] != null) {
      final btcKeypairJson = Map<String, dynamic>.from(result['btcKeypair']);
      if (btcKeypairJson['_isPrivateEncrypted'] == true && btcKeypairJson['privateKey'] != null) {
        final encryptedPrivate = btcKeypairJson['privateKey'] as Map<String, dynamic>;
        final decryptedPrivate = EncryptionService.decryptString(encryptedPrivate, password);
        btcKeypairJson['privateKey'] = decryptedPrivate;
        btcKeypairJson.remove('_isPrivateEncrypted');
      }
      result['btcKeypair'] = btcKeypairJson;
    }
    
    return result;
  }
  
  /// Checks if an account has any encrypted private keys
  static bool hasEncryptedPrivateKeys(Map<String, dynamic> accountJson) {
    if (accountJson['keypair']?['_isPrivateEncrypted'] == true) return true;
    if (accountJson['raKeypair']?['_isPrivateEncrypted'] == true) return true;
    if (accountJson['btcKeypair']?['_isPrivateEncrypted'] == true) return true;
    return false;
  }
}