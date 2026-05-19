import 'package:freezed_annotation/freezed_annotation.dart';

part 'bridge_lock_record.freezed.dart';
part 'bridge_lock_record.g.dart';

/// Status values mirroring `BridgeLockStatus` on the CLI
/// (`ReserveBlockCore.Bitcoin.Models.BridgeLockRecord`).
///
/// The CLI serializes these as their enum name (e.g. "Locked", "Minted").
enum BridgeLockStatus {
  locked,
  proofSubmitted,
  minted,
  redeeming,
  redeemed,
  unlocked,
  failed,
  attestationPending,
  attestationReady,
  mintedOnBase,
  exitBurned,
  unlockedOnVFX,
  btcExitBurned,
  btcExitSigning,
  btcExitBroadcast,
  btcExitComplete,
  expired,
  unknown,
}

/// Maps the CLI's string status to a [BridgeLockStatus]. Falls back to
/// [BridgeLockStatus.unknown] for forward-compatibility if the CLI adds new
/// states we haven't surfaced yet.
BridgeLockStatus bridgeLockStatusFromString(String? raw) {
  switch (raw) {
    case 'Locked':
      return BridgeLockStatus.locked;
    case 'ProofSubmitted':
      return BridgeLockStatus.proofSubmitted;
    case 'Minted':
      return BridgeLockStatus.minted;
    case 'Redeeming':
      return BridgeLockStatus.redeeming;
    case 'Redeemed':
      return BridgeLockStatus.redeemed;
    case 'Unlocked':
      return BridgeLockStatus.unlocked;
    case 'Failed':
      return BridgeLockStatus.failed;
    case 'AttestationPending':
      return BridgeLockStatus.attestationPending;
    case 'AttestationReady':
      return BridgeLockStatus.attestationReady;
    case 'MintedOnBase':
      return BridgeLockStatus.mintedOnBase;
    case 'ExitBurned':
      return BridgeLockStatus.exitBurned;
    case 'UnlockedOnVFX':
      return BridgeLockStatus.unlockedOnVFX;
    case 'BTCExitBurned':
      return BridgeLockStatus.btcExitBurned;
    case 'BTCExitSigning':
      return BridgeLockStatus.btcExitSigning;
    case 'BTCExitBroadcast':
      return BridgeLockStatus.btcExitBroadcast;
    case 'BTCExitComplete':
      return BridgeLockStatus.btcExitComplete;
    case 'Expired':
      return BridgeLockStatus.expired;
    default:
      return BridgeLockStatus.unknown;
  }
}

/// Full state-machine record for a bridge lock, mirroring
/// `BridgeLockRecord` on the CLI.
///
/// Sources:
/// - `GET /wallet/api/vbtc/bridge/status/{lockId}` (lowercase keys via
///   anonymous projection in `WalletVbtcService.GetBridgeLockStatus`)
/// - `GET /vbtcapi/vbtc/GetBridgeLocksByOwner/{owner}` (CapitalCase keys —
///   raw `BridgeLockRecord` instances inside a `Locks` array)
///
/// Callers should normalize the casing before constructing this model.
/// See [BridgeLockRecord.fromUnifiedJson].
@freezed
class BridgeLockRecord with _$BridgeLockRecord {
  const BridgeLockRecord._();

  factory BridgeLockRecord({
    @JsonKey(name: "lockId") @Default("") String lockId,
    @JsonKey(name: "scUID") @Default("") String scUid,
    @JsonKey(name: "ownerAddress") @Default("") String ownerAddress,
    @JsonKey(name: "amount") @Default(0.0) double amount,
    @JsonKey(name: "amountSats") @Default(0) int amountSats,
    @JsonKey(name: "evmDestination") @Default("") String evmDestination,
    @JsonKey(name: "status") String? statusRaw,
    @JsonKey(name: "vfxLockTxHash") String? vfxLockTxHash,
    @JsonKey(name: "vfxLockConfirmedOnChain")
    @Default(false)
    bool vfxLockConfirmedOnChain,
    @JsonKey(name: "vfxLockBlockHeight") @Default(0) int vfxLockBlockHeight,
    @JsonKey(name: "baseTxHash") String? baseTxHash,
    @JsonKey(name: "exitBurnTxHash") String? exitBurnTxHash,
    @JsonKey(name: "signaturesCollected") @Default(0) int signaturesCollected,
    @JsonKey(name: "requiredSignatures") @Default(0) int requiredSignatures,
    @JsonKey(name: "mintNonce") @Default(0) int mintNonce,
    @JsonKey(name: "signatures") Map<String, String>? signatures,
    @JsonKey(name: "createdAtUtc") @Default(0) int createdAtUtc,
    @JsonKey(name: "relayedAtUtc") int? relayedAtUtc,
    @JsonKey(name: "finalizedAtUtc") int? finalizedAtUtc,
    @JsonKey(name: "errorMessage") String? errorMessage,
    @JsonKey(name: "btcExitDestination") String? btcExitDestination,
    @JsonKey(name: "btcExitTxHash") String? btcExitTxHash,
  }) = _BridgeLockRecord;

