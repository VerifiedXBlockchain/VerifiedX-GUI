// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shielded_balance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ShieldedBalance _$ShieldedBalanceFromJson(Map<String, dynamic> json) {
  return _ShieldedBalance.fromJson(json);
}

/// @nodoc
mixin _$ShieldedBalance {
  @JsonKey(name: "ShieldedBalances")
  Map<String, double> get shieldedBalances =>
      throw _privateConstructorUsedError;
  @JsonKey(name: "UnspentCommitments")
  int get unspentCommitments => throw _privateConstructorUsedError;
  @JsonKey(name: "UnspentSum")
  double get unspentSum => throw _privateConstructorUsedError;
  @JsonKey(name: "LastScannedBlock")
  int get lastScannedBlock => throw _privateConstructorUsedError;
  @JsonKey(name: "IsViewOnly")
  bool get isViewOnly => throw _privateConstructorUsedError;
  @JsonKey(name: "Commitments")
  List<ShieldedCommitment>? get commitments =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ShieldedBalanceCopyWith<ShieldedBalance> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShieldedBalanceCopyWith<$Res> {
  factory $ShieldedBalanceCopyWith(
          ShieldedBalance value, $Res Function(ShieldedBalance) then) =
      _$ShieldedBalanceCopyWithImpl<$Res, ShieldedBalance>;
  @useResult
  $Res call(
      {@JsonKey(name: "ShieldedBalances") Map<String, double> shieldedBalances,
      @JsonKey(name: "UnspentCommitments") int unspentCommitments,
      @JsonKey(name: "UnspentSum") double unspentSum,
      @JsonKey(name: "LastScannedBlock") int lastScannedBlock,
      @JsonKey(name: "IsViewOnly") bool isViewOnly,
      @JsonKey(name: "Commitments") List<ShieldedCommitment>? commitments});
}

/// @nodoc
class _$ShieldedBalanceCopyWithImpl<$Res, $Val extends ShieldedBalance>
    implements $ShieldedBalanceCopyWith<$Res> {
  _$ShieldedBalanceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? shieldedBalances = null,
    Object? unspentCommitments = null,
    Object? unspentSum = null,
    Object? lastScannedBlock = null,
    Object? isViewOnly = null,
    Object? commitments = freezed,
  }) {
    return _then(_value.copyWith(
      shieldedBalances: null == shieldedBalances
          ? _value.shieldedBalances
          : shieldedBalances // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      unspentCommitments: null == unspentCommitments
          ? _value.unspentCommitments
          : unspentCommitments // ignore: cast_nullable_to_non_nullable
              as int,
      unspentSum: null == unspentSum
          ? _value.unspentSum
          : unspentSum // ignore: cast_nullable_to_non_nullable
              as double,
      lastScannedBlock: null == lastScannedBlock
          ? _value.lastScannedBlock
          : lastScannedBlock // ignore: cast_nullable_to_non_nullable
              as int,
      isViewOnly: null == isViewOnly
          ? _value.isViewOnly
          : isViewOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      commitments: freezed == commitments
          ? _value.commitments
          : commitments // ignore: cast_nullable_to_non_nullable
              as List<ShieldedCommitment>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ShieldedBalanceCopyWith<$Res>
    implements $ShieldedBalanceCopyWith<$Res> {
  factory _$$_ShieldedBalanceCopyWith(
          _$_ShieldedBalance value, $Res Function(_$_ShieldedBalance) then) =
      __$$_ShieldedBalanceCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "ShieldedBalances") Map<String, double> shieldedBalances,
      @JsonKey(name: "UnspentCommitments") int unspentCommitments,
      @JsonKey(name: "UnspentSum") double unspentSum,
      @JsonKey(name: "LastScannedBlock") int lastScannedBlock,
      @JsonKey(name: "IsViewOnly") bool isViewOnly,
      @JsonKey(name: "Commitments") List<ShieldedCommitment>? commitments});
}

