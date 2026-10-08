import 'package:path/path.dart' as p;

final _snapshotFileNamePattern = RegExp(r'^[A-Za-z0-9_][A-Za-z0-9_.-]*\.db$');

/// One file from a snapshot manifest, resolved to where it will be written.
class SnapshotFileTarget {
  final String url;
  final String fileName;
  final String filePath;

  const SnapshotFileTarget({
    required this.url,
    required this.fileName,
    required this.filePath,
  });
}

/// Thrown when a snapshot manifest lists a file that cannot be imported.
class SnapshotFileRejected implements Exception {
  final String url;
  final String reason;

  const SnapshotFileRejected(this.url, this.reason);

  @override
  String toString() => 'SnapshotFileRejected($url): $reason';
}

/// Resolves a snapshot download [url] to a file inside [databasesFolder].
///
/// The URL must be HTTPS and its last path segment a plain database file
/// name (no separators, drive letters or `..`). As a last check the joined
/// path is normalized and must still sit directly inside [databasesFolder].
/// [context] defaults to the host platform's path rules.
SnapshotFileTarget resolveSnapshotFile(
  String url,
  String databasesFolder, {
  p.Context? context,
}) {
  final pathContext = context ?? p.context;

  final uri = Uri.tryParse(url);
  if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
    throw SnapshotFileRejected(url, 'not an https URL');
  }

  final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  if (segments.isEmpty) {
    throw SnapshotFileRejected(url, 'no file name');
  }

  final fileName = segments.last;
  if (!_snapshotFileNamePattern.hasMatch(fileName) || fileName.contains('..')) {
    throw SnapshotFileRejected(url, 'unsupported file name');
  }

  final folder = pathContext.normalize(databasesFolder);
  final filePath = pathContext.normalize(pathContext.join(folder, fileName));
  if (!pathContext.isWithin(folder, filePath) || pathContext.dirname(filePath) != folder) {
    throw SnapshotFileRejected(url, 'resolves outside the databases folder');
  }

  return SnapshotFileTarget(url: url, fileName: fileName, filePath: filePath);
}

/// Resolves every URL in a snapshot manifest, rejecting the whole list if
/// any entry is unsafe or two entries map to the same file.
List<SnapshotFileTarget> resolveSnapshotFiles(
  List<String> urls,
  String databasesFolder, {
  p.Context? context,
}) {
  final targets = <SnapshotFileTarget>[];
  final seen = <String>{};
  for (final url in urls) {
    final target = resolveSnapshotFile(url, databasesFolder, context: context);
    if (!seen.add(target.fileName.toLowerCase())) {
      throw SnapshotFileRejected(url, 'duplicate file name');
    }
    targets.add(target);
  }
  return targets;
}
