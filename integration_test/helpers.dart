import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps frames in short steps until [finder] matches at least one widget or
/// [timeout] elapses. Use this instead of [WidgetTester.pumpAndSettle] while
/// the app boots: the boot screen runs a looping animation, so frames never
/// settle.
///
/// Throws a [TimeoutException] listing the text on screen when the widget
/// never appears.
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
  Duration step = const Duration(milliseconds: 100),
}) {
  return _pumpUntil(
    tester,
    () => finder.evaluate().isNotEmpty,
    timeout: timeout,
    step: step,
    description: 'Timed out after $timeout waiting for $finder to appear',
  );
}

/// Pumps frames in short steps until [finder] matches nothing or [timeout]
/// elapses. Throws a [TimeoutException] listing the text on screen when the
/// widget never goes away.
Future<void> pumpUntilGone(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
  Duration step = const Duration(milliseconds: 100),
}) {
  return _pumpUntil(
    tester,
    () => finder.evaluate().isEmpty,
    timeout: timeout,
    step: step,
    description: 'Timed out after $timeout waiting for $finder to go away',
  );
}

/// Sends a GET to [url] and returns a short description of whatever answered,
/// or null when nothing listens there (connection refused, or no answer
/// within [timeout]). The status code does not matter: a CLI holding another
/// API token answers 401 and is still a running CLI.
Future<String?> probeHttp(
  Uri url, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final client = HttpClient()..connectionTimeout = timeout;
  try {
    final request = await client.getUrl(url).timeout(timeout);
    final response = await request.close().timeout(timeout);
    await response.drain<void>();
    return 'HTTP ${response.statusCode}';
  } on SocketException {
    return null;
  } on TimeoutException {
    return null;
  } on HttpException catch (e) {
    return 'unexpected answer: $e';
  } finally {
    client.close(force: true);
  }
}

/// The text of every [Text] widget currently in the tree, for failure
/// messages: on the boot screen this includes the CLI launch log.
List<String> visibleText(WidgetTester tester) {
  return tester
      .widgetList<Text>(find.byType(Text))
      .map((text) => text.data ?? text.textSpan?.toPlainText() ?? '')
      .where((data) => data.trim().isNotEmpty)
      .toList();
}

/// Elapsed time is the sum of the pumped steps rather than wall-clock time,
/// so the deadline also holds under the fake clock of a plain widget test.
Future<void> _pumpUntil(
  WidgetTester tester,
  bool Function() condition, {
  required Duration timeout,
  required Duration step,
  required String description,
}) async {
  var elapsed = Duration.zero;
  do {
    await tester.pump(step);
    elapsed += step;
    if (condition()) {
      return;
    }
  } while (elapsed < timeout);
  throw TimeoutException(
    '$description.\nText on screen: ${visibleText(tester)}',
    timeout,
  );
}
