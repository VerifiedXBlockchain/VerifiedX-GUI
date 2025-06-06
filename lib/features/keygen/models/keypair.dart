import 'package:freezed_annotation/freezed_annotation.dart';

part 'keypair.freezed.dart';
part 'keypair.g.dart';

@freezed
abstract class Keypair with _$Keypair {
  const Keypair._();

  factory Keypair({
    required String private,
    required String address,
    required String public,
    String? email,
    // @JsonKey(toJson: null) ECPrivateKey? ecPrivateKey,
    String? mneumonic,
    String? btcWif,
  }) = _Keypair;

  factory Keypair.fromJson(Map<String, dynamic> json) => _$KeypairFromJson(json);

  String get privateCorrected {
    if (private.startsWith("00")) {
      return private;
    }

    return "00$private";
  }
}
