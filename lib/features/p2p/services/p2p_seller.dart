import '../models/p2p_collection.dart';
import '../models/p2p_listing.dart';
import '../models/p2p_page.dart';
import 'p2p_nft_source.dart';
import 'p2p_service.dart';
import 'p2p_session.dart';

/// What a shop's owner does that is not a transaction: collections and
/// listings are records in the registry, written with the owner's sign-in
/// token. Each call signs the address in when it has to (a message signed by
/// Core) and throws a `P2pError`, a `P2pSigningError` or a
/// `P2pSignInMismatch`.
class P2pSeller {
  final P2pService _service;
  final P2pSession _session;
  final P2pNftSource _nfts;

  P2pSeller({
    required P2pService service,
    required P2pSession session,
    required P2pNftSource nfts,
  })  : _service = service,
        _session = session,
        _nfts = nfts;

  /// The shop's collections as its owner sees them: the hidden ones too.
  Future<List<P2pCollection>> collections(String address, String shopUrl) async {
    final page = await _session.withToken(
      address,
      (token) => _service.listCollections(shopUrl, token: token, limit: P2pPage.maxLimit),
    );
    return page.results;
  }

  Future<P2pCollection> createCollection(String address, String shopUrl, {required String name, String description = ''}) {
    return _session.withToken(
      address,
      (token) => _service.createCollection(token: token, shopUrl: shopUrl, name: name, description: description),
    );
  }

  Future<P2pCollection> updateCollection(String address, int id, {String? name, String? description, bool? isLive}) {
    return _session.withToken(
      address,
      (token) => _service.updateCollection(token: token, id: id, name: name, description: description, isLive: isLive),
    );
  }

  Future<void> deleteCollection(String address, int id) {
    return _session.withToken(address, (token) => _service.deleteCollection(token: token, id: id));
  }

  /// Whether Spyglass holds the NFT's media, which a listing's picture is
  /// read from.
  Future<bool> hasMedia(String nftId) => _nfts.hasMedia(nftId);

  /// Puts the NFT's media in Spyglass as [address], its owner. Throws a
  /// `P2pMediaUploadError`.
  Future<void> uploadMedia(String address, String nftId) async {
    await _nfts.uploadMedia(nftId, await _session.token(address));
  }

  /// Lists an NFT of [address]'s in one of its shop's collections.
  Future<P2pListing> list(String address, int collectionId, P2pListingInput input) {
    return _session.withToken(
      address,
      (token) => _service.createListing(token: token, collectionId: collectionId, input: input),
    );
  }

  /// Changes a listing's prices and dates.
  Future<P2pListing> updateListing(String address, int id, P2pListingInput input) {
    return _session.withToken(address, (token) => _service.updateListing(token: token, id: id, input: input));
  }

  /// Withdraws a listing whose sale has not started.
  Future<P2pListing> cancelListing(String address, int id) {
    return _session.withToken(address, (token) => _service.cancelListing(token: token, id: id));
  }
}
