import '../models/p2p_auth_token.dart';
import '../models/p2p_error.dart';
import '../utils/p2p_rules.dart';
import 'p2p_service.dart';
import 'p2p_signer.dart';

/// Spyglass signed in another address than the one that signed.
class P2pSignInMismatch implements Exception {
  const P2pSignInMismatch();

  @override
  String toString() => 'P2pSignInMismatch';
}

/// The wallet's sign-in tokens for the P2P registry: one per address, for
/// its hour, in memory only. Signing in is a message signed by Core (16
/// letters, a dot, the Unix time) posted to `/api/auth/sign-token/`; no key
/// leaves Core and nothing is stored on disk.
class P2pSession {
  /// A token lasts one hour at Spyglass.
  static const Duration tokenLifetime = Duration(hours: 1);

  /// A token this close to its end is replaced before it is used.
  static const Duration renewBefore = Duration(minutes: 2);

  final P2pService _service;
  final P2pMessageSigner _signer;
  final DateTime Function() _now;

  final Map<String, P2pAuthToken> _held = {};
  final Map<String, Future<String>> _signingIn = {};
  // Bumped by [clear], so a sign-in that was under way when the wallet
  // locked does not put its token back.
  int _generation = 0;

  P2pSession({
    required P2pService service,
    required P2pMessageSigner signer,
    DateTime Function()? now,
  })  : _service = service,
        _signer = signer,
        _now = now ?? DateTime.now;

  /// The token held for [address], if it is good for a while yet.
  String? cached(String address) {
    final held = _held[address];
    if (held == null || !held.expiresAt.subtract(renewBefore).isAfter(_now().toUtc())) {
      return null;
    }
    return held.token;
  }

  /// The email Spyglass holds for [address], known once it has signed in.
  String? emailOf(String address) => _held[address]?.email;

  /// The token for [address], signing in when none is held. One sign-in at a
  /// time per address: concurrent callers share it.
  Future<String> token(String address) {
    final held = cached(address);
    if (held != null) {
      return Future.value(held);
    }
    final running = _signingIn[address];
    if (running != null) {
      return running;
    }
    late final Future<String> started;
    // A block body: whenComplete waits for a future its action returns, and
    // `remove` returns this very future.
    started = _signIn(address).whenComplete(() {
      if (identical(_signingIn[address], started)) {
        _signingIn.remove(address);
      }
    });
    _signingIn[address] = started;
    return started;
  }

  /// Drops the token for [address] (after a 401).
  void forget(String address) {
    _held.remove(address);
  }

  /// Drops every token (the wallet locked).
  void clear() {
    _generation++;
    _held.clear();
    _signingIn.clear();
  }

  /// Runs [run] with [address]'s token. On a 401 (`token_expired`,
  /// `token_invalid`) it signs in once more and runs it once more.
  Future<T> withToken<T>(String address, Future<T> Function(String token) run) async {
    final token = await this.token(address);
    try {
      return await run(token);
    } on P2pError catch (e) {
      if (!e.isUnauthorized) {
        rethrow;
      }
    }
    forget(address);
    return run(await this.token(address));
  }

  Future<String> _signIn(String address) async {
    final generation = _generation;
    final signedAt = _now().toUtc();
    final message = p2pSignInMessage(signedAt.millisecondsSinceEpoch ~/ 1000);
    final signature = await _signer.sign(message, address);
    final answer = await _service.signToken(address: address, message: message, signature: signature);
    if (answer.address.isNotEmpty && answer.address != address) {
      throw const P2pSignInMismatch();
    }
    // This clock and Spyglass's can differ: the token is kept no longer than
    // its hour from here.
    final latest = signedAt.add(tokenLifetime);
    final expiresAt = answer.expiresAt.isBefore(latest) ? answer.expiresAt : latest;
    if (generation == _generation) {
      _held[address] = P2pAuthToken(token: answer.token, address: address, expiresAt: expiresAt, email: answer.email);
    }
    return answer.token;
  }
}
