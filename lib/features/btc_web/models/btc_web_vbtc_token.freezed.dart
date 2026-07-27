// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'btc_web_vbtc_token.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

BtcWebVbtcToken _$BtcWebVbtcTokenFromJson(Map<String, dynamic> json) {
  return _BtcWebVbtcToken.fromJson(json);
}

/// @nodoc
mixin _$BtcWebVbtcToken {
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  Map<String, dynamic> get addresses => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  @JsonKey(name: 'sc_identifier')
  String get scIdentifier => throw _privateConstructorUsedError;
  @JsonKey(name: 'owner_address')
  String get ownerAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String get imageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'deposit_address')
  String get depositAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'public_key_proofs')
  String? get publicKeyProofs => throw _privateConstructorUsedError;
  @JsonKey(name: 'global_balance')
  double get globalBalance => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  WebNft get nft => throw _privateConstructorUsedError;
  int get version => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_pending_withdrawal')
  bool get isPendingWithdrawal => throw _privateConstructorUsedError;
  @JsonKey(name: 'frost_group_public_key')
  String? get frostGroupPublicKey => throw _privateConstructorUsedError;
  @JsonKey(name: 'required_threshold')
  int? get requiredThreshold => throw _privateConstructorUsedError;
  @JsonKey(name: 'withdrawal_requests')
  List<Map<String, dynamic>>? get withdrawalRequests =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BtcWebVbtcTokenCopyWith<BtcWebVbtcToken> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BtcWebVbtcTokenCopyWith<$Res> {
  factory $BtcWebVbtcTokenCopyWith(
          BtcWebVbtcToken value, $Res Function(BtcWebVbtcToken) then) =
      _$BtcWebVbtcTokenCopyWithImpl<$Res, BtcWebVbtcToken>;
  @useResult
  $Res call(
      {String name,
      String description,
      Map<String, dynamic> addresses,
      String address,
      @JsonKey(name: 'sc_identifier')
          String scIdentifier,
      @JsonKey(name: 'owner_address')
          String ownerAddress,
      @JsonKey(name: 'image_url')
          String imageUrl,
      @JsonKey(name: 'deposit_address')
          String depositAddress,
      @JsonKey(name: 'public_key_proofs')
          String? publicKeyProofs,
      @JsonKey(name: 'global_balance')
          double globalBalance,
      @JsonKey(name: 'created_at')
          DateTime createdAt,
      WebNft nft,
      int version,
      @JsonKey(name: 'is_pending_withdrawal')
          bool isPendingWithdrawal,
      @JsonKey(name: 'frost_group_public_key')
          String? frostGroupPublicKey,
      @JsonKey(name: 'required_threshold')
          int? requiredThreshold,
      @JsonKey(name: 'withdrawal_requests')
          List<Map<String, dynamic>>? withdrawalRequests});

  $WebNftCopyWith<$Res> get nft;
}

