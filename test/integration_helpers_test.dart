import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../integration_test/helpers.dart';

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
}
