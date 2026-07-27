// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bridge_lock_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

BridgeLockRequest _$BridgeLockRequestFromJson(Map<String, dynamic> json) {
  return _BridgeLockRequest.fromJson(json);
}

/// @nodoc
mixin _$BridgeLockRequest {
  @JsonKey(name: "scUID")
  String get scUid => throw _privateConstructorUsedError;
  @JsonKey(name: "ownerAddress")
  String get ownerAddress => throw _privateConstructorUsedError;
  @JsonKey(name: "amount")
  String get amount => throw _privateConstructorUsedError;
  @JsonKey(name: "evmDestination")
  String get evmDestination => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BridgeLockRequestCopyWith<BridgeLockRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BridgeLockRequestCopyWith<$Res> {
  factory $BridgeLockRequestCopyWith(
          BridgeLockRequest value, $Res Function(BridgeLockRequest) then) =
      _$BridgeLockRequestCopyWithImpl<$Res, BridgeLockRequest>;
  @useResult
  $Res call(
      {@JsonKey(name: "scUID") String scUid,
      @JsonKey(name: "ownerAddress") String ownerAddress,
      @JsonKey(name: "amount") String amount,
      @JsonKey(name: "evmDestination") String evmDestination});
}

/// @nodoc
class _$BridgeLockRequestCopyWithImpl<$Res, $Val extends BridgeLockRequest>
    implements $BridgeLockRequestCopyWith<$Res> {
  _$BridgeLockRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scUid = null,
    Object? ownerAddress = null,
    Object? amount = null,
    Object? evmDestination = null,
  }) {
    return _then(_value.copyWith(
      scUid: null == scUid
          ? _value.scUid
          : scUid // ignore: cast_nullable_to_non_nullable
              as String,
      ownerAddress: null == ownerAddress
          ? _value.ownerAddress
          : ownerAddress // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as String,
      evmDestination: null == evmDestination
          ? _value.evmDestination
          : evmDestination // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_BridgeLockRequestCopyWith<$Res>
    implements $BridgeLockRequestCopyWith<$Res> {
  factory _$$_BridgeLockRequestCopyWith(_$_BridgeLockRequest value,
          $Res Function(_$_BridgeLockRequest) then) =
      __$$_BridgeLockRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "scUID") String scUid,
      @JsonKey(name: "ownerAddress") String ownerAddress,
      @JsonKey(name: "amount") String amount,
      @JsonKey(name: "evmDestination") String evmDestination});
}

/// @nodoc
class __$$_BridgeLockRequestCopyWithImpl<$Res>
    extends _$BridgeLockRequestCopyWithImpl<$Res, _$_BridgeLockRequest>
    implements _$$_BridgeLockRequestCopyWith<$Res> {
  __$$_BridgeLockRequestCopyWithImpl(
      _$_BridgeLockRequest _value, $Res Function(_$_BridgeLockRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scUid = null,
    Object? ownerAddress = null,
    Object? amount = null,
    Object? evmDestination = null,
  }) {
    return _then(_$_BridgeLockRequest(
      scUid: null == scUid
          ? _value.scUid
          : scUid // ignore: cast_nullable_to_non_nullable
              as String,
      ownerAddress: null == ownerAddress
          ? _value.ownerAddress
          : ownerAddress // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as String,
      evmDestination: null == evmDestination
          ? _value.evmDestination
          : evmDestination // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_BridgeLockRequest extends _BridgeLockRequest {
  _$_BridgeLockRequest(
      {@JsonKey(name: "scUID") required this.scUid,
      @JsonKey(name: "ownerAddress") required this.ownerAddress,
      @JsonKey(name: "amount") required this.amount,
      @JsonKey(name: "evmDestination") required this.evmDestination})
      : super._();

  factory _$_BridgeLockRequest.fromJson(Map<String, dynamic> json) =>
      _$$_BridgeLockRequestFromJson(json);

  @override
  @JsonKey(name: "scUID")
  final String scUid;
  @override
  @JsonKey(name: "ownerAddress")
  final String ownerAddress;
  @override
  @JsonKey(name: "amount")
  final String amount;
  @override
  @JsonKey(name: "evmDestination")
  final String evmDestination;

  @override
  String toString() {
    return 'BridgeLockRequest(scUid: $scUid, ownerAddress: $ownerAddress, amount: $amount, evmDestination: $evmDestination)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_BridgeLockRequest &&
            (identical(other.scUid, scUid) || other.scUid == scUid) &&
            (identical(other.ownerAddress, ownerAddress) ||
                other.ownerAddress == ownerAddress) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.evmDestination, evmDestination) ||
                other.evmDestination == evmDestination));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, scUid, ownerAddress, amount, evmDestination);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_BridgeLockRequestCopyWith<_$_BridgeLockRequest> get copyWith =>
      __$$_BridgeLockRequestCopyWithImpl<_$_BridgeLockRequest>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_BridgeLockRequestToJson(
      this,
    );
  }
}

abstract class _BridgeLockRequest extends BridgeLockRequest {
  factory _BridgeLockRequest(
      {@JsonKey(name: "scUID")
          required final String scUid,
      @JsonKey(name: "ownerAddress")
          required final String ownerAddress,
      @JsonKey(name: "amount")
          required final String amount,
      @JsonKey(name: "evmDestination")
          required final String evmDestination}) = _$_BridgeLockRequest;
  _BridgeLockRequest._() : super._();

  factory _BridgeLockRequest.fromJson(Map<String, dynamic> json) =
      _$_BridgeLockRequest.fromJson;

  @override
  @JsonKey(name: "scUID")
  String get scUid;
  @override
  @JsonKey(name: "ownerAddress")
  String get ownerAddress;
  @override
  @JsonKey(name: "amount")
  String get amount;
  @override
  @JsonKey(name: "evmDestination")
  String get evmDestination;
  @override
  @JsonKey(ignore: true)
  _$$_BridgeLockRequestCopyWith<_$_BridgeLockRequest> get copyWith =>
      throw _privateConstructorUsedError;
}
