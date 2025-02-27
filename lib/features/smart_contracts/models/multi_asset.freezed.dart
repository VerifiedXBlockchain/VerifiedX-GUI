// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'multi_asset.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

MultiAsset _$MultiAssetFromJson(Map<String, dynamic> json) {
  return _MultiAsset.fromJson(json);
}

/// @nodoc
mixin _$MultiAsset {
  String get id => throw _privateConstructorUsedError;
  List<Asset> get assets => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MultiAssetCopyWith<MultiAsset> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MultiAssetCopyWith<$Res> {
  factory $MultiAssetCopyWith(
          MultiAsset value, $Res Function(MultiAsset) then) =
      _$MultiAssetCopyWithImpl<$Res, MultiAsset>;
  @useResult
  $Res call({String id, List<Asset> assets});
}

/// @nodoc
class _$MultiAssetCopyWithImpl<$Res, $Val extends MultiAsset>
    implements $MultiAssetCopyWith<$Res> {
  _$MultiAssetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? assets = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      assets: null == assets
          ? _value.assets
          : assets // ignore: cast_nullable_to_non_nullable
              as List<Asset>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_MultiAssetCopyWith<$Res>
    implements $MultiAssetCopyWith<$Res> {
  factory _$$_MultiAssetCopyWith(
          _$_MultiAsset value, $Res Function(_$_MultiAsset) then) =
      __$$_MultiAssetCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, List<Asset> assets});
}

/// @nodoc
class __$$_MultiAssetCopyWithImpl<$Res>
    extends _$MultiAssetCopyWithImpl<$Res, _$_MultiAsset>
    implements _$$_MultiAssetCopyWith<$Res> {
  __$$_MultiAssetCopyWithImpl(
      _$_MultiAsset _value, $Res Function(_$_MultiAsset) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? assets = null,
  }) {
    return _then(_$_MultiAsset(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      assets: null == assets
          ? _value._assets
          : assets // ignore: cast_nullable_to_non_nullable
              as List<Asset>,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$_MultiAsset extends _MultiAsset {
  const _$_MultiAsset({this.id = "", final List<Asset> assets = const []})
      : _assets = assets,
        super._();

  factory _$_MultiAsset.fromJson(Map<String, dynamic> json) =>
      _$$_MultiAssetFromJson(json);

  @override
  @JsonKey()
  final String id;
  final List<Asset> _assets;
  @override
  @JsonKey()
  List<Asset> get assets {
    if (_assets is EqualUnmodifiableListView) return _assets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_assets);
  }

  @override
  String toString() {
    return 'MultiAsset(id: $id, assets: $assets)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_MultiAsset &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other._assets, _assets));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, const DeepCollectionEquality().hash(_assets));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_MultiAssetCopyWith<_$_MultiAsset> get copyWith =>
      __$$_MultiAssetCopyWithImpl<_$_MultiAsset>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_MultiAssetToJson(
      this,
    );
  }
}

abstract class _MultiAsset extends MultiAsset {
  const factory _MultiAsset({final String id, final List<Asset> assets}) =
      _$_MultiAsset;
  const _MultiAsset._() : super._();

  factory _MultiAsset.fromJson(Map<String, dynamic> json) =
      _$_MultiAsset.fromJson;

  @override
  String get id;
  @override
  List<Asset> get assets;
  @override
  @JsonKey(ignore: true)
  _$$_MultiAssetCopyWith<_$_MultiAsset> get copyWith =>
      throw _privateConstructorUsedError;
}
