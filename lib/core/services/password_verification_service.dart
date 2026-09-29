import '../singletons.dart';
import '../storage.dart';
import 'encryption_service.dart';
import 'web_account_password_store.dart';

class PasswordVerificationService {
  static Storage get _storage => singleton<Storage>();

  /// Stores the wallet-wide password hash. Passwords are per account (see
  /// [WebAccountPasswordStore]); this hash backs the legacy fallback and marks
  /// the wallet as password protected.
  static void storePasswordHash(String password) {
    final hash = EncryptionService.hashPassword(password);
    _storage.setString(Storage.STORED_PASSWORD_HASH, hash);
  }

  /// Verifies [password] against the active account's password.
  static bool verifyPassword(String password) {
    return WebAccountPasswordStore(_storage)
        .verifyActiveAccountPassword(password);
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
