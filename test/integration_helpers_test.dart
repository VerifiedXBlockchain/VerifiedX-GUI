import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../integration_test/helpers.dart';

/// flutter_test swaps every [HttpClient] for a stub that answers 400. The
/// probe tests need the real client to reach the local server they start.
class _RealHttpOverrides extends HttpOverrides {}

Future<T> withRealHttp<T>(Future<T> Function() body) {
  return HttpOverrides.runWithHttpOverrides(body, _RealHttpOverrides());
}

/// Shows "waiting" and swaps to "ready" after [delay].
class _DelayedText extends StatefulWidget {
  final Duration delay;

  const _DelayedText({required this.delay});

  @override
  State<_DelayedText> createState() => _DelayedTextState();
}

class _DelayedTextState extends State<_DelayedText> {
  bool ready = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) {
        setState(() => ready = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(ready ? 'ready' : 'waiting');
  }
}

void main() {
  testWidgets('pumpUntilFound returns once the finder matches', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: _DelayedText(delay: Duration(seconds: 1)),
    ));
    expect(find.text('ready'), findsNothing);

    await pumpUntilFound(
      tester,
      find.text('ready'),
      timeout: const Duration(seconds: 5),
    );

    expect(find.text('ready'), findsOneWidget);
  });

  testWidgets('pumpUntilFound times out listing the text on screen',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Text('still booting')));

    await expectLater(
      () => pumpUntilFound(
        tester,
        find.text('never shown'),
        timeout: const Duration(milliseconds: 500),
      ),
      throwsA(isA<TimeoutException>()
          .having((e) => e.message, 'message', contains('still booting'))),
    );
  });

  testWidgets('pumpUntilGone returns once the finder stops matching',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: _DelayedText(delay: Duration(seconds: 1)),
    ));
    expect(find.text('waiting'), findsOneWidget);

    await pumpUntilGone(
      tester,
      find.text('waiting'),
      timeout: const Duration(seconds: 5),
    );

    expect(find.text('waiting'), findsNothing);
    expect(find.text('ready'), findsOneWidget);
  });

  testWidgets('pumpUntilGone times out when the widget stays', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Text('stuck')));

    await expectLater(
      () => pumpUntilGone(
        tester,
        find.text('stuck'),
        timeout: const Duration(milliseconds: 500),
      ),
      throwsA(isA<TimeoutException>()),
    );
  });

  group('probeHttp', () {
    test('describes the answer when something listens, whatever the status',
        () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) {
        request.response.statusCode = HttpStatus.unauthorized;
        request.response.close();
      });
      try {
        final answer = await withRealHttp(() => probeHttp(
              Uri.parse('http://127.0.0.1:${server.port}/api/V1/CheckStatus/'),
            ));
        expect(answer, 'HTTP 401');
      } finally {
        await server.close(force: true);
      }
    });

    test('is null when nothing listens', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final port = server.port;
      await server.close(force: true);

      final answer =
          await withRealHttp(() => probeHttp(Uri.parse('http://127.0.0.1:$port/')));
      expect(answer, isNull);
    });
  });
}
