// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onramp_purchase_details.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

OnrampPurchaseDetails _$OnrampPurchaseDetailsFromJson(
    Map<String, dynamic> json) {
  return _OnrampPurchaseDetails.fromJson(json);
}

/// @nodoc
mixin _$OnrampPurchaseDetails {
  String get uuid => throw _privateConstructorUsedError;
  OnrampPurchaseProvider? get provider => throw _privateConstructorUsedError;
  @JsonKey(name: 'vfx_address')
  String get vfxAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'vfx_transaction_hash')
  String? get vfxTransactionHash => throw _privateConstructorUsedError;
  OnrampPurchaseStatus get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $OnrampPurchaseDetailsCopyWith<OnrampPurchaseDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnrampPurchaseDetailsCopyWith<$Res> {
  factory $OnrampPurchaseDetailsCopyWith(OnrampPurchaseDetails value,
          $Res Function(OnrampPurchaseDetails) then) =
      _$OnrampPurchaseDetailsCopyWithImpl<$Res, OnrampPurchaseDetails>;
  @useResult
  $Res call(
      {String uuid,
      OnrampPurchaseProvider? provider,
      @JsonKey(name: 'vfx_address') String vfxAddress,
      @JsonKey(name: 'vfx_transaction_hash') String? vfxTransactionHash,
      OnrampPurchaseStatus status,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class _$OnrampPurchaseDetailsCopyWithImpl<$Res,
        $Val extends OnrampPurchaseDetails>
    implements $OnrampPurchaseDetailsCopyWith<$Res> {
  _$OnrampPurchaseDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uuid = null,
    Object? provider = freezed,
    Object? vfxAddress = null,
    Object? vfxTransactionHash = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      uuid: null == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      provider: freezed == provider
          ? _value.provider
          : provider // ignore: cast_nullable_to_non_nullable
              as OnrampPurchaseProvider?,
      vfxAddress: null == vfxAddress
          ? _value.vfxAddress
          : vfxAddress // ignore: cast_nullable_to_non_nullable
              as String,
      vfxTransactionHash: freezed == vfxTransactionHash
          ? _value.vfxTransactionHash
          : vfxTransactionHash // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OnrampPurchaseStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_OnrampPurchaseDetailsCopyWith<$Res>
    implements $OnrampPurchaseDetailsCopyWith<$Res> {
  factory _$$_OnrampPurchaseDetailsCopyWith(_$_OnrampPurchaseDetails value,
          $Res Function(_$_OnrampPurchaseDetails) then) =
      __$$_OnrampPurchaseDetailsCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String uuid,
      OnrampPurchaseProvider? provider,
      @JsonKey(name: 'vfx_address') String vfxAddress,
      @JsonKey(name: 'vfx_transaction_hash') String? vfxTransactionHash,
      OnrampPurchaseStatus status,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class __$$_OnrampPurchaseDetailsCopyWithImpl<$Res>
    extends _$OnrampPurchaseDetailsCopyWithImpl<$Res, _$_OnrampPurchaseDetails>
    implements _$$_OnrampPurchaseDetailsCopyWith<$Res> {
  __$$_OnrampPurchaseDetailsCopyWithImpl(_$_OnrampPurchaseDetails _value,
      $Res Function(_$_OnrampPurchaseDetails) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uuid = null,
    Object? provider = freezed,
    Object? vfxAddress = null,
    Object? vfxTransactionHash = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$_OnrampPurchaseDetails(
      uuid: null == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      provider: freezed == provider
          ? _value.provider
          : provider // ignore: cast_nullable_to_non_nullable
              as OnrampPurchaseProvider?,
      vfxAddress: null == vfxAddress
          ? _value.vfxAddress
          : vfxAddress // ignore: cast_nullable_to_non_nullable
              as String,
      vfxTransactionHash: freezed == vfxTransactionHash
          ? _value.vfxTransactionHash
          : vfxTransactionHash // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OnrampPurchaseStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_OnrampPurchaseDetails extends _OnrampPurchaseDetails {
  const _$_OnrampPurchaseDetails(
      {required this.uuid,
      this.provider,
      @JsonKey(name: 'vfx_address') required this.vfxAddress,
      @JsonKey(name: 'vfx_transaction_hash') this.vfxTransactionHash,
      required this.status,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt})
      : super._();

  factory _$_OnrampPurchaseDetails.fromJson(Map<String, dynamic> json) =>
      _$$_OnrampPurchaseDetailsFromJson(json);

  @override
  final String uuid;
  @override
  final OnrampPurchaseProvider? provider;
  @override
  @JsonKey(name: 'vfx_address')
  final String vfxAddress;
  @override
  @JsonKey(name: 'vfx_transaction_hash')
  final String? vfxTransactionHash;
  @override
  final OnrampPurchaseStatus status;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'OnrampPurchaseDetails(uuid: $uuid, provider: $provider, vfxAddress: $vfxAddress, vfxTransactionHash: $vfxTransactionHash, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_OnrampPurchaseDetails &&
            (identical(other.uuid, uuid) || other.uuid == uuid) &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.vfxAddress, vfxAddress) ||
                other.vfxAddress == vfxAddress) &&
            (identical(other.vfxTransactionHash, vfxTransactionHash) ||
                other.vfxTransactionHash == vfxTransactionHash) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, uuid, provider, vfxAddress,
      vfxTransactionHash, status, createdAt, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_OnrampPurchaseDetailsCopyWith<_$_OnrampPurchaseDetails> get copyWith =>
      __$$_OnrampPurchaseDetailsCopyWithImpl<_$_OnrampPurchaseDetails>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_OnrampPurchaseDetailsToJson(
      this,
    );
  }
}

abstract class _OnrampPurchaseDetails extends OnrampPurchaseDetails {
  const factory _OnrampPurchaseDetails(
      {required final String uuid,
      final OnrampPurchaseProvider? provider,
      @JsonKey(name: 'vfx_address')
          required final String vfxAddress,
      @JsonKey(name: 'vfx_transaction_hash')
          final String? vfxTransactionHash,
      required final OnrampPurchaseStatus status,
      @JsonKey(name: 'created_at')
          required final DateTime createdAt,
      @JsonKey(name: 'updated_at')
          required final DateTime updatedAt}) = _$_OnrampPurchaseDetails;
  const _OnrampPurchaseDetails._() : super._();

  factory _OnrampPurchaseDetails.fromJson(Map<String, dynamic> json) =
      _$_OnrampPurchaseDetails.fromJson;

  @override
  String get uuid;
  @override
  OnrampPurchaseProvider? get provider;
  @override
  @JsonKey(name: 'vfx_address')
  String get vfxAddress;
  @override
  @JsonKey(name: 'vfx_transaction_hash')
  String? get vfxTransactionHash;
  @override
  OnrampPurchaseStatus get status;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$_OnrampPurchaseDetailsCopyWith<_$_OnrampPurchaseDetails> get copyWith =>
      throw _privateConstructorUsedError;
}
