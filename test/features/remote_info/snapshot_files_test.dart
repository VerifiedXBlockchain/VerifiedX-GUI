import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:rbx_wallet/features/remote_info/utils/snapshot_files.dart';

const _base = 'https://snapshots.verifiedx.io/mainnet_20261008_070016';

void main() {
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
        () => resolveSnapshotFiles(['$_base/rsrvblkdata.db', '$_base/..%5Cescape.db'], '/data/Databases', context: posix),
        throwsA(isA<SnapshotFileRejected>()),
      );
      expect(
        () => resolveSnapshotFiles(['$_base/rsrvblkdata.db', 'https://other.example/RSRVBLKDATA.db'], '/data/Databases', context: posix),
        throwsA(isA<SnapshotFileRejected>()),
      );
    });
  });
}
