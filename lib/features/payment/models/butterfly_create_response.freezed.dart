// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'butterfly_create_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ButterflyCreateResponse _$ButterflyCreateResponseFromJson(
    Map<String, dynamic> json) {
  return _ButterflyCreateResponse.fromJson(json);
}

/// @nodoc
mixin _$ButterflyCreateResponse {
  @JsonKey(name: 'link_id')
  String get linkId => throw _privateConstructorUsedError;
  String? get uuid => throw _privateConstructorUsedError;
  @JsonKey(name: 'short_url')
  String get shortUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_url')
  String get fullUrl => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'escrow_address')
  String get escrowAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'raw_transaction')
  Map<String, dynamic>? get rawTransaction =>
      throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'token_symbol')
  String? get tokenSymbol => throw _privateConstructorUsedError;
  String? get chain => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ButterflyCreateResponseCopyWith<ButterflyCreateResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ButterflyCreateResponseCopyWith<$Res> {
  factory $ButterflyCreateResponseCopyWith(ButterflyCreateResponse value,
          $Res Function(ButterflyCreateResponse) then) =
      _$ButterflyCreateResponseCopyWithImpl<$Res, ButterflyCreateResponse>;
  @useResult
  $Res call(
      {@JsonKey(name: 'link_id') String linkId,
      String? uuid,
      @JsonKey(name: 'short_url') String shortUrl,
      @JsonKey(name: 'full_url') String fullUrl,
      String status,
      @JsonKey(name: 'escrow_address') String escrowAddress,
      @JsonKey(name: 'raw_transaction') Map<String, dynamic>? rawTransaction,
      double amount,
      @JsonKey(name: 'token_symbol') String? tokenSymbol,
      String? chain});
}

/// @nodoc
class _$ButterflyCreateResponseCopyWithImpl<$Res,
        $Val extends ButterflyCreateResponse>
    implements $ButterflyCreateResponseCopyWith<$Res> {
  _$ButterflyCreateResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? linkId = null,
    Object? uuid = freezed,
    Object? shortUrl = null,
    Object? fullUrl = null,
    Object? status = null,
    Object? escrowAddress = null,
    Object? rawTransaction = freezed,
    Object? amount = null,
    Object? tokenSymbol = freezed,
    Object? chain = freezed,
  }) {
    return _then(_value.copyWith(
      linkId: null == linkId
          ? _value.linkId
          : linkId // ignore: cast_nullable_to_non_nullable
              as String,
      uuid: freezed == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String?,
      shortUrl: null == shortUrl
          ? _value.shortUrl
          : shortUrl // ignore: cast_nullable_to_non_nullable
              as String,
      fullUrl: null == fullUrl
          ? _value.fullUrl
          : fullUrl // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      escrowAddress: null == escrowAddress
          ? _value.escrowAddress
          : escrowAddress // ignore: cast_nullable_to_non_nullable
              as String,
      rawTransaction: freezed == rawTransaction
          ? _value.rawTransaction
          : rawTransaction // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      tokenSymbol: freezed == tokenSymbol
          ? _value.tokenSymbol
          : tokenSymbol // ignore: cast_nullable_to_non_nullable
              as String?,
      chain: freezed == chain
          ? _value.chain
          : chain // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ButterflyCreateResponseCopyWith<$Res>
    implements $ButterflyCreateResponseCopyWith<$Res> {
  factory _$$_ButterflyCreateResponseCopyWith(_$_ButterflyCreateResponse value,
          $Res Function(_$_ButterflyCreateResponse) then) =
      __$$_ButterflyCreateResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'link_id') String linkId,
      String? uuid,
      @JsonKey(name: 'short_url') String shortUrl,
      @JsonKey(name: 'full_url') String fullUrl,
      String status,
      @JsonKey(name: 'escrow_address') String escrowAddress,
      @JsonKey(name: 'raw_transaction') Map<String, dynamic>? rawTransaction,
      double amount,
      @JsonKey(name: 'token_symbol') String? tokenSymbol,
      String? chain});
}

