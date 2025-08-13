// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onramp_quote_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

OnrampQuoteResponse _$OnrampQuoteResponseFromJson(Map<String, dynamic> json) {
  return _OnrampQuoteResponse.fromJson(json);
}

/// @nodoc
mixin _$OnrampQuoteResponse {
  @JsonKey(name: "purchase_uuid")
  String get purchaseUuid => throw _privateConstructorUsedError;
  @JsonKey(name: 'stripe_checkout_url')
  String get stripeCheckoutUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'crypto_dot_com_checkout_url')
  String get cryptoDotComCheckoutUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount_usd')
  double get amountUsd => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount_vfx')
  double get amountVfx => throw _privateConstructorUsedError;
  @JsonKey(name: 'vfx_address')
  String get vfxAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'quote_valid_until')
  DateTime get quoteValidUntil => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $OnrampQuoteResponseCopyWith<OnrampQuoteResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnrampQuoteResponseCopyWith<$Res> {
  factory $OnrampQuoteResponseCopyWith(
          OnrampQuoteResponse value, $Res Function(OnrampQuoteResponse) then) =
      _$OnrampQuoteResponseCopyWithImpl<$Res, OnrampQuoteResponse>;
  @useResult
  $Res call(
      {@JsonKey(name: "purchase_uuid")
          String purchaseUuid,
      @JsonKey(name: 'stripe_checkout_url')
          String stripeCheckoutUrl,
      @JsonKey(name: 'crypto_dot_com_checkout_url')
          String cryptoDotComCheckoutUrl,
      @JsonKey(name: 'amount_usd')
          double amountUsd,
      @JsonKey(name: 'amount_vfx')
          double amountVfx,
      @JsonKey(name: 'vfx_address')
          String vfxAddress,
      @JsonKey(name: 'quote_valid_until')
          DateTime quoteValidUntil});
}

/// @nodoc
class _$OnrampQuoteResponseCopyWithImpl<$Res, $Val extends OnrampQuoteResponse>
    implements $OnrampQuoteResponseCopyWith<$Res> {
  _$OnrampQuoteResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? purchaseUuid = null,
    Object? stripeCheckoutUrl = null,
    Object? cryptoDotComCheckoutUrl = null,
    Object? amountUsd = null,
    Object? amountVfx = null,
    Object? vfxAddress = null,
    Object? quoteValidUntil = null,
  }) {
    return _then(_value.copyWith(
      purchaseUuid: null == purchaseUuid
          ? _value.purchaseUuid
          : purchaseUuid // ignore: cast_nullable_to_non_nullable
              as String,
      stripeCheckoutUrl: null == stripeCheckoutUrl
          ? _value.stripeCheckoutUrl
          : stripeCheckoutUrl // ignore: cast_nullable_to_non_nullable
              as String,
      cryptoDotComCheckoutUrl: null == cryptoDotComCheckoutUrl
          ? _value.cryptoDotComCheckoutUrl
          : cryptoDotComCheckoutUrl // ignore: cast_nullable_to_non_nullable
              as String,
      amountUsd: null == amountUsd
          ? _value.amountUsd
          : amountUsd // ignore: cast_nullable_to_non_nullable
              as double,
      amountVfx: null == amountVfx
          ? _value.amountVfx
          : amountVfx // ignore: cast_nullable_to_non_nullable
              as double,
      vfxAddress: null == vfxAddress
          ? _value.vfxAddress
          : vfxAddress // ignore: cast_nullable_to_non_nullable
              as String,
      quoteValidUntil: null == quoteValidUntil
          ? _value.quoteValidUntil
          : quoteValidUntil // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_OnrampQuoteResponseCopyWith<$Res>
    implements $OnrampQuoteResponseCopyWith<$Res> {
  factory _$$_OnrampQuoteResponseCopyWith(_$_OnrampQuoteResponse value,
          $Res Function(_$_OnrampQuoteResponse) then) =
      __$$_OnrampQuoteResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "purchase_uuid")
          String purchaseUuid,
      @JsonKey(name: 'stripe_checkout_url')
          String stripeCheckoutUrl,
      @JsonKey(name: 'crypto_dot_com_checkout_url')
          String cryptoDotComCheckoutUrl,
      @JsonKey(name: 'amount_usd')
          double amountUsd,
      @JsonKey(name: 'amount_vfx')
          double amountVfx,
      @JsonKey(name: 'vfx_address')
          String vfxAddress,
      @JsonKey(name: 'quote_valid_until')
          DateTime quoteValidUntil});
}

