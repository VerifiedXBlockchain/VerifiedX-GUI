import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/theme/pretty_icons.dart';

Future<void> pumpHost(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
  await tester.pumpAndSettle();
}

Finder wrapperOf(Type type) => find
    .descendant(
      of: find.byType(type),
      matching: find.byType(Semantics),
    )
    .first;

void main() {
  testWidgets('exposes its label and the button role, and taps through', (tester) async {
    var taps = 0;
    await pumpHost(
      tester,
      PrettyIconButton(
        type: PrettyIconType.custom,
        customIcon: Icons.paste,
        label: 'Paste',
        onPressed: () => taps++,
      ),
    );

    final data = tester.getSemantics(wrapperOf(PrettyIconButton)).getSemanticsData();
    expect(data.label, 'Paste');
    expect(data.hasFlag(SemanticsFlag.isButton), isTrue);
    expect(data.hasAction(SemanticsAction.tap), isTrue);

    await tester.tap(find.byType(PrettyIconButton));
    expect(taps, 1);
  });

  testWidgets('is still a button without a label', (tester) async {
    await pumpHost(
      tester,
      PrettyIconButton(
        type: PrettyIconType.custom,
        customIcon: Icons.paste,
        onPressed: () {},
      ),
    );

    final data = tester.getSemantics(wrapperOf(PrettyIconButton)).getSemanticsData();
    expect(data.label, isEmpty);
    expect(data.hasFlag(SemanticsFlag.isButton), isTrue);
    expect(data.hasAction(SemanticsAction.tap), isTrue);
  });
}
