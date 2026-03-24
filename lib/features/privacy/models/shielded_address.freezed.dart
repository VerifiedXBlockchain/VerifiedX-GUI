// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shielded_address.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ShieldedAddress _$ShieldedAddressFromJson(Map<String, dynamic> json) {
  return _ShieldedAddress.fromJson(json);
}

/// @nodoc
mixin _$ShieldedAddress {
  @JsonKey(name: "ZfxAddress")
  String get zfxAddress => throw _privateConstructorUsedError;
  @JsonKey(name: "DerivationPath")
  String get derivationPath => throw _privateConstructorUsedError;
  @JsonKey(name: "CoinType")
  int get coinType => throw _privateConstructorUsedError;
  @JsonKey(name: "AddressIndex")
  int get addressIndex => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ShieldedAddressCopyWith<ShieldedAddress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShieldedAddressCopyWith<$Res> {
  factory $ShieldedAddressCopyWith(
          ShieldedAddress value, $Res Function(ShieldedAddress) then) =
      _$ShieldedAddressCopyWithImpl<$Res, ShieldedAddress>;
  @useResult
  $Res call(
      {@JsonKey(name: "ZfxAddress") String zfxAddress,
      @JsonKey(name: "DerivationPath") String derivationPath,
      @JsonKey(name: "CoinType") int coinType,
      @JsonKey(name: "AddressIndex") int addressIndex});
}

/// @nodoc
class _$ShieldedAddressCopyWithImpl<$Res, $Val extends ShieldedAddress>
    implements $ShieldedAddressCopyWith<$Res> {
  _$ShieldedAddressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? zfxAddress = null,
    Object? derivationPath = null,
    Object? coinType = null,
    Object? addressIndex = null,
  }) {
    return _then(_value.copyWith(
      zfxAddress: null == zfxAddress
          ? _value.zfxAddress
          : zfxAddress // ignore: cast_nullable_to_non_nullable
              as String,
      derivationPath: null == derivationPath
          ? _value.derivationPath
          : derivationPath // ignore: cast_nullable_to_non_nullable
              as String,
      coinType: null == coinType
          ? _value.coinType
          : coinType // ignore: cast_nullable_to_non_nullable
              as int,
      addressIndex: null == addressIndex
          ? _value.addressIndex
          : addressIndex // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ShieldedAddressCopyWith<$Res>
    implements $ShieldedAddressCopyWith<$Res> {
  factory _$$_ShieldedAddressCopyWith(
          _$_ShieldedAddress value, $Res Function(_$_ShieldedAddress) then) =
      __$$_ShieldedAddressCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "ZfxAddress") String zfxAddress,
      @JsonKey(name: "DerivationPath") String derivationPath,
      @JsonKey(name: "CoinType") int coinType,
      @JsonKey(name: "AddressIndex") int addressIndex});
}

/// @nodoc
class __$$_ShieldedAddressCopyWithImpl<$Res>
    extends _$ShieldedAddressCopyWithImpl<$Res, _$_ShieldedAddress>
    implements _$$_ShieldedAddressCopyWith<$Res> {
  __$$_ShieldedAddressCopyWithImpl(
      _$_ShieldedAddress _value, $Res Function(_$_ShieldedAddress) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? zfxAddress = null,
    Object? derivationPath = null,
    Object? coinType = null,
    Object? addressIndex = null,
  }) {
    return _then(_$_ShieldedAddress(
      zfxAddress: null == zfxAddress
          ? _value.zfxAddress
          : zfxAddress // ignore: cast_nullable_to_non_nullable
              as String,
      derivationPath: null == derivationPath
          ? _value.derivationPath
          : derivationPath // ignore: cast_nullable_to_non_nullable
              as String,
      coinType: null == coinType
          ? _value.coinType
          : coinType // ignore: cast_nullable_to_non_nullable
              as int,
      addressIndex: null == addressIndex
          ? _value.addressIndex
          : addressIndex // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ShieldedAddress extends _ShieldedAddress {
  _$_ShieldedAddress(
      {@JsonKey(name: "ZfxAddress") required this.zfxAddress,
      @JsonKey(name: "DerivationPath") required this.derivationPath,
      @JsonKey(name: "CoinType") this.coinType = 889,
      @JsonKey(name: "AddressIndex") this.addressIndex = 0})
      : super._();

  factory _$_ShieldedAddress.fromJson(Map<String, dynamic> json) =>
      _$$_ShieldedAddressFromJson(json);

  @override
  @JsonKey(name: "ZfxAddress")
  final String zfxAddress;
  @override
  @JsonKey(name: "DerivationPath")
  final String derivationPath;
  @override
  @JsonKey(name: "CoinType")
  final int coinType;
  @override
  @JsonKey(name: "AddressIndex")
  final int addressIndex;

  @override
  String toString() {
    return 'ShieldedAddress(zfxAddress: $zfxAddress, derivationPath: $derivationPath, coinType: $coinType, addressIndex: $addressIndex)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ShieldedAddress &&
            (identical(other.zfxAddress, zfxAddress) ||
                other.zfxAddress == zfxAddress) &&
            (identical(other.derivationPath, derivationPath) ||
                other.derivationPath == derivationPath) &&
            (identical(other.coinType, coinType) ||
                other.coinType == coinType) &&
            (identical(other.addressIndex, addressIndex) ||
                other.addressIndex == addressIndex));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, zfxAddress, derivationPath, coinType, addressIndex);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ShieldedAddressCopyWith<_$_ShieldedAddress> get copyWith =>
      __$$_ShieldedAddressCopyWithImpl<_$_ShieldedAddress>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ShieldedAddressToJson(
      this,
    );
  }
}

abstract class _ShieldedAddress extends ShieldedAddress {
  factory _ShieldedAddress(
          {@JsonKey(name: "ZfxAddress") required final String zfxAddress,
          @JsonKey(name: "DerivationPath") required final String derivationPath,
          @JsonKey(name: "CoinType") final int coinType,
          @JsonKey(name: "AddressIndex") final int addressIndex}) =
      _$_ShieldedAddress;
  _ShieldedAddress._() : super._();

  factory _ShieldedAddress.fromJson(Map<String, dynamic> json) =
      _$_ShieldedAddress.fromJson;

  @override
  @JsonKey(name: "ZfxAddress")
  String get zfxAddress;
  @override
  @JsonKey(name: "DerivationPath")
  String get derivationPath;
  @override
  @JsonKey(name: "CoinType")
  int get coinType;
  @override
  @JsonKey(name: "AddressIndex")
  int get addressIndex;
  @override
  @JsonKey(ignore: true)
  _$$_ShieldedAddressCopyWith<_$_ShieldedAddress> get copyWith =>
      throw _privateConstructorUsedError;
}
