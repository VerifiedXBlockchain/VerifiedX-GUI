// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'p2p_shop.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

P2pShop _$P2pShopFromJson(Map<String, dynamic> json) {
  return _P2pShop.fromJson(json);
}

/// @nodoc
mixin _$P2pShop {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'unique_id')
  String get uniqueId =>
      throw _privateConstructorUsedError; // Normalised: no `vfx://`, lower case.
  String get url => throw _privateConstructorUsedError;
  @JsonKey(name: 'display_url')
  String get displayUrl => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'owner_address')
  String get ownerAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'chain_state', unknownEnumValue: P2pShopChainState.unknown)
  P2pShopChainState get chainState => throw _privateConstructorUsedError;
  @JsonKey(name: 'registered_at')
  DateTime? get registeredAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'collection_count')
  int get collectionCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'live_listing_count')
  int get liveListingCount =>
      throw _privateConstructorUsedError; // On the shop's own page only (`GET /p2p/shops/{url}/`); null in a list.
  List<P2pCollection>? get collections => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $P2pShopCopyWith<P2pShop> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $P2pShopCopyWith<$Res> {
  factory $P2pShopCopyWith(P2pShop value, $Res Function(P2pShop) then) =
      _$P2pShopCopyWithImpl<$Res, P2pShop>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'unique_id')
          String uniqueId,
      String url,
      @JsonKey(name: 'display_url')
          String displayUrl,
      String name,
      String description,
      @JsonKey(name: 'owner_address')
          String ownerAddress,
      @JsonKey(name: 'chain_state', unknownEnumValue: P2pShopChainState.unknown)
          P2pShopChainState chainState,
      @JsonKey(name: 'registered_at')
          DateTime? registeredAt,
      @JsonKey(name: 'updated_at')
          DateTime? updatedAt,
      @JsonKey(name: 'collection_count')
          int collectionCount,
      @JsonKey(name: 'live_listing_count')
          int liveListingCount,
      List<P2pCollection>? collections});
}

/// @nodoc
class _$P2pShopCopyWithImpl<$Res, $Val extends P2pShop>
    implements $P2pShopCopyWith<$Res> {
  _$P2pShopCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? uniqueId = null,
    Object? url = null,
    Object? displayUrl = null,
    Object? name = null,
    Object? description = null,
    Object? ownerAddress = null,
    Object? chainState = null,
    Object? registeredAt = freezed,
    Object? updatedAt = freezed,
    Object? collectionCount = null,
    Object? liveListingCount = null,
    Object? collections = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      uniqueId: null == uniqueId
          ? _value.uniqueId
          : uniqueId // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      displayUrl: null == displayUrl
          ? _value.displayUrl
          : displayUrl // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      ownerAddress: null == ownerAddress
          ? _value.ownerAddress
          : ownerAddress // ignore: cast_nullable_to_non_nullable
              as String,
      chainState: null == chainState
          ? _value.chainState
          : chainState // ignore: cast_nullable_to_non_nullable
              as P2pShopChainState,
      registeredAt: freezed == registeredAt
          ? _value.registeredAt
          : registeredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      collectionCount: null == collectionCount
          ? _value.collectionCount
          : collectionCount // ignore: cast_nullable_to_non_nullable
              as int,
      liveListingCount: null == liveListingCount
          ? _value.liveListingCount
          : liveListingCount // ignore: cast_nullable_to_non_nullable
              as int,
      collections: freezed == collections
          ? _value.collections
          : collections // ignore: cast_nullable_to_non_nullable
              as List<P2pCollection>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_P2pShopCopyWith<$Res> implements $P2pShopCopyWith<$Res> {
  factory _$$_P2pShopCopyWith(
          _$_P2pShop value, $Res Function(_$_P2pShop) then) =
      __$$_P2pShopCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'unique_id')
          String uniqueId,
      String url,
      @JsonKey(name: 'display_url')
          String displayUrl,
      String name,
      String description,
      @JsonKey(name: 'owner_address')
          String ownerAddress,
      @JsonKey(name: 'chain_state', unknownEnumValue: P2pShopChainState.unknown)
          P2pShopChainState chainState,
      @JsonKey(name: 'registered_at')
          DateTime? registeredAt,
      @JsonKey(name: 'updated_at')
          DateTime? updatedAt,
      @JsonKey(name: 'collection_count')
          int collectionCount,
      @JsonKey(name: 'live_listing_count')
          int liveListingCount,
      List<P2pCollection>? collections});
}

