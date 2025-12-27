// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'snapshot_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

SnapshotInfo _$SnapshotInfoFromJson(Map<String, dynamic> json) {
  return _SnapshotInfo.fromJson(json);
}

/// @nodoc
mixin _$SnapshotInfo {
  bool get success => throw _privateConstructorUsedError;
  String? get network => throw _privateConstructorUsedError;
  int? get height => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_size_bytes')
  int? get totalSizeBytes => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'completed_at')
  DateTime? get completedAt => throw _privateConstructorUsedError;
  List<String>? get urls => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SnapshotInfoCopyWith<SnapshotInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnapshotInfoCopyWith<$Res> {
  factory $SnapshotInfoCopyWith(
          SnapshotInfo value, $Res Function(SnapshotInfo) then) =
      _$SnapshotInfoCopyWithImpl<$Res, SnapshotInfo>;
  @useResult
  $Res call(
      {bool success,
      String? network,
      int? height,
      @JsonKey(name: 'total_size_bytes') int? totalSizeBytes,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'completed_at') DateTime? completedAt,
      List<String>? urls,
      String? error,
      String? message});
}

/// @nodoc
class _$SnapshotInfoCopyWithImpl<$Res, $Val extends SnapshotInfo>
    implements $SnapshotInfoCopyWith<$Res> {
  _$SnapshotInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? network = freezed,
    Object? height = freezed,
    Object? totalSizeBytes = freezed,
    Object? createdAt = freezed,
    Object? completedAt = freezed,
    Object? urls = freezed,
    Object? error = freezed,
    Object? message = freezed,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      network: freezed == network
          ? _value.network
          : network // ignore: cast_nullable_to_non_nullable
              as String?,
      height: freezed == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int?,
      totalSizeBytes: freezed == totalSizeBytes
          ? _value.totalSizeBytes
          : totalSizeBytes // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      urls: freezed == urls
          ? _value.urls
          : urls // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_SnapshotInfoCopyWith<$Res>
    implements $SnapshotInfoCopyWith<$Res> {
  factory _$$_SnapshotInfoCopyWith(
          _$_SnapshotInfo value, $Res Function(_$_SnapshotInfo) then) =
      __$$_SnapshotInfoCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool success,
      String? network,
      int? height,
      @JsonKey(name: 'total_size_bytes') int? totalSizeBytes,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'completed_at') DateTime? completedAt,
      List<String>? urls,
      String? error,
      String? message});
}

/// @nodoc
class __$$_SnapshotInfoCopyWithImpl<$Res>
    extends _$SnapshotInfoCopyWithImpl<$Res, _$_SnapshotInfo>
    implements _$$_SnapshotInfoCopyWith<$Res> {
  __$$_SnapshotInfoCopyWithImpl(
      _$_SnapshotInfo _value, $Res Function(_$_SnapshotInfo) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? network = freezed,
    Object? height = freezed,
    Object? totalSizeBytes = freezed,
    Object? createdAt = freezed,
    Object? completedAt = freezed,
    Object? urls = freezed,
    Object? error = freezed,
    Object? message = freezed,
  }) {
    return _then(_$_SnapshotInfo(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      network: freezed == network
          ? _value.network
          : network // ignore: cast_nullable_to_non_nullable
              as String?,
      height: freezed == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int?,
      totalSizeBytes: freezed == totalSizeBytes
          ? _value.totalSizeBytes
          : totalSizeBytes // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      urls: freezed == urls
          ? _value._urls
          : urls // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_SnapshotInfo extends _SnapshotInfo {
  _$_SnapshotInfo(
      {required this.success,
      this.network,
      this.height,
      @JsonKey(name: 'total_size_bytes') this.totalSizeBytes,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'completed_at') this.completedAt,
      final List<String>? urls,
      this.error,
      this.message})
      : _urls = urls,
        super._();

  factory _$_SnapshotInfo.fromJson(Map<String, dynamic> json) =>
      _$$_SnapshotInfoFromJson(json);

  @override
  final bool success;
  @override
  final String? network;
  @override
  final int? height;
  @override
  @JsonKey(name: 'total_size_bytes')
  final int? totalSizeBytes;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;
  final List<String>? _urls;
  @override
  List<String>? get urls {
    final value = _urls;
    if (value == null) return null;
    if (_urls is EqualUnmodifiableListView) return _urls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? error;
  @override
  final String? message;

  @override
  String toString() {
    return 'SnapshotInfo(success: $success, network: $network, height: $height, totalSizeBytes: $totalSizeBytes, createdAt: $createdAt, completedAt: $completedAt, urls: $urls, error: $error, message: $message)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_SnapshotInfo &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.network, network) || other.network == network) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.totalSizeBytes, totalSizeBytes) ||
                other.totalSizeBytes == totalSizeBytes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            const DeepCollectionEquality().equals(other._urls, _urls) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      success,
      network,
      height,
      totalSizeBytes,
      createdAt,
      completedAt,
      const DeepCollectionEquality().hash(_urls),
      error,
      message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_SnapshotInfoCopyWith<_$_SnapshotInfo> get copyWith =>
      __$$_SnapshotInfoCopyWithImpl<_$_SnapshotInfo>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_SnapshotInfoToJson(
      this,
    );
  }
}

abstract class _SnapshotInfo extends SnapshotInfo {
  factory _SnapshotInfo(
      {required final bool success,
      final String? network,
      final int? height,
      @JsonKey(name: 'total_size_bytes') final int? totalSizeBytes,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      @JsonKey(name: 'completed_at') final DateTime? completedAt,
      final List<String>? urls,
      final String? error,
      final String? message}) = _$_SnapshotInfo;
  _SnapshotInfo._() : super._();

  factory _SnapshotInfo.fromJson(Map<String, dynamic> json) =
      _$_SnapshotInfo.fromJson;

  @override
  bool get success;
  @override
  String? get network;
  @override
  int? get height;
  @override
  @JsonKey(name: 'total_size_bytes')
  int? get totalSizeBytes;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'completed_at')
  DateTime? get completedAt;
  @override
  List<String>? get urls;
  @override
  String? get error;
  @override
  String? get message;
  @override
  @JsonKey(ignore: true)
  _$$_SnapshotInfoCopyWith<_$_SnapshotInfo> get copyWith =>
      throw _privateConstructorUsedError;
}
