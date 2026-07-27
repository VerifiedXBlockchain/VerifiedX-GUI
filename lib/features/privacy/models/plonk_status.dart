import 'package:freezed_annotation/freezed_annotation.dart';

part 'plonk_status.freezed.dart';
part 'plonk_status.g.dart';

@freezed
class PlonkStatus with _$PlonkStatus {
  const PlonkStatus._();

  factory PlonkStatus({
    @JsonKey(name: "ProofProvingImplemented") @Default(false) bool proofProvingImplemented,
    @JsonKey(name: "ProofVerificationImplemented") @Default(false) bool proofVerificationImplemented,
    @JsonKey(name: "EnforcePlonkProofsForZk") @Default(false) bool enforcePlonkProofsForZk,
    @JsonKey(name: "CapVerifyV1") @Default(false) bool capVerifyV1,
    @JsonKey(name: "CapProveV1") @Default(false) bool capProveV1,
  }) = _PlonkStatus;

  factory PlonkStatus.fromJson(Map<String, dynamic> json) => _$PlonkStatusFromJson(json);

  bool get isPrivacyEnabled => proofProvingImplemented && proofVerificationImplemented;
}
