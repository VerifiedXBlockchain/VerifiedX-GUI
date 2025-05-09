import 'package:freezed_annotation/freezed_annotation.dart';

import '../../nft/models/web_nft.dart';

part 'btc_web_vbtc_token.freezed.dart';
part 'btc_web_vbtc_token.g.dart';

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
    @JsonKey(name: 'public_key_proofs') required String publicKeyProofs,
    @JsonKey(name: 'global_balance') required double globalBalance,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    required WebNft nft,
  }) = _BtcWebVbtcToken;

  factory BtcWebVbtcToken.fromJson(Map<String, dynamic> json) => _$BtcWebVbtcTokenFromJson(json);

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
