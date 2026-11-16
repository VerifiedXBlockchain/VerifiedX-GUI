import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/env.dart';
import '../../wallet/providers/wallet_list_provider.dart';
import '../models/p2p_error.dart';
import 'p2p_session_provider.dart';

part 'p2p_listed_nfts_provider.g.dart';

/// The ids of this wallet's NFTs that are in an active listing of the P2P
/// registry, for the "Listed" badge. One read of Spyglass per local address
/// (`GET /nft/listed/{owner}/`), where the old shop's flag walks Core's
/// collections and listings.
///
/// A badge only: a listed NFT can still be moved, which ends its listing.
@Riverpod(keepAlive: true)
class P2pListedNfts extends _$P2pListedNfts {
  // What each address has listed, so one failed read does not drop the rest.
  final Map<String, Set<String>> _byAddress = {};

  // The refresh under way, shared by everyone who asks meanwhile.
  Future<void>? _refreshing;

  @override
  Set<String> build() => const {};

  /// Reads every local address's listed NFTs again. Does nothing where the
  /// P2P shop is off.
  ///
  /// One at a time: the wallet's loop asks every 15 seconds without waiting
  /// for the last answer, and two rounds under way at once could land out of
  /// order and put a closed listing's badge back. A call made while a round
  /// is out joins it.
  Future<void> refresh() {
    if (!Env.p2pEnabled) {
      return Future.value();
    }
    return _refreshing ??= _readAll().whenComplete(() {
      _refreshing = null;
    });
  }

  Future<void> _readAll() async {
    final service = ref.read(p2pServiceProvider);
    final addresses = ref.read(walletListProvider).where((w) => !w.isReserved).map((w) => w.address).toSet();
    _byAddress.removeWhere((address, _) => !addresses.contains(address));

    await Future.wait(addresses.map((address) async {
      try {
        _byAddress[address] = await service.listedNftIds(address);
      } on P2pError {
        // Keep what this address had: the next round reads it again.
      }
    }));
    state = {for (final ids in _byAddress.values) ...ids};
  }
}
