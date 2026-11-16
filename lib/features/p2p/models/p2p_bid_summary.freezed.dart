// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'p2p_bid_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

P2pBidSummary _$P2pBidSummaryFromJson(Map<String, dynamic> json) {
  return _P2pBidSummary.fromJson(json);
}

/// @nodoc
mixin _$P2pBidSummary {
  int get id => throw _privateConstructorUsedError;
  String get address =>
      throw _privateConstructorUsedError; // A decimal string with up to 8 places.
  String get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_buy_now')
  bool get isBuyNow => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: P2pBidStatus.unknown)
  P2pBidStatus get status => throw _privateConstructorUsedError;
  DateTime? get at => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $P2pBidSummaryCopyWith<P2pBidSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $P2pBidSummaryCopyWith<$Res> {
  factory $P2pBidSummaryCopyWith(
          P2pBidSummary value, $Res Function(P2pBidSummary) then) =
      _$P2pBidSummaryCopyWithImpl<$Res, P2pBidSummary>;
  @useResult
  $Res call(
      {int id,
      String address,
      String amount,
      @JsonKey(name: 'is_buy_now') bool isBuyNow,
      @JsonKey(unknownEnumValue: P2pBidStatus.unknown) P2pBidStatus status,
      DateTime? at});
}

/// @nodoc
class _$P2pBidSummaryCopyWithImpl<$Res, $Val extends P2pBidSummary>
    implements $P2pBidSummaryCopyWith<$Res> {
  _$P2pBidSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? address = null,
    Object? amount = null,
    Object? isBuyNow = null,
    Object? status = null,
    Object? at = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as String,
      isBuyNow: null == isBuyNow
          ? _value.isBuyNow
          : isBuyNow // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as P2pBidStatus,
      at: freezed == at
          ? _value.at
          : at // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_P2pBidSummaryCopyWith<$Res>
    implements $P2pBidSummaryCopyWith<$Res> {
  factory _$$_P2pBidSummaryCopyWith(
          _$_P2pBidSummary value, $Res Function(_$_P2pBidSummary) then) =
      __$$_P2pBidSummaryCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String address,
      String amount,
      @JsonKey(name: 'is_buy_now') bool isBuyNow,
      @JsonKey(unknownEnumValue: P2pBidStatus.unknown) P2pBidStatus status,
      DateTime? at});
}

/// @nodoc
class __$$_P2pBidSummaryCopyWithImpl<$Res>
    extends _$P2pBidSummaryCopyWithImpl<$Res, _$_P2pBidSummary>
    implements _$$_P2pBidSummaryCopyWith<$Res> {
  __$$_P2pBidSummaryCopyWithImpl(
      _$_P2pBidSummary _value, $Res Function(_$_P2pBidSummary) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? address = null,
    Object? amount = null,
    Object? isBuyNow = null,
    Object? status = null,
    Object? at = freezed,
  }) {
    return _then(_$_P2pBidSummary(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as String,
      isBuyNow: null == isBuyNow
          ? _value.isBuyNow
          : isBuyNow // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as P2pBidStatus,
      at: freezed == at
          ? _value.at
          : at // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_P2pBidSummary extends _P2pBidSummary {
  _$_P2pBidSummary(
      {required this.id,
      required this.address,
      required this.amount,
      @JsonKey(name: 'is_buy_now')
          this.isBuyNow = false,
      @JsonKey(unknownEnumValue: P2pBidStatus.unknown)
          this.status = P2pBidStatus.unknown,
      this.at})
      : super._();

  factory _$_P2pBidSummary.fromJson(Map<String, dynamic> json) =>
      _$$_P2pBidSummaryFromJson(json);

  @override
  final int id;
  @override
  final String address;
// A decimal string with up to 8 places.
  @override
  final String amount;
  @override
  @JsonKey(name: 'is_buy_now')
  final bool isBuyNow;
  @override
  @JsonKey(unknownEnumValue: P2pBidStatus.unknown)
  final P2pBidStatus status;
  @override
  final DateTime? at;

  @override
  String toString() {
    return 'P2pBidSummary(id: $id, address: $address, amount: $amount, isBuyNow: $isBuyNow, status: $status, at: $at)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_P2pBidSummary &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.isBuyNow, isBuyNow) ||
                other.isBuyNow == isBuyNow) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.at, at) || other.at == at));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, address, amount, isBuyNow, status, at);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_P2pBidSummaryCopyWith<_$_P2pBidSummary> get copyWith =>
      __$$_P2pBidSummaryCopyWithImpl<_$_P2pBidSummary>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_P2pBidSummaryToJson(
      this,
    );
  }
}

abstract class _P2pBidSummary extends P2pBidSummary {
  factory _P2pBidSummary(
      {required final int id,
      required final String address,
      required final String amount,
      @JsonKey(name: 'is_buy_now')
          final bool isBuyNow,
      @JsonKey(unknownEnumValue: P2pBidStatus.unknown)
          final P2pBidStatus status,
      final DateTime? at}) = _$_P2pBidSummary;
  _P2pBidSummary._() : super._();

  factory _P2pBidSummary.fromJson(Map<String, dynamic> json) =
      _$_P2pBidSummary.fromJson;

  @override
  int get id;
  @override
  String get address;
  @override // A decimal string with up to 8 places.
  String get amount;
  @override
  @JsonKey(name: 'is_buy_now')
  bool get isBuyNow;
  @override
  @JsonKey(unknownEnumValue: P2pBidStatus.unknown)
  P2pBidStatus get status;
  @override
  DateTime? get at;
  @override
  @JsonKey(ignore: true)
  _$$_P2pBidSummaryCopyWith<_$_P2pBidSummary> get copyWith =>
      throw _privateConstructorUsedError;
}
