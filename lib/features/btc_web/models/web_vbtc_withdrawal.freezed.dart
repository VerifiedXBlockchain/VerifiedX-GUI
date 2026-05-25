// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'web_vbtc_withdrawal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

WebVbtcWithdrawal _$WebVbtcWithdrawalFromJson(Map<String, dynamic> json) {
  return _WebVbtcWithdrawal.fromJson(json);
}

/// @nodoc
mixin _$WebVbtcWithdrawal {
  @JsonKey(name: 'requestor_address')
  String get requestorAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'btc_address')
  String get btcAddress => throw _privateConstructorUsedError;
  String get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'fee_rate')
  String get feeRate => throw _privateConstructorUsedError;
  @JsonKey(name: 'btc_transaction_hash')
  String? get btcTransactionHash => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'request_transaction_hash')
  String get requestTransactionHash => throw _privateConstructorUsedError;
  @JsonKey(name: 'completion_transaction_hash')
  String? get completionTransactionHash => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'completed_at')
  DateTime? get completedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WebVbtcWithdrawalCopyWith<WebVbtcWithdrawal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WebVbtcWithdrawalCopyWith<$Res> {
  factory $WebVbtcWithdrawalCopyWith(
          WebVbtcWithdrawal value, $Res Function(WebVbtcWithdrawal) then) =
      _$WebVbtcWithdrawalCopyWithImpl<$Res, WebVbtcWithdrawal>;
  @useResult
  $Res call(
      {@JsonKey(name: 'requestor_address')
          String requestorAddress,
      @JsonKey(name: 'btc_address')
          String btcAddress,
      String amount,
      @JsonKey(name: 'fee_rate')
          String feeRate,
      @JsonKey(name: 'btc_transaction_hash')
          String? btcTransactionHash,
      String status,
      @JsonKey(name: 'request_transaction_hash')
          String requestTransactionHash,
      @JsonKey(name: 'completion_transaction_hash')
          String? completionTransactionHash,
      @JsonKey(name: 'created_at')
          DateTime createdAt,
      @JsonKey(name: 'completed_at')
          DateTime? completedAt});
}

/// @nodoc
class _$WebVbtcWithdrawalCopyWithImpl<$Res, $Val extends WebVbtcWithdrawal>
    implements $WebVbtcWithdrawalCopyWith<$Res> {
  _$WebVbtcWithdrawalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requestorAddress = null,
    Object? btcAddress = null,
    Object? amount = null,
    Object? feeRate = null,
    Object? btcTransactionHash = freezed,
    Object? status = null,
    Object? requestTransactionHash = null,
    Object? completionTransactionHash = freezed,
    Object? createdAt = null,
    Object? completedAt = freezed,
  }) {
    return _then(_value.copyWith(
      requestorAddress: null == requestorAddress
          ? _value.requestorAddress
          : requestorAddress // ignore: cast_nullable_to_non_nullable
              as String,
      btcAddress: null == btcAddress
          ? _value.btcAddress
          : btcAddress // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as String,
      feeRate: null == feeRate
          ? _value.feeRate
          : feeRate // ignore: cast_nullable_to_non_nullable
              as String,
      btcTransactionHash: freezed == btcTransactionHash
          ? _value.btcTransactionHash
          : btcTransactionHash // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      requestTransactionHash: null == requestTransactionHash
          ? _value.requestTransactionHash
          : requestTransactionHash // ignore: cast_nullable_to_non_nullable
              as String,
      completionTransactionHash: freezed == completionTransactionHash
          ? _value.completionTransactionHash
          : completionTransactionHash // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_WebVbtcWithdrawalCopyWith<$Res>
    implements $WebVbtcWithdrawalCopyWith<$Res> {
  factory _$$_WebVbtcWithdrawalCopyWith(_$_WebVbtcWithdrawal value,
          $Res Function(_$_WebVbtcWithdrawal) then) =
      __$$_WebVbtcWithdrawalCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'requestor_address')
          String requestorAddress,
      @JsonKey(name: 'btc_address')
          String btcAddress,
      String amount,
      @JsonKey(name: 'fee_rate')
          String feeRate,
      @JsonKey(name: 'btc_transaction_hash')
          String? btcTransactionHash,
      String status,
      @JsonKey(name: 'request_transaction_hash')
          String requestTransactionHash,
      @JsonKey(name: 'completion_transaction_hash')
          String? completionTransactionHash,
      @JsonKey(name: 'created_at')
          DateTime createdAt,
      @JsonKey(name: 'completed_at')
          DateTime? completedAt});
}

