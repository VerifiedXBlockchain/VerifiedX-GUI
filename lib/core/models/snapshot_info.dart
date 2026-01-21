import 'package:freezed_annotation/freezed_annotation.dart';

part 'snapshot_info.freezed.dart';
part 'snapshot_info.g.dart';

@freezed
class SnapshotInfo with _$SnapshotInfo {
  const SnapshotInfo._();

  factory SnapshotInfo({
    required bool success,
    String? network,
    int? height,
    @JsonKey(name: 'total_size_bytes') int? totalSizeBytes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    List<String>? urls,
    String? error,
    String? message,
  }) = _SnapshotInfo;

  factory SnapshotInfo.fromJson(Map<String, dynamic> json) =>
      _$SnapshotInfoFromJson(json);

  bool get isAvailable => success && height != null && urls != null && urls!.isNotEmpty;
}
