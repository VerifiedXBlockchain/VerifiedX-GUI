// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shielded_commitment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ShieldedCommitment _$ShieldedCommitmentFromJson(Map<String, dynamic> json) {
  return _ShieldedCommitment.fromJson(json);
}

/// @nodoc
mixin _$ShieldedCommitment {
  @JsonKey(name: "Commitment")
  String get commitment => throw _privateConstructorUsedError;
  @JsonKey(name: "AssetType")
  String get assetType => throw _privateConstructorUsedError;
  @JsonKey(name: "Amount")
  double get amount => throw _privateConstructorUsedError;
  @JsonKey(name: "TreePosition")
  int get treePosition => throw _privateConstructorUsedError;
  @JsonKey(name: "BlockHeight")
  int get blockHeight => throw _privateConstructorUsedError;
  @JsonKey(name: "IsSpent")
  bool get isSpent => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ShieldedCommitmentCopyWith<ShieldedCommitment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShieldedCommitmentCopyWith<$Res> {
  factory $ShieldedCommitmentCopyWith(
          ShieldedCommitment value, $Res Function(ShieldedCommitment) then) =
      _$ShieldedCommitmentCopyWithImpl<$Res, ShieldedCommitment>;
  @useResult
  $Res call(
      {@JsonKey(name: "Commitment") String commitment,
      @JsonKey(name: "AssetType") String assetType,
      @JsonKey(name: "Amount") double amount,
      @JsonKey(name: "TreePosition") int treePosition,
      @JsonKey(name: "BlockHeight") int blockHeight,
      @JsonKey(name: "IsSpent") bool isSpent});
}

/// @nodoc
class _$ShieldedCommitmentCopyWithImpl<$Res, $Val extends ShieldedCommitment>
    implements $ShieldedCommitmentCopyWith<$Res> {
  _$ShieldedCommitmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? commitment = null,
    Object? assetType = null,
    Object? amount = null,
    Object? treePosition = null,
    Object? blockHeight = null,
    Object? isSpent = null,
  }) {
    return _then(_value.copyWith(
      commitment: null == commitment
          ? _value.commitment
          : commitment // ignore: cast_nullable_to_non_nullable
              as String,
      assetType: null == assetType
          ? _value.assetType
          : assetType // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      treePosition: null == treePosition
          ? _value.treePosition
          : treePosition // ignore: cast_nullable_to_non_nullable
              as int,
      blockHeight: null == blockHeight
          ? _value.blockHeight
          : blockHeight // ignore: cast_nullable_to_non_nullable
              as int,
      isSpent: null == isSpent
          ? _value.isSpent
          : isSpent // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ShieldedCommitmentCopyWith<$Res>
    implements $ShieldedCommitmentCopyWith<$Res> {
  factory _$$_ShieldedCommitmentCopyWith(_$_ShieldedCommitment value,
          $Res Function(_$_ShieldedCommitment) then) =
      __$$_ShieldedCommitmentCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "Commitment") String commitment,
      @JsonKey(name: "AssetType") String assetType,
      @JsonKey(name: "Amount") double amount,
      @JsonKey(name: "TreePosition") int treePosition,
      @JsonKey(name: "BlockHeight") int blockHeight,
      @JsonKey(name: "IsSpent") bool isSpent});
}

