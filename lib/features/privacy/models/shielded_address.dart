import 'package:freezed_annotation/freezed_annotation.dart';

part 'shielded_address.freezed.dart';
part 'shielded_address.g.dart';

@freezed
class ShieldedAddress with _$ShieldedAddress {
  const ShieldedAddress._();

  factory ShieldedAddress({
    @JsonKey(name: "ZfxAddress") required String zfxAddress,
    @JsonKey(name: "TransparentSourceAddress") @Default("") String transparentSourceAddress,
  }) = _ShieldedAddress;

  factory ShieldedAddress.fromJson(Map<String, dynamic> json) => _$ShieldedAddressFromJson(json);
}
