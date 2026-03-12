// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mpc_ceremony.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

MpcCeremony _$MpcCeremonyFromJson(Map<String, dynamic> json) {
  return _MpcCeremony.fromJson(json);
}

/// @nodoc
mixin _$MpcCeremony {
  @JsonKey(name: "CeremonyId")
  String get ceremonyId => throw _privateConstructorUsedError;
  @JsonKey(name: "Status", fromJson: mpcCeremonyStatusFromString)
  MpcCeremonyStatus get status => throw _privateConstructorUsedError;
  @JsonKey(name: "ProgressPercentage")
  int get progressPercentage => throw _privateConstructorUsedError;
  @JsonKey(name: "DepositAddress")
  String? get depositAddress => throw _privateConstructorUsedError;
  @JsonKey(name: "FrostGroupPublicKey")
  String? get frostGroupPublicKey => throw _privateConstructorUsedError;
  @JsonKey(name: "DkgProof")
  String? get dkgProof => throw _privateConstructorUsedError;
  @JsonKey(name: "ValidatorCount")
  int? get validatorCount => throw _privateConstructorUsedError;
  @JsonKey(name: "RequiredThreshold")
  int? get requiredThreshold => throw _privateConstructorUsedError;
  @JsonKey(name: "ProofBlockHeight")
  int? get proofBlockHeight => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MpcCeremonyCopyWith<MpcCeremony> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MpcCeremonyCopyWith<$Res> {
  factory $MpcCeremonyCopyWith(
          MpcCeremony value, $Res Function(MpcCeremony) then) =
      _$MpcCeremonyCopyWithImpl<$Res, MpcCeremony>;
  @useResult
  $Res call(
      {@JsonKey(name: "CeremonyId")
          String ceremonyId,
      @JsonKey(name: "Status", fromJson: mpcCeremonyStatusFromString)
          MpcCeremonyStatus status,
      @JsonKey(name: "ProgressPercentage")
          int progressPercentage,
      @JsonKey(name: "DepositAddress")
          String? depositAddress,
      @JsonKey(name: "FrostGroupPublicKey")
          String? frostGroupPublicKey,
      @JsonKey(name: "DkgProof")
          String? dkgProof,
      @JsonKey(name: "ValidatorCount")
          int? validatorCount,
      @JsonKey(name: "RequiredThreshold")
          int? requiredThreshold,
      @JsonKey(name: "ProofBlockHeight")
          int? proofBlockHeight});
}

/// @nodoc
class _$MpcCeremonyCopyWithImpl<$Res, $Val extends MpcCeremony>
    implements $MpcCeremonyCopyWith<$Res> {
  _$MpcCeremonyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ceremonyId = null,
    Object? status = null,
    Object? progressPercentage = null,
    Object? depositAddress = freezed,
    Object? frostGroupPublicKey = freezed,
    Object? dkgProof = freezed,
    Object? validatorCount = freezed,
    Object? requiredThreshold = freezed,
    Object? proofBlockHeight = freezed,
  }) {
    return _then(_value.copyWith(
      ceremonyId: null == ceremonyId
          ? _value.ceremonyId
          : ceremonyId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MpcCeremonyStatus,
      progressPercentage: null == progressPercentage
          ? _value.progressPercentage
          : progressPercentage // ignore: cast_nullable_to_non_nullable
              as int,
      depositAddress: freezed == depositAddress
          ? _value.depositAddress
          : depositAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      frostGroupPublicKey: freezed == frostGroupPublicKey
          ? _value.frostGroupPublicKey
          : frostGroupPublicKey // ignore: cast_nullable_to_non_nullable
              as String?,
      dkgProof: freezed == dkgProof
          ? _value.dkgProof
          : dkgProof // ignore: cast_nullable_to_non_nullable
              as String?,
      validatorCount: freezed == validatorCount
          ? _value.validatorCount
          : validatorCount // ignore: cast_nullable_to_non_nullable
              as int?,
      requiredThreshold: freezed == requiredThreshold
          ? _value.requiredThreshold
          : requiredThreshold // ignore: cast_nullable_to_non_nullable
              as int?,
      proofBlockHeight: freezed == proofBlockHeight
          ? _value.proofBlockHeight
          : proofBlockHeight // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_MpcCeremonyCopyWith<$Res>
    implements $MpcCeremonyCopyWith<$Res> {
  factory _$$_MpcCeremonyCopyWith(
          _$_MpcCeremony value, $Res Function(_$_MpcCeremony) then) =
      __$$_MpcCeremonyCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "CeremonyId")
          String ceremonyId,
      @JsonKey(name: "Status", fromJson: mpcCeremonyStatusFromString)
          MpcCeremonyStatus status,
      @JsonKey(name: "ProgressPercentage")
          int progressPercentage,
      @JsonKey(name: "DepositAddress")
          String? depositAddress,
      @JsonKey(name: "FrostGroupPublicKey")
          String? frostGroupPublicKey,
      @JsonKey(name: "DkgProof")
          String? dkgProof,
      @JsonKey(name: "ValidatorCount")
          int? validatorCount,
      @JsonKey(name: "RequiredThreshold")
          int? requiredThreshold,
      @JsonKey(name: "ProofBlockHeight")
          int? proofBlockHeight});
}