/// @nodoc
class __$$_ShieldedBalanceCopyWithImpl<$Res>
    extends _$ShieldedBalanceCopyWithImpl<$Res, _$_ShieldedBalance>
    implements _$$_ShieldedBalanceCopyWith<$Res> {
  __$$_ShieldedBalanceCopyWithImpl(
      _$_ShieldedBalance _value, $Res Function(_$_ShieldedBalance) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? shieldedBalances = null,
    Object? unspentCommitments = null,
    Object? unspentSum = null,
    Object? lastScannedBlock = null,
    Object? isViewOnly = null,
    Object? commitments = freezed,
  }) {
    return _then(_$_ShieldedBalance(
      shieldedBalances: null == shieldedBalances
          ? _value._shieldedBalances
          : shieldedBalances // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      unspentCommitments: null == unspentCommitments
          ? _value.unspentCommitments
          : unspentCommitments // ignore: cast_nullable_to_non_nullable
              as int,
      unspentSum: null == unspentSum
          ? _value.unspentSum
          : unspentSum // ignore: cast_nullable_to_non_nullable
              as double,
      lastScannedBlock: null == lastScannedBlock
          ? _value.lastScannedBlock
          : lastScannedBlock // ignore: cast_nullable_to_non_nullable
              as int,
      isViewOnly: null == isViewOnly
          ? _value.isViewOnly
          : isViewOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      commitments: freezed == commitments
          ? _value._commitments
          : commitments // ignore: cast_nullable_to_non_nullable
              as List<ShieldedCommitment>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ShieldedBalance extends _ShieldedBalance {
  _$_ShieldedBalance(
      {@JsonKey(name: "ShieldedBalances")
          final Map<String, double> shieldedBalances = const {},
      @JsonKey(name: "UnspentCommitments")
          this.unspentCommitments = 0,
      @JsonKey(name: "UnspentSum")
          this.unspentSum = 0.0,
      @JsonKey(name: "LastScannedBlock")
          this.lastScannedBlock = 0,
      @JsonKey(name: "IsViewOnly")
          this.isViewOnly = false,
      @JsonKey(name: "Commitments")
          final List<ShieldedCommitment>? commitments})
      : _shieldedBalances = shieldedBalances,
        _commitments = commitments,
        super._();

  factory _$_ShieldedBalance.fromJson(Map<String, dynamic> json) =>
      _$$_ShieldedBalanceFromJson(json);

  final Map<String, double> _shieldedBalances;
  @override
  @JsonKey(name: "ShieldedBalances")
  Map<String, double> get shieldedBalances {
    if (_shieldedBalances is EqualUnmodifiableMapView) return _shieldedBalances;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_shieldedBalances);
  }

  @override
  @JsonKey(name: "UnspentCommitments")
  final int unspentCommitments;
  @override
  @JsonKey(name: "UnspentSum")
  final double unspentSum;
  @override
  @JsonKey(name: "LastScannedBlock")
  final int lastScannedBlock;
  @override
  @JsonKey(name: "IsViewOnly")
  final bool isViewOnly;
  final List<ShieldedCommitment>? _commitments;
  @override
  @JsonKey(name: "Commitments")
  List<ShieldedCommitment>? get commitments {
    final value = _commitments;
    if (value == null) return null;
    if (_commitments is EqualUnmodifiableListView) return _commitments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'ShieldedBalance(shieldedBalances: $shieldedBalances, unspentCommitments: $unspentCommitments, unspentSum: $unspentSum, lastScannedBlock: $lastScannedBlock, isViewOnly: $isViewOnly, commitments: $commitments)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ShieldedBalance &&
            const DeepCollectionEquality()
                .equals(other._shieldedBalances, _shieldedBalances) &&
            (identical(other.unspentCommitments, unspentCommitments) ||
                other.unspentCommitments == unspentCommitments) &&
            (identical(other.unspentSum, unspentSum) ||
                other.unspentSum == unspentSum) &&
            (identical(other.lastScannedBlock, lastScannedBlock) ||
                other.lastScannedBlock == lastScannedBlock) &&
            (identical(other.isViewOnly, isViewOnly) ||
                other.isViewOnly == isViewOnly) &&
            const DeepCollectionEquality()
                .equals(other._commitments, _commitments));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_shieldedBalances),
      unspentCommitments,
      unspentSum,
      lastScannedBlock,
      isViewOnly,
      const DeepCollectionEquality().hash(_commitments));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ShieldedBalanceCopyWith<_$_ShieldedBalance> get copyWith =>
      __$$_ShieldedBalanceCopyWithImpl<_$_ShieldedBalance>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ShieldedBalanceToJson(
      this,
    );
  }
}

abstract class _ShieldedBalance extends ShieldedBalance {
  factory _ShieldedBalance(
      {@JsonKey(name: "ShieldedBalances")
          final Map<String, double> shieldedBalances,
      @JsonKey(name: "UnspentCommitments")
          final int unspentCommitments,
      @JsonKey(name: "UnspentSum")
          final double unspentSum,
      @JsonKey(name: "LastScannedBlock")
          final int lastScannedBlock,
      @JsonKey(name: "IsViewOnly")
          final bool isViewOnly,
      @JsonKey(name: "Commitments")
          final List<ShieldedCommitment>? commitments}) = _$_ShieldedBalance;
  _ShieldedBalance._() : super._();

  factory _ShieldedBalance.fromJson(Map<String, dynamic> json) =
      _$_ShieldedBalance.fromJson;

  @override
  @JsonKey(name: "ShieldedBalances")
  Map<String, double> get shieldedBalances;
  @override
  @JsonKey(name: "UnspentCommitments")
  int get unspentCommitments;
  @override
  @JsonKey(name: "UnspentSum")
  double get unspentSum;
  @override
  @JsonKey(name: "LastScannedBlock")
  int get lastScannedBlock;
  @override
  @JsonKey(name: "IsViewOnly")
  bool get isViewOnly;
  @override
  @JsonKey(name: "Commitments")
  List<ShieldedCommitment>? get commitments;
  @override
  @JsonKey(ignore: true)
  _$$_ShieldedBalanceCopyWith<_$_ShieldedBalance> get copyWith =>
      throw _privateConstructorUsedError;
}
