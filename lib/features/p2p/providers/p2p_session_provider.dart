import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../encrypt/providers/password_required_provider.dart';
import '../services/p2p_service.dart';
import '../services/p2p_session.dart';
import '../services/p2p_signer.dart';

part 'p2p_session_provider.g.dart';

@Riverpod(keepAlive: true)
P2pService p2pService(P2pServiceRef ref) {
  return P2pService();
}

/// Signs the shop's messages (sign-in, bids) through Core.
@Riverpod(keepAlive: true)
P2pMessageSigner p2pSigner(P2pSignerRef ref) {
  return P2pCoreSigner();
}

/// The wallet's sign-in tokens for the P2P registry, one per address, dropped
/// when the wallet locks.
@Riverpod(keepAlive: true)
P2pSession p2pSession(P2pSessionRef ref) {
  final session = P2pSession(
    service: ref.watch(p2pServiceProvider),
    signer: ref.watch(p2pSignerProvider),
  );
  ref.listen<bool>(passwordRequiredProvider, (_, locked) {
    if (locked) {
      session.clear();
    }
  });
  return session;
}
