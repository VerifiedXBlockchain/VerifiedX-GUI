import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/theme/pretty_icons.dart';
import 'package:rbx_wallet/features/navigation/components/root_container_side_nav_item.dart';

Future<void> pumpItem(WidgetTester tester, {required bool isExpanded}) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 240,
        child: RootContainerSideNavItem(
          title: 'Dashboard',
          onPressed: () {},
          isActive: false,
          isExpanded: isExpanded,
          iconType: PrettyIconType.dashboard,
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

SemanticsData itemSemantics(WidgetTester tester) {
  final wrapper = find
      .descendant(
        of: find.byType(RootContainerSideNavItem),
        matching: find.byType(Semantics),
      )
      .first;
  return tester.getSemantics(wrapper).getSemanticsData();
}

void main() {
  testWidgets('collapsed item is a button named through its icon tooltip', (tester) async {
    await pumpItem(tester, isExpanded: false);

    final data = itemSemantics(tester);
    expect(data.tooltip, 'Dashboard');
    expect(data.hasFlag(SemanticsFlag.isButton), isTrue);
    expect(data.hasAction(SemanticsAction.tap), isTrue);
  });

  testWidgets('expanded item is a button named by its visible title', (tester) async {
    await pumpItem(tester, isExpanded: true);

    final data = itemSemantics(tester);
    expect(data.label, 'Dashboard');
    expect(data.hasFlag(SemanticsFlag.isButton), isTrue);
    expect(data.hasAction(SemanticsAction.tap), isTrue);
  });
}