/// @nodoc
class __$$_MpcCeremonyCopyWithImpl<$Res>
    extends _$MpcCeremonyCopyWithImpl<$Res, _$_MpcCeremony>
    implements _$$_MpcCeremonyCopyWith<$Res> {
  __$$_MpcCeremonyCopyWithImpl(
      _$_MpcCeremony _value, $Res Function(_$_MpcCeremony) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ceremonyId = null,
    Object? status = null,
    Object? progressPercentage = null,
    Object? depositAddress = freezed,
    Object? frostGroupPublicKey = freezed,
    Object? dkgProof = freezed,
    Object? validatorCount = freezed,
    Object? requiredThreshold = freezed,
    Object? proofBlockHeight = freezed,
  }) {
    return _then(_$_MpcCeremony(
      ceremonyId: null == ceremonyId
          ? _value.ceremonyId
          : ceremonyId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MpcCeremonyStatus,
      progressPercentage: null == progressPercentage
          ? _value.progressPercentage
          : progressPercentage // ignore: cast_nullable_to_non_nullable
              as int,
      depositAddress: freezed == depositAddress
          ? _value.depositAddress
          : depositAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      frostGroupPublicKey: freezed == frostGroupPublicKey
          ? _value.frostGroupPublicKey
          : frostGroupPublicKey // ignore: cast_nullable_to_non_nullable
              as String?,
      dkgProof: freezed == dkgProof
          ? _value.dkgProof
          : dkgProof // ignore: cast_nullable_to_non_nullable
              as String?,
      validatorCount: freezed == validatorCount
          ? _value.validatorCount
          : validatorCount // ignore: cast_nullable_to_non_nullable
              as int?,
      requiredThreshold: freezed == requiredThreshold
          ? _value.requiredThreshold
          : requiredThreshold // ignore: cast_nullable_to_non_nullable
              as int?,
      proofBlockHeight: freezed == proofBlockHeight
          ? _value.proofBlockHeight
          : proofBlockHeight // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_MpcCeremony extends _MpcCeremony {
  _$_MpcCeremony(
      {@JsonKey(name: "CeremonyId")
          required this.ceremonyId,
      @JsonKey(name: "Status", fromJson: mpcCeremonyStatusFromString)
          required this.status,
      @JsonKey(name: "ProgressPercentage")
          this.progressPercentage = 0,
      @JsonKey(name: "DepositAddress")
          this.depositAddress,
      @JsonKey(name: "FrostGroupPublicKey")
          this.frostGroupPublicKey,
      @JsonKey(name: "DkgProof")
          this.dkgProof,
      @JsonKey(name: "ValidatorCount")
          this.validatorCount,
      @JsonKey(name: "RequiredThreshold")
          this.requiredThreshold,
      @JsonKey(name: "ProofBlockHeight")
          this.proofBlockHeight})
      : super._();

  factory _$_MpcCeremony.fromJson(Map<String, dynamic> json) =>
      _$$_MpcCeremonyFromJson(json);

  @override
  @JsonKey(name: "CeremonyId")
  final String ceremonyId;
  @override
  @JsonKey(name: "Status", fromJson: mpcCeremonyStatusFromString)
  final MpcCeremonyStatus status;
  @override
  @JsonKey(name: "ProgressPercentage")
  final int progressPercentage;
  @override
  @JsonKey(name: "DepositAddress")
  final String? depositAddress;
  @override
  @JsonKey(name: "FrostGroupPublicKey")
  final String? frostGroupPublicKey;
  @override
  @JsonKey(name: "DkgProof")
  final String? dkgProof;
  @override
  @JsonKey(name: "ValidatorCount")
  final int? validatorCount;
  @override
  @JsonKey(name: "RequiredThreshold")
  final int? requiredThreshold;
  @override
  @JsonKey(name: "ProofBlockHeight")
  final int? proofBlockHeight;

  @override
  String toString() {
    return 'MpcCeremony(ceremonyId: $ceremonyId, status: $status, progressPercentage: $progressPercentage, depositAddress: $depositAddress, frostGroupPublicKey: $frostGroupPublicKey, dkgProof: $dkgProof, validatorCount: $validatorCount, requiredThreshold: $requiredThreshold, proofBlockHeight: $proofBlockHeight)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_MpcCeremony &&
            (identical(other.ceremonyId, ceremonyId) ||
                other.ceremonyId == ceremonyId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.progressPercentage, progressPercentage) ||
                other.progressPercentage == progressPercentage) &&
            (identical(other.depositAddress, depositAddress) ||
                other.depositAddress == depositAddress) &&
            (identical(other.frostGroupPublicKey, frostGroupPublicKey) ||
                other.frostGroupPublicKey == frostGroupPublicKey) &&
            (identical(other.dkgProof, dkgProof) ||
                other.dkgProof == dkgProof) &&
            (identical(other.validatorCount, validatorCount) ||
                other.validatorCount == validatorCount) &&
            (identical(other.requiredThreshold, requiredThreshold) ||
                other.requiredThreshold == requiredThreshold) &&
            (identical(other.proofBlockHeight, proofBlockHeight) ||
                other.proofBlockHeight == proofBlockHeight));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      ceremonyId,
      status,
      progressPercentage,
      depositAddress,
      frostGroupPublicKey,
      dkgProof,
      validatorCount,
      requiredThreshold,
      proofBlockHeight);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_MpcCeremonyCopyWith<_$_MpcCeremony> get copyWith =>
      __$$_MpcCeremonyCopyWithImpl<_$_MpcCeremony>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_MpcCeremonyToJson(
      this,
    );
  }
}

