import 'package:freezed_annotation/freezed_annotation.dart';

import '../../nft/models/web_nft.dart';

part 'btc_web_vbtc_token.freezed.dart';
part 'btc_web_vbtc_token.g.dart';

/// Withdrawal request statuses that still need completing.
///
/// These are the explorer's values, not the CLI's: the web wallet reads
/// `withdrawal_requests[].status` off `/btc/vbtc-v2/`, where
/// `VbtcV2WithdrawalRequest.Status` is lowercase snake_case and the full set is
/// `requested`, `pending_btc`, `completed`, `cancellation_requested`,
/// `cancelled`. This mirrors the explorer's own `ACTIVE_STATUSES`.
///
/// `pending_btc` matters most: it is set once FROST has produced a signed
/// Bitcoin transaction, which is exactly the state a user needs to be able to
/// come back and finish. `cancellation_requested` is deliberately absent — a
/// contested withdrawal must not be offered for resuming.
const kResumableWithdrawalStatuses = {'requested', 'pending_btc'};

/// Read case-insensitively so a change of spelling upstream cannot silently
/// make every withdrawal look settled.
bool withdrawalIsResumable(Map<String, dynamic> withdrawalRequest) {
  final status = withdrawalRequest['status'];
  if (status is! String) return false;
  return kResumableWithdrawalStatuses.contains(status.trim().toLowerCase());
}

/// How long before the chain stops treating a request as the contract's active
/// one (VBTCWithdrawalRequest.EXPIRY_BLOCKS = 360, at ~12s blocks ≈ 72 min).
///
/// Judged from `created_at` because the explorer's withdrawal rows carry no
/// block height. Deliberately longer than the real window: being late only
/// means a user waits a little before starting fresh, whereas being early
/// would stop them resuming a request the chain still considers live.
const kWithdrawalStaleAfter = Duration(minutes: 90);

/// True once the chain no longer treats this request as the contract's active
/// one, so the next request simply overwrites it.
///
/// Such a request must not capture the withdraw button. It is not necessarily
/// dead — nothing stops a completion — but the user has to be able to start a
/// new withdrawal instead of being routed forever into resuming one the chain
/// has already moved past.
bool withdrawalIsStale(Map<String, dynamic> withdrawalRequest, {DateTime? now}) {
  final created = withdrawalRequest['created_at'];
  if (created is! String) return false;
  final at = DateTime.tryParse(created);
  if (at == null) return false;
  final reference = now ?? DateTime.now().toUtc();
  return reference.difference(at.toUtc()) > kWithdrawalStaleAfter;
}

@freezed
class BtcWebVbtcToken with _$BtcWebVbtcToken {
  const BtcWebVbtcToken._();

  factory BtcWebVbtcToken({
    required String name,
    required String description,
    required Map<String, dynamic> addresses,
    required String address,
    @JsonKey(name: 'sc_identifier') required String scIdentifier,
    @JsonKey(name: 'owner_address') required String ownerAddress,
    @JsonKey(name: 'image_url') required String imageUrl,
    @JsonKey(name: 'deposit_address') required String depositAddress,
    @JsonKey(name: 'public_key_proofs') String? publicKeyProofs,
    @JsonKey(name: 'global_balance') required double globalBalance,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    required WebNft nft,
    @Default(1) int version,
    @JsonKey(name: 'is_pending_withdrawal') @Default(false) bool isPendingWithdrawal,
    @JsonKey(name: 'frost_group_public_key') String? frostGroupPublicKey,
    @JsonKey(name: 'required_threshold') int? requiredThreshold,
    @JsonKey(name: 'withdrawal_requests') List<Map<String, dynamic>>? withdrawalRequests,
  }) = _BtcWebVbtcToken;

  factory BtcWebVbtcToken.fromJson(Map<String, dynamic> json) => _$BtcWebVbtcTokenFromJson(json);

  /// Outstanding withdrawals that `address` itself requested.
  ///
  /// Scoped to the requestor on purpose. A vBTC contract is shared — every
  /// holder's withdrawals sit in the same list — and completing one signs the
  /// FROST leader auth with whichever wallet is active. The node takes the
  /// coordinator from the stored request's RequestorAddress, so acting on
  /// somebody else's request makes the leader address and the signature
  /// disagree, and every validator rejects the ceremony. It never starts, so
  /// the caller sees a hang rather than an error.
  ///
  /// Returns nothing for a null address: with no wallet to compare against
  /// there is no request this session can safely finish.
  List<Map<String, dynamic>> resumableWithdrawalRequestsFor(String? address) {
    if (address == null || address.isEmpty) return const [];
    return (withdrawalRequests ?? [])
        .where(withdrawalIsResumable)
        .where((w) => w['requestor_address'] == address)
        .toList();
  }

  /// This wallet's outstanding withdrawals that the chain still treats as the
  /// contract's active one, so resuming is the only way forward.
  ///
  /// Once a request goes stale the next one overwrites it, so it must not keep
  /// capturing the withdraw button — otherwise a request that will not finish
  /// leaves the holder unable to start another.
  List<Map<String, dynamic>> liveResumableWithdrawalRequestsFor(String? address, {DateTime? now}) =>
      resumableWithdrawalRequestsFor(address)
          .where((w) => !withdrawalIsStale(w, now: now))
          .toList();

  /// True when `address` has a withdrawal of its own still to finish.
  bool hasResumableWithdrawalFor(String? address) =>
      resumableWithdrawalRequestsFor(address).isNotEmpty;

  double balanceForAddress(String? address) {
    if (address == null) {
      return 0.0;
    }
    if (addresses.containsKey(address)) {
      return addresses[address];
    }

    return 0.0;
  }
}
