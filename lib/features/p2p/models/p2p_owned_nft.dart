import 'p2p_listing.dart';

/// An NFT in this wallet as the shop's "List an NFT" picker needs it: read
/// from Core, which is where the wallet's own NFTs and their media are.
class P2pOwnedNft {
  final String id;
  final String name;

  /// The account that owns it now.
  final String owner;

  /// Whether its mint is on chain.
  final bool isMinted;

  /// False for a token or a vBTC vault, which no shop sells.
  final bool isSellable;

  /// The contract's royalty, or null.
  final P2pRoyalty? royalty;

  /// A picture of it on this disk, or null when its media is not a picture.
  final String? imagePath;

  const P2pOwnedNft({
    required this.id,
    required this.name,
    required this.owner,
    this.isMinted = true,
    this.isSellable = true,
    this.royalty,
    this.imagePath,
  });
}