/// @nodoc
class __$$_P2pShopCopyWithImpl<$Res>
    extends _$P2pShopCopyWithImpl<$Res, _$_P2pShop>
    implements _$$_P2pShopCopyWith<$Res> {
  __$$_P2pShopCopyWithImpl(_$_P2pShop _value, $Res Function(_$_P2pShop) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? uniqueId = null,
    Object? url = null,
    Object? displayUrl = null,
    Object? name = null,
    Object? description = null,
    Object? ownerAddress = null,
    Object? chainState = null,
    Object? registeredAt = freezed,
    Object? updatedAt = freezed,
    Object? collectionCount = null,
    Object? liveListingCount = null,
    Object? collections = freezed,
  }) {
    return _then(_$_P2pShop(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      uniqueId: null == uniqueId
          ? _value.uniqueId
          : uniqueId // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      displayUrl: null == displayUrl
          ? _value.displayUrl
          : displayUrl // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      ownerAddress: null == ownerAddress
          ? _value.ownerAddress
          : ownerAddress // ignore: cast_nullable_to_non_nullable
              as String,
      chainState: null == chainState
          ? _value.chainState
          : chainState // ignore: cast_nullable_to_non_nullable
              as P2pShopChainState,
      registeredAt: freezed == registeredAt
          ? _value.registeredAt
          : registeredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      collectionCount: null == collectionCount
          ? _value.collectionCount
          : collectionCount // ignore: cast_nullable_to_non_nullable
              as int,
      liveListingCount: null == liveListingCount
          ? _value.liveListingCount
          : liveListingCount // ignore: cast_nullable_to_non_nullable
              as int,
      collections: freezed == collections
          ? _value._collections
          : collections // ignore: cast_nullable_to_non_nullable
              as List<P2pCollection>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_P2pShop extends _P2pShop {
  _$_P2pShop(
      {required this.id,
      @JsonKey(name: 'unique_id')
          required this.uniqueId,
      required this.url,
      @JsonKey(name: 'display_url')
          required this.displayUrl,
      required this.name,
      this.description = '',
      @JsonKey(name: 'owner_address')
          required this.ownerAddress,
      @JsonKey(name: 'chain_state', unknownEnumValue: P2pShopChainState.unknown)
          this.chainState = P2pShopChainState.unknown,
      @JsonKey(name: 'registered_at')
          this.registeredAt,
      @JsonKey(name: 'updated_at')
          this.updatedAt,
      @JsonKey(name: 'collection_count')
          this.collectionCount = 0,
      @JsonKey(name: 'live_listing_count')
          this.liveListingCount = 0,
      final List<P2pCollection>? collections})
      : _collections = collections,
        super._();

  factory _$_P2pShop.fromJson(Map<String, dynamic> json) =>
      _$$_P2pShopFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'unique_id')
  final String uniqueId;
// Normalised: no `vfx://`, lower case.
  @override
  final String url;
  @override
  @JsonKey(name: 'display_url')
  final String displayUrl;
  @override
  final String name;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey(name: 'owner_address')
  final String ownerAddress;
  @override
  @JsonKey(name: 'chain_state', unknownEnumValue: P2pShopChainState.unknown)
  final P2pShopChainState chainState;
  @override
  @JsonKey(name: 'registered_at')
  final DateTime? registeredAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @override
  @JsonKey(name: 'collection_count')
  final int collectionCount;
  @override
  @JsonKey(name: 'live_listing_count')
  final int liveListingCount;
// On the shop's own page only (`GET /p2p/shops/{url}/`); null in a list.
  final List<P2pCollection>? _collections;
// On the shop's own page only (`GET /p2p/shops/{url}/`); null in a list.
  @override
  List<P2pCollection>? get collections {
    final value = _collections;
    if (value == null) return null;
    if (_collections is EqualUnmodifiableListView) return _collections;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'P2pShop(id: $id, uniqueId: $uniqueId, url: $url, displayUrl: $displayUrl, name: $name, description: $description, ownerAddress: $ownerAddress, chainState: $chainState, registeredAt: $registeredAt, updatedAt: $updatedAt, collectionCount: $collectionCount, liveListingCount: $liveListingCount, collections: $collections)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_P2pShop &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.uniqueId, uniqueId) ||
                other.uniqueId == uniqueId) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.displayUrl, displayUrl) ||
                other.displayUrl == displayUrl) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.ownerAddress, ownerAddress) ||
                other.ownerAddress == ownerAddress) &&
            (identical(other.chainState, chainState) ||
                other.chainState == chainState) &&
            (identical(other.registeredAt, registeredAt) ||
                other.registeredAt == registeredAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.collectionCount, collectionCount) ||
                other.collectionCount == collectionCount) &&
            (identical(other.liveListingCount, liveListingCount) ||
                other.liveListingCount == liveListingCount) &&
            const DeepCollectionEquality()
                .equals(other._collections, _collections));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      uniqueId,
      url,
      displayUrl,
      name,
      description,
      ownerAddress,
      chainState,
      registeredAt,
      updatedAt,
      collectionCount,
      liveListingCount,
      const DeepCollectionEquality().hash(_collections));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_P2pShopCopyWith<_$_P2pShop> get copyWith =>
      __$$_P2pShopCopyWithImpl<_$_P2pShop>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_P2pShopToJson(
      this,
    );
  }
}

