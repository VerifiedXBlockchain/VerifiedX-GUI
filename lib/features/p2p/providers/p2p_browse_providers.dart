import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/session_provider.dart';
import '../models/p2p_listing.dart';
import '../models/p2p_me.dart';
import '../models/p2p_page.dart';
import '../models/p2p_shop.dart';
import 'p2p_session_provider.dart';

part 'p2p_browse_providers.g.dart';

/// The VFX address the shop screens act for: the wallet's selected account,
/// or null when none is (or a Bitcoin account is selected).
@riverpod
String? p2pViewerAddress(P2pViewerAddressRef ref) {
  return ref.watch(sessionProvider.select((s) => s.btcSelected ? null : s.currentWallet?.address));
}

/// What the selected account can spend, as Core reports it; null with no
/// account selected.
@riverpod
double? p2pViewerBalance(P2pViewerBalanceRef ref) {
  return ref.watch(sessionProvider.select((s) => s.btcSelected ? null : s.currentWallet?.spendableBalance));
}

/// What [address] sells and has bid on (`GET /p2p/me/`). Reading it signs
/// [address] in to the registry: a message signed by Core, never a
/// transaction.
@riverpod
Future<P2pMe> p2pMe(P2pMeRef ref, String address) {
  final service = ref.watch(p2pServiceProvider);
  return ref.watch(p2pSessionProvider).withToken(address, service.me);
}

/// The shop [address] owns, or null when it has none.
@riverpod
Future<P2pShop?> p2pOwnerShop(P2pOwnerShopRef ref, String address) {
  return ref.watch(p2pServiceProvider).ownerShop(address);
}

/// A page of the registry's shops, newest first.
@riverpod
Future<P2pPage<P2pShop>> p2pShopList(P2pShopListRef ref, {String search = '', int page = 1}) {
  return ref.watch(p2pServiceProvider).listShops(search: search, page: page);
}

/// A shop with its collections, or null when no shop has the URL.
@riverpod
Future<P2pShop?> p2pShop(P2pShopRef ref, String url) {
  return ref.watch(p2pServiceProvider).getShop(url);
}

/// A page of a shop's public listings: the active ones and those sold in the
/// last 7 days.
@riverpod
Future<P2pPage<P2pListing>> p2pShopListings(
  P2pShopListingsRef ref,
  String url, {
  int? collectionId,
  int page = 1,
  int? limit,
}) {
  return ref.watch(p2pServiceProvider).listListings(url, collectionId: collectionId, page: page, limit: limit);
}