/// @nodoc
class _$BtcWebVbtcTokenCopyWithImpl<$Res, $Val extends BtcWebVbtcToken>
    implements $BtcWebVbtcTokenCopyWith<$Res> {
  _$BtcWebVbtcTokenCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? addresses = null,
    Object? address = null,
    Object? scIdentifier = null,
    Object? ownerAddress = null,
    Object? imageUrl = null,
    Object? depositAddress = null,
    Object? publicKeyProofs = freezed,
    Object? globalBalance = null,
    Object? createdAt = null,
    Object? nft = null,
    Object? version = null,
    Object? isPendingWithdrawal = null,
    Object? frostGroupPublicKey = freezed,
    Object? requiredThreshold = freezed,
    Object? withdrawalRequests = freezed,
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
      addresses: null == addresses
          ? _value.addresses
          : addresses // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      scIdentifier: null == scIdentifier
          ? _value.scIdentifier
          : scIdentifier // ignore: cast_nullable_to_non_nullable
              as String,
      ownerAddress: null == ownerAddress
          ? _value.ownerAddress
          : ownerAddress // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      depositAddress: null == depositAddress
          ? _value.depositAddress
          : depositAddress // ignore: cast_nullable_to_non_nullable
              as String,
      publicKeyProofs: freezed == publicKeyProofs
          ? _value.publicKeyProofs
          : publicKeyProofs // ignore: cast_nullable_to_non_nullable
              as String?,
      globalBalance: null == globalBalance
          ? _value.globalBalance
          : globalBalance // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      nft: null == nft
          ? _value.nft
          : nft // ignore: cast_nullable_to_non_nullable
              as WebNft,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as int,
      isPendingWithdrawal: null == isPendingWithdrawal
          ? _value.isPendingWithdrawal
          : isPendingWithdrawal // ignore: cast_nullable_to_non_nullable
              as bool,
      frostGroupPublicKey: freezed == frostGroupPublicKey
          ? _value.frostGroupPublicKey
          : frostGroupPublicKey // ignore: cast_nullable_to_non_nullable
              as String?,
      requiredThreshold: freezed == requiredThreshold
          ? _value.requiredThreshold
          : requiredThreshold // ignore: cast_nullable_to_non_nullable
              as int?,
      withdrawalRequests: freezed == withdrawalRequests
          ? _value.withdrawalRequests
          : withdrawalRequests // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $WebNftCopyWith<$Res> get nft {
    return $WebNftCopyWith<$Res>(_value.nft, (value) {
      return _then(_value.copyWith(nft: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_BtcWebVbtcTokenCopyWith<$Res>
    implements $BtcWebVbtcTokenCopyWith<$Res> {
  factory _$$_BtcWebVbtcTokenCopyWith(
          _$_BtcWebVbtcToken value, $Res Function(_$_BtcWebVbtcToken) then) =
      __$$_BtcWebVbtcTokenCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String description,
      Map<String, dynamic> addresses,
      String address,
      @JsonKey(name: 'sc_identifier')
          String scIdentifier,
      @JsonKey(name: 'owner_address')
          String ownerAddress,
      @JsonKey(name: 'image_url')
          String imageUrl,
      @JsonKey(name: 'deposit_address')
          String depositAddress,
      @JsonKey(name: 'public_key_proofs')
          String? publicKeyProofs,
      @JsonKey(name: 'global_balance')
          double globalBalance,
      @JsonKey(name: 'created_at')
          DateTime createdAt,
      WebNft nft,
      int version,
      @JsonKey(name: 'is_pending_withdrawal')
          bool isPendingWithdrawal,
      @JsonKey(name: 'frost_group_public_key')
          String? frostGroupPublicKey,
      @JsonKey(name: 'required_threshold')
          int? requiredThreshold,
      @JsonKey(name: 'withdrawal_requests')
          List<Map<String, dynamic>>? withdrawalRequests});

  @override
  $WebNftCopyWith<$Res> get nft;
}

/// @nodoc
class __$$_BtcWebVbtcTokenCopyWithImpl<$Res>
    extends _$BtcWebVbtcTokenCopyWithImpl<$Res, _$_BtcWebVbtcToken>
    implements _$$_BtcWebVbtcTokenCopyWith<$Res> {
  __$$_BtcWebVbtcTokenCopyWithImpl(
      _$_BtcWebVbtcToken _value, $Res Function(_$_BtcWebVbtcToken) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? addresses = null,
    Object? address = null,
    Object? scIdentifier = null,
    Object? ownerAddress = null,
    Object? imageUrl = null,
    Object? depositAddress = null,
    Object? publicKeyProofs = freezed,
    Object? globalBalance = null,
    Object? createdAt = null,
    Object? nft = null,
    Object? version = null,
    Object? isPendingWithdrawal = null,
    Object? frostGroupPublicKey = freezed,
    Object? requiredThreshold = freezed,
    Object? withdrawalRequests = freezed,
  }) {
    return _then(_$_BtcWebVbtcToken(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      addresses: null == addresses
          ? _value._addresses
          : addresses // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      scIdentifier: null == scIdentifier
          ? _value.scIdentifier
          : scIdentifier // ignore: cast_nullable_to_non_nullable
              as String,
      ownerAddress: null == ownerAddress
          ? _value.ownerAddress
          : ownerAddress // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      depositAddress: null == depositAddress
          ? _value.depositAddress
          : depositAddress // ignore: cast_nullable_to_non_nullable
              as String,
      publicKeyProofs: freezed == publicKeyProofs
          ? _value.publicKeyProofs
          : publicKeyProofs // ignore: cast_nullable_to_non_nullable
              as String?,
      globalBalance: null == globalBalance
          ? _value.globalBalance
          : globalBalance // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      nft: null == nft
          ? _value.nft
          : nft // ignore: cast_nullable_to_non_nullable
              as WebNft,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as int,
      isPendingWithdrawal: null == isPendingWithdrawal
          ? _value.isPendingWithdrawal
          : isPendingWithdrawal // ignore: cast_nullable_to_non_nullable
              as bool,
      frostGroupPublicKey: freezed == frostGroupPublicKey
          ? _value.frostGroupPublicKey
          : frostGroupPublicKey // ignore: cast_nullable_to_non_nullable
              as String?,
      requiredThreshold: freezed == requiredThreshold
          ? _value.requiredThreshold
          : requiredThreshold // ignore: cast_nullable_to_non_nullable
              as int?,
      withdrawalRequests: freezed == withdrawalRequests
          ? _value._withdrawalRequests
          : withdrawalRequests // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_BtcWebVbtcToken extends _BtcWebVbtcToken {
  _$_BtcWebVbtcToken(
      {required this.name,
      required this.description,
      required final Map<String, dynamic> addresses,
      required this.address,
      @JsonKey(name: 'sc_identifier')
          required this.scIdentifier,
      @JsonKey(name: 'owner_address')
          required this.ownerAddress,
      @JsonKey(name: 'image_url')
          required this.imageUrl,
      @JsonKey(name: 'deposit_address')
          required this.depositAddress,
      @JsonKey(name: 'public_key_proofs')
          this.publicKeyProofs,
      @JsonKey(name: 'global_balance')
          required this.globalBalance,
      @JsonKey(name: 'created_at')
          required this.createdAt,
      required this.nft,
      this.version = 1,
      @JsonKey(name: 'is_pending_withdrawal')
          this.isPendingWithdrawal = false,
      @JsonKey(name: 'frost_group_public_key')
          this.frostGroupPublicKey,
      @JsonKey(name: 'required_threshold')
          this.requiredThreshold,
      @JsonKey(name: 'withdrawal_requests')
          final List<Map<String, dynamic>>? withdrawalRequests})
      : _addresses = addresses,
        _withdrawalRequests = withdrawalRequests,
        super._();

  factory _$_BtcWebVbtcToken.fromJson(Map<String, dynamic> json) =>
      _$$_BtcWebVbtcTokenFromJson(json);

  @override
  final String name;
  @override
  final String description;
  final Map<String, dynamic> _addresses;
  @override
  Map<String, dynamic> get addresses {
    if (_addresses is EqualUnmodifiableMapView) return _addresses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_addresses);
  }

  @override
  final String address;
  @override
  @JsonKey(name: 'sc_identifier')
  final String scIdentifier;
  @override
  @JsonKey(name: 'owner_address')
  final String ownerAddress;
  @override
  @JsonKey(name: 'image_url')
  final String imageUrl;
  @override
  @JsonKey(name: 'deposit_address')
  final String depositAddress;
  @override
  @JsonKey(name: 'public_key_proofs')
  final String? publicKeyProofs;
  @override
  @JsonKey(name: 'global_balance')
  final double globalBalance;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  final WebNft nft;
  @override
  @JsonKey()
  final int version;
  @override
  @JsonKey(name: 'is_pending_withdrawal')
  final bool isPendingWithdrawal;
  @override
  @JsonKey(name: 'frost_group_public_key')
  final String? frostGroupPublicKey;
  @override
  @JsonKey(name: 'required_threshold')
  final int? requiredThreshold;
  final List<Map<String, dynamic>>? _withdrawalRequests;
  @override
  @JsonKey(name: 'withdrawal_requests')
  List<Map<String, dynamic>>? get withdrawalRequests {
    final value = _withdrawalRequests;
    if (value == null) return null;
    if (_withdrawalRequests is EqualUnmodifiableListView)
      return _withdrawalRequests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'BtcWebVbtcToken(name: $name, description: $description, addresses: $addresses, address: $address, scIdentifier: $scIdentifier, ownerAddress: $ownerAddress, imageUrl: $imageUrl, depositAddress: $depositAddress, publicKeyProofs: $publicKeyProofs, globalBalance: $globalBalance, createdAt: $createdAt, nft: $nft, version: $version, isPendingWithdrawal: $isPendingWithdrawal, frostGroupPublicKey: $frostGroupPublicKey, requiredThreshold: $requiredThreshold, withdrawalRequests: $withdrawalRequests)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_BtcWebVbtcToken &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._addresses, _addresses) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.scIdentifier, scIdentifier) ||
                other.scIdentifier == scIdentifier) &&
            (identical(other.ownerAddress, ownerAddress) ||
                other.ownerAddress == ownerAddress) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.depositAddress, depositAddress) ||
                other.depositAddress == depositAddress) &&
            (identical(other.publicKeyProofs, publicKeyProofs) ||
                other.publicKeyProofs == publicKeyProofs) &&
            (identical(other.globalBalance, globalBalance) ||
                other.globalBalance == globalBalance) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.nft, nft) || other.nft == nft) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.isPendingWithdrawal, isPendingWithdrawal) ||
                other.isPendingWithdrawal == isPendingWithdrawal) &&
            (identical(other.frostGroupPublicKey, frostGroupPublicKey) ||
                other.frostGroupPublicKey == frostGroupPublicKey) &&
            (identical(other.requiredThreshold, requiredThreshold) ||
                other.requiredThreshold == requiredThreshold) &&
            const DeepCollectionEquality()
                .equals(other._withdrawalRequests, _withdrawalRequests));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      description,
      const DeepCollectionEquality().hash(_addresses),
      address,
      scIdentifier,
      ownerAddress,
      imageUrl,
      depositAddress,
      publicKeyProofs,
      globalBalance,
      createdAt,
      nft,
      version,
      isPendingWithdrawal,
      frostGroupPublicKey,
      requiredThreshold,
      const DeepCollectionEquality().hash(_withdrawalRequests));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_BtcWebVbtcTokenCopyWith<_$_BtcWebVbtcToken> get copyWith =>
      __$$_BtcWebVbtcTokenCopyWithImpl<_$_BtcWebVbtcToken>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_BtcWebVbtcTokenToJson(
      this,
    );
  }
}