abstract class _P2pShop extends P2pShop {
  factory _P2pShop(
      {required final int id,
      @JsonKey(name: 'unique_id')
          required final String uniqueId,
      required final String url,
      @JsonKey(name: 'display_url')
          required final String displayUrl,
      required final String name,
      final String description,
      @JsonKey(name: 'owner_address')
          required final String ownerAddress,
      @JsonKey(name: 'chain_state', unknownEnumValue: P2pShopChainState.unknown)
          final P2pShopChainState chainState,
      @JsonKey(name: 'registered_at')
          final DateTime? registeredAt,
      @JsonKey(name: 'updated_at')
          final DateTime? updatedAt,
      @JsonKey(name: 'collection_count')
          final int collectionCount,
      @JsonKey(name: 'live_listing_count')
          final int liveListingCount,
      final List<P2pCollection>? collections}) = _$_P2pShop;
  _P2pShop._() : super._();

  factory _P2pShop.fromJson(Map<String, dynamic> json) = _$_P2pShop.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'unique_id')
  String get uniqueId;
  @override // Normalised: no `vfx://`, lower case.
  String get url;
  @override
  @JsonKey(name: 'display_url')
  String get displayUrl;
  @override
  String get name;
  @override
  String get description;
  @override
  @JsonKey(name: 'owner_address')
  String get ownerAddress;
  @override
  @JsonKey(name: 'chain_state', unknownEnumValue: P2pShopChainState.unknown)
  P2pShopChainState get chainState;
  @override
  @JsonKey(name: 'registered_at')
  DateTime? get registeredAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  @JsonKey(name: 'collection_count')
  int get collectionCount;
  @override
  @JsonKey(name: 'live_listing_count')
  int get liveListingCount;
  @override // On the shop's own page only (`GET /p2p/shops/{url}/`); null in a list.
  List<P2pCollection>? get collections;
  @override
  @JsonKey(ignore: true)
  _$$_P2pShopCopyWith<_$_P2pShop> get copyWith =>
      throw _privateConstructorUsedError;
}

P2pUrlAvailability _$P2pUrlAvailabilityFromJson(Map<String, dynamic> json) {
  return _P2pUrlAvailability.fromJson(json);
}

