import 'dart:io';

import 'package:path/path.dart' as p;

/// Core databases that hold keys or other data a snapshot cannot recreate:
/// accounts and reserve accounts, the HD seed, the keystore, BTC accounts,
/// vBTC validator key shares, arbiter shares, shielded wallets and node
/// settings. A snapshot import keeps these in place and never overwrites
/// them. Names are lower case; Core's LiteDB log companion for each is
/// `<name>-log.db`.
const snapshotPreservedDatabases = {
  'rsrvwaldata.db',
  'rsrvhdwaldata.db',
  'rsrvkeystore.db',
  'rsrvbitcoin.db',
  'rsrvvbtc.db',
  'rsrvshares.db',
  'db_privacy.db',
  'rsrvsettings.db',
};

/// Whether [fileName] (a bare file name, any case) is one of
/// [snapshotPreservedDatabases] or its log file.
bool isSnapshotPreservedDatabase(String fileName) {
  final lower = fileName.toLowerCase();
  if (snapshotPreservedDatabases.contains(lower)) {
    return true;
  }
  if (lower.endsWith('-log.db')) {
    return snapshotPreservedDatabases.contains(lower.replaceFirst(RegExp(r'-log\.db$'), '.db'));
  }
  return false;
}

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
/// name (no separators, drive letters or `..`). Preserved databases are
/// refused so a snapshot can never replace them. As a last check the joined
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

  if (isSnapshotPreservedDatabase(fileName)) {
    throw SnapshotFileRejected(url, 'would replace a preserved database');
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

/// Gets [databasesFolder] ready for a snapshot download.
///
/// Every preserved database found there is first copied into a new
/// timestamped folder under [backupRoot] and the copy's size checked; then
/// everything else in [databasesFolder] (chain data and anything derived
/// from it) is deleted. The preserved databases stay where they are. Returns
/// the backup folder, or null when there was nothing to back up. Throws if
/// the backup cannot be made, before anything is deleted.
Future<String?> prepareDatabasesFolderForSnapshot({
  required String databasesFolder,
  required String backupRoot,
  DateTime? now,
}) async {
  final folder = Directory(databasesFolder);
  if (!await folder.exists()) {
    await folder.create(recursive: true);
    return null;
  }

  final entries = await folder.list(followLinks: false).toList();
  final preserved = entries.whereType<File>().where((f) => isSnapshotPreservedDatabase(p.basename(f.path))).toList();

  String? backupPath;
  if (preserved.isNotEmpty) {
    backupPath = await _createBackupFolder(backupRoot, now ?? DateTime.now());
    for (final file in preserved) {
      final copy = await file.copy(p.join(backupPath, p.basename(file.path)));
      final originalSize = await file.length();
      final copySize = await copy.length();
      if (copySize != originalSize) {
        throw FileSystemException('Backup copy is $copySize bytes, expected $originalSize', copy.path);
      }
    }
  }

  for (final entry in entries) {
    if (entry is File && isSnapshotPreservedDatabase(p.basename(entry.path))) {
      continue;
    }
    await entry.delete(recursive: true);
  }

  return backupPath;
}

Future<String> _createBackupFolder(String backupRoot, DateTime now) async {
  String two(int n) => n.toString().padLeft(2, '0');
  final stamp = '${now.year}${two(now.month)}${two(now.day)}-${two(now.hour)}${two(now.minute)}${two(now.second)}';
  var candidate = p.join(backupRoot, 'snapshot-import-$stamp');
  var suffix = 1;
  while (await Directory(candidate).exists()) {
    candidate = p.join(backupRoot, 'snapshot-import-$stamp-$suffix');
    suffix++;
  }
  await Directory(candidate).create(recursive: true);
  return candidate;
}
