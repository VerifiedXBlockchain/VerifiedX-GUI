// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'butterfly_status_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ButterflyStatusResponse _$ButterflyStatusResponseFromJson(
    Map<String, dynamic> json) {
  return _ButterflyStatusResponse.fromJson(json);
}

/// @nodoc
mixin _$ButterflyStatusResponse {
  String? get uuid => throw _privateConstructorUsedError;
  @JsonKey(name: 'link_id')
  String? get linkId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'claim_amount')
  String? get claimAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'asset_type')
  String? get assetType => throw _privateConstructorUsedError;
  String? get chain => throw _privateConstructorUsedError;
  @JsonKey(name: 'token_symbol')
  String? get tokenSymbol => throw _privateConstructorUsedError;
  @JsonKey(name: 'escrow_address')
  String? get escrowAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'short_url')
  String? get shortUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_url')
  String? get fullUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'usd_value')
  String? get usdValue => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  String? get icon => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ButterflyStatusResponseCopyWith<ButterflyStatusResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ButterflyStatusResponseCopyWith<$Res> {
  factory $ButterflyStatusResponseCopyWith(ButterflyStatusResponse value,
          $Res Function(ButterflyStatusResponse) then) =
      _$ButterflyStatusResponseCopyWithImpl<$Res, ButterflyStatusResponse>;
  @useResult
  $Res call(
      {String? uuid,
      @JsonKey(name: 'link_id') String? linkId,
      String status,
      String? amount,
      @JsonKey(name: 'claim_amount') String? claimAmount,
      @JsonKey(name: 'asset_type') String? assetType,
      String? chain,
      @JsonKey(name: 'token_symbol') String? tokenSymbol,
      @JsonKey(name: 'escrow_address') String? escrowAddress,
      @JsonKey(name: 'short_url') String? shortUrl,
      @JsonKey(name: 'full_url') String? fullUrl,
      @JsonKey(name: 'usd_value') String? usdValue,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      String? icon,
      String? message});
}

