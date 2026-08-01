import 'package:freezed_annotation/freezed_annotation.dart';

import '../../nft/models/web_nft.dart';

part 'btc_web_vbtc_token.freezed.dart';
part 'btc_web_vbtc_token.g.dart';

/// Withdrawal request statuses that still need completing. The API has used
/// both spellings, and treating only one as resumable strands the other in a
/// state where the UI offers a fresh request instead of finishing the existing
/// one.
const kResumableWithdrawalStatuses = {'pending', 'requested'};

bool withdrawalIsResumable(Map<String, dynamic> withdrawalRequest) =>
    kResumableWithdrawalStatuses.contains(withdrawalRequest['status']);

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

  List<Map<String, dynamic>> get resumableWithdrawalRequests =>
      (withdrawalRequests ?? []).where(withdrawalIsResumable).toList();

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