/// @nodoc
class __$$_OnrampQuoteResponseCopyWithImpl<$Res>
    extends _$OnrampQuoteResponseCopyWithImpl<$Res, _$_OnrampQuoteResponse>
    implements _$$_OnrampQuoteResponseCopyWith<$Res> {
  __$$_OnrampQuoteResponseCopyWithImpl(_$_OnrampQuoteResponse _value,
      $Res Function(_$_OnrampQuoteResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? purchaseUuid = null,
    Object? stripeCheckoutUrl = null,
    Object? cryptoDotComCheckoutUrl = null,
    Object? amountUsd = null,
    Object? amountVfx = null,
    Object? vfxAddress = null,
    Object? quoteValidUntil = null,
  }) {
    return _then(_$_OnrampQuoteResponse(
      purchaseUuid: null == purchaseUuid
          ? _value.purchaseUuid
          : purchaseUuid // ignore: cast_nullable_to_non_nullable
              as String,
      stripeCheckoutUrl: null == stripeCheckoutUrl
          ? _value.stripeCheckoutUrl
          : stripeCheckoutUrl // ignore: cast_nullable_to_non_nullable
              as String,
      cryptoDotComCheckoutUrl: null == cryptoDotComCheckoutUrl
          ? _value.cryptoDotComCheckoutUrl
          : cryptoDotComCheckoutUrl // ignore: cast_nullable_to_non_nullable
              as String,
      amountUsd: null == amountUsd
          ? _value.amountUsd
          : amountUsd // ignore: cast_nullable_to_non_nullable
              as double,
      amountVfx: null == amountVfx
          ? _value.amountVfx
          : amountVfx // ignore: cast_nullable_to_non_nullable
              as double,
      vfxAddress: null == vfxAddress
          ? _value.vfxAddress
          : vfxAddress // ignore: cast_nullable_to_non_nullable
              as String,
      quoteValidUntil: null == quoteValidUntil
          ? _value.quoteValidUntil
          : quoteValidUntil // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_OnrampQuoteResponse extends _OnrampQuoteResponse {
  const _$_OnrampQuoteResponse(
      {@JsonKey(name: "purchase_uuid")
          required this.purchaseUuid,
      @JsonKey(name: 'stripe_checkout_url')
          required this.stripeCheckoutUrl,
      @JsonKey(name: 'crypto_dot_com_checkout_url')
          required this.cryptoDotComCheckoutUrl,
      @JsonKey(name: 'amount_usd')
          required this.amountUsd,
      @JsonKey(name: 'amount_vfx')
          required this.amountVfx,
      @JsonKey(name: 'vfx_address')
          required this.vfxAddress,
      @JsonKey(name: 'quote_valid_until')
          required this.quoteValidUntil})
      : super._();

  factory _$_OnrampQuoteResponse.fromJson(Map<String, dynamic> json) =>
      _$$_OnrampQuoteResponseFromJson(json);

  @override
  @JsonKey(name: "purchase_uuid")
  final String purchaseUuid;
  @override
  @JsonKey(name: 'stripe_checkout_url')
  final String stripeCheckoutUrl;
  @override
  @JsonKey(name: 'crypto_dot_com_checkout_url')
  final String cryptoDotComCheckoutUrl;
  @override
  @JsonKey(name: 'amount_usd')
  final double amountUsd;
  @override
  @JsonKey(name: 'amount_vfx')
  final double amountVfx;
  @override
  @JsonKey(name: 'vfx_address')
  final String vfxAddress;
  @override
  @JsonKey(name: 'quote_valid_until')
  final DateTime quoteValidUntil;

  @override
  String toString() {
    return 'OnrampQuoteResponse(purchaseUuid: $purchaseUuid, stripeCheckoutUrl: $stripeCheckoutUrl, cryptoDotComCheckoutUrl: $cryptoDotComCheckoutUrl, amountUsd: $amountUsd, amountVfx: $amountVfx, vfxAddress: $vfxAddress, quoteValidUntil: $quoteValidUntil)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_OnrampQuoteResponse &&
            (identical(other.purchaseUuid, purchaseUuid) ||
                other.purchaseUuid == purchaseUuid) &&
            (identical(other.stripeCheckoutUrl, stripeCheckoutUrl) ||
                other.stripeCheckoutUrl == stripeCheckoutUrl) &&
            (identical(
                    other.cryptoDotComCheckoutUrl, cryptoDotComCheckoutUrl) ||
                other.cryptoDotComCheckoutUrl == cryptoDotComCheckoutUrl) &&
            (identical(other.amountUsd, amountUsd) ||
                other.amountUsd == amountUsd) &&
            (identical(other.amountVfx, amountVfx) ||
                other.amountVfx == amountVfx) &&
            (identical(other.vfxAddress, vfxAddress) ||
                other.vfxAddress == vfxAddress) &&
            (identical(other.quoteValidUntil, quoteValidUntil) ||
                other.quoteValidUntil == quoteValidUntil));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      purchaseUuid,
      stripeCheckoutUrl,
      cryptoDotComCheckoutUrl,
      amountUsd,
      amountVfx,
      vfxAddress,
      quoteValidUntil);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_OnrampQuoteResponseCopyWith<_$_OnrampQuoteResponse> get copyWith =>
      __$$_OnrampQuoteResponseCopyWithImpl<_$_OnrampQuoteResponse>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_OnrampQuoteResponseToJson(
      this,
    );
  }
}

abstract class _OnrampQuoteResponse extends OnrampQuoteResponse {
  const factory _OnrampQuoteResponse(
      {@JsonKey(name: "purchase_uuid")
          required final String purchaseUuid,
      @JsonKey(name: 'stripe_checkout_url')
          required final String stripeCheckoutUrl,
      @JsonKey(name: 'crypto_dot_com_checkout_url')
          required final String cryptoDotComCheckoutUrl,
      @JsonKey(name: 'amount_usd')
          required final double amountUsd,
      @JsonKey(name: 'amount_vfx')
          required final double amountVfx,
      @JsonKey(name: 'vfx_address')
          required final String vfxAddress,
      @JsonKey(name: 'quote_valid_until')
          required final DateTime quoteValidUntil}) = _$_OnrampQuoteResponse;
  const _OnrampQuoteResponse._() : super._();

  factory _OnrampQuoteResponse.fromJson(Map<String, dynamic> json) =
      _$_OnrampQuoteResponse.fromJson;

  @override
  @JsonKey(name: "purchase_uuid")
  String get purchaseUuid;
  @override
  @JsonKey(name: 'stripe_checkout_url')
  String get stripeCheckoutUrl;
  @override
  @JsonKey(name: 'crypto_dot_com_checkout_url')
  String get cryptoDotComCheckoutUrl;
  @override
  @JsonKey(name: 'amount_usd')
  double get amountUsd;
  @override
  @JsonKey(name: 'amount_vfx')
  double get amountVfx;
  @override
  @JsonKey(name: 'vfx_address')
  String get vfxAddress;
  @override
  @JsonKey(name: 'quote_valid_until')
  DateTime get quoteValidUntil;
  @override
  @JsonKey(ignore: true)
  _$$_OnrampQuoteResponseCopyWith<_$_OnrampQuoteResponse> get copyWith =>
      throw _privateConstructorUsedError;
}