/// @nodoc
mixin _$P2pUrlAvailability {
  String get url => throw _privateConstructorUsedError;
  String get normalized => throw _privateConstructorUsedError;
  bool get available =>
      throw _privateConstructorUsedError; // `taken`, `invalid` or null.
  String? get reason => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $P2pUrlAvailabilityCopyWith<P2pUrlAvailability> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $P2pUrlAvailabilityCopyWith<$Res> {
  factory $P2pUrlAvailabilityCopyWith(
          P2pUrlAvailability value, $Res Function(P2pUrlAvailability) then) =
      _$P2pUrlAvailabilityCopyWithImpl<$Res, P2pUrlAvailability>;
  @useResult
  $Res call({String url, String normalized, bool available, String? reason});
}

/// @nodoc
class _$P2pUrlAvailabilityCopyWithImpl<$Res, $Val extends P2pUrlAvailability>
    implements $P2pUrlAvailabilityCopyWith<$Res> {
  _$P2pUrlAvailabilityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? normalized = null,
    Object? available = null,
    Object? reason = freezed,
  }) {
    return _then(_value.copyWith(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      normalized: null == normalized
          ? _value.normalized
          : normalized // ignore: cast_nullable_to_non_nullable
              as String,
      available: null == available
          ? _value.available
          : available // ignore: cast_nullable_to_non_nullable
              as bool,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_P2pUrlAvailabilityCopyWith<$Res>
    implements $P2pUrlAvailabilityCopyWith<$Res> {
  factory _$$_P2pUrlAvailabilityCopyWith(_$_P2pUrlAvailability value,
          $Res Function(_$_P2pUrlAvailability) then) =
      __$$_P2pUrlAvailabilityCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String url, String normalized, bool available, String? reason});
}

/// @nodoc
class __$$_P2pUrlAvailabilityCopyWithImpl<$Res>
    extends _$P2pUrlAvailabilityCopyWithImpl<$Res, _$_P2pUrlAvailability>
    implements _$$_P2pUrlAvailabilityCopyWith<$Res> {
  __$$_P2pUrlAvailabilityCopyWithImpl(
      _$_P2pUrlAvailability _value, $Res Function(_$_P2pUrlAvailability) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? normalized = null,
    Object? available = null,
    Object? reason = freezed,
  }) {
    return _then(_$_P2pUrlAvailability(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      normalized: null == normalized
          ? _value.normalized
          : normalized // ignore: cast_nullable_to_non_nullable
              as String,
      available: null == available
          ? _value.available
          : available // ignore: cast_nullable_to_non_nullable
              as bool,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_P2pUrlAvailability implements _P2pUrlAvailability {
  _$_P2pUrlAvailability(
      {required this.url,
      required this.normalized,
      required this.available,
      this.reason});

  factory _$_P2pUrlAvailability.fromJson(Map<String, dynamic> json) =>
      _$$_P2pUrlAvailabilityFromJson(json);

  @override
  final String url;
  @override
  final String normalized;
  @override
  final bool available;
// `taken`, `invalid` or null.
  @override
  final String? reason;

  @override
  String toString() {
    return 'P2pUrlAvailability(url: $url, normalized: $normalized, available: $available, reason: $reason)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_P2pUrlAvailability &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.normalized, normalized) ||
                other.normalized == normalized) &&
            (identical(other.available, available) ||
                other.available == available) &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, url, normalized, available, reason);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_P2pUrlAvailabilityCopyWith<_$_P2pUrlAvailability> get copyWith =>
      __$$_P2pUrlAvailabilityCopyWithImpl<_$_P2pUrlAvailability>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_P2pUrlAvailabilityToJson(
      this,
    );
  }
}

abstract class _P2pUrlAvailability implements P2pUrlAvailability {
  factory _P2pUrlAvailability(
      {required final String url,
      required final String normalized,
      required final bool available,
      final String? reason}) = _$_P2pUrlAvailability;

  factory _P2pUrlAvailability.fromJson(Map<String, dynamic> json) =
      _$_P2pUrlAvailability.fromJson;

  @override
  String get url;
  @override
  String get normalized;
  @override
  bool get available;
  @override // `taken`, `invalid` or null.
  String? get reason;
  @override
  @JsonKey(ignore: true)
  _$$_P2pUrlAvailabilityCopyWith<_$_P2pUrlAvailability> get copyWith =>
      throw _privateConstructorUsedError;
}
