// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'p2p_listing.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

P2pRoyalty _$P2pRoyaltyFromJson(Map<String, dynamic> json) {
  return _P2pRoyalty.fromJson(json);
}

/// @nodoc
mixin _$P2pRoyalty {
  String get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'pay_to')
  String get payTo => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $P2pRoyaltyCopyWith<P2pRoyalty> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $P2pRoyaltyCopyWith<$Res> {
  factory $P2pRoyaltyCopyWith(
          P2pRoyalty value, $Res Function(P2pRoyalty) then) =
      _$P2pRoyaltyCopyWithImpl<$Res, P2pRoyalty>;
  @useResult
  $Res call({String amount, @JsonKey(name: 'pay_to') String payTo});
}

/// @nodoc
class _$P2pRoyaltyCopyWithImpl<$Res, $Val extends P2pRoyalty>
    implements $P2pRoyaltyCopyWith<$Res> {
  _$P2pRoyaltyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? amount = null,
    Object? payTo = null,
  }) {
    return _then(_value.copyWith(
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as String,
      payTo: null == payTo
          ? _value.payTo
          : payTo // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_P2pRoyaltyCopyWith<$Res>
    implements $P2pRoyaltyCopyWith<$Res> {
  factory _$$_P2pRoyaltyCopyWith(
          _$_P2pRoyalty value, $Res Function(_$_P2pRoyalty) then) =
      __$$_P2pRoyaltyCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String amount, @JsonKey(name: 'pay_to') String payTo});
}

/// @nodoc
class __$$_P2pRoyaltyCopyWithImpl<$Res>
    extends _$P2pRoyaltyCopyWithImpl<$Res, _$_P2pRoyalty>
    implements _$$_P2pRoyaltyCopyWith<$Res> {
  __$$_P2pRoyaltyCopyWithImpl(
      _$_P2pRoyalty _value, $Res Function(_$_P2pRoyalty) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? amount = null,
    Object? payTo = null,
  }) {
    return _then(_$_P2pRoyalty(
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as String,
      payTo: null == payTo
          ? _value.payTo
          : payTo // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_P2pRoyalty implements _P2pRoyalty {
  _$_P2pRoyalty(
      {required this.amount, @JsonKey(name: 'pay_to') required this.payTo});

  factory _$_P2pRoyalty.fromJson(Map<String, dynamic> json) =>
      _$$_P2pRoyaltyFromJson(json);

  @override
  final String amount;
  @override
  @JsonKey(name: 'pay_to')
  final String payTo;

  @override
  String toString() {
    return 'P2pRoyalty(amount: $amount, payTo: $payTo)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_P2pRoyalty &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.payTo, payTo) || other.payTo == payTo));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, amount, payTo);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_P2pRoyaltyCopyWith<_$_P2pRoyalty> get copyWith =>
      __$$_P2pRoyaltyCopyWithImpl<_$_P2pRoyalty>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_P2pRoyaltyToJson(
      this,
    );
  }
}

abstract class _P2pRoyalty implements P2pRoyalty {
  factory _P2pRoyalty(
      {required final String amount,
      @JsonKey(name: 'pay_to') required final String payTo}) = _$_P2pRoyalty;

  factory _P2pRoyalty.fromJson(Map<String, dynamic> json) =
      _$_P2pRoyalty.fromJson;

  @override
  String get amount;
  @override
  @JsonKey(name: 'pay_to')
  String get payTo;
  @override
  @JsonKey(ignore: true)
  _$$_P2pRoyaltyCopyWith<_$_P2pRoyalty> get copyWith =>
      throw _privateConstructorUsedError;
}

P2pListingNft _$P2pListingNftFromJson(Map<String, dynamic> json) {
  return _P2pListingNft.fromJson(json);
}

/// @nodoc
mixin _$P2pListingNft {
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'minter_name')
  String get minterName => throw _privateConstructorUsedError;
  @JsonKey(name: 'thumbnail_url')
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'asset_url')
  String? get assetUrl => throw _privateConstructorUsedError;
  P2pRoyalty? get royalty => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $P2pListingNftCopyWith<P2pListingNft> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $P2pListingNftCopyWith<$Res> {
  factory $P2pListingNftCopyWith(
          P2pListingNft value, $Res Function(P2pListingNft) then) =
      _$P2pListingNftCopyWithImpl<$Res, P2pListingNft>;
  @useResult
  $Res call(
      {String name,
      String description,
      @JsonKey(name: 'minter_name') String minterName,
      @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
      @JsonKey(name: 'asset_url') String? assetUrl,
      P2pRoyalty? royalty});

  $P2pRoyaltyCopyWith<$Res>? get royalty;
}

/// @nodoc
class _$P2pListingNftCopyWithImpl<$Res, $Val extends P2pListingNft>
    implements $P2pListingNftCopyWith<$Res> {
  _$P2pListingNftCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? minterName = null,
    Object? thumbnailUrl = freezed,
    Object? assetUrl = freezed,
    Object? royalty = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      minterName: null == minterName
          ? _value.minterName
          : minterName // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      assetUrl: freezed == assetUrl
          ? _value.assetUrl
          : assetUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      royalty: freezed == royalty
          ? _value.royalty
          : royalty // ignore: cast_nullable_to_non_nullable
              as P2pRoyalty?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $P2pRoyaltyCopyWith<$Res>? get royalty {
    if (_value.royalty == null) {
      return null;
    }

    return $P2pRoyaltyCopyWith<$Res>(_value.royalty!, (value) {
      return _then(_value.copyWith(royalty: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_P2pListingNftCopyWith<$Res>
    implements $P2pListingNftCopyWith<$Res> {
  factory _$$_P2pListingNftCopyWith(
          _$_P2pListingNft value, $Res Function(_$_P2pListingNft) then) =
      __$$_P2pListingNftCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String description,
      @JsonKey(name: 'minter_name') String minterName,
      @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
      @JsonKey(name: 'asset_url') String? assetUrl,
      P2pRoyalty? royalty});

  @override
  $P2pRoyaltyCopyWith<$Res>? get royalty;
}

/// @nodoc
class __$$_P2pListingNftCopyWithImpl<$Res>
    extends _$P2pListingNftCopyWithImpl<$Res, _$_P2pListingNft>
    implements _$$_P2pListingNftCopyWith<$Res> {
  __$$_P2pListingNftCopyWithImpl(
      _$_P2pListingNft _value, $Res Function(_$_P2pListingNft) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? minterName = null,
    Object? thumbnailUrl = freezed,
    Object? assetUrl = freezed,
    Object? royalty = freezed,
  }) {
    return _then(_$_P2pListingNft(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      minterName: null == minterName
          ? _value.minterName
          : minterName // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      assetUrl: freezed == assetUrl
          ? _value.assetUrl
          : assetUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      royalty: freezed == royalty
          ? _value.royalty
          : royalty // ignore: cast_nullable_to_non_nullable
              as P2pRoyalty?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_P2pListingNft implements _P2pListingNft {
  _$_P2pListingNft(
      {this.name = '',
      this.description = '',
      @JsonKey(name: 'minter_name') this.minterName = '',
      @JsonKey(name: 'thumbnail_url') this.thumbnailUrl,
      @JsonKey(name: 'asset_url') this.assetUrl,
      this.royalty});

  factory _$_P2pListingNft.fromJson(Map<String, dynamic> json) =>
      _$$_P2pListingNftFromJson(json);

  @override
  @JsonKey()
  final String name;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey(name: 'minter_name')
  final String minterName;
  @override
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;
  @override
  @JsonKey(name: 'asset_url')
  final String? assetUrl;
  @override
  final P2pRoyalty? royalty;

  @override
  String toString() {
    return 'P2pListingNft(name: $name, description: $description, minterName: $minterName, thumbnailUrl: $thumbnailUrl, assetUrl: $assetUrl, royalty: $royalty)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_P2pListingNft &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.minterName, minterName) ||
                other.minterName == minterName) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.assetUrl, assetUrl) ||
                other.assetUrl == assetUrl) &&
            (identical(other.royalty, royalty) || other.royalty == royalty));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, name, description, minterName,
      thumbnailUrl, assetUrl, royalty);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_P2pListingNftCopyWith<_$_P2pListingNft> get copyWith =>
      __$$_P2pListingNftCopyWithImpl<_$_P2pListingNft>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_P2pListingNftToJson(
      this,
    );
  }
}

abstract class _P2pListingNft implements P2pListingNft {
  factory _P2pListingNft(
      {final String name,
      final String description,
      @JsonKey(name: 'minter_name') final String minterName,
      @JsonKey(name: 'thumbnail_url') final String? thumbnailUrl,
      @JsonKey(name: 'asset_url') final String? assetUrl,
      final P2pRoyalty? royalty}) = _$_P2pListingNft;

  factory _P2pListingNft.fromJson(Map<String, dynamic> json) =
      _$_P2pListingNft.fromJson;

  @override
  String get name;
  @override
  String get description;
  @override
  @JsonKey(name: 'minter_name')
  String get minterName;
  @override
  @JsonKey(name: 'thumbnail_url')
  String? get thumbnailUrl;
  @override
  @JsonKey(name: 'asset_url')
  String? get assetUrl;
  @override
  P2pRoyalty? get royalty;
  @override
  @JsonKey(ignore: true)
  _$$_P2pListingNftCopyWith<_$_P2pListingNft> get copyWith =>
      throw _privateConstructorUsedError;
}

P2pHighBid _$P2pHighBidFromJson(Map<String, dynamic> json) {
  return _P2pHighBid.fromJson(json);
}

/// @nodoc
mixin _$P2pHighBid {
  String get amount => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  DateTime? get at => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $P2pHighBidCopyWith<P2pHighBid> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $P2pHighBidCopyWith<$Res> {
  factory $P2pHighBidCopyWith(
          P2pHighBid value, $Res Function(P2pHighBid) then) =
      _$P2pHighBidCopyWithImpl<$Res, P2pHighBid>;
  @useResult
  $Res call({String amount, String address, DateTime? at});
}

/// @nodoc
class _$P2pHighBidCopyWithImpl<$Res, $Val extends P2pHighBid>
    implements $P2pHighBidCopyWith<$Res> {
  _$P2pHighBidCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? amount = null,
    Object? address = null,
    Object? at = freezed,
  }) {
    return _then(_value.copyWith(
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      at: freezed == at
          ? _value.at
          : at // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_P2pHighBidCopyWith<$Res>
    implements $P2pHighBidCopyWith<$Res> {
  factory _$$_P2pHighBidCopyWith(
          _$_P2pHighBid value, $Res Function(_$_P2pHighBid) then) =
      __$$_P2pHighBidCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String amount, String address, DateTime? at});
}

/// @nodoc
class __$$_P2pHighBidCopyWithImpl<$Res>
    extends _$P2pHighBidCopyWithImpl<$Res, _$_P2pHighBid>
    implements _$$_P2pHighBidCopyWith<$Res> {
  __$$_P2pHighBidCopyWithImpl(
      _$_P2pHighBid _value, $Res Function(_$_P2pHighBid) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? amount = null,
    Object? address = null,
    Object? at = freezed,
  }) {
    return _then(_$_P2pHighBid(
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      at: freezed == at
          ? _value.at
          : at // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_P2pHighBid implements _P2pHighBid {
  _$_P2pHighBid({required this.amount, required this.address, this.at});

  factory _$_P2pHighBid.fromJson(Map<String, dynamic> json) =>
      _$$_P2pHighBidFromJson(json);

  @override
  final String amount;
  @override
  final String address;
  @override
  final DateTime? at;

  @override
  String toString() {
    return 'P2pHighBid(amount: $amount, address: $address, at: $at)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_P2pHighBid &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.at, at) || other.at == at));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, amount, address, at);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_P2pHighBidCopyWith<_$_P2pHighBid> get copyWith =>
      __$$_P2pHighBidCopyWithImpl<_$_P2pHighBid>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_P2pHighBidToJson(
      this,
    );
  }
}

abstract class _P2pHighBid implements P2pHighBid {
  factory _P2pHighBid(
      {required final String amount,
      required final String address,
      final DateTime? at}) = _$_P2pHighBid;

  factory _P2pHighBid.fromJson(Map<String, dynamic> json) =
      _$_P2pHighBid.fromJson;

  @override
  String get amount;
  @override
  String get address;
  @override
  DateTime? get at;
  @override
  @JsonKey(ignore: true)
  _$$_P2pHighBidCopyWith<_$_P2pHighBid> get copyWith =>
      throw _privateConstructorUsedError;
}

P2pSale _$P2pSaleFromJson(Map<String, dynamic> json) {
  return _P2pSale.fromJson(json);
}

/// @nodoc
mixin _$P2pSale {
  P2pTxDescription? get start => throw _privateConstructorUsedError;
  P2pTxDescription? get complete => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $P2pSaleCopyWith<P2pSale> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $P2pSaleCopyWith<$Res> {
  factory $P2pSaleCopyWith(P2pSale value, $Res Function(P2pSale) then) =
      _$P2pSaleCopyWithImpl<$Res, P2pSale>;
  @useResult
  $Res call({P2pTxDescription? start, P2pTxDescription? complete});

  $P2pTxDescriptionCopyWith<$Res>? get start;
  $P2pTxDescriptionCopyWith<$Res>? get complete;
}

/// @nodoc
class _$P2pSaleCopyWithImpl<$Res, $Val extends P2pSale>
    implements $P2pSaleCopyWith<$Res> {
  _$P2pSaleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? start = freezed,
    Object? complete = freezed,
  }) {
    return _then(_value.copyWith(
      start: freezed == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as P2pTxDescription?,
      complete: freezed == complete
          ? _value.complete
          : complete // ignore: cast_nullable_to_non_nullable
              as P2pTxDescription?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $P2pTxDescriptionCopyWith<$Res>? get start {
    if (_value.start == null) {
      return null;
    }

    return $P2pTxDescriptionCopyWith<$Res>(_value.start!, (value) {
      return _then(_value.copyWith(start: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $P2pTxDescriptionCopyWith<$Res>? get complete {
    if (_value.complete == null) {
      return null;
    }

    return $P2pTxDescriptionCopyWith<$Res>(_value.complete!, (value) {
      return _then(_value.copyWith(complete: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_P2pSaleCopyWith<$Res> implements $P2pSaleCopyWith<$Res> {
  factory _$$_P2pSaleCopyWith(
          _$_P2pSale value, $Res Function(_$_P2pSale) then) =
      __$$_P2pSaleCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({P2pTxDescription? start, P2pTxDescription? complete});

  @override
  $P2pTxDescriptionCopyWith<$Res>? get start;
  @override
  $P2pTxDescriptionCopyWith<$Res>? get complete;
}

/// @nodoc
class __$$_P2pSaleCopyWithImpl<$Res>
    extends _$P2pSaleCopyWithImpl<$Res, _$_P2pSale>
    implements _$$_P2pSaleCopyWith<$Res> {
  __$$_P2pSaleCopyWithImpl(_$_P2pSale _value, $Res Function(_$_P2pSale) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? start = freezed,
    Object? complete = freezed,
  }) {
    return _then(_$_P2pSale(
      start: freezed == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as P2pTxDescription?,
      complete: freezed == complete
          ? _value.complete
          : complete // ignore: cast_nullable_to_non_nullable
              as P2pTxDescription?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_P2pSale implements _P2pSale {
  _$_P2pSale({this.start, this.complete});

  factory _$_P2pSale.fromJson(Map<String, dynamic> json) =>
      _$$_P2pSaleFromJson(json);

  @override
  final P2pTxDescription? start;
  @override
  final P2pTxDescription? complete;

  @override
  String toString() {
    return 'P2pSale(start: $start, complete: $complete)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_P2pSale &&
            (identical(other.start, start) || other.start == start) &&
            (identical(other.complete, complete) ||
                other.complete == complete));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, start, complete);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_P2pSaleCopyWith<_$_P2pSale> get copyWith =>
      __$$_P2pSaleCopyWithImpl<_$_P2pSale>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_P2pSaleToJson(
      this,
    );
  }
}

abstract class _P2pSale implements P2pSale {
  factory _P2pSale(
      {final P2pTxDescription? start,
      final P2pTxDescription? complete}) = _$_P2pSale;

  factory _P2pSale.fromJson(Map<String, dynamic> json) = _$_P2pSale.fromJson;

  @override
  P2pTxDescription? get start;
  @override
  P2pTxDescription? get complete;
  @override
  @JsonKey(ignore: true)
  _$$_P2pSaleCopyWith<_$_P2pSale> get copyWith =>
      throw _privateConstructorUsedError;
}

P2pListing _$P2pListingFromJson(Map<String, dynamic> json) {
  return _P2pListing.fromJson(json);
}

/// @nodoc
mixin _$P2pListing {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'shop_url')
  String get shopUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'collection_id')
  int? get collectionId => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: P2pListingState.unknown)
  P2pListingState get state => throw _privateConstructorUsedError;
  @JsonKey(name: 'smart_contract_uid')
  String get smartContractUid => throw _privateConstructorUsedError;
  P2pListingNft? get nft => throw _privateConstructorUsedError;
  @JsonKey(name: 'seller_address')
  String get sellerAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'buy_now_price')
  String? get buyNowPrice =>
      throw _privateConstructorUsedError; // An auction's opening price; null for a buy-now-only listing.
  @JsonKey(name: 'floor_price')
  String? get floorPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'reserve_price')
  String? get reservePrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'reserve_met')
  bool get reserveMet => throw _privateConstructorUsedError;
  @JsonKey(name: 'starts_at')
  DateTime? get startsAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'ends_at')
  DateTime? get endsAt =>
      throw _privateConstructorUsedError; // Core's KeySign: signed into every bid. New for every listing.
  @JsonKey(name: 'purchase_key')
  String get purchaseKey => throw _privateConstructorUsedError;
  @JsonKey(name: 'high_bid')
  P2pHighBid? get highBid => throw _privateConstructorUsedError;
  @JsonKey(name: 'bid_count')
  int get bidCount =>
      throw _privateConstructorUsedError; // What the next auction bid must at least be; null for buy-now only.
  @JsonKey(name: 'next_min_bid')
  String? get nextMinBid => throw _privateConstructorUsedError;
  @JsonKey(name: 'winner_address')
  String? get winnerAddress =>
      throw _privateConstructorUsedError; // When `awaitingSaleStart` turns `unfulfilled`: 48 hours after the win.
  @JsonKey(name: 'sale_start_deadline')
  DateTime? get saleStartDeadline => throw _privateConstructorUsedError;
  @JsonKey(name: 'sold_price')
  String? get soldPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'chain_state', unknownEnumValue: P2pListingChainState.unknown)
  P2pListingChainState get chainState => throw _privateConstructorUsedError;
  P2pSale? get sale => throw _privateConstructorUsedError;
  @JsonKey(name: 'royalty_enforced')
  bool get royaltyEnforced =>
      throw _privateConstructorUsedError; // Why it closed without a sale (`nft_moved`, `shop_deleted`, ...), or
// null. An open set: shown as detail beside the state.
  @JsonKey(name: 'end_reason')
  String? get endReason =>
      throw _privateConstructorUsedError; // On the listing's own page only: its newest 100 bids, newest first.
  List<P2pBidSummary>? get bids => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $P2pListingCopyWith<P2pListing> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $P2pListingCopyWith<$Res> {
  factory $P2pListingCopyWith(
          P2pListing value, $Res Function(P2pListing) then) =
      _$P2pListingCopyWithImpl<$Res, P2pListing>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'shop_url')
          String shopUrl,
      @JsonKey(name: 'collection_id')
          int? collectionId,
      @JsonKey(unknownEnumValue: P2pListingState.unknown)
          P2pListingState state,
      @JsonKey(name: 'smart_contract_uid')
          String smartContractUid,
      P2pListingNft? nft,
      @JsonKey(name: 'seller_address')
          String sellerAddress,
      @JsonKey(name: 'buy_now_price')
          String? buyNowPrice,
      @JsonKey(name: 'floor_price')
          String? floorPrice,
      @JsonKey(name: 'reserve_price')
          String? reservePrice,
      @JsonKey(name: 'reserve_met')
          bool reserveMet,
      @JsonKey(name: 'starts_at')
          DateTime? startsAt,
      @JsonKey(name: 'ends_at')
          DateTime? endsAt,
      @JsonKey(name: 'purchase_key')
          String purchaseKey,
      @JsonKey(name: 'high_bid')
          P2pHighBid? highBid,
      @JsonKey(name: 'bid_count')
          int bidCount,
      @JsonKey(name: 'next_min_bid')
          String? nextMinBid,
      @JsonKey(name: 'winner_address')
          String? winnerAddress,
      @JsonKey(name: 'sale_start_deadline')
          DateTime? saleStartDeadline,
      @JsonKey(name: 'sold_price')
          String? soldPrice,
      @JsonKey(name: 'chain_state', unknownEnumValue: P2pListingChainState.unknown)
          P2pListingChainState chainState,
      P2pSale? sale,
      @JsonKey(name: 'royalty_enforced')
          bool royaltyEnforced,
      @JsonKey(name: 'end_reason')
          String? endReason,
      List<P2pBidSummary>? bids});

  $P2pListingNftCopyWith<$Res>? get nft;
  $P2pHighBidCopyWith<$Res>? get highBid;
  $P2pSaleCopyWith<$Res>? get sale;
}

/// @nodoc
class _$P2pListingCopyWithImpl<$Res, $Val extends P2pListing>
    implements $P2pListingCopyWith<$Res> {
  _$P2pListingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? shopUrl = null,
    Object? collectionId = freezed,
    Object? state = null,
    Object? smartContractUid = null,
    Object? nft = freezed,
    Object? sellerAddress = null,
    Object? buyNowPrice = freezed,
    Object? floorPrice = freezed,
    Object? reservePrice = freezed,
    Object? reserveMet = null,
    Object? startsAt = freezed,
    Object? endsAt = freezed,
    Object? purchaseKey = null,
    Object? highBid = freezed,
    Object? bidCount = null,
    Object? nextMinBid = freezed,
    Object? winnerAddress = freezed,
    Object? saleStartDeadline = freezed,
    Object? soldPrice = freezed,
    Object? chainState = null,
    Object? sale = freezed,
    Object? royaltyEnforced = null,
    Object? endReason = freezed,
    Object? bids = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      shopUrl: null == shopUrl
          ? _value.shopUrl
          : shopUrl // ignore: cast_nullable_to_non_nullable
              as String,
      collectionId: freezed == collectionId
          ? _value.collectionId
          : collectionId // ignore: cast_nullable_to_non_nullable
              as int?,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as P2pListingState,
      smartContractUid: null == smartContractUid
          ? _value.smartContractUid
          : smartContractUid // ignore: cast_nullable_to_non_nullable
              as String,
      nft: freezed == nft
          ? _value.nft
          : nft // ignore: cast_nullable_to_non_nullable
              as P2pListingNft?,
      sellerAddress: null == sellerAddress
          ? _value.sellerAddress
          : sellerAddress // ignore: cast_nullable_to_non_nullable
              as String,
      buyNowPrice: freezed == buyNowPrice
          ? _value.buyNowPrice
          : buyNowPrice // ignore: cast_nullable_to_non_nullable
              as String?,
      floorPrice: freezed == floorPrice
          ? _value.floorPrice
          : floorPrice // ignore: cast_nullable_to_non_nullable
              as String?,
      reservePrice: freezed == reservePrice
          ? _value.reservePrice
          : reservePrice // ignore: cast_nullable_to_non_nullable
              as String?,
      reserveMet: null == reserveMet
          ? _value.reserveMet
          : reserveMet // ignore: cast_nullable_to_non_nullable
              as bool,
      startsAt: freezed == startsAt
          ? _value.startsAt
          : startsAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endsAt: freezed == endsAt
          ? _value.endsAt
          : endsAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      purchaseKey: null == purchaseKey
          ? _value.purchaseKey
          : purchaseKey // ignore: cast_nullable_to_non_nullable
              as String,
      highBid: freezed == highBid
          ? _value.highBid
          : highBid // ignore: cast_nullable_to_non_nullable
              as P2pHighBid?,
      bidCount: null == bidCount
          ? _value.bidCount
          : bidCount // ignore: cast_nullable_to_non_nullable
              as int,
      nextMinBid: freezed == nextMinBid
          ? _value.nextMinBid
          : nextMinBid // ignore: cast_nullable_to_non_nullable
              as String?,
      winnerAddress: freezed == winnerAddress
          ? _value.winnerAddress
          : winnerAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      saleStartDeadline: freezed == saleStartDeadline
          ? _value.saleStartDeadline
          : saleStartDeadline // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      soldPrice: freezed == soldPrice
          ? _value.soldPrice
          : soldPrice // ignore: cast_nullable_to_non_nullable
              as String?,
      chainState: null == chainState
          ? _value.chainState
          : chainState // ignore: cast_nullable_to_non_nullable
              as P2pListingChainState,
      sale: freezed == sale
          ? _value.sale
          : sale // ignore: cast_nullable_to_non_nullable
              as P2pSale?,
      royaltyEnforced: null == royaltyEnforced
          ? _value.royaltyEnforced
          : royaltyEnforced // ignore: cast_nullable_to_non_nullable
              as bool,
      endReason: freezed == endReason
          ? _value.endReason
          : endReason // ignore: cast_nullable_to_non_nullable
              as String?,
      bids: freezed == bids
          ? _value.bids
          : bids // ignore: cast_nullable_to_non_nullable
              as List<P2pBidSummary>?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $P2pListingNftCopyWith<$Res>? get nft {
    if (_value.nft == null) {
      return null;
    }

    return $P2pListingNftCopyWith<$Res>(_value.nft!, (value) {
      return _then(_value.copyWith(nft: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $P2pHighBidCopyWith<$Res>? get highBid {
    if (_value.highBid == null) {
      return null;
    }

    return $P2pHighBidCopyWith<$Res>(_value.highBid!, (value) {
      return _then(_value.copyWith(highBid: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $P2pSaleCopyWith<$Res>? get sale {
    if (_value.sale == null) {
      return null;
    }

    return $P2pSaleCopyWith<$Res>(_value.sale!, (value) {
      return _then(_value.copyWith(sale: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_P2pListingCopyWith<$Res>
    implements $P2pListingCopyWith<$Res> {
  factory _$$_P2pListingCopyWith(
          _$_P2pListing value, $Res Function(_$_P2pListing) then) =
      __$$_P2pListingCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'shop_url')
          String shopUrl,
      @JsonKey(name: 'collection_id')
          int? collectionId,
      @JsonKey(unknownEnumValue: P2pListingState.unknown)
          P2pListingState state,
      @JsonKey(name: 'smart_contract_uid')
          String smartContractUid,
      P2pListingNft? nft,
      @JsonKey(name: 'seller_address')
          String sellerAddress,
      @JsonKey(name: 'buy_now_price')
          String? buyNowPrice,
      @JsonKey(name: 'floor_price')
          String? floorPrice,
      @JsonKey(name: 'reserve_price')
          String? reservePrice,
      @JsonKey(name: 'reserve_met')
          bool reserveMet,
      @JsonKey(name: 'starts_at')
          DateTime? startsAt,
      @JsonKey(name: 'ends_at')
          DateTime? endsAt,
      @JsonKey(name: 'purchase_key')
          String purchaseKey,
      @JsonKey(name: 'high_bid')
          P2pHighBid? highBid,
      @JsonKey(name: 'bid_count')
          int bidCount,
      @JsonKey(name: 'next_min_bid')
          String? nextMinBid,
      @JsonKey(name: 'winner_address')
          String? winnerAddress,
      @JsonKey(name: 'sale_start_deadline')
          DateTime? saleStartDeadline,
      @JsonKey(name: 'sold_price')
          String? soldPrice,
      @JsonKey(name: 'chain_state', unknownEnumValue: P2pListingChainState.unknown)
          P2pListingChainState chainState,
      P2pSale? sale,
      @JsonKey(name: 'royalty_enforced')
          bool royaltyEnforced,
      @JsonKey(name: 'end_reason')
          String? endReason,
      List<P2pBidSummary>? bids});

  @override
  $P2pListingNftCopyWith<$Res>? get nft;
  @override
  $P2pHighBidCopyWith<$Res>? get highBid;
  @override
  $P2pSaleCopyWith<$Res>? get sale;
}

/// @nodoc
class __$$_P2pListingCopyWithImpl<$Res>
    extends _$P2pListingCopyWithImpl<$Res, _$_P2pListing>
    implements _$$_P2pListingCopyWith<$Res> {
  __$$_P2pListingCopyWithImpl(
      _$_P2pListing _value, $Res Function(_$_P2pListing) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? shopUrl = null,
    Object? collectionId = freezed,
    Object? state = null,
    Object? smartContractUid = null,
    Object? nft = freezed,
    Object? sellerAddress = null,
    Object? buyNowPrice = freezed,
    Object? floorPrice = freezed,
    Object? reservePrice = freezed,
    Object? reserveMet = null,
    Object? startsAt = freezed,
    Object? endsAt = freezed,
    Object? purchaseKey = null,
    Object? highBid = freezed,
    Object? bidCount = null,
    Object? nextMinBid = freezed,
    Object? winnerAddress = freezed,
    Object? saleStartDeadline = freezed,
    Object? soldPrice = freezed,
    Object? chainState = null,
    Object? sale = freezed,
    Object? royaltyEnforced = null,
    Object? endReason = freezed,
    Object? bids = freezed,
  }) {
    return _then(_$_P2pListing(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      shopUrl: null == shopUrl
          ? _value.shopUrl
          : shopUrl // ignore: cast_nullable_to_non_nullable
              as String,
      collectionId: freezed == collectionId
          ? _value.collectionId
          : collectionId // ignore: cast_nullable_to_non_nullable
              as int?,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as P2pListingState,
      smartContractUid: null == smartContractUid
          ? _value.smartContractUid
          : smartContractUid // ignore: cast_nullable_to_non_nullable
              as String,
      nft: freezed == nft
          ? _value.nft
          : nft // ignore: cast_nullable_to_non_nullable
              as P2pListingNft?,
      sellerAddress: null == sellerAddress
          ? _value.sellerAddress
          : sellerAddress // ignore: cast_nullable_to_non_nullable
              as String,
      buyNowPrice: freezed == buyNowPrice
          ? _value.buyNowPrice
          : buyNowPrice // ignore: cast_nullable_to_non_nullable
              as String?,
      floorPrice: freezed == floorPrice
          ? _value.floorPrice
          : floorPrice // ignore: cast_nullable_to_non_nullable
              as String?,
      reservePrice: freezed == reservePrice
          ? _value.reservePrice
          : reservePrice // ignore: cast_nullable_to_non_nullable
              as String?,
      reserveMet: null == reserveMet
          ? _value.reserveMet
          : reserveMet // ignore: cast_nullable_to_non_nullable
              as bool,
      startsAt: freezed == startsAt
          ? _value.startsAt
          : startsAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endsAt: freezed == endsAt
          ? _value.endsAt
          : endsAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      purchaseKey: null == purchaseKey
          ? _value.purchaseKey
          : purchaseKey // ignore: cast_nullable_to_non_nullable
              as String,
      highBid: freezed == highBid
          ? _value.highBid
          : highBid // ignore: cast_nullable_to_non_nullable
              as P2pHighBid?,
      bidCount: null == bidCount
          ? _value.bidCount
          : bidCount // ignore: cast_nullable_to_non_nullable
              as int,
      nextMinBid: freezed == nextMinBid
          ? _value.nextMinBid
          : nextMinBid // ignore: cast_nullable_to_non_nullable
              as String?,
      winnerAddress: freezed == winnerAddress
          ? _value.winnerAddress
          : winnerAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      saleStartDeadline: freezed == saleStartDeadline
          ? _value.saleStartDeadline
          : saleStartDeadline // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      soldPrice: freezed == soldPrice
          ? _value.soldPrice
          : soldPrice // ignore: cast_nullable_to_non_nullable
              as String?,
      chainState: null == chainState
          ? _value.chainState
          : chainState // ignore: cast_nullable_to_non_nullable
              as P2pListingChainState,
      sale: freezed == sale
          ? _value.sale
          : sale // ignore: cast_nullable_to_non_nullable
              as P2pSale?,
      royaltyEnforced: null == royaltyEnforced
          ? _value.royaltyEnforced
          : royaltyEnforced // ignore: cast_nullable_to_non_nullable
              as bool,
      endReason: freezed == endReason
          ? _value.endReason
          : endReason // ignore: cast_nullable_to_non_nullable
              as String?,
      bids: freezed == bids
          ? _value._bids
          : bids // ignore: cast_nullable_to_non_nullable
              as List<P2pBidSummary>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_P2pListing extends _P2pListing {
  _$_P2pListing(
      {required this.id,
      @JsonKey(name: 'shop_url')
          required this.shopUrl,
      @JsonKey(name: 'collection_id')
          this.collectionId,
      @JsonKey(unknownEnumValue: P2pListingState.unknown)
          this.state = P2pListingState.unknown,
      @JsonKey(name: 'smart_contract_uid')
          required this.smartContractUid,
      this.nft,
      @JsonKey(name: 'seller_address')
          required this.sellerAddress,
      @JsonKey(name: 'buy_now_price')
          this.buyNowPrice,
      @JsonKey(name: 'floor_price')
          this.floorPrice,
      @JsonKey(name: 'reserve_price')
          this.reservePrice,
      @JsonKey(name: 'reserve_met')
          this.reserveMet = false,
      @JsonKey(name: 'starts_at')
          this.startsAt,
      @JsonKey(name: 'ends_at')
          this.endsAt,
      @JsonKey(name: 'purchase_key')
          required this.purchaseKey,
      @JsonKey(name: 'high_bid')
          this.highBid,
      @JsonKey(name: 'bid_count')
          this.bidCount = 0,
      @JsonKey(name: 'next_min_bid')
          this.nextMinBid,
      @JsonKey(name: 'winner_address')
          this.winnerAddress,
      @JsonKey(name: 'sale_start_deadline')
          this.saleStartDeadline,
      @JsonKey(name: 'sold_price')
          this.soldPrice,
      @JsonKey(name: 'chain_state', unknownEnumValue: P2pListingChainState.unknown)
          this.chainState = P2pListingChainState.unknown,
      this.sale,
      @JsonKey(name: 'royalty_enforced')
          this.royaltyEnforced = true,
      @JsonKey(name: 'end_reason')
          this.endReason,
      final List<P2pBidSummary>? bids})
      : _bids = bids,
        super._();

  factory _$_P2pListing.fromJson(Map<String, dynamic> json) =>
      _$$_P2pListingFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'shop_url')
  final String shopUrl;
  @override
  @JsonKey(name: 'collection_id')
  final int? collectionId;
  @override
  @JsonKey(unknownEnumValue: P2pListingState.unknown)
  final P2pListingState state;
  @override
  @JsonKey(name: 'smart_contract_uid')
  final String smartContractUid;
  @override
  final P2pListingNft? nft;
  @override
  @JsonKey(name: 'seller_address')
  final String sellerAddress;
  @override
  @JsonKey(name: 'buy_now_price')
  final String? buyNowPrice;
// An auction's opening price; null for a buy-now-only listing.
  @override
  @JsonKey(name: 'floor_price')
  final String? floorPrice;
  @override
  @JsonKey(name: 'reserve_price')
  final String? reservePrice;
  @override
  @JsonKey(name: 'reserve_met')
  final bool reserveMet;
  @override
  @JsonKey(name: 'starts_at')
  final DateTime? startsAt;
  @override
  @JsonKey(name: 'ends_at')
  final DateTime? endsAt;
// Core's KeySign: signed into every bid. New for every listing.
  @override
  @JsonKey(name: 'purchase_key')
  final String purchaseKey;
  @override
  @JsonKey(name: 'high_bid')
  final P2pHighBid? highBid;
  @override
  @JsonKey(name: 'bid_count')
  final int bidCount;
// What the next auction bid must at least be; null for buy-now only.
  @override
  @JsonKey(name: 'next_min_bid')
  final String? nextMinBid;
  @override
  @JsonKey(name: 'winner_address')
  final String? winnerAddress;
// When `awaitingSaleStart` turns `unfulfilled`: 48 hours after the win.
  @override
  @JsonKey(name: 'sale_start_deadline')
  final DateTime? saleStartDeadline;
  @override
  @JsonKey(name: 'sold_price')
  final String? soldPrice;
  @override
  @JsonKey(name: 'chain_state', unknownEnumValue: P2pListingChainState.unknown)
  final P2pListingChainState chainState;
  @override
  final P2pSale? sale;
  @override
  @JsonKey(name: 'royalty_enforced')
  final bool royaltyEnforced;
// Why it closed without a sale (`nft_moved`, `shop_deleted`, ...), or
// null. An open set: shown as detail beside the state.
  @override
  @JsonKey(name: 'end_reason')
  final String? endReason;
// On the listing's own page only: its newest 100 bids, newest first.
  final List<P2pBidSummary>? _bids;
// On the listing's own page only: its newest 100 bids, newest first.
  @override
  List<P2pBidSummary>? get bids {
    final value = _bids;
    if (value == null) return null;
    if (_bids is EqualUnmodifiableListView) return _bids;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'P2pListing(id: $id, shopUrl: $shopUrl, collectionId: $collectionId, state: $state, smartContractUid: $smartContractUid, nft: $nft, sellerAddress: $sellerAddress, buyNowPrice: $buyNowPrice, floorPrice: $floorPrice, reservePrice: $reservePrice, reserveMet: $reserveMet, startsAt: $startsAt, endsAt: $endsAt, purchaseKey: $purchaseKey, highBid: $highBid, bidCount: $bidCount, nextMinBid: $nextMinBid, winnerAddress: $winnerAddress, saleStartDeadline: $saleStartDeadline, soldPrice: $soldPrice, chainState: $chainState, sale: $sale, royaltyEnforced: $royaltyEnforced, endReason: $endReason, bids: $bids)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_P2pListing &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.shopUrl, shopUrl) || other.shopUrl == shopUrl) &&
            (identical(other.collectionId, collectionId) ||
                other.collectionId == collectionId) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.smartContractUid, smartContractUid) ||
                other.smartContractUid == smartContractUid) &&
            (identical(other.nft, nft) || other.nft == nft) &&
            (identical(other.sellerAddress, sellerAddress) ||
                other.sellerAddress == sellerAddress) &&
            (identical(other.buyNowPrice, buyNowPrice) ||
                other.buyNowPrice == buyNowPrice) &&
            (identical(other.floorPrice, floorPrice) ||
                other.floorPrice == floorPrice) &&
            (identical(other.reservePrice, reservePrice) ||
                other.reservePrice == reservePrice) &&
            (identical(other.reserveMet, reserveMet) ||
                other.reserveMet == reserveMet) &&
            (identical(other.startsAt, startsAt) ||
                other.startsAt == startsAt) &&
            (identical(other.endsAt, endsAt) || other.endsAt == endsAt) &&
            (identical(other.purchaseKey, purchaseKey) ||
                other.purchaseKey == purchaseKey) &&
            (identical(other.highBid, highBid) || other.highBid == highBid) &&
            (identical(other.bidCount, bidCount) ||
                other.bidCount == bidCount) &&
            (identical(other.nextMinBid, nextMinBid) ||
                other.nextMinBid == nextMinBid) &&
            (identical(other.winnerAddress, winnerAddress) ||
                other.winnerAddress == winnerAddress) &&
            (identical(other.saleStartDeadline, saleStartDeadline) ||
                other.saleStartDeadline == saleStartDeadline) &&
            (identical(other.soldPrice, soldPrice) ||
                other.soldPrice == soldPrice) &&
            (identical(other.chainState, chainState) ||
                other.chainState == chainState) &&
            (identical(other.sale, sale) || other.sale == sale) &&
            (identical(other.royaltyEnforced, royaltyEnforced) ||
                other.royaltyEnforced == royaltyEnforced) &&
            (identical(other.endReason, endReason) ||
                other.endReason == endReason) &&
            const DeepCollectionEquality().equals(other._bids, _bids));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        shopUrl,
        collectionId,
        state,
        smartContractUid,
        nft,
        sellerAddress,
        buyNowPrice,
        floorPrice,
        reservePrice,
        reserveMet,
        startsAt,
        endsAt,
        purchaseKey,
        highBid,
        bidCount,
        nextMinBid,
        winnerAddress,
        saleStartDeadline,
        soldPrice,
        chainState,
        sale,
        royaltyEnforced,
        endReason,
        const DeepCollectionEquality().hash(_bids)
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_P2pListingCopyWith<_$_P2pListing> get copyWith =>
      __$$_P2pListingCopyWithImpl<_$_P2pListing>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_P2pListingToJson(
      this,
    );
  }
}

abstract class _P2pListing extends P2pListing {
  factory _P2pListing(
      {required final int id,
      @JsonKey(name: 'shop_url')
          required final String shopUrl,
      @JsonKey(name: 'collection_id')
          final int? collectionId,
      @JsonKey(unknownEnumValue: P2pListingState.unknown)
          final P2pListingState state,
      @JsonKey(name: 'smart_contract_uid')
          required final String smartContractUid,
      final P2pListingNft? nft,
      @JsonKey(name: 'seller_address')
          required final String sellerAddress,
      @JsonKey(name: 'buy_now_price')
          final String? buyNowPrice,
      @JsonKey(name: 'floor_price')
          final String? floorPrice,
      @JsonKey(name: 'reserve_price')
          final String? reservePrice,
      @JsonKey(name: 'reserve_met')
          final bool reserveMet,
      @JsonKey(name: 'starts_at')
          final DateTime? startsAt,
      @JsonKey(name: 'ends_at')
          final DateTime? endsAt,
      @JsonKey(name: 'purchase_key')
          required final String purchaseKey,
      @JsonKey(name: 'high_bid')
          final P2pHighBid? highBid,
      @JsonKey(name: 'bid_count')
          final int bidCount,
      @JsonKey(name: 'next_min_bid')
          final String? nextMinBid,
      @JsonKey(name: 'winner_address')
          final String? winnerAddress,
      @JsonKey(name: 'sale_start_deadline')
          final DateTime? saleStartDeadline,
      @JsonKey(name: 'sold_price')
          final String? soldPrice,
      @JsonKey(name: 'chain_state', unknownEnumValue: P2pListingChainState.unknown)
          final P2pListingChainState chainState,
      final P2pSale? sale,
      @JsonKey(name: 'royalty_enforced')
          final bool royaltyEnforced,
      @JsonKey(name: 'end_reason')
          final String? endReason,
      final List<P2pBidSummary>? bids}) = _$_P2pListing;
  _P2pListing._() : super._();

  factory _P2pListing.fromJson(Map<String, dynamic> json) =
      _$_P2pListing.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'shop_url')
  String get shopUrl;
  @override
  @JsonKey(name: 'collection_id')
  int? get collectionId;
  @override
  @JsonKey(unknownEnumValue: P2pListingState.unknown)
  P2pListingState get state;
  @override
  @JsonKey(name: 'smart_contract_uid')
  String get smartContractUid;
  @override
  P2pListingNft? get nft;
  @override
  @JsonKey(name: 'seller_address')
  String get sellerAddress;
  @override
  @JsonKey(name: 'buy_now_price')
  String? get buyNowPrice;
  @override // An auction's opening price; null for a buy-now-only listing.
  @JsonKey(name: 'floor_price')
  String? get floorPrice;
  @override
  @JsonKey(name: 'reserve_price')
  String? get reservePrice;
  @override
  @JsonKey(name: 'reserve_met')
  bool get reserveMet;
  @override
  @JsonKey(name: 'starts_at')
  DateTime? get startsAt;
  @override
  @JsonKey(name: 'ends_at')
  DateTime? get endsAt;
  @override // Core's KeySign: signed into every bid. New for every listing.
  @JsonKey(name: 'purchase_key')
  String get purchaseKey;
  @override
  @JsonKey(name: 'high_bid')
  P2pHighBid? get highBid;
  @override
  @JsonKey(name: 'bid_count')
  int get bidCount;
  @override // What the next auction bid must at least be; null for buy-now only.
  @JsonKey(name: 'next_min_bid')
  String? get nextMinBid;
  @override
  @JsonKey(name: 'winner_address')
  String? get winnerAddress;
  @override // When `awaitingSaleStart` turns `unfulfilled`: 48 hours after the win.
  @JsonKey(name: 'sale_start_deadline')
  DateTime? get saleStartDeadline;
  @override
  @JsonKey(name: 'sold_price')
  String? get soldPrice;
  @override
  @JsonKey(name: 'chain_state', unknownEnumValue: P2pListingChainState.unknown)
  P2pListingChainState get chainState;
  @override
  P2pSale? get sale;
  @override
  @JsonKey(name: 'royalty_enforced')
  bool get royaltyEnforced;
  @override // Why it closed without a sale (`nft_moved`, `shop_deleted`, ...), or
// null. An open set: shown as detail beside the state.
  @JsonKey(name: 'end_reason')
  String? get endReason;
  @override // On the listing's own page only: its newest 100 bids, newest first.
  List<P2pBidSummary>? get bids;
  @override
  @JsonKey(ignore: true)
  _$$_P2pListingCopyWith<_$_P2pListing> get copyWith =>
      throw _privateConstructorUsedError;
}

P2pBidResult _$P2pBidResultFromJson(Map<String, dynamic> json) {
  return _P2pBidResult.fromJson(json);
}

/// @nodoc
mixin _$P2pBidResult {
  P2pBidSummary get bid => throw _privateConstructorUsedError;
  P2pListing get listing => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $P2pBidResultCopyWith<P2pBidResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $P2pBidResultCopyWith<$Res> {
  factory $P2pBidResultCopyWith(
          P2pBidResult value, $Res Function(P2pBidResult) then) =
      _$P2pBidResultCopyWithImpl<$Res, P2pBidResult>;
  @useResult
  $Res call({P2pBidSummary bid, P2pListing listing});

  $P2pBidSummaryCopyWith<$Res> get bid;
  $P2pListingCopyWith<$Res> get listing;
}

/// @nodoc
class _$P2pBidResultCopyWithImpl<$Res, $Val extends P2pBidResult>
    implements $P2pBidResultCopyWith<$Res> {
  _$P2pBidResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bid = null,
    Object? listing = null,
  }) {
    return _then(_value.copyWith(
      bid: null == bid
          ? _value.bid
          : bid // ignore: cast_nullable_to_non_nullable
              as P2pBidSummary,
      listing: null == listing
          ? _value.listing
          : listing // ignore: cast_nullable_to_non_nullable
              as P2pListing,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $P2pBidSummaryCopyWith<$Res> get bid {
    return $P2pBidSummaryCopyWith<$Res>(_value.bid, (value) {
      return _then(_value.copyWith(bid: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $P2pListingCopyWith<$Res> get listing {
    return $P2pListingCopyWith<$Res>(_value.listing, (value) {
      return _then(_value.copyWith(listing: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_P2pBidResultCopyWith<$Res>
    implements $P2pBidResultCopyWith<$Res> {
  factory _$$_P2pBidResultCopyWith(
          _$_P2pBidResult value, $Res Function(_$_P2pBidResult) then) =
      __$$_P2pBidResultCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({P2pBidSummary bid, P2pListing listing});

  @override
  $P2pBidSummaryCopyWith<$Res> get bid;
  @override
  $P2pListingCopyWith<$Res> get listing;
}

/// @nodoc
class __$$_P2pBidResultCopyWithImpl<$Res>
    extends _$P2pBidResultCopyWithImpl<$Res, _$_P2pBidResult>
    implements _$$_P2pBidResultCopyWith<$Res> {
  __$$_P2pBidResultCopyWithImpl(
      _$_P2pBidResult _value, $Res Function(_$_P2pBidResult) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bid = null,
    Object? listing = null,
  }) {
    return _then(_$_P2pBidResult(
      bid: null == bid
          ? _value.bid
          : bid // ignore: cast_nullable_to_non_nullable
              as P2pBidSummary,
      listing: null == listing
          ? _value.listing
          : listing // ignore: cast_nullable_to_non_nullable
              as P2pListing,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_P2pBidResult implements _P2pBidResult {
  _$_P2pBidResult({required this.bid, required this.listing});

  factory _$_P2pBidResult.fromJson(Map<String, dynamic> json) =>
      _$$_P2pBidResultFromJson(json);

  @override
  final P2pBidSummary bid;
  @override
  final P2pListing listing;

  @override
  String toString() {
    return 'P2pBidResult(bid: $bid, listing: $listing)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_P2pBidResult &&
            (identical(other.bid, bid) || other.bid == bid) &&
            (identical(other.listing, listing) || other.listing == listing));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, bid, listing);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_P2pBidResultCopyWith<_$_P2pBidResult> get copyWith =>
      __$$_P2pBidResultCopyWithImpl<_$_P2pBidResult>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_P2pBidResultToJson(
      this,
    );
  }
}

abstract class _P2pBidResult implements P2pBidResult {
  factory _P2pBidResult(
      {required final P2pBidSummary bid,
      required final P2pListing listing}) = _$_P2pBidResult;

  factory _P2pBidResult.fromJson(Map<String, dynamic> json) =
      _$_P2pBidResult.fromJson;

  @override
  P2pBidSummary get bid;
  @override
  P2pListing get listing;
  @override
  @JsonKey(ignore: true)
  _$$_P2pBidResultCopyWith<_$_P2pBidResult> get copyWith =>
      throw _privateConstructorUsedError;
}