abstract class _BtcWebVbtcToken extends BtcWebVbtcToken {
  factory _BtcWebVbtcToken(
          {required final String name,
          required final String description,
          required final Map<String, dynamic> addresses,
          required final String address,
          @JsonKey(name: 'sc_identifier')
              required final String scIdentifier,
          @JsonKey(name: 'owner_address')
              required final String ownerAddress,
          @JsonKey(name: 'image_url')
              required final String imageUrl,
          @JsonKey(name: 'deposit_address')
              required final String depositAddress,
          @JsonKey(name: 'public_key_proofs')
              final String? publicKeyProofs,
          @JsonKey(name: 'global_balance')
              required final double globalBalance,
          @JsonKey(name: 'created_at')
              required final DateTime createdAt,
          required final WebNft nft,
          final int version,
          @JsonKey(name: 'is_pending_withdrawal')
              final bool isPendingWithdrawal,
          @JsonKey(name: 'frost_group_public_key')
              final String? frostGroupPublicKey,
          @JsonKey(name: 'required_threshold')
              final int? requiredThreshold,
          @JsonKey(name: 'withdrawal_requests')
              final List<Map<String, dynamic>>? withdrawalRequests}) =
      _$_BtcWebVbtcToken;
  _BtcWebVbtcToken._() : super._();