/// @nodoc
class __$$_ButterflyCreateResponseCopyWithImpl<$Res>
    extends _$ButterflyCreateResponseCopyWithImpl<$Res,
        _$_ButterflyCreateResponse>
    implements _$$_ButterflyCreateResponseCopyWith<$Res> {
  __$$_ButterflyCreateResponseCopyWithImpl(_$_ButterflyCreateResponse _value,
      $Res Function(_$_ButterflyCreateResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? linkId = null,
    Object? uuid = freezed,
    Object? shortUrl = null,
    Object? fullUrl = null,
    Object? status = null,
    Object? escrowAddress = null,
    Object? rawTransaction = freezed,
    Object? amount = null,
    Object? tokenSymbol = freezed,
    Object? chain = freezed,
  }) {
    return _then(_$_ButterflyCreateResponse(
      linkId: null == linkId
          ? _value.linkId
          : linkId // ignore: cast_nullable_to_non_nullable
              as String,
      uuid: freezed == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String?,
      shortUrl: null == shortUrl
          ? _value.shortUrl
          : shortUrl // ignore: cast_nullable_to_non_nullable
              as String,
      fullUrl: null == fullUrl
          ? _value.fullUrl
          : fullUrl // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      escrowAddress: null == escrowAddress
          ? _value.escrowAddress
          : escrowAddress // ignore: cast_nullable_to_non_nullable
              as String,
      rawTransaction: freezed == rawTransaction
          ? _value._rawTransaction
          : rawTransaction // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      tokenSymbol: freezed == tokenSymbol
          ? _value.tokenSymbol
          : tokenSymbol // ignore: cast_nullable_to_non_nullable
              as String?,
      chain: freezed == chain
          ? _value.chain
          : chain // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ButterflyCreateResponse extends _ButterflyCreateResponse {
  const _$_ButterflyCreateResponse(
      {@JsonKey(name: 'link_id')
          required this.linkId,
      this.uuid,
      @JsonKey(name: 'short_url')
          required this.shortUrl,
      @JsonKey(name: 'full_url')
          required this.fullUrl,
      required this.status,
      @JsonKey(name: 'escrow_address')
          required this.escrowAddress,
      @JsonKey(name: 'raw_transaction')
          final Map<String, dynamic>? rawTransaction,
      required this.amount,
      @JsonKey(name: 'token_symbol')
          this.tokenSymbol,
      this.chain})
      : _rawTransaction = rawTransaction,
        super._();

  factory _$_ButterflyCreateResponse.fromJson(Map<String, dynamic> json) =>
      _$$_ButterflyCreateResponseFromJson(json);

  @override
  @JsonKey(name: 'link_id')
  final String linkId;
  @override
  final String? uuid;
  @override
  @JsonKey(name: 'short_url')
  final String shortUrl;
  @override
  @JsonKey(name: 'full_url')
  final String fullUrl;
  @override
  final String status;
  @override
  @JsonKey(name: 'escrow_address')
  final String escrowAddress;
  final Map<String, dynamic>? _rawTransaction;
  @override
  @JsonKey(name: 'raw_transaction')
  Map<String, dynamic>? get rawTransaction {
    final value = _rawTransaction;
    if (value == null) return null;
    if (_rawTransaction is EqualUnmodifiableMapView) return _rawTransaction;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final double amount;
  @override
  @JsonKey(name: 'token_symbol')
  final String? tokenSymbol;
  @override
  final String? chain;

  @override
  String toString() {
    return 'ButterflyCreateResponse(linkId: $linkId, uuid: $uuid, shortUrl: $shortUrl, fullUrl: $fullUrl, status: $status, escrowAddress: $escrowAddress, rawTransaction: $rawTransaction, amount: $amount, tokenSymbol: $tokenSymbol, chain: $chain)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ButterflyCreateResponse &&
            (identical(other.linkId, linkId) || other.linkId == linkId) &&
            (identical(other.uuid, uuid) || other.uuid == uuid) &&
            (identical(other.shortUrl, shortUrl) ||
                other.shortUrl == shortUrl) &&
            (identical(other.fullUrl, fullUrl) || other.fullUrl == fullUrl) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.escrowAddress, escrowAddress) ||
                other.escrowAddress == escrowAddress) &&
            const DeepCollectionEquality()
                .equals(other._rawTransaction, _rawTransaction) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.tokenSymbol, tokenSymbol) ||
                other.tokenSymbol == tokenSymbol) &&
            (identical(other.chain, chain) || other.chain == chain));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      linkId,
      uuid,
      shortUrl,
      fullUrl,
      status,
      escrowAddress,
      const DeepCollectionEquality().hash(_rawTransaction),
      amount,
      tokenSymbol,
      chain);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ButterflyCreateResponseCopyWith<_$_ButterflyCreateResponse>
      get copyWith =>
          __$$_ButterflyCreateResponseCopyWithImpl<_$_ButterflyCreateResponse>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ButterflyCreateResponseToJson(
      this,
    );
  }
}

abstract class _ButterflyCreateResponse extends ButterflyCreateResponse {
  const factory _ButterflyCreateResponse(
      {@JsonKey(name: 'link_id')
          required final String linkId,
      final String? uuid,
      @JsonKey(name: 'short_url')
          required final String shortUrl,
      @JsonKey(name: 'full_url')
          required final String fullUrl,
      required final String status,
      @JsonKey(name: 'escrow_address')
          required final String escrowAddress,
      @JsonKey(name: 'raw_transaction')
          final Map<String, dynamic>? rawTransaction,
      required final double amount,
      @JsonKey(name: 'token_symbol')
          final String? tokenSymbol,
      final String? chain}) = _$_ButterflyCreateResponse;
  const _ButterflyCreateResponse._() : super._();

  factory _ButterflyCreateResponse.fromJson(Map<String, dynamic> json) =
      _$_ButterflyCreateResponse.fromJson;

  @override
  @JsonKey(name: 'link_id')
  String get linkId;
  @override
  String? get uuid;
  @override
  @JsonKey(name: 'short_url')
  String get shortUrl;
  @override
  @JsonKey(name: 'full_url')
  String get fullUrl;
  @override
  String get status;
  @override
  @JsonKey(name: 'escrow_address')
  String get escrowAddress;
  @override
  @JsonKey(name: 'raw_transaction')
  Map<String, dynamic>? get rawTransaction;
  @override
  double get amount;
  @override
  @JsonKey(name: 'token_symbol')
  String? get tokenSymbol;
  @override
  String? get chain;
  @override
  @JsonKey(ignore: true)
  _$$_ButterflyCreateResponseCopyWith<_$_ButterflyCreateResponse>
      get copyWith => throw _privateConstructorUsedError;
}
