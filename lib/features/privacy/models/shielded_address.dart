import 'package:freezed_annotation/freezed_annotation.dart';

part 'shielded_address.freezed.dart';
part 'shielded_address.g.dart';

@freezed
class ShieldedAddress with _$ShieldedAddress {
  const ShieldedAddress._();

  factory ShieldedAddress({
    @JsonKey(name: "ZfxAddress") required String zfxAddress,
    @JsonKey(name: "DerivationPath") required String derivationPath,
    @JsonKey(name: "CoinType") @Default(889) int coinType,
    @JsonKey(name: "AddressIndex") @Default(0) int addressIndex,
  }) = _ShieldedAddress;

  factory ShieldedAddress.fromJson(Map<String, dynamic> json) => _$ShieldedAddressFromJson(json);
}
