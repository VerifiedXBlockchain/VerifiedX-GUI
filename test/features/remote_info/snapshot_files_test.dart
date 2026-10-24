import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:rbx_wallet/features/remote_info/utils/snapshot_files.dart';

const _base = 'https://snapshots.verifiedx.io/mainnet_20261008_070016';

void main() {
  group('isSnapshotPreservedDatabase', () {
    test('matches key databases and their log files in any case', () {
      expect(isSnapshotPreservedDatabase('rsrvwaldata.db'), isTrue);
      expect(isSnapshotPreservedDatabase('rsrvwaldata-log.db'), isTrue);
      expect(isSnapshotPreservedDatabase('RSRVBITCOIN.DB'), isTrue);
      expect(isSnapshotPreservedDatabase('DB_Privacy.db'), isTrue);
      expect(isSnapshotPreservedDatabase('rsrvvbtc-log.db'), isTrue);
    });

    test('does not match chain data', () {
      expect(isSnapshotPreservedDatabase('rsrvblkdata.db'), isFalse);
      expect(isSnapshotPreservedDatabase('rsrvvbtcwithdrawalrequests.db'), isFalse);
      expect(isSnapshotPreservedDatabase('rsrvwstatetrei-log.db'), isFalse);
    });
  });

  group('resolveSnapshotFile on POSIX', () {
    final posix = p.Context(style: p.Style.posix);
    const folder = '/Users/someone/rbx/Databases';

    test('resolves a chain database into the folder', () {
      final target = resolveSnapshotFile('$_base/rsrvblkdata.db', folder, context: posix);
      expect(target.fileName, 'rsrvblkdata.db');
      expect(target.filePath, '/Users/someone/rbx/Databases/rsrvblkdata.db');
    });

    test('refuses parent-directory and encoded separators', () {
      for (final url in [
        '$_base/..%2F..%2Fescape.db',
        '$_base/..',
        '$_base/.hidden.db',
        '$_base/sub%2Fdir.db',
      ]) {
        expect(() => resolveSnapshotFile(url, folder, context: posix), throwsA(isA<SnapshotFileRejected>()), reason: url);
      }
    });

    test('refuses non-https URLs and names that are not database files', () {
      for (final url in [
        'http://snapshots.verifiedx.io/x/rsrvblkdata.db',
        'file:///etc/rsrvblkdata.db',
        '$_base/',
        '$_base/config.txt',
      ]) {
        expect(() => resolveSnapshotFile(url, folder, context: posix), throwsA(isA<SnapshotFileRejected>()), reason: url);
      }
    });

    test('refuses a file that would replace a key database', () {
      expect(() => resolveSnapshotFile('$_base/rsrvwaldata.db', folder, context: posix), throwsA(isA<SnapshotFileRejected>()));
      expect(() => resolveSnapshotFile('$_base/RsrvHdWalData-log.db', folder, context: posix), throwsA(isA<SnapshotFileRejected>()));
    });
  });

  group('resolveSnapshotFile on Windows', () {
    final windows = p.Context(style: p.Style.windows);
    const folder = r'C:\Users\someone\AppData\Local\RBX\Databases';

    test('dot segments in the URL itself collapse to a plain name in the folder', () {
      for (final url in [
        '$_base/../rsrvblkdata.db',
        r'https://snapshots.verifiedx.io/x/..\..\rsrvblkdata.db',
      ]) {
        final target = resolveSnapshotFile(url, folder, context: windows);
        expect(target.filePath, r'C:\Users\someone\AppData\Local\RBX\Databases\rsrvblkdata.db', reason: url);
      }
    });

    test('resolves a chain database into the folder', () {
      final target = resolveSnapshotFile('$_base/rsrvblkdata.db', folder, context: windows);
      expect(target.filePath, r'C:\Users\someone\AppData\Local\RBX\Databases\rsrvblkdata.db');
    });

    test('refuses backslashes, drive letters and absolute paths', () {
      for (final url in [
        '$_base/..%5C..%5Cescape.db',
        '$_base/C:%5CWindows%5Cescape.db',
        '$_base/C:escape.db',
        '$_base/%5C%5Cserver%5Cshare%5Cescape.db',
      ]) {
        expect(() => resolveSnapshotFile(url, folder, context: windows), throwsA(isA<SnapshotFileRejected>()), reason: url);
      }
    });
  });

  group('resolveSnapshotFiles', () {
    test('accepts the published manifest layout', () {
      final targets = resolveSnapshotFiles(
        ['$_base/rsrvblkdata.db', '$_base/rsrvblkdata-log.db', '$_base/rsrvvbtcwithdrawalrequests.db'],
        '/data/Databases',
        context: p.Context(style: p.Style.posix),
      );
      expect(targets.map((t) => t.fileName), ['rsrvblkdata.db', 'rsrvblkdata-log.db', 'rsrvvbtcwithdrawalrequests.db']);
    });

    test('rejects the whole list when one entry is unsafe or duplicated', () {
      final posix = p.Context(style: p.Style.posix);
      expect(
        () => resolveSnapshotFiles(['$_base/rsrvblkdata.db', '$_base/rsrvwaldata.db'], '/data/Databases', context: posix),
        throwsA(isA<SnapshotFileRejected>()),
      );
      expect(
        () => resolveSnapshotFiles(['$_base/rsrvblkdata.db', 'https://other.example/RSRVBLKDATA.db'], '/data/Databases', context: posix),
        throwsA(isA<SnapshotFileRejected>()),
      );
    });
  });

  group('prepareDatabasesFolderForSnapshot', () {
    late Directory root;
    late String databases;
    late String backups;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('snapshot_files_test');
      databases = p.join(root.path, 'Databases');
      backups = p.join(root.path, 'SnapshotBackups');
    });

    tearDown(() async {
      await root.delete(recursive: true);
    });

    Future<void> writeFile(String name, String contents) async {
      await File(p.join(databases, name)).create(recursive: true);
      await File(p.join(databases, name)).writeAsString(contents);
    }

    test('keeps key databases, backs them up and clears chain data', () async {
      await writeFile('rsrvwaldata.db', 'accounts');
      await writeFile('rsrvwaldata-log.db', 'accounts-log');
      await writeFile('rsrvbitcoin.db', 'btc');
      await writeFile('rsrvvbtc.db', 'shares');
      await writeFile('rsrvblkdata.db', 'blocks');
      await writeFile('rsrvmempooldata.db', 'mempool');
      await Directory(p.join(databases, 'stale')).create();

      final backup = await prepareDatabasesFolderForSnapshot(
        databasesFolder: databases,
        backupRoot: backups,
        now: DateTime(2026, 10, 8, 9, 5, 7),
      );

      expect(backup, p.join(backups, 'snapshot-import-20261008-090507'));

      final remaining = Directory(databases).listSync().map((e) => p.basename(e.path)).toSet();
      expect(remaining, {'rsrvwaldata.db', 'rsrvwaldata-log.db', 'rsrvbitcoin.db', 'rsrvvbtc.db'});
      expect(await File(p.join(databases, 'rsrvwaldata.db')).readAsString(), 'accounts');

      final backedUp = Directory(backup!).listSync().map((e) => p.basename(e.path)).toSet();
      expect(backedUp, {'rsrvwaldata.db', 'rsrvwaldata-log.db', 'rsrvbitcoin.db', 'rsrvvbtc.db'});
      expect(await File(p.join(backup, 'rsrvbitcoin.db')).readAsString(), 'btc');
    });

    test('uses a fresh backup folder on a repeat import', () async {
      await writeFile('rsrvkeystore.db', 'keys');
      final now = DateTime(2026, 10, 8, 9, 5, 7);

      final first = await prepareDatabasesFolderForSnapshot(databasesFolder: databases, backupRoot: backups, now: now);
      final second = await prepareDatabasesFolderForSnapshot(databasesFolder: databases, backupRoot: backups, now: now);

      expect(second, isNot(first));
      expect(await File(p.join(first!, 'rsrvkeystore.db')).readAsString(), 'keys');
      expect(await File(p.join(second!, 'rsrvkeystore.db')).readAsString(), 'keys');
    });

    test('creates a missing folder and reports no backup', () async {
      final backup = await prepareDatabasesFolderForSnapshot(databasesFolder: databases, backupRoot: backups);

      expect(backup, isNull);
      expect(Directory(databases).existsSync(), isTrue);
      expect(Directory(backups).existsSync(), isFalse);
    });

    test('leaves nothing deleted when the backup cannot be written', () async {
      await writeFile('rsrvwaldata.db', 'accounts');
      await writeFile('rsrvblkdata.db', 'blocks');
      // A file where the backup folder should go makes the backup fail.
      await File(backups).writeAsString('in the way');

      await expectLater(
        prepareDatabasesFolderForSnapshot(databasesFolder: databases, backupRoot: backups),
        throwsA(isA<FileSystemException>()),
      );

      final remaining = Directory(databases).listSync().map((e) => p.basename(e.path)).toSet();
      expect(remaining, {'rsrvwaldata.db', 'rsrvblkdata.db'});
    });
  });
}
