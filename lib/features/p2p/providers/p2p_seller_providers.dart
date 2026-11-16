import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/p2p_collection.dart';
import '../models/p2p_owned_nft.dart';
import '../services/p2p_nft_source.dart';
import '../services/p2p_seller.dart';
import 'p2p_browse_providers.dart';
import 'p2p_listed_nfts_provider.dart';
import 'p2p_session_provider.dart';

part 'p2p_seller_providers.g.dart';

/// The wallet's own NFTs and their media.
@Riverpod(keepAlive: true)
P2pNftSource p2pNftSource(P2pNftSourceRef ref) {
  return P2pWalletNftSource();
}

@Riverpod(keepAlive: true)
P2pSeller p2pSeller(P2pSellerRef ref) {
  return P2pSeller(
    service: ref.watch(p2pServiceProvider),
    session: ref.watch(p2pSessionProvider),
    nfts: ref.watch(p2pNftSourceProvider),
  );
}

/// [address]'s shop's collections, hidden ones included. Reading them signs
/// [address] in to the registry.
@riverpod
Future<List<P2pCollection>> p2pOwnerCollections(P2pOwnerCollectionsRef ref, String address, String shopUrl) {
  return ref.watch(p2pSellerProvider).collections(address, shopUrl);
}

/// Every NFT in this wallet, read from Core.
@riverpod
Future<List<P2pOwnedNft>> p2pWalletNfts(P2pWalletNftsRef ref) {
  return ref.watch(p2pNftSourceProvider).walletNfts();
}

/// The NFT whose own page asked for it to be listed, until My shop takes the
/// request up and opens "List an NFT" for it.
final p2pListRequestProvider = StateProvider<String?>((ref) => null);

/// Reads again everything [address]'s shop screens show: after a collection
/// or a listing of its changed.
void refreshP2pSeller(WidgetRef ref, String address) {
  ref.invalidate(p2pOwnerCollectionsProvider);
  ref.invalidate(p2pMeProvider(address));
  ref.invalidate(p2pOwnerShopProvider(address));
  ref.invalidate(p2pShopProvider);
  ref.invalidate(p2pShopListingsProvider);
  ref.read(p2pListedNftsProvider.notifier).refresh();
}
