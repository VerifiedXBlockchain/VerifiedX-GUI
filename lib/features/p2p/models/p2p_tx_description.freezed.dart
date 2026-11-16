// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'p2p_tx_description.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

P2pTxDescription _$P2pTxDescriptionFromJson(Map<String, dynamic> json) {
  return _P2pTxDescription.fromJson(json);
}

/// @nodoc
mixin _$P2pTxDescription {
// Core's TransactionType: 5 NFT_SALE, 7 DSTR.
  int get type => throw _privateConstructorUsedError;
  String get function => throw _privateConstructorUsedError;
  @JsonKey(name: 'from_address')
  String get fromAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'to_address')
  String get toAddress => throw _privateConstructorUsedError;
  String? get amount => throw _privateConstructorUsedError;
  String? get fee => throw _privateConstructorUsedError; // Unix seconds.
  int? get timestamp => throw _privateConstructorUsedError;
  Map<String, dynamic> get data => throw _privateConstructorUsedError;
  String? get hash => throw _privateConstructorUsedError;
  int? get height => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $P2pTxDescriptionCopyWith<P2pTxDescription> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $P2pTxDescriptionCopyWith<$Res> {
  factory $P2pTxDescriptionCopyWith(
          P2pTxDescription value, $Res Function(P2pTxDescription) then) =
      _$P2pTxDescriptionCopyWithImpl<$Res, P2pTxDescription>;
  @useResult
  $Res call(
      {int type,
      String function,
      @JsonKey(name: 'from_address') String fromAddress,
      @JsonKey(name: 'to_address') String toAddress,
      String? amount,
      String? fee,
      int? timestamp,
      Map<String, dynamic> data,
      String? hash,
      int? height});
}

/// @nodoc
class _$P2pTxDescriptionCopyWithImpl<$Res, $Val extends P2pTxDescription>
    implements $P2pTxDescriptionCopyWith<$Res> {
  _$P2pTxDescriptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? function = null,
    Object? fromAddress = null,
    Object? toAddress = null,
    Object? amount = freezed,
    Object? fee = freezed,
    Object? timestamp = freezed,
    Object? data = null,
    Object? hash = freezed,
    Object? height = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as int,
      function: null == function
          ? _value.function
          : function // ignore: cast_nullable_to_non_nullable
              as String,
      fromAddress: null == fromAddress
          ? _value.fromAddress
          : fromAddress // ignore: cast_nullable_to_non_nullable
              as String,
      toAddress: null == toAddress
          ? _value.toAddress
          : toAddress // ignore: cast_nullable_to_non_nullable
              as String,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as String?,
      fee: freezed == fee
          ? _value.fee
          : fee // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int?,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      hash: freezed == hash
          ? _value.hash
          : hash // ignore: cast_nullable_to_non_nullable
              as String?,
      height: freezed == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_P2pTxDescriptionCopyWith<$Res>
    implements $P2pTxDescriptionCopyWith<$Res> {
  factory _$$_P2pTxDescriptionCopyWith(
          _$_P2pTxDescription value, $Res Function(_$_P2pTxDescription) then) =
      __$$_P2pTxDescriptionCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int type,
      String function,
      @JsonKey(name: 'from_address') String fromAddress,
      @JsonKey(name: 'to_address') String toAddress,
      String? amount,
      String? fee,
      int? timestamp,
      Map<String, dynamic> data,
      String? hash,
      int? height});
}

