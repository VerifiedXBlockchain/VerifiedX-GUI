// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bridge_preflight.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

BridgePreflight _$BridgePreflightFromJson(Map<String, dynamic> json) {
  return _BridgePreflight.fromJson(json);
}

/// @nodoc
mixin _$BridgePreflight {
  @JsonKey(name: "success")
  bool get success => throw _privateConstructorUsedError;
  @JsonKey(name: "message")
  String? get message => throw _privateConstructorUsedError; // VFX side
  @JsonKey(name: "ownerAddress")
  String get ownerAddress => throw _privateConstructorUsedError;
  @JsonKey(name: "scUID")
  String get scUid => throw _privateConstructorUsedError;
  @JsonKey(name: "availableVbtc")
  double get availableVbtc => throw _privateConstructorUsedError;
  @JsonKey(name: "vbtcError")
  String? get vbtcError =>
      throw _privateConstructorUsedError; // Derived Base address
  @JsonKey(name: "derivedBaseAddress")
  String get derivedBaseAddress => throw _privateConstructorUsedError;
  @JsonKey(name: "hasDerivedAddress")
  bool get hasDerivedAddress =>
      throw _privateConstructorUsedError; // Base balances
  @JsonKey(name: "ethBalance")
  double? get ethBalance => throw _privateConstructorUsedError;
  @JsonKey(name: "ethError")
  String? get ethError => throw _privateConstructorUsedError;
  @JsonKey(name: "vbtcBBalance")
  double? get vbtcBBalance => throw _privateConstructorUsedError;
  @JsonKey(name: "vbtcBError")
  String? get vbtcBError =>
      throw _privateConstructorUsedError; // Config / network
  @JsonKey(name: "bridgeConfigured")
  bool get bridgeConfigured => throw _privateConstructorUsedError;
  @JsonKey(name: "canReadEth")
  bool get canReadEth => throw _privateConstructorUsedError;
  @JsonKey(name: "canReadVbtc")
  bool get canReadVbtc => throw _privateConstructorUsedError;
  @JsonKey(name: "networkName")
  String? get networkName => throw _privateConstructorUsedError;
  @JsonKey(name: "chainId")
  int? get chainId => throw _privateConstructorUsedError;
  @JsonKey(name: "contractAddress")
  String? get contractAddress => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BridgePreflightCopyWith<BridgePreflight> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BridgePreflightCopyWith<$Res> {
  factory $BridgePreflightCopyWith(
          BridgePreflight value, $Res Function(BridgePreflight) then) =
      _$BridgePreflightCopyWithImpl<$Res, BridgePreflight>;
  @useResult
  $Res call(
      {@JsonKey(name: "success") bool success,
      @JsonKey(name: "message") String? message,
      @JsonKey(name: "ownerAddress") String ownerAddress,
      @JsonKey(name: "scUID") String scUid,
      @JsonKey(name: "availableVbtc") double availableVbtc,
      @JsonKey(name: "vbtcError") String? vbtcError,
      @JsonKey(name: "derivedBaseAddress") String derivedBaseAddress,
      @JsonKey(name: "hasDerivedAddress") bool hasDerivedAddress,
      @JsonKey(name: "ethBalance") double? ethBalance,
      @JsonKey(name: "ethError") String? ethError,
      @JsonKey(name: "vbtcBBalance") double? vbtcBBalance,
      @JsonKey(name: "vbtcBError") String? vbtcBError,
      @JsonKey(name: "bridgeConfigured") bool bridgeConfigured,
      @JsonKey(name: "canReadEth") bool canReadEth,
      @JsonKey(name: "canReadVbtc") bool canReadVbtc,
      @JsonKey(name: "networkName") String? networkName,
      @JsonKey(name: "chainId") int? chainId,
      @JsonKey(name: "contractAddress") String? contractAddress});
}

/// @nodoc
class _$BridgePreflightCopyWithImpl<$Res, $Val extends BridgePreflight>
    implements $BridgePreflightCopyWith<$Res> {
  _$BridgePreflightCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = freezed,
    Object? ownerAddress = null,
    Object? scUid = null,
    Object? availableVbtc = null,
    Object? vbtcError = freezed,
    Object? derivedBaseAddress = null,
    Object? hasDerivedAddress = null,
    Object? ethBalance = freezed,
    Object? ethError = freezed,
    Object? vbtcBBalance = freezed,
    Object? vbtcBError = freezed,
    Object? bridgeConfigured = null,
    Object? canReadEth = null,
    Object? canReadVbtc = null,
    Object? networkName = freezed,
    Object? chainId = freezed,
    Object? contractAddress = freezed,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      ownerAddress: null == ownerAddress
          ? _value.ownerAddress
          : ownerAddress // ignore: cast_nullable_to_non_nullable
              as String,
      scUid: null == scUid
          ? _value.scUid
          : scUid // ignore: cast_nullable_to_non_nullable
              as String,
      availableVbtc: null == availableVbtc
          ? _value.availableVbtc
          : availableVbtc // ignore: cast_nullable_to_non_nullable
              as double,
      vbtcError: freezed == vbtcError
          ? _value.vbtcError
          : vbtcError // ignore: cast_nullable_to_non_nullable
              as String?,
      derivedBaseAddress: null == derivedBaseAddress
          ? _value.derivedBaseAddress
          : derivedBaseAddress // ignore: cast_nullable_to_non_nullable
              as String,
      hasDerivedAddress: null == hasDerivedAddress
          ? _value.hasDerivedAddress
          : hasDerivedAddress // ignore: cast_nullable_to_non_nullable
              as bool,
      ethBalance: freezed == ethBalance
          ? _value.ethBalance
          : ethBalance // ignore: cast_nullable_to_non_nullable
              as double?,
      ethError: freezed == ethError
          ? _value.ethError
          : ethError // ignore: cast_nullable_to_non_nullable
              as String?,
      vbtcBBalance: freezed == vbtcBBalance
          ? _value.vbtcBBalance
          : vbtcBBalance // ignore: cast_nullable_to_non_nullable
              as double?,
      vbtcBError: freezed == vbtcBError
          ? _value.vbtcBError
          : vbtcBError // ignore: cast_nullable_to_non_nullable
              as String?,
      bridgeConfigured: null == bridgeConfigured
          ? _value.bridgeConfigured
          : bridgeConfigured // ignore: cast_nullable_to_non_nullable
              as bool,
      canReadEth: null == canReadEth
          ? _value.canReadEth
          : canReadEth // ignore: cast_nullable_to_non_nullable
              as bool,
      canReadVbtc: null == canReadVbtc
          ? _value.canReadVbtc
          : canReadVbtc // ignore: cast_nullable_to_non_nullable
              as bool,
      networkName: freezed == networkName
          ? _value.networkName
          : networkName // ignore: cast_nullable_to_non_nullable
              as String?,
      chainId: freezed == chainId
          ? _value.chainId
          : chainId // ignore: cast_nullable_to_non_nullable
              as int?,
      contractAddress: freezed == contractAddress
          ? _value.contractAddress
          : contractAddress // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_BridgePreflightCopyWith<$Res>
    implements $BridgePreflightCopyWith<$Res> {
  factory _$$_BridgePreflightCopyWith(
          _$_BridgePreflight value, $Res Function(_$_BridgePreflight) then) =
      __$$_BridgePreflightCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "success") bool success,
      @JsonKey(name: "message") String? message,
      @JsonKey(name: "ownerAddress") String ownerAddress,
      @JsonKey(name: "scUID") String scUid,
      @JsonKey(name: "availableVbtc") double availableVbtc,
      @JsonKey(name: "vbtcError") String? vbtcError,
      @JsonKey(name: "derivedBaseAddress") String derivedBaseAddress,
      @JsonKey(name: "hasDerivedAddress") bool hasDerivedAddress,
      @JsonKey(name: "ethBalance") double? ethBalance,
      @JsonKey(name: "ethError") String? ethError,
      @JsonKey(name: "vbtcBBalance") double? vbtcBBalance,
      @JsonKey(name: "vbtcBError") String? vbtcBError,
      @JsonKey(name: "bridgeConfigured") bool bridgeConfigured,
      @JsonKey(name: "canReadEth") bool canReadEth,
      @JsonKey(name: "canReadVbtc") bool canReadVbtc,
      @JsonKey(name: "networkName") String? networkName,
      @JsonKey(name: "chainId") int? chainId,
      @JsonKey(name: "contractAddress") String? contractAddress});
}