  factory _BtcWebVbtcToken.fromJson(Map<String, dynamic> json) =
      _$_BtcWebVbtcToken.fromJson;

  @override
  String get name;
  @override
  String get description;
  @override
  Map<String, dynamic> get addresses;
  @override
  String get address;
  @override
  @JsonKey(name: 'sc_identifier')
  String get scIdentifier;
  @override
  @JsonKey(name: 'owner_address')
  String get ownerAddress;
  @override
  @JsonKey(name: 'image_url')
  String get imageUrl;
  @override
  @JsonKey(name: 'deposit_address')
  String get depositAddress;
  @override
  @JsonKey(name: 'public_key_proofs')
  String? get publicKeyProofs;
  @override
  @JsonKey(name: 'global_balance')
  double get globalBalance;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  WebNft get nft;
  @override
  int get version;
  @override
  @JsonKey(name: 'is_pending_withdrawal')
  bool get isPendingWithdrawal;
  @override
  @JsonKey(name: 'frost_group_public_key')
  String? get frostGroupPublicKey;
  @override
  @JsonKey(name: 'required_threshold')
  int? get requiredThreshold;
  @override
  @JsonKey(name: 'withdrawal_requests')
  List<Map<String, dynamic>>? get withdrawalRequests;
  @override
  @JsonKey(ignore: true)
  _$$_BtcWebVbtcTokenCopyWith<_$_BtcWebVbtcToken> get copyWith =>
      throw _privateConstructorUsedError;
}
