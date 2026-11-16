// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'p2p_collection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

P2pCollection _$P2pCollectionFromJson(Map<String, dynamic> json) {
  return _P2pCollection.fromJson(json);
}

/// @nodoc
mixin _$P2pCollection {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'shop_url')
  String get shopUrl => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_live')
  bool get isLive =>
      throw _privateConstructorUsedError; // Every shop gets a default collection, "Main", when it is registered.
  @JsonKey(name: 'is_default')
  bool get isDefault => throw _privateConstructorUsedError;
  @JsonKey(name: 'listing_count')
  int get listingCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $P2pCollectionCopyWith<P2pCollection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $P2pCollectionCopyWith<$Res> {
  factory $P2pCollectionCopyWith(
          P2pCollection value, $Res Function(P2pCollection) then) =
      _$P2pCollectionCopyWithImpl<$Res, P2pCollection>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'shop_url') String shopUrl,
      String name,
      String description,
      @JsonKey(name: 'is_live') bool isLive,
      @JsonKey(name: 'is_default') bool isDefault,
      @JsonKey(name: 'listing_count') int listingCount});
}

/// @nodoc
class _$P2pCollectionCopyWithImpl<$Res, $Val extends P2pCollection>
    implements $P2pCollectionCopyWith<$Res> {
  _$P2pCollectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? shopUrl = null,
    Object? name = null,
    Object? description = null,
    Object? isLive = null,
    Object? isDefault = null,
    Object? listingCount = null,
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
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      isLive: null == isLive
          ? _value.isLive
          : isLive // ignore: cast_nullable_to_non_nullable
              as bool,
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
      listingCount: null == listingCount
          ? _value.listingCount
          : listingCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_P2pCollectionCopyWith<$Res>
    implements $P2pCollectionCopyWith<$Res> {
  factory _$$_P2pCollectionCopyWith(
          _$_P2pCollection value, $Res Function(_$_P2pCollection) then) =
      __$$_P2pCollectionCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'shop_url') String shopUrl,
      String name,
      String description,
      @JsonKey(name: 'is_live') bool isLive,
      @JsonKey(name: 'is_default') bool isDefault,
      @JsonKey(name: 'listing_count') int listingCount});
}

/// @nodoc
class __$$_P2pCollectionCopyWithImpl<$Res>
    extends _$P2pCollectionCopyWithImpl<$Res, _$_P2pCollection>
    implements _$$_P2pCollectionCopyWith<$Res> {
  __$$_P2pCollectionCopyWithImpl(
      _$_P2pCollection _value, $Res Function(_$_P2pCollection) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? shopUrl = null,
    Object? name = null,
    Object? description = null,
    Object? isLive = null,
    Object? isDefault = null,
    Object? listingCount = null,
  }) {
    return _then(_$_P2pCollection(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      shopUrl: null == shopUrl
          ? _value.shopUrl
          : shopUrl // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      isLive: null == isLive
          ? _value.isLive
          : isLive // ignore: cast_nullable_to_non_nullable
              as bool,
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
      listingCount: null == listingCount
          ? _value.listingCount
          : listingCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_P2pCollection extends _P2pCollection {
  _$_P2pCollection(
      {required this.id,
      @JsonKey(name: 'shop_url') required this.shopUrl,
      required this.name,
      this.description = '',
      @JsonKey(name: 'is_live') this.isLive = true,
      @JsonKey(name: 'is_default') this.isDefault = false,
      @JsonKey(name: 'listing_count') this.listingCount = 0})
      : super._();

  factory _$_P2pCollection.fromJson(Map<String, dynamic> json) =>
      _$$_P2pCollectionFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'shop_url')
  final String shopUrl;
  @override
  final String name;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey(name: 'is_live')
  final bool isLive;
// Every shop gets a default collection, "Main", when it is registered.
  @override
  @JsonKey(name: 'is_default')
  final bool isDefault;
  @override
  @JsonKey(name: 'listing_count')
  final int listingCount;

  @override
  String toString() {
    return 'P2pCollection(id: $id, shopUrl: $shopUrl, name: $name, description: $description, isLive: $isLive, isDefault: $isDefault, listingCount: $listingCount)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_P2pCollection &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.shopUrl, shopUrl) || other.shopUrl == shopUrl) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.isLive, isLive) || other.isLive == isLive) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.listingCount, listingCount) ||
                other.listingCount == listingCount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, shopUrl, name, description,
      isLive, isDefault, listingCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_P2pCollectionCopyWith<_$_P2pCollection> get copyWith =>
      __$$_P2pCollectionCopyWithImpl<_$_P2pCollection>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_P2pCollectionToJson(
      this,
    );
  }
}

abstract class _P2pCollection extends P2pCollection {
  factory _P2pCollection(
          {required final int id,
          @JsonKey(name: 'shop_url') required final String shopUrl,
          required final String name,
          final String description,
          @JsonKey(name: 'is_live') final bool isLive,
          @JsonKey(name: 'is_default') final bool isDefault,
          @JsonKey(name: 'listing_count') final int listingCount}) =
      _$_P2pCollection;
  _P2pCollection._() : super._();

  factory _P2pCollection.fromJson(Map<String, dynamic> json) =
      _$_P2pCollection.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'shop_url')
  String get shopUrl;
  @override
  String get name;
  @override
  String get description;
  @override
  @JsonKey(name: 'is_live')
  bool get isLive;
  @override // Every shop gets a default collection, "Main", when it is registered.
  @JsonKey(name: 'is_default')
  bool get isDefault;
  @override
  @JsonKey(name: 'listing_count')
  int get listingCount;
  @override
  @JsonKey(ignore: true)
  _$$_P2pCollectionCopyWith<_$_P2pCollection> get copyWith =>
      throw _privateConstructorUsedError;
}