/// @nodoc
class __$$_BridgePreflightCopyWithImpl<$Res>
    extends _$BridgePreflightCopyWithImpl<$Res, _$_BridgePreflight>
    implements _$$_BridgePreflightCopyWith<$Res> {
  __$$_BridgePreflightCopyWithImpl(
      _$_BridgePreflight _value, $Res Function(_$_BridgePreflight) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = freezed,
    Object? ownerAddress = null,
    Object? scUid = null,
    Object? availableVbtc = null,
    Object? vbtcError = freezed,
    Object? derivedBaseAddress = null,
    Object? hasDerivedAddress = null,
    Object? ethBalance = freezed,
    Object? ethError = freezed,
    Object? vbtcBBalance = freezed,
    Object? vbtcBError = freezed,
    Object? bridgeConfigured = null,
    Object? canReadEth = null,
    Object? canReadVbtc = null,
    Object? networkName = freezed,
    Object? chainId = freezed,
    Object? contractAddress = freezed,
  }) {
    return _then(_$_BridgePreflight(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      ownerAddress: null == ownerAddress
          ? _value.ownerAddress
          : ownerAddress // ignore: cast_nullable_to_non_nullable
              as String,
      scUid: null == scUid
          ? _value.scUid
          : scUid // ignore: cast_nullable_to_non_nullable
              as String,
      availableVbtc: null == availableVbtc
          ? _value.availableVbtc
          : availableVbtc // ignore: cast_nullable_to_non_nullable
              as double,
      vbtcError: freezed == vbtcError
          ? _value.vbtcError
          : vbtcError // ignore: cast_nullable_to_non_nullable
              as String?,
      derivedBaseAddress: null == derivedBaseAddress
          ? _value.derivedBaseAddress
          : derivedBaseAddress // ignore: cast_nullable_to_non_nullable
              as String,
      hasDerivedAddress: null == hasDerivedAddress
          ? _value.hasDerivedAddress
          : hasDerivedAddress // ignore: cast_nullable_to_non_nullable
              as bool,
      ethBalance: freezed == ethBalance
          ? _value.ethBalance
          : ethBalance // ignore: cast_nullable_to_non_nullable
              as double?,
      ethError: freezed == ethError
          ? _value.ethError
          : ethError // ignore: cast_nullable_to_non_nullable
              as String?,
      vbtcBBalance: freezed == vbtcBBalance
          ? _value.vbtcBBalance
          : vbtcBBalance // ignore: cast_nullable_to_non_nullable
              as double?,
      vbtcBError: freezed == vbtcBError
          ? _value.vbtcBError
          : vbtcBError // ignore: cast_nullable_to_non_nullable
              as String?,
      bridgeConfigured: null == bridgeConfigured
          ? _value.bridgeConfigured
          : bridgeConfigured // ignore: cast_nullable_to_non_nullable
              as bool,
      canReadEth: null == canReadEth
          ? _value.canReadEth
          : canReadEth // ignore: cast_nullable_to_non_nullable
              as bool,
      canReadVbtc: null == canReadVbtc
          ? _value.canReadVbtc
          : canReadVbtc // ignore: cast_nullable_to_non_nullable
              as bool,
      networkName: freezed == networkName
          ? _value.networkName
          : networkName // ignore: cast_nullable_to_non_nullable
              as String?,
      chainId: freezed == chainId
          ? _value.chainId
          : chainId // ignore: cast_nullable_to_non_nullable
              as int?,
      contractAddress: freezed == contractAddress
          ? _value.contractAddress
          : contractAddress // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_BridgePreflight extends _BridgePreflight {
  _$_BridgePreflight(
      {@JsonKey(name: "success") this.success = false,
      @JsonKey(name: "message") this.message,
      @JsonKey(name: "ownerAddress") this.ownerAddress = "",
      @JsonKey(name: "scUID") this.scUid = "",
      @JsonKey(name: "availableVbtc") this.availableVbtc = 0.0,
      @JsonKey(name: "vbtcError") this.vbtcError,
      @JsonKey(name: "derivedBaseAddress") this.derivedBaseAddress = "",
      @JsonKey(name: "hasDerivedAddress") this.hasDerivedAddress = false,
      @JsonKey(name: "ethBalance") this.ethBalance,
      @JsonKey(name: "ethError") this.ethError,
      @JsonKey(name: "vbtcBBalance") this.vbtcBBalance,
      @JsonKey(name: "vbtcBError") this.vbtcBError,
      @JsonKey(name: "bridgeConfigured") this.bridgeConfigured = false,
      @JsonKey(name: "canReadEth") this.canReadEth = false,
      @JsonKey(name: "canReadVbtc") this.canReadVbtc = false,
      @JsonKey(name: "networkName") this.networkName,
      @JsonKey(name: "chainId") this.chainId,
      @JsonKey(name: "contractAddress") this.contractAddress})
      : super._();

  factory _$_BridgePreflight.fromJson(Map<String, dynamic> json) =>
      _$$_BridgePreflightFromJson(json);

  @override
  @JsonKey(name: "success")
  final bool success;
  @override
  @JsonKey(name: "message")
  final String? message;
// VFX side
  @override
  @JsonKey(name: "ownerAddress")
  final String ownerAddress;
  @override
  @JsonKey(name: "scUID")
  final String scUid;
  @override
  @JsonKey(name: "availableVbtc")
  final double availableVbtc;
  @override
  @JsonKey(name: "vbtcError")
  final String? vbtcError;
// Derived Base address
  @override
  @JsonKey(name: "derivedBaseAddress")
  final String derivedBaseAddress;
  @override
  @JsonKey(name: "hasDerivedAddress")
  final bool hasDerivedAddress;
// Base balances
  @override
  @JsonKey(name: "ethBalance")
  final double? ethBalance;
  @override
  @JsonKey(name: "ethError")
  final String? ethError;
  @override
  @JsonKey(name: "vbtcBBalance")
  final double? vbtcBBalance;
  @override
  @JsonKey(name: "vbtcBError")
  final String? vbtcBError;
// Config / network
  @override
  @JsonKey(name: "bridgeConfigured")
  final bool bridgeConfigured;
  @override
  @JsonKey(name: "canReadEth")
  final bool canReadEth;
  @override
  @JsonKey(name: "canReadVbtc")
  final bool canReadVbtc;
  @override
  @JsonKey(name: "networkName")
  final String? networkName;
  @override
  @JsonKey(name: "chainId")
  final int? chainId;
  @override
  @JsonKey(name: "contractAddress")
  final String? contractAddress;

  @override
  String toString() {
    return 'BridgePreflight(success: $success, message: $message, ownerAddress: $ownerAddress, scUid: $scUid, availableVbtc: $availableVbtc, vbtcError: $vbtcError, derivedBaseAddress: $derivedBaseAddress, hasDerivedAddress: $hasDerivedAddress, ethBalance: $ethBalance, ethError: $ethError, vbtcBBalance: $vbtcBBalance, vbtcBError: $vbtcBError, bridgeConfigured: $bridgeConfigured, canReadEth: $canReadEth, canReadVbtc: $canReadVbtc, networkName: $networkName, chainId: $chainId, contractAddress: $contractAddress)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_BridgePreflight &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.ownerAddress, ownerAddress) ||
                other.ownerAddress == ownerAddress) &&
            (identical(other.scUid, scUid) || other.scUid == scUid) &&
            (identical(other.availableVbtc, availableVbtc) ||
                other.availableVbtc == availableVbtc) &&
            (identical(other.vbtcError, vbtcError) ||
                other.vbtcError == vbtcError) &&
            (identical(other.derivedBaseAddress, derivedBaseAddress) ||
                other.derivedBaseAddress == derivedBaseAddress) &&
            (identical(other.hasDerivedAddress, hasDerivedAddress) ||
                other.hasDerivedAddress == hasDerivedAddress) &&
            (identical(other.ethBalance, ethBalance) ||
                other.ethBalance == ethBalance) &&
            (identical(other.ethError, ethError) ||
                other.ethError == ethError) &&
            (identical(other.vbtcBBalance, vbtcBBalance) ||
                other.vbtcBBalance == vbtcBBalance) &&
            (identical(other.vbtcBError, vbtcBError) ||
                other.vbtcBError == vbtcBError) &&
            (identical(other.bridgeConfigured, bridgeConfigured) ||
                other.bridgeConfigured == bridgeConfigured) &&
            (identical(other.canReadEth, canReadEth) ||
                other.canReadEth == canReadEth) &&
            (identical(other.canReadVbtc, canReadVbtc) ||
                other.canReadVbtc == canReadVbtc) &&
            (identical(other.networkName, networkName) ||
                other.networkName == networkName) &&
            (identical(other.chainId, chainId) || other.chainId == chainId) &&
            (identical(other.contractAddress, contractAddress) ||
                other.contractAddress == contractAddress));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      success,
      message,
      ownerAddress,
      scUid,
      availableVbtc,
      vbtcError,
      derivedBaseAddress,
      hasDerivedAddress,
      ethBalance,
      ethError,
      vbtcBBalance,
      vbtcBError,
      bridgeConfigured,
      canReadEth,
      canReadVbtc,
      networkName,
      chainId,
      contractAddress);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_BridgePreflightCopyWith<_$_BridgePreflight> get copyWith =>
      __$$_BridgePreflightCopyWithImpl<_$_BridgePreflight>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_BridgePreflightToJson(
      this,
    );
  }
}

