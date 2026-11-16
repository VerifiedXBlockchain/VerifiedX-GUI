import 'package:dio/dio.dart';

import '../../../core/services/base_service.dart';
import '../../../core/services/locked_wallet_gate.dart';
import '../utils/p2p_rules.dart';

/// Why a message could not be signed.
enum P2pSigningFailure {
  /// The address is not one of this wallet's accounts.
  notInWallet,

  /// The wallet is locked and was not unlocked.
  walletLocked,

  /// The node did not answer.
  unreachable,

  /// The node answered with something that is not a signature.
  unexpected,
}

class P2pSigningError implements Exception {
  final P2pSigningFailure failure;

  const P2pSigningError(this.failure);

  @override
  String toString() => "P2pSigningError(${failure.name})";
}

/// Signs a plain message with an address's key: the sign-in message and a
/// bid. Neither is a transaction.
abstract class P2pMessageSigner {
  /// The signature of [message] by [address], as
  /// `base64(DER) + "." + base58(public key)`. Throws a [P2pSigningError].
  Future<String> sign(String message, String address);
}

/// Signs through the local Core node (`/api/V1/CreateSignature`), so the key
/// never leaves Core. While the wallet is locked Core refuses the call, and
/// `BaseService` asks for the password and sends it once more.
class P2pCoreSigner extends BaseService implements P2pMessageSigner {
  @override
  Future<String> sign(String message, String address) async {
    final String answer;
    try {
      answer = await getText(
        absoluteUrl('/CreateSignature/${Uri.encodeComponent(message)}/${Uri.encodeComponent(address)}'),
        cleanPath: false,
      );
    } on WalletLockedException {
      throw const P2pSigningError(P2pSigningFailure.walletLocked);
    } on DioException {
      throw const P2pSigningError(P2pSigningFailure.unreachable);
    }

    final signature = answer.trim();
    if (isP2pSignatureFormat(signature)) {
      return signature;
    }
    // Core: "ERROR - Account not associated with wallet."
    if (signature.startsWith('ERROR')) {
      throw const P2pSigningError(P2pSigningFailure.notInWallet);
    }
    throw const P2pSigningError(P2pSigningFailure.unexpected);
  }
}
