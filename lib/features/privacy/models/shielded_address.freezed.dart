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
  @JsonKey(name: "TransparentSourceAddress")
  String get transparentSourceAddress => throw _privateConstructorUsedError;

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
      {@JsonKey(name: "ZfxAddress")
          String zfxAddress,
      @JsonKey(name: "TransparentSourceAddress")
          String transparentSourceAddress});
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
    Object? transparentSourceAddress = null,
  }) {
    return _then(_value.copyWith(
      zfxAddress: null == zfxAddress
          ? _value.zfxAddress
          : zfxAddress // ignore: cast_nullable_to_non_nullable
              as String,
      transparentSourceAddress: null == transparentSourceAddress
          ? _value.transparentSourceAddress
          : transparentSourceAddress // ignore: cast_nullable_to_non_nullable
              as String,
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
      {@JsonKey(name: "ZfxAddress")
          String zfxAddress,
      @JsonKey(name: "TransparentSourceAddress")
          String transparentSourceAddress});
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
    Object? transparentSourceAddress = null,
  }) {
    return _then(_$_ShieldedAddress(
      zfxAddress: null == zfxAddress
          ? _value.zfxAddress
          : zfxAddress // ignore: cast_nullable_to_non_nullable
              as String,
      transparentSourceAddress: null == transparentSourceAddress
          ? _value.transparentSourceAddress
          : transparentSourceAddress // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ShieldedAddress extends _ShieldedAddress {
  _$_ShieldedAddress(
      {@JsonKey(name: "ZfxAddress")
          required this.zfxAddress,
      @JsonKey(name: "TransparentSourceAddress")
          this.transparentSourceAddress = ""})
      : super._();

  factory _$_ShieldedAddress.fromJson(Map<String, dynamic> json) =>
      _$$_ShieldedAddressFromJson(json);

  @override
  @JsonKey(name: "ZfxAddress")
  final String zfxAddress;
  @override
  @JsonKey(name: "TransparentSourceAddress")
  final String transparentSourceAddress;

  @override
  String toString() {
    return 'ShieldedAddress(zfxAddress: $zfxAddress, transparentSourceAddress: $transparentSourceAddress)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ShieldedAddress &&
            (identical(other.zfxAddress, zfxAddress) ||
                other.zfxAddress == zfxAddress) &&
            (identical(
                    other.transparentSourceAddress, transparentSourceAddress) ||
                other.transparentSourceAddress == transparentSourceAddress));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, zfxAddress, transparentSourceAddress);

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
      {@JsonKey(name: "ZfxAddress")
          required final String zfxAddress,
      @JsonKey(name: "TransparentSourceAddress")
          final String transparentSourceAddress}) = _$_ShieldedAddress;
  _ShieldedAddress._() : super._();

  factory _ShieldedAddress.fromJson(Map<String, dynamic> json) =
      _$_ShieldedAddress.fromJson;

  @override
  @JsonKey(name: "ZfxAddress")
  String get zfxAddress;
  @override
  @JsonKey(name: "TransparentSourceAddress")
  String get transparentSourceAddress;
  @override
  @JsonKey(ignore: true)
  _$$_ShieldedAddressCopyWith<_$_ShieldedAddress> get copyWith =>
      throw _privateConstructorUsedError;
}