/// @nodoc
class __$$_P2pTxDescriptionCopyWithImpl<$Res>
    extends _$P2pTxDescriptionCopyWithImpl<$Res, _$_P2pTxDescription>
    implements _$$_P2pTxDescriptionCopyWith<$Res> {
  __$$_P2pTxDescriptionCopyWithImpl(
      _$_P2pTxDescription _value, $Res Function(_$_P2pTxDescription) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? function = null,
    Object? fromAddress = null,
    Object? toAddress = null,
    Object? amount = freezed,
    Object? fee = freezed,
    Object? timestamp = freezed,
    Object? data = null,
    Object? hash = freezed,
    Object? height = freezed,
  }) {
    return _then(_$_P2pTxDescription(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as int,
      function: null == function
          ? _value.function
          : function // ignore: cast_nullable_to_non_nullable
              as String,
      fromAddress: null == fromAddress
          ? _value.fromAddress
          : fromAddress // ignore: cast_nullable_to_non_nullable
              as String,
      toAddress: null == toAddress
          ? _value.toAddress
          : toAddress // ignore: cast_nullable_to_non_nullable
              as String,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as String?,
      fee: freezed == fee
          ? _value.fee
          : fee // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int?,
      data: null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      hash: freezed == hash
          ? _value.hash
          : hash // ignore: cast_nullable_to_non_nullable
              as String?,
      height: freezed == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_P2pTxDescription extends _P2pTxDescription {
  _$_P2pTxDescription(
      {required this.type,
      required this.function,
      @JsonKey(name: 'from_address') required this.fromAddress,
      @JsonKey(name: 'to_address') required this.toAddress,
      this.amount,
      this.fee,
      this.timestamp,
      final Map<String, dynamic> data = const <String, dynamic>{},
      this.hash,
      this.height})
      : _data = data,
        super._();

  factory _$_P2pTxDescription.fromJson(Map<String, dynamic> json) =>
      _$$_P2pTxDescriptionFromJson(json);

// Core's TransactionType: 5 NFT_SALE, 7 DSTR.
  @override
  final int type;
  @override
  final String function;
  @override
  @JsonKey(name: 'from_address')
  final String fromAddress;
  @override
  @JsonKey(name: 'to_address')
  final String toAddress;
  @override
  final String? amount;
  @override
  final String? fee;
// Unix seconds.
  @override
  final int? timestamp;
  final Map<String, dynamic> _data;
  @override
  @JsonKey()
  Map<String, dynamic> get data {
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_data);
  }

  @override
  final String? hash;
  @override
  final int? height;

  @override
  String toString() {
    return 'P2pTxDescription(type: $type, function: $function, fromAddress: $fromAddress, toAddress: $toAddress, amount: $amount, fee: $fee, timestamp: $timestamp, data: $data, hash: $hash, height: $height)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_P2pTxDescription &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.function, function) ||
                other.function == function) &&
            (identical(other.fromAddress, fromAddress) ||
                other.fromAddress == fromAddress) &&
            (identical(other.toAddress, toAddress) ||
                other.toAddress == toAddress) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.fee, fee) || other.fee == fee) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.hash, hash) || other.hash == hash) &&
            (identical(other.height, height) || other.height == height));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      type,
      function,
      fromAddress,
      toAddress,
      amount,
      fee,
      timestamp,
      const DeepCollectionEquality().hash(_data),
      hash,
      height);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_P2pTxDescriptionCopyWith<_$_P2pTxDescription> get copyWith =>
      __$$_P2pTxDescriptionCopyWithImpl<_$_P2pTxDescription>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_P2pTxDescriptionToJson(
      this,
    );
  }
}

abstract class _P2pTxDescription extends P2pTxDescription {
  factory _P2pTxDescription(
      {required final int type,
      required final String function,
      @JsonKey(name: 'from_address') required final String fromAddress,
      @JsonKey(name: 'to_address') required final String toAddress,
      final String? amount,
      final String? fee,
      final int? timestamp,
      final Map<String, dynamic> data,
      final String? hash,
      final int? height}) = _$_P2pTxDescription;
  _P2pTxDescription._() : super._();

  factory _P2pTxDescription.fromJson(Map<String, dynamic> json) =
      _$_P2pTxDescription.fromJson;

  @override // Core's TransactionType: 5 NFT_SALE, 7 DSTR.
  int get type;
  @override
  String get function;
  @override
  @JsonKey(name: 'from_address')
  String get fromAddress;
  @override
  @JsonKey(name: 'to_address')
  String get toAddress;
  @override
  String? get amount;
  @override
  String? get fee;
  @override // Unix seconds.
  int? get timestamp;
  @override
  Map<String, dynamic> get data;
  @override
  String? get hash;
  @override
  int? get height;
  @override
  @JsonKey(ignore: true)
  _$$_P2pTxDescriptionCopyWith<_$_P2pTxDescription> get copyWith =>
      throw _privateConstructorUsedError;
}
