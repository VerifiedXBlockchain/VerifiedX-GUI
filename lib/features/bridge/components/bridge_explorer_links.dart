import '../../../core/env.dart';

/// URL builders for transaction explorer links shown across the bridge flow.
///
/// VFX side uses Spyglass (the project's normal block explorer), Base side
/// uses Basescan. Both have testnet variants that match the project's
/// `Env.isTestNet` flag.
class BridgeExplorerLinks {
  BridgeExplorerLinks._();

  /// VFX block explorer URL for a transaction hash.
  static String vfxTx(String txHash) {
    return "${Env.explorerWebsiteBaseUrl}/transaction/$txHash";
  }

  /// Basescan URL for an EVM transaction hash. Falls back to the Base Sepolia
  /// explorer when running against testnet.
  static String baseTx(String txHash) {
    final root = Env.isTestNet
        ? "https://sepolia.basescan.org"
        : "https://basescan.org";
    return "$root/tx/$txHash";
  }

  /// Basescan URL for an EVM address (used on the result screen so users can
  /// land on their Base address after a successful bridge).
  static String baseAddress(String address) {
    final root = Env.isTestNet
        ? "https://sepolia.basescan.org"
        : "https://basescan.org";
    return "$root/address/$address";
  }
}