/// @nodoc
class _$ButterflyStatusResponseCopyWithImpl<$Res,
        $Val extends ButterflyStatusResponse>
    implements $ButterflyStatusResponseCopyWith<$Res> {
  _$ButterflyStatusResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uuid = freezed,
    Object? linkId = freezed,
    Object? status = null,
    Object? amount = freezed,
    Object? claimAmount = freezed,
    Object? assetType = freezed,
    Object? chain = freezed,
    Object? tokenSymbol = freezed,
    Object? escrowAddress = freezed,
    Object? shortUrl = freezed,
    Object? fullUrl = freezed,
    Object? usdValue = freezed,
    Object? createdAt = freezed,
    Object? icon = freezed,
    Object? message = freezed,
  }) {
    return _then(_value.copyWith(
      uuid: freezed == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String?,
      linkId: freezed == linkId
          ? _value.linkId
          : linkId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as String?,
      claimAmount: freezed == claimAmount
          ? _value.claimAmount
          : claimAmount // ignore: cast_nullable_to_non_nullable
              as String?,
      assetType: freezed == assetType
          ? _value.assetType
          : assetType // ignore: cast_nullable_to_non_nullable
              as String?,
      chain: freezed == chain
          ? _value.chain
          : chain // ignore: cast_nullable_to_non_nullable
              as String?,
      tokenSymbol: freezed == tokenSymbol
          ? _value.tokenSymbol
          : tokenSymbol // ignore: cast_nullable_to_non_nullable
              as String?,
      escrowAddress: freezed == escrowAddress
          ? _value.escrowAddress
          : escrowAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      shortUrl: freezed == shortUrl
          ? _value.shortUrl
          : shortUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      fullUrl: freezed == fullUrl
          ? _value.fullUrl
          : fullUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      usdValue: freezed == usdValue
          ? _value.usdValue
          : usdValue // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ButterflyStatusResponseCopyWith<$Res>
    implements $ButterflyStatusResponseCopyWith<$Res> {
  factory _$$_ButterflyStatusResponseCopyWith(_$_ButterflyStatusResponse value,
          $Res Function(_$_ButterflyStatusResponse) then) =
      __$$_ButterflyStatusResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? uuid,
      @JsonKey(name: 'link_id') String? linkId,
      String status,
      String? amount,
      @JsonKey(name: 'claim_amount') String? claimAmount,
      @JsonKey(name: 'asset_type') String? assetType,
      String? chain,
      @JsonKey(name: 'token_symbol') String? tokenSymbol,
      @JsonKey(name: 'escrow_address') String? escrowAddress,
      @JsonKey(name: 'short_url') String? shortUrl,
      @JsonKey(name: 'full_url') String? fullUrl,
      @JsonKey(name: 'usd_value') String? usdValue,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      String? icon,
      String? message});
}

/// @nodoc
class __$$_ButterflyStatusResponseCopyWithImpl<$Res>
    extends _$ButterflyStatusResponseCopyWithImpl<$Res,
        _$_ButterflyStatusResponse>
    implements _$$_ButterflyStatusResponseCopyWith<$Res> {
  __$$_ButterflyStatusResponseCopyWithImpl(_$_ButterflyStatusResponse _value,
      $Res Function(_$_ButterflyStatusResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uuid = freezed,
    Object? linkId = freezed,
    Object? status = null,
    Object? amount = freezed,
    Object? claimAmount = freezed,
    Object? assetType = freezed,
    Object? chain = freezed,
    Object? tokenSymbol = freezed,
    Object? escrowAddress = freezed,
    Object? shortUrl = freezed,
    Object? fullUrl = freezed,
    Object? usdValue = freezed,
    Object? createdAt = freezed,
    Object? icon = freezed,
    Object? message = freezed,
  }) {
    return _then(_$_ButterflyStatusResponse(
      uuid: freezed == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String?,
      linkId: freezed == linkId
          ? _value.linkId
          : linkId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as String?,
      claimAmount: freezed == claimAmount
          ? _value.claimAmount
          : claimAmount // ignore: cast_nullable_to_non_nullable
              as String?,
      assetType: freezed == assetType
          ? _value.assetType
          : assetType // ignore: cast_nullable_to_non_nullable
              as String?,
      chain: freezed == chain
          ? _value.chain
          : chain // ignore: cast_nullable_to_non_nullable
              as String?,
      tokenSymbol: freezed == tokenSymbol
          ? _value.tokenSymbol
          : tokenSymbol // ignore: cast_nullable_to_non_nullable
              as String?,
      escrowAddress: freezed == escrowAddress
          ? _value.escrowAddress
          : escrowAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      shortUrl: freezed == shortUrl
          ? _value.shortUrl
          : shortUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      fullUrl: freezed == fullUrl
          ? _value.fullUrl
          : fullUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      usdValue: freezed == usdValue
          ? _value.usdValue
          : usdValue // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ButterflyStatusResponse extends _ButterflyStatusResponse {
  const _$_ButterflyStatusResponse(
      {this.uuid,
      @JsonKey(name: 'link_id') this.linkId,
      required this.status,
      this.amount,
      @JsonKey(name: 'claim_amount') this.claimAmount,
      @JsonKey(name: 'asset_type') this.assetType,
      this.chain,
      @JsonKey(name: 'token_symbol') this.tokenSymbol,
      @JsonKey(name: 'escrow_address') this.escrowAddress,
      @JsonKey(name: 'short_url') this.shortUrl,
      @JsonKey(name: 'full_url') this.fullUrl,
      @JsonKey(name: 'usd_value') this.usdValue,
      @JsonKey(name: 'created_at') this.createdAt,
      this.icon,
      this.message})
      : super._();

  factory _$_ButterflyStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$$_ButterflyStatusResponseFromJson(json);

  @override
  final String? uuid;
  @override
  @JsonKey(name: 'link_id')
  final String? linkId;
  @override
  final String status;
  @override
  final String? amount;
  @override
  @JsonKey(name: 'claim_amount')
  final String? claimAmount;
  @override
  @JsonKey(name: 'asset_type')
  final String? assetType;
  @override
  final String? chain;
  @override
  @JsonKey(name: 'token_symbol')
  final String? tokenSymbol;
  @override
  @JsonKey(name: 'escrow_address')
  final String? escrowAddress;
  @override
  @JsonKey(name: 'short_url')
  final String? shortUrl;
  @override
  @JsonKey(name: 'full_url')
  final String? fullUrl;
  @override
  @JsonKey(name: 'usd_value')
  final String? usdValue;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  final String? icon;
  @override
  final String? message;

  @override
  String toString() {
    return 'ButterflyStatusResponse(uuid: $uuid, linkId: $linkId, status: $status, amount: $amount, claimAmount: $claimAmount, assetType: $assetType, chain: $chain, tokenSymbol: $tokenSymbol, escrowAddress: $escrowAddress, shortUrl: $shortUrl, fullUrl: $fullUrl, usdValue: $usdValue, createdAt: $createdAt, icon: $icon, message: $message)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ButterflyStatusResponse &&
            (identical(other.uuid, uuid) || other.uuid == uuid) &&
            (identical(other.linkId, linkId) || other.linkId == linkId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.claimAmount, claimAmount) ||
                other.claimAmount == claimAmount) &&
            (identical(other.assetType, assetType) ||
                other.assetType == assetType) &&
            (identical(other.chain, chain) || other.chain == chain) &&
            (identical(other.tokenSymbol, tokenSymbol) ||
                other.tokenSymbol == tokenSymbol) &&
            (identical(other.escrowAddress, escrowAddress) ||
                other.escrowAddress == escrowAddress) &&
            (identical(other.shortUrl, shortUrl) ||
                other.shortUrl == shortUrl) &&
            (identical(other.fullUrl, fullUrl) || other.fullUrl == fullUrl) &&
            (identical(other.usdValue, usdValue) ||
                other.usdValue == usdValue) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      uuid,
      linkId,
      status,
      amount,
      claimAmount,
      assetType,
      chain,
      tokenSymbol,
      escrowAddress,
      shortUrl,
      fullUrl,
      usdValue,
      createdAt,
      icon,
      message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ButterflyStatusResponseCopyWith<_$_ButterflyStatusResponse>
      get copyWith =>
          __$$_ButterflyStatusResponseCopyWithImpl<_$_ButterflyStatusResponse>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ButterflyStatusResponseToJson(
      this,
    );
  }
}

abstract class _ButterflyStatusResponse extends ButterflyStatusResponse {
  const factory _ButterflyStatusResponse(
      {final String? uuid,
      @JsonKey(name: 'link_id') final String? linkId,
      required final String status,
      final String? amount,
      @JsonKey(name: 'claim_amount') final String? claimAmount,
      @JsonKey(name: 'asset_type') final String? assetType,
      final String? chain,
      @JsonKey(name: 'token_symbol') final String? tokenSymbol,
      @JsonKey(name: 'escrow_address') final String? escrowAddress,
      @JsonKey(name: 'short_url') final String? shortUrl,
      @JsonKey(name: 'full_url') final String? fullUrl,
      @JsonKey(name: 'usd_value') final String? usdValue,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      final String? icon,
      final String? message}) = _$_ButterflyStatusResponse;
  const _ButterflyStatusResponse._() : super._();

  factory _ButterflyStatusResponse.fromJson(Map<String, dynamic> json) =
      _$_ButterflyStatusResponse.fromJson;

  @override
  String? get uuid;
  @override
  @JsonKey(name: 'link_id')
  String? get linkId;
  @override
  String get status;
  @override
  String? get amount;
  @override
  @JsonKey(name: 'claim_amount')
  String? get claimAmount;
  @override
  @JsonKey(name: 'asset_type')
  String? get assetType;
  @override
  String? get chain;
  @override
  @JsonKey(name: 'token_symbol')
  String? get tokenSymbol;
  @override
  @JsonKey(name: 'escrow_address')
  String? get escrowAddress;
  @override
  @JsonKey(name: 'short_url')
  String? get shortUrl;
  @override
  @JsonKey(name: 'full_url')
  String? get fullUrl;
  @override
  @JsonKey(name: 'usd_value')
  String? get usdValue;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  String? get icon;
  @override
  String? get message;
  @override
  @JsonKey(ignore: true)
  _$$_ButterflyStatusResponseCopyWith<_$_ButterflyStatusResponse>
      get copyWith => throw _privateConstructorUsedError;
}
