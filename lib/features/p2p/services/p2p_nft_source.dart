import '../../../core/services/explorer_service.dart';
import '../../nft/models/nft.dart';
import '../../nft/services/nft_service.dart';
import '../../smart_contracts/features/royalty/royalty.dart';
import '../models/p2p_listing.dart';
import '../models/p2p_owned_nft.dart';
import '../utils/p2p_amount.dart';

/// The NFT's media could not be put in Spyglass.
class P2pMediaUploadError implements Exception {
  /// The file that failed, or empty when attaching the uploaded files did.
  final String fileName;

  const P2pMediaUploadError([this.fileName = '']);

  @override
  String toString() => "P2pMediaUploadError($fileName)";
}

/// The wallet's own NFTs and their media, for listing one in the shop.
abstract class P2pNftSource {
  /// Every NFT in this wallet, whichever account owns it.
  Future<List<P2pOwnedNft>> walletNfts();

  /// Whether Spyglass holds media for the NFT, which is what a listing's
  /// picture is read from. An NFT minted in this wallet has none there until
  /// it is uploaded.
  Future<bool> hasMedia(String id);

  /// Uploads the NFT's media from this disk to Spyglass and attaches it to
  /// the NFT, authorised by its owner's sign-in [token]. Throws a
  /// [P2pMediaUploadError].
  Future<void> uploadMedia(String id, String token);
}

/// Reads the NFTs from Core through the wallet's own NFT service (a read:
/// nothing is signed) and puts media in Spyglass with the calls the NFT
/// page's "Sync media" uses.
class P2pWalletNftSource implements P2pNftSource {
  /// A bound on the pages read from Core.
  static const int maxPages = 50;

  /// How many NFTs are read at a time for their owner.
  static const int ownerReadsAtOnce = 6;

  final NftService _nfts;
  final ExplorerService _explorer;

  P2pWalletNftSource({NftService? nfts, ExplorerService? explorer})
      : _nfts = nfts ?? NftService(),
        _explorer = explorer ?? ExplorerService();

  @override
  Future<List<P2pOwnedNft>> walletNfts() async {
    final listed = <Nft>[];
    for (var page = 1; page <= maxPages; page++) {
      final result = await _nfts.list(page);
      listed.addAll(result.results);
      if (result.results.isEmpty || listed.length >= result.count) {
        break;
      }
    }
    // Core's list does not say who owns an NFT; its single read does. An NFT
    // whose owner cannot be read is kept, owned by no account of this wallet.
    final found = <P2pOwnedNft>[];
    for (var start = 0; start < listed.length; start += ownerReadsAtOnce) {
      final batch = listed.skip(start).take(ownerReadsAtOnce);
      found.addAll(await Future.wait(batch.map((nft) async => p2pOwnedNftOf(await _nfts.retrieve(nft.id) ?? nft))));
    }
    return found;
  }

  @override
  Future<bool> hasMedia(String id) async {
    final nft = await _explorer.retrieveWebNft(id);
    return nft?.assetUrls?.isNotEmpty ?? false;
  }

  @override
  Future<void> uploadMedia(String id, String token) async {
    final nft = await _nfts.retrieve(id);
    if (nft == null) {
      throw const P2pMediaUploadError();
    }
    final urls = <String, String>{};
    for (final asset in [nft.primaryAsset, ...nft.additionalAssets]) {
      final String? url;
      try {
        url = await _explorer.uploadAsset(await asset.file.readAsBytes(), asset.fileName, asset.extension);
      } catch (_) {
        // A file that is not on this disk, or an upload Spyglass refused.
        throw P2pMediaUploadError(asset.fileName);
      }
      if (url == null) {
        throw P2pMediaUploadError(asset.fileName);
      }
      urls[asset.fileName] = url;
    }
    if (!await _explorer.associateMedia(id, urls, authToken: token)) {
      throw const P2pMediaUploadError();
    }
  }
}

/// Core's feature numbers for a fungible token and a vBTC vault.
const Set<int> _unsellableFeatures = {3, 13};

/// [nft] as the picker shows it. The features are read as Core sends them,
/// not through the NFT model's typed getters, so an amount Core writes as a
/// whole number reads too.
P2pOwnedNft p2pOwnedNftOf(Nft nft) {
  P2pRoyalty? royalty;
  var sellable = true;
  for (final feature in nft.features) {
    final name = feature['FeatureName'];
    final values = feature['FeatureFeatures'];
    if (_unsellableFeatures.contains(name)) {
      sellable = false;
    }
    if (name == Royalty.compilerEnum && values is Map) {
      final amount = values['RoyaltyAmount'];
      final payTo = values['RoyaltyPayToAddress'];
      if (amount is num && amount.isFinite && amount > 0 && payTo is String && payTo.isNotEmpty) {
        royalty = P2pRoyalty(amount: P2pAmount.fromDouble(amount.toDouble()).toDecimalString(), payTo: payTo);
      }
    }
  }
  final asset = nft.primaryAsset;
  final path = asset.isImage ? asset.fixedLocation : '';
  return P2pOwnedNft(
    id: nft.id,
    name: nft.name,
    owner: nft.currentOwner,
    isMinted: nft.isPublished,
    isSellable: sellable,
    royalty: royalty,
    imagePath: path.isEmpty ? null : path,
  );
}