/// @nodoc
class __$$_ShieldedCommitmentCopyWithImpl<$Res>
    extends _$ShieldedCommitmentCopyWithImpl<$Res, _$_ShieldedCommitment>
    implements _$$_ShieldedCommitmentCopyWith<$Res> {
  __$$_ShieldedCommitmentCopyWithImpl(
      _$_ShieldedCommitment _value, $Res Function(_$_ShieldedCommitment) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? commitment = null,
    Object? assetType = null,
    Object? amount = null,
    Object? treePosition = null,
    Object? blockHeight = null,
    Object? isSpent = null,
  }) {
    return _then(_$_ShieldedCommitment(
      commitment: null == commitment
          ? _value.commitment
          : commitment // ignore: cast_nullable_to_non_nullable
              as String,
      assetType: null == assetType
          ? _value.assetType
          : assetType // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      treePosition: null == treePosition
          ? _value.treePosition
          : treePosition // ignore: cast_nullable_to_non_nullable
              as int,
      blockHeight: null == blockHeight
          ? _value.blockHeight
          : blockHeight // ignore: cast_nullable_to_non_nullable
              as int,
      isSpent: null == isSpent
          ? _value.isSpent
          : isSpent // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ShieldedCommitment extends _ShieldedCommitment {
  _$_ShieldedCommitment(
      {@JsonKey(name: "Commitment") required this.commitment,
      @JsonKey(name: "AssetType") required this.assetType,
      @JsonKey(name: "Amount") this.amount = 0.0,
      @JsonKey(name: "TreePosition") this.treePosition = 0,
      @JsonKey(name: "BlockHeight") this.blockHeight = 0,
      @JsonKey(name: "IsSpent") this.isSpent = false})
      : super._();

  factory _$_ShieldedCommitment.fromJson(Map<String, dynamic> json) =>
      _$$_ShieldedCommitmentFromJson(json);

  @override
  @JsonKey(name: "Commitment")
  final String commitment;
  @override
  @JsonKey(name: "AssetType")
  final String assetType;
  @override
  @JsonKey(name: "Amount")
  final double amount;
  @override
  @JsonKey(name: "TreePosition")
  final int treePosition;
  @override
  @JsonKey(name: "BlockHeight")
  final int blockHeight;
  @override
  @JsonKey(name: "IsSpent")
  final bool isSpent;

  @override
  String toString() {
    return 'ShieldedCommitment(commitment: $commitment, assetType: $assetType, amount: $amount, treePosition: $treePosition, blockHeight: $blockHeight, isSpent: $isSpent)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ShieldedCommitment &&
            (identical(other.commitment, commitment) ||
                other.commitment == commitment) &&
            (identical(other.assetType, assetType) ||
                other.assetType == assetType) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.treePosition, treePosition) ||
                other.treePosition == treePosition) &&
            (identical(other.blockHeight, blockHeight) ||
                other.blockHeight == blockHeight) &&
            (identical(other.isSpent, isSpent) || other.isSpent == isSpent));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, commitment, assetType, amount,
      treePosition, blockHeight, isSpent);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ShieldedCommitmentCopyWith<_$_ShieldedCommitment> get copyWith =>
      __$$_ShieldedCommitmentCopyWithImpl<_$_ShieldedCommitment>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ShieldedCommitmentToJson(
      this,
    );
  }
}

abstract class _ShieldedCommitment extends ShieldedCommitment {
  factory _ShieldedCommitment(
      {@JsonKey(name: "Commitment") required final String commitment,
      @JsonKey(name: "AssetType") required final String assetType,
      @JsonKey(name: "Amount") final double amount,
      @JsonKey(name: "TreePosition") final int treePosition,
      @JsonKey(name: "BlockHeight") final int blockHeight,
      @JsonKey(name: "IsSpent") final bool isSpent}) = _$_ShieldedCommitment;
  _ShieldedCommitment._() : super._();

  factory _ShieldedCommitment.fromJson(Map<String, dynamic> json) =
      _$_ShieldedCommitment.fromJson;

  @override
  @JsonKey(name: "Commitment")
  String get commitment;
  @override
  @JsonKey(name: "AssetType")
  String get assetType;
  @override
  @JsonKey(name: "Amount")
  double get amount;
  @override
  @JsonKey(name: "TreePosition")
  int get treePosition;
  @override
  @JsonKey(name: "BlockHeight")
  int get blockHeight;
  @override
  @JsonKey(name: "IsSpent")
  bool get isSpent;
  @override
  @JsonKey(ignore: true)
  _$$_ShieldedCommitmentCopyWith<_$_ShieldedCommitment> get copyWith =>
      throw _privateConstructorUsedError;
}