  factory BridgeLockRecord.fromJson(Map<String, dynamic> json) =>
      _$BridgeLockRecordFromJson(json);

  /// Build a record from either the WalletController response (lowercase keys)
  /// or the raw `BridgeLockRecord` shape returned by VBTCController endpoints
  /// (CapitalCase keys). Falls back to the alternate casing for any key that
  /// isn't present.
  factory BridgeLockRecord.fromUnifiedJson(Map<String, dynamic> raw) {
    // Pick the first non-null value across a list of candidate keys.
    Object? pick(List<String> keys) {
      for (final k in keys) {
        if (raw.containsKey(k) && raw[k] != null) return raw[k];
      }
      return null;
    }

    final signaturesMap = pick(['signatures', 'ValidatorSignatures']);
    final signatureCount = pick(['signaturesCollected']) ??
        ((signaturesMap is Map) ? signaturesMap.length : 0);

    return BridgeLockRecord.fromJson({
      'lockId': pick(['lockId', 'LockId']) ?? '',
      'scUID': pick(['scUID', 'SmartContractUID']) ?? '',
      'ownerAddress': pick(['ownerAddress', 'OwnerAddress']) ?? '',
      'amount': pick(['amount', 'Amount']) ?? 0,
      'amountSats': pick(['amountSats', 'AmountSats']) ?? 0,
      'evmDestination': pick(['evmDestination', 'EvmDestination']) ?? '',
      'status': pick(['status', 'Status']),
      'vfxLockTxHash': pick(['vfxLockTxHash', 'VfxLockTxHash']),
      'vfxLockConfirmedOnChain':
          pick(['vfxLockConfirmedOnChain', 'VfxLockConfirmedOnChain']) ?? false,
      'vfxLockBlockHeight':
          pick(['vfxLockBlockHeight', 'VfxLockBlockHeight']) ?? 0,
      'baseTxHash': pick(['baseTxHash', 'BaseTxHash']),
      'exitBurnTxHash': pick(['exitBurnTxHash', 'ExitBurnTxHash']),
      'signaturesCollected': signatureCount,
      'requiredSignatures':
          pick(['requiredSignatures', 'RequiredSignatures']) ?? 0,
      'mintNonce': pick(['mintNonce', 'MintNonce']) ?? 0,
      'signatures': signaturesMap,
      'createdAtUtc': pick(['createdAtUtc', 'CreatedAtUtc']) ?? 0,
      'relayedAtUtc': pick(['relayedAtUtc', 'RelayedAtUtc']),
      'finalizedAtUtc': pick(['finalizedAtUtc', 'FinalizedAtUtc']),
      'errorMessage': pick(['errorMessage', 'ErrorMessage']),
      'btcExitDestination': pick(['btcExitDestination', 'BtcExitDestination']),
      'btcExitTxHash': pick(['btcExitTxHash', 'BtcExitTxHash']),
    });
  }

  /// Parsed enum for the CLI's string status. Returns
  /// [BridgeLockStatus.unknown] if the value is missing or unrecognized.
  BridgeLockStatus get status => bridgeLockStatusFromString(statusRaw);

  /// True when the bridge is in a terminal state — no further polling needed.
  bool get isTerminal {
    switch (status) {
      case BridgeLockStatus.minted:
      case BridgeLockStatus.mintedOnBase:
      case BridgeLockStatus.failed:
      case BridgeLockStatus.expired:
        return true;
      default:
        return false;
    }
  }

  /// True when the bridge succeeded end-to-end.
  bool get isSuccessful =>
      status == BridgeLockStatus.minted ||
      status == BridgeLockStatus.mintedOnBase;

  /// True when the bridge ended in failure.
  bool get isFailed => status == BridgeLockStatus.failed;

  /// Created-at as a [DateTime], or null if the timestamp is missing.
  DateTime? get createdAt =>
      createdAtUtc > 0 ? DateTime.fromMillisecondsSinceEpoch(createdAtUtc * 1000, isUtc: true) : null;
}
