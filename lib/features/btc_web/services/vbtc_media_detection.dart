import '../../nft/models/web_nft.dart';

/// Asset names the mint stamps on a vBTC contract that carries no real media.
///
/// A default-asset vBTC v2 contract registers a placeholder so the token has
/// something to render, but no file is ever written to disk or shipped through
/// a beacon. The node reaches the same conclusion from the state trei's
/// MD5List, which lists only `defaultvBTC*` entries for these contracts
/// (MD5Utility.HasMedia).
const _kNoMediaAssetNames = {'vbtc_v2_token'};

/// Prefix of the built-in placeholder images (`defaultvBTC.png`,
/// `defaultvBTC_V2.png`). Matched as a prefix because both spellings exist.
const _kDefaultAssetPrefix = 'defaultvbtc';

/// True when this contract demonstrably has no media file to transfer.
///
/// Deliberately conservative, because the two mistakes are not equal. Deciding
/// "no media" for a contract that HAS a file would skip shipping it and leave
/// the recipient unable to fetch it. Deciding "has media" for one that does not
/// merely keeps today's behaviour. So this returns true only on positive
/// evidence — a zero-size asset AND a recognised placeholder name — and false
/// whenever anything is unclear.
bool vbtcContractHasNoMedia(WebNft? nft) {
  if (nft == null) return false;

  if (nft.primaryAssetSize != 0) return false;

  final name = nft.primaryAssetName.trim().toLowerCase();
  if (name.isEmpty) return false;

  return _kNoMediaAssetNames.contains(name) || name.startsWith(_kDefaultAssetPrefix);
}
