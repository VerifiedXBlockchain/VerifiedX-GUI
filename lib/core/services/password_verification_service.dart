import '../singletons.dart';
import '../storage.dart';
import 'encryption_service.dart';

class PasswordVerificationService {
  static final Storage _storage = singleton<Storage>();

  /// Stores a password hash for future verification
  static void storePasswordHash(String password) {
    final hash = EncryptionService.hashPassword(password);
    _storage.setString(Storage.STORED_PASSWORD_HASH, hash);
  }

  /// Verifies if the provided password matches the stored hash
  static bool verifyPassword(String password) {
    final storedHash = _storage.getString(Storage.STORED_PASSWORD_HASH);
    if (storedHash == null) return false;
    
    return EncryptionService.verifyPassword(password, storedHash);
  }

  /// Checks if there's a stored password hash
  static bool hasStoredPassword() {
    return _storage.hasPasswordHash();
  }

  /// Removes stored password hash (for logout/account deletion)
  static void clearStoredPassword() {
    _storage.remove(Storage.STORED_PASSWORD_HASH);
  }
}