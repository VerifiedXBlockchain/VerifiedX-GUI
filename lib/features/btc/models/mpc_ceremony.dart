import 'package:freezed_annotation/freezed_annotation.dart';

part 'mpc_ceremony.freezed.dart';
part 'mpc_ceremony.g.dart';

enum MpcCeremonyStatus {
  initiated,
  validatingValidators,
  round1InProgress,
  round2InProgress,
  round3InProgress,
  completed,
  failed,
  timedOut,
}

MpcCeremonyStatus mpcCeremonyStatusFromString(String value) {
  switch (value) {
    case 'Initiated':
      return MpcCeremonyStatus.initiated;
    case 'ValidatingValidators':
      return MpcCeremonyStatus.validatingValidators;
    case 'Round1InProgress':
      return MpcCeremonyStatus.round1InProgress;
    case 'Round2InProgress':
      return MpcCeremonyStatus.round2InProgress;
    case 'Round3InProgress':
      return MpcCeremonyStatus.round3InProgress;
    case 'Completed':
      return MpcCeremonyStatus.completed;
    case 'Failed':
      return MpcCeremonyStatus.failed;
    case 'TimedOut':
      return MpcCeremonyStatus.timedOut;
    default:
      return MpcCeremonyStatus.initiated;
  }
}

@freezed
class MpcCeremony with _$MpcCeremony {
  const MpcCeremony._();

  factory MpcCeremony({
    @JsonKey(name: "CeremonyId") required String ceremonyId,
    @JsonKey(name: "Status", fromJson: mpcCeremonyStatusFromString) required MpcCeremonyStatus status,
    @JsonKey(name: "ProgressPercentage") @Default(0) int progressPercentage,
    @JsonKey(name: "DepositAddress") String? depositAddress,
    @JsonKey(name: "FrostGroupPublicKey") String? frostGroupPublicKey,
    @JsonKey(name: "DkgProof") String? dkgProof,
    @JsonKey(name: "ValidatorCount") int? validatorCount,
    @JsonKey(name: "RequiredThreshold") int? requiredThreshold,
    @JsonKey(name: "ProofBlockHeight") int? proofBlockHeight,
  }) = _MpcCeremony;

  factory MpcCeremony.fromJson(Map<String, dynamic> json) => _$MpcCeremonyFromJson(json);

  bool get isTerminal =>
      status == MpcCeremonyStatus.completed ||
      status == MpcCeremonyStatus.failed ||
      status == MpcCeremonyStatus.timedOut;
}
