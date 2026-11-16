import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/p2p_collection.dart';
import '../models/p2p_owned_nft.dart';
import '../components/p2p_email_dialog.dart';
import '../services/p2p_email_prompt.dart';
import '../services/p2p_nft_source.dart';
import '../services/p2p_seller.dart';
import 'p2p_browse_providers.dart';
import 'p2p_listed_nfts_provider.dart';
import 'p2p_sale_notices_provider.dart';
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

/// Which accounts were already asked for an email.
@Riverpod(keepAlive: true)
P2pEmailAsked p2pEmailAsked(P2pEmailAskedRef ref) {
  return P2pStoredEmailAsked();
}

/// The optional email prompt, shown once per account.
@Riverpod(keepAlive: true)
P2pEmailPrompt p2pEmailPrompt(P2pEmailPromptRef ref) {
  return P2pEmailPrompt(
    session: ref.watch(p2pSessionProvider),
    asked: ref.watch(p2pEmailAskedProvider),
    show: P2pEmailDialog.show,
  );
}

/// An NFT whose own page asked for it to be listed.
class P2pListRequest {
  /// How long a request waits to be taken up (while a shop is opened, say).
  static const Duration goodFor = Duration(minutes: 15);

  final String nftId;

  /// The account that was selected when it was asked.
  final String? address;
  final DateTime at;

  const P2pListRequest({required this.nftId, required this.address, required this.at});

  /// Whether My shop, showing [address] at [now], should act on it: asked
  /// for this account, not long ago. A request left behind does not open a
  /// dialog for another account or hours later.
  bool isFor(String address, DateTime now) => this.address == address && now.difference(at) < goodFor;
}

/// The latest such request, until My shop takes it up and opens "List an
/// NFT" for it.
final p2pListRequestProvider = StateProvider<P2pListRequest?>((ref) => null);

/// Reads again everything [address]'s shop screens show: after a collection
/// or a listing of its changed.
void refreshP2pSeller(WidgetRef ref, String address) {
  refreshP2pSellerIn(ProviderScope.containerOf(ref.context, listen: false), address);
}

/// [refreshP2pSeller] for a caller that may outlive its widget: a step
/// confirmed in a dialog, whose row can be gone by the time it is done.
void refreshP2pSellerIn(ProviderContainer container, String address) {
  container.invalidate(p2pOwnerCollectionsProvider);
  container.invalidate(p2pMeProvider(address));
  container.invalidate(p2pOwnerShopProvider(address));
  container.invalidate(p2pShopProvider);
  container.invalidate(p2pShopListingsProvider);
  container.read(p2pListedNftsProvider.notifier).refresh();
  // A sale started or a listing withdrawn: the badge follows at once.
  container.read(p2pSaleNoticesProvider.notifier).poll(force: true);
}
