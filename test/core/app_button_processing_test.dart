import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/components/buttons.dart';

void main() {
  group('AppButton while processing', () {
    Future<List<String>> tapButton(WidgetTester tester, {required bool processing, bool withBusyHandler = true, bool disabled = false}) async {
      final taps = <String>[];
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AppButton(
            label: 'Pending Pause',
            processing: processing,
            disabled: disabled,
            onPressed: () => taps.add('pressed'),
            onPressedWhileProcessing: withBusyHandler ? () => taps.add('busy') : null,
          ),
        ),
      ));
      await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
      await tester.pump();
      return taps;
    }

    testWidgets('a busy button with a busy handler answers the tap with it', (tester) async {
      expect(await tapButton(tester, processing: true), ['busy']);
    });

    testWidgets('a busy button without one still ignores the tap', (tester) async {
      expect(await tapButton(tester, processing: true, withBusyHandler: false), isEmpty);
    });

    testWidgets('an idle button runs onPressed, and a disabled one nothing', (tester) async {
      expect(await tapButton(tester, processing: false), ['pressed']);
      expect(await tapButton(tester, processing: true, disabled: true), isEmpty);
    });
  });
}