/// @nodoc
class __$$_WebVbtcWithdrawalCopyWithImpl<$Res>
    extends _$WebVbtcWithdrawalCopyWithImpl<$Res, _$_WebVbtcWithdrawal>
    implements _$$_WebVbtcWithdrawalCopyWith<$Res> {
  __$$_WebVbtcWithdrawalCopyWithImpl(
      _$_WebVbtcWithdrawal _value, $Res Function(_$_WebVbtcWithdrawal) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requestorAddress = null,
    Object? btcAddress = null,
    Object? amount = null,
    Object? feeRate = null,
    Object? btcTransactionHash = freezed,
    Object? status = null,
    Object? requestTransactionHash = null,
    Object? completionTransactionHash = freezed,
    Object? createdAt = null,
    Object? completedAt = freezed,
  }) {
    return _then(_$_WebVbtcWithdrawal(
      requestorAddress: null == requestorAddress
          ? _value.requestorAddress
          : requestorAddress // ignore: cast_nullable_to_non_nullable
              as String,
      btcAddress: null == btcAddress
          ? _value.btcAddress
          : btcAddress // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as String,
      feeRate: null == feeRate
          ? _value.feeRate
          : feeRate // ignore: cast_nullable_to_non_nullable
              as String,
      btcTransactionHash: freezed == btcTransactionHash
          ? _value.btcTransactionHash
          : btcTransactionHash // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      requestTransactionHash: null == requestTransactionHash
          ? _value.requestTransactionHash
          : requestTransactionHash // ignore: cast_nullable_to_non_nullable
              as String,
      completionTransactionHash: freezed == completionTransactionHash
          ? _value.completionTransactionHash
          : completionTransactionHash // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_WebVbtcWithdrawal extends _WebVbtcWithdrawal {
  _$_WebVbtcWithdrawal(
      {@JsonKey(name: 'requestor_address')
          required this.requestorAddress,
      @JsonKey(name: 'btc_address')
          required this.btcAddress,
      required this.amount,
      @JsonKey(name: 'fee_rate')
          required this.feeRate,
      @JsonKey(name: 'btc_transaction_hash')
          this.btcTransactionHash,
      required this.status,
      @JsonKey(name: 'request_transaction_hash')
          required this.requestTransactionHash,
      @JsonKey(name: 'completion_transaction_hash')
          this.completionTransactionHash,
      @JsonKey(name: 'created_at')
          required this.createdAt,
      @JsonKey(name: 'completed_at')
          this.completedAt})
      : super._();

  factory _$_WebVbtcWithdrawal.fromJson(Map<String, dynamic> json) =>
      _$$_WebVbtcWithdrawalFromJson(json);

  @override
  @JsonKey(name: 'requestor_address')
  final String requestorAddress;
  @override
  @JsonKey(name: 'btc_address')
  final String btcAddress;
  @override
  final String amount;
  @override
  @JsonKey(name: 'fee_rate')
  final String feeRate;
  @override
  @JsonKey(name: 'btc_transaction_hash')
  final String? btcTransactionHash;
  @override
  final String status;
  @override
  @JsonKey(name: 'request_transaction_hash')
  final String requestTransactionHash;
  @override
  @JsonKey(name: 'completion_transaction_hash')
  final String? completionTransactionHash;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;

  @override
  String toString() {
    return 'WebVbtcWithdrawal(requestorAddress: $requestorAddress, btcAddress: $btcAddress, amount: $amount, feeRate: $feeRate, btcTransactionHash: $btcTransactionHash, status: $status, requestTransactionHash: $requestTransactionHash, completionTransactionHash: $completionTransactionHash, createdAt: $createdAt, completedAt: $completedAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_WebVbtcWithdrawal &&
            (identical(other.requestorAddress, requestorAddress) ||
                other.requestorAddress == requestorAddress) &&
            (identical(other.btcAddress, btcAddress) ||
                other.btcAddress == btcAddress) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.feeRate, feeRate) || other.feeRate == feeRate) &&
            (identical(other.btcTransactionHash, btcTransactionHash) ||
                other.btcTransactionHash == btcTransactionHash) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.requestTransactionHash, requestTransactionHash) ||
                other.requestTransactionHash == requestTransactionHash) &&
            (identical(other.completionTransactionHash,
                    completionTransactionHash) ||
                other.completionTransactionHash == completionTransactionHash) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      requestorAddress,
      btcAddress,
      amount,
      feeRate,
      btcTransactionHash,
      status,
      requestTransactionHash,
      completionTransactionHash,
      createdAt,
      completedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_WebVbtcWithdrawalCopyWith<_$_WebVbtcWithdrawal> get copyWith =>
      __$$_WebVbtcWithdrawalCopyWithImpl<_$_WebVbtcWithdrawal>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_WebVbtcWithdrawalToJson(
      this,
    );
  }
}

abstract class _WebVbtcWithdrawal extends WebVbtcWithdrawal {
  factory _WebVbtcWithdrawal(
      {@JsonKey(name: 'requestor_address')
          required final String requestorAddress,
      @JsonKey(name: 'btc_address')
          required final String btcAddress,
      required final String amount,
      @JsonKey(name: 'fee_rate')
          required final String feeRate,
      @JsonKey(name: 'btc_transaction_hash')
          final String? btcTransactionHash,
      required final String status,
      @JsonKey(name: 'request_transaction_hash')
          required final String requestTransactionHash,
      @JsonKey(name: 'completion_transaction_hash')
          final String? completionTransactionHash,
      @JsonKey(name: 'created_at')
          required final DateTime createdAt,
      @JsonKey(name: 'completed_at')
          final DateTime? completedAt}) = _$_WebVbtcWithdrawal;
  _WebVbtcWithdrawal._() : super._();

  factory _WebVbtcWithdrawal.fromJson(Map<String, dynamic> json) =
      _$_WebVbtcWithdrawal.fromJson;

  @override
  @JsonKey(name: 'requestor_address')
  String get requestorAddress;
  @override
  @JsonKey(name: 'btc_address')
  String get btcAddress;
  @override
  String get amount;
  @override
  @JsonKey(name: 'fee_rate')
  String get feeRate;
  @override
  @JsonKey(name: 'btc_transaction_hash')
  String? get btcTransactionHash;
  @override
  String get status;
  @override
  @JsonKey(name: 'request_transaction_hash')
  String get requestTransactionHash;
  @override
  @JsonKey(name: 'completion_transaction_hash')
  String? get completionTransactionHash;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'completed_at')
  DateTime? get completedAt;
  @override
  @JsonKey(ignore: true)
  _$$_WebVbtcWithdrawalCopyWith<_$_WebVbtcWithdrawal> get copyWith =>
      throw _privateConstructorUsedError;
}