abstract class _BridgePreflight extends BridgePreflight {
  factory _BridgePreflight(
          {@JsonKey(name: "success") final bool success,
          @JsonKey(name: "message") final String? message,
          @JsonKey(name: "ownerAddress") final String ownerAddress,
          @JsonKey(name: "scUID") final String scUid,
          @JsonKey(name: "availableVbtc") final double availableVbtc,
          @JsonKey(name: "vbtcError") final String? vbtcError,
          @JsonKey(name: "derivedBaseAddress") final String derivedBaseAddress,
          @JsonKey(name: "hasDerivedAddress") final bool hasDerivedAddress,
          @JsonKey(name: "ethBalance") final double? ethBalance,
          @JsonKey(name: "ethError") final String? ethError,
          @JsonKey(name: "vbtcBBalance") final double? vbtcBBalance,
          @JsonKey(name: "vbtcBError") final String? vbtcBError,
          @JsonKey(name: "bridgeConfigured") final bool bridgeConfigured,
          @JsonKey(name: "canReadEth") final bool canReadEth,
          @JsonKey(name: "canReadVbtc") final bool canReadVbtc,
          @JsonKey(name: "networkName") final String? networkName,
          @JsonKey(name: "chainId") final int? chainId,
          @JsonKey(name: "contractAddress") final String? contractAddress}) =
      _$_BridgePreflight;
  _BridgePreflight._() : super._();

