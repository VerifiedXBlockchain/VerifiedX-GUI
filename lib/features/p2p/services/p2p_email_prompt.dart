import '../../../core/singletons.dart';
import '../../../core/storage.dart';
import 'p2p_session.dart';

/// Which accounts were already asked for an email, so nobody is asked twice.
abstract class P2pEmailAsked {
  bool wasAsked(String address);

  void markAsked(String address);
}

/// Kept in the app's own settings on this computer.
class P2pStoredEmailAsked implements P2pEmailAsked {
  static const String storageKey = 'P2P_EMAIL_ASKED';

  Storage get _storage => singleton<Storage>();

  @override
  bool wasAsked(String address) => (_storage.getStringList(storageKey) ?? const []).contains(address);

  @override
  void markAsked(String address) {
    final asked = [...?_storage.getStringList(storageKey)];
    if (!asked.contains(address)) {
      _storage.setStringList(storageKey, [...asked, address]);
    }
  }
}

/// Offers, once per account, to give Spyglass an email for the sale emails
/// it sends: when a shop is opened and at a first bid. Never when Spyglass
/// already holds one for the account (its sign-in answer says so).
class P2pEmailPrompt {
  final P2pSession _session;
  final P2pEmailAsked _asked;

  /// Shows the prompt for an address.
  final Future<void> Function(String address) _show;

  P2pEmailPrompt({
    required P2pSession session,
    required P2pEmailAsked asked,
    required Future<void> Function(String address) show,
  })  : _session = session,
        _asked = asked,
        _show = show;

  /// Whether [address] would be asked now.
  bool shouldAsk(String address) => _session.emailOf(address) == null && !_asked.wasAsked(address);

  Future<void> maybeAsk(String address) async {
    if (!shouldAsk(address)) {
      return;
    }
    _asked.markAsked(address);
    await _show(address);
  }
}
