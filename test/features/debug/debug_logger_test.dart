import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/debug/debug_logger.dart';

void main() {
  late Directory temp;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    temp = Directory.systemTemp.createTempSync('debug_logger_test');
  });

  tearDown(() {
    temp.deleteSync(recursive: true);
  });

  test('appendEntry creates a missing folder and file', () async {
    final file = File('${temp.path}/DatabasesTestNet/${DebugLogger.fileName}');

    await DebugLogger.appendEntry(file, 'first error', StackTrace.fromString('frame one'));

    final contents = file.readAsStringSync();
    expect(contents, contains('first error'));
    expect(contents, contains('frame one'));
  });

  test('appendEntry keeps earlier entries', () async {
    final file = File('${temp.path}/${DebugLogger.fileName}');

    await DebugLogger.appendEntry(file, 'first error', StackTrace.empty);
    await DebugLogger.appendEntry(file, 'second error', StackTrace.empty);

    final contents = file.readAsStringSync();
    expect(contents.indexOf('first error'), lessThan(contents.indexOf('second error')));
  });

  test('log never throws when the data folder cannot be resolved', () async {
    // No path_provider implementation is registered in tests, so resolving
    // the documents directory fails; log must swallow that.
    await expectLater(DebugLogger.log('boom', StackTrace.empty), completes);
  });
}
