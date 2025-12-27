// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snapshot_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_SnapshotInfo _$$_SnapshotInfoFromJson(Map<String, dynamic> json) =>
    _$_SnapshotInfo(
      success: json['success'] as bool,
      network: json['network'] as String?,
      height: json['height'] as int?,
      totalSizeBytes: json['total_size_bytes'] as int?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      urls: (json['urls'] as List<dynamic>?)?.map((e) => e as String).toList(),
      error: json['error'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$_SnapshotInfoToJson(_$_SnapshotInfo instance) =>
    <String, dynamic>{
      'success': instance.success,
      'network': instance.network,
      'height': instance.height,
      'total_size_bytes': instance.totalSizeBytes,
      'created_at': instance.createdAt?.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
      'urls': instance.urls,
      'error': instance.error,
      'message': instance.message,
    };
