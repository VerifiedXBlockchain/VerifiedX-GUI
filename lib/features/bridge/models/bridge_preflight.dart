import 'package:freezed_annotation/freezed_annotation.dart';

part 'bridge_preflight.freezed.dart';
part 'bridge_preflight.g.dart';

/// Preflight info for the vBTC → Base bridge.
///
/// Mirrors the response from
/// `GET /wallet/api/vbtc/bridge/preflight/{ownerAddress}/{scUID}`
/// served by `WalletController.VBTCBridgePreflight` (lowercase JSON keys).
@freezed
class BridgePreflight with _$BridgePreflight {
  const BridgePreflight._();

  factory BridgePreflight({
    @JsonKey(name: "success") @Default(false) bool success,
    @JsonKey(name: "message") String? message,
    // VFX side
    @JsonKey(name: "ownerAddress") @Default("") String ownerAddress,
    @JsonKey(name: "scUID") @Default("") String scUid,
    @JsonKey(name: "availableVbtc") @Default(0.0) double availableVbtc,
    @JsonKey(name: "vbtcError") String? vbtcError,
    // Derived Base address
    @JsonKey(name: "derivedBaseAddress") @Default("") String derivedBaseAddress,
    @JsonKey(name: "hasDerivedAddress") @Default(false) bool hasDerivedAddress,
    // Base balances
    @JsonKey(name: "ethBalance") double? ethBalance,
    @JsonKey(name: "ethError") String? ethError,
    @JsonKey(name: "vbtcBBalance") double? vbtcBBalance,
    @JsonKey(name: "vbtcBError") String? vbtcBError,
    // Config / network
    @JsonKey(name: "bridgeConfigured") @Default(false) bool bridgeConfigured,
    @JsonKey(name: "canReadEth") @Default(false) bool canReadEth,
    @JsonKey(name: "canReadVbtc") @Default(false) bool canReadVbtc,
    @JsonKey(name: "networkName") String? networkName,
    @JsonKey(name: "chainId") int? chainId,
    @JsonKey(name: "contractAddress") String? contractAddress,
  }) = _BridgePreflight;

  factory BridgePreflight.fromJson(Map<String, dynamic> json) =>
      _$BridgePreflightFromJson(json);

  /// True when the user has no vBTC to bridge.
  bool get hasNoVbtc => availableVbtc <= 0;

  /// True when the derived Base address has less ETH than the warning threshold.
  /// Returns false when ETH balance is unknown (don't warn on missing data).
  bool isLowOnGas(double minEth) {
    final eth = ethBalance;
    if (eth == null) return false;
    return eth < minEth;
  }
}
