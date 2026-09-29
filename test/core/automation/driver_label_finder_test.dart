import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/automation/driver_label_finder.dart';

/// The extension never nests finders, so the factories are unused.
class _Factories with CreateFinderFactory, DeserializeFinderFactory {}

void main() {
  final factories = _Factories();
  final extension = ByLabelFinderExtension();

  group('widgetHasLabel', () {
    test('matches a Semantics label', () {
      final widget = Semantics(label: 'Copy address', child: const SizedBox());
      expect(widgetHasLabel(widget, 'Copy address'), isTrue);
      expect(widgetHasLabel(widget, 'Copy'), isFalse);
    });

    test('matches a Tooltip message', () {
      final widget =
          Tooltip(message: 'Reload wallet info', child: const SizedBox());
      expect(widgetHasLabel(widget, 'Reload wallet info'), isTrue);
      expect(widgetHasLabel(widget, 'Reload'), isFalse);
    });

    test('ignores other widgets and a Semantics tooltip', () {
      expect(widgetHasLabel(const Text('Reload'), 'Reload'), isFalse);
      expect(
        widgetHasLabel(
            Semantics(tooltip: 'Reload', child: const SizedBox()), 'Reload'),
        isFalse,
      );
    });
  });

  group('ByLabel wire format', () {
    test('serializes to the map drive.dart sends', () {
      expect(const ByLabel('Copy address').serialize(), {
        'finderType': 'ByLabel',
        'label': 'Copy address',
      });
    });

    test('round-trips through the extension', () {
      final finder = extension.deserialize(
        const ByLabel('Copy address').serialize(),
        factories,
      );
      expect(finder, isA<ByLabel>());
      expect((finder as ByLabel).label, 'Copy address');
    });

    test('rejects a finder without a label', () {
      expect(
        () => extension.deserialize({'finderType': 'ByLabel'}, factories),
        throwsArgumentError,
      );
    });
  });

  testWidgets('createFinder finds labelled controls and taps through them',
      (tester) async {
    var reloads = 0;
    var copies = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            IconButton(
              tooltip: 'Reload wallet info',
              icon: const Icon(Icons.refresh),
              onPressed: () => reloads++,
            ),
            Semantics(
              label: 'Copy address',
              button: true,
              child: InkWell(
                onTap: () => copies++,
                child: const Icon(Icons.copy),
              ),
            ),
            const Icon(Icons.warning, semanticLabel: 'Warning'),
            const Text('Reload wallet info'),
          ],
        ),
      ),
    ));

    Finder byLabel(String label) =>
        extension.createFinder(ByLabel(label), factories);

    expect(byLabel('Reload wallet info'), findsOneWidget);
    expect(tester.widget(byLabel('Reload wallet info')), isA<Tooltip>());
    expect(byLabel('Copy address'), findsOneWidget);
    expect(tester.widget(byLabel('Copy address')), isA<Semantics>());
    expect(byLabel('Warning'), findsOneWidget);
    expect(byLabel('Nothing here'), findsNothing);

    await tester.tap(byLabel('Reload wallet info'));
    await tester.tap(byLabel('Copy address'));
    expect(reloads, 1);
    expect(copies, 1);
  });
}