abstract class _MpcCeremony extends MpcCeremony {
  factory _MpcCeremony(
      {@JsonKey(name: "CeremonyId")
          required final String ceremonyId,
      @JsonKey(name: "Status", fromJson: mpcCeremonyStatusFromString)
          required final MpcCeremonyStatus status,
      @JsonKey(name: "ProgressPercentage")
          final int progressPercentage,
      @JsonKey(name: "DepositAddress")
          final String? depositAddress,
      @JsonKey(name: "FrostGroupPublicKey")
          final String? frostGroupPublicKey,
      @JsonKey(name: "DkgProof")
          final String? dkgProof,
      @JsonKey(name: "ValidatorCount")
          final int? validatorCount,
      @JsonKey(name: "RequiredThreshold")
          final int? requiredThreshold,
      @JsonKey(name: "ProofBlockHeight")
          final int? proofBlockHeight}) = _$_MpcCeremony;
  _MpcCeremony._() : super._();

  factory _MpcCeremony.fromJson(Map<String, dynamic> json) =
      _$_MpcCeremony.fromJson;

  @override
  @JsonKey(name: "CeremonyId")
  String get ceremonyId;
  @override
  @JsonKey(name: "Status", fromJson: mpcCeremonyStatusFromString)
  MpcCeremonyStatus get status;
  @override
  @JsonKey(name: "ProgressPercentage")
  int get progressPercentage;
  @override
  @JsonKey(name: "DepositAddress")
  String? get depositAddress;
  @override
  @JsonKey(name: "FrostGroupPublicKey")
  String? get frostGroupPublicKey;
  @override
  @JsonKey(name: "DkgProof")
  String? get dkgProof;
  @override
  @JsonKey(name: "ValidatorCount")
  int? get validatorCount;
  @override
  @JsonKey(name: "RequiredThreshold")
  int? get requiredThreshold;
  @override
  @JsonKey(name: "ProofBlockHeight")
  int? get proofBlockHeight;
  @override
  @JsonKey(ignore: true)
  _$$_MpcCeremonyCopyWith<_$_MpcCeremony> get copyWith =>
      throw _privateConstructorUsedError;
}