  factory _BridgePreflight.fromJson(Map<String, dynamic> json) =
      _$_BridgePreflight.fromJson;

  @override
  @JsonKey(name: "success")
  bool get success;
  @override
  @JsonKey(name: "message")
  String? get message;
  @override // VFX side
  @JsonKey(name: "ownerAddress")
  String get ownerAddress;
  @override
  @JsonKey(name: "scUID")
  String get scUid;
  @override
  @JsonKey(name: "availableVbtc")
  double get availableVbtc;
  @override
  @JsonKey(name: "vbtcError")
  String? get vbtcError;
  @override // Derived Base address
  @JsonKey(name: "derivedBaseAddress")
  String get derivedBaseAddress;
  @override
  @JsonKey(name: "hasDerivedAddress")
  bool get hasDerivedAddress;
  @override // Base balances
  @JsonKey(name: "ethBalance")
  double? get ethBalance;
  @override
  @JsonKey(name: "ethError")
  String? get ethError;
  @override
  @JsonKey(name: "vbtcBBalance")
  double? get vbtcBBalance;
  @override
  @JsonKey(name: "vbtcBError")
  String? get vbtcBError;
  @override // Config / network
  @JsonKey(name: "bridgeConfigured")
  bool get bridgeConfigured;
  @override
  @JsonKey(name: "canReadEth")
  bool get canReadEth;
  @override
  @JsonKey(name: "canReadVbtc")
  bool get canReadVbtc;
  @override
  @JsonKey(name: "networkName")
  String? get networkName;
  @override
  @JsonKey(name: "chainId")
  int? get chainId;
  @override
  @JsonKey(name: "contractAddress")
  String? get contractAddress;
  @override
  @JsonKey(ignore: true)
  _$$_BridgePreflightCopyWith<_$_BridgePreflight> get copyWith =>
      throw _privateConstructorUsedError;
}
