import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/navigation/components/root_container_expander.dart';
import 'package:rbx_wallet/l10n/generated/app_localizations.dart';

/// Mirrors the side nav: the expander sits in a scrolling column next to
/// the nav list.
Future<void> pumpExpander(WidgetTester tester, {required bool isExpanded, VoidCallback? onToggle}) async {
  await tester.pumpWidget(MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(container: true, button: true, child: const Text('Dashboard')),
            Align(
              alignment: Alignment.centerLeft,
              child: RootContainerExpander(
                key: const ValueKey('nav:expander'),
                onToggleExpanded: onToggle ?? () {},
                isExpanded: isExpanded,
              ),
            ),
          ],
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('expanded expander is a button named Collapse navigation', (tester) async {
    final handle = tester.ensureSemantics();
    var toggles = 0;
    await pumpExpander(tester, isExpanded: true, onToggle: () => toggles++);

    final node = tester.getSemantics(find.bySemanticsLabel('Collapse navigation'));
    final data = node.getSemanticsData();
    expect(data.label, 'Collapse navigation');
    expect(data.hasFlag(SemanticsFlag.isButton), isTrue);
    expect(data.hasAction(SemanticsAction.tap), isTrue);

    tester.binding.pipelineOwner.semanticsOwner!.performAction(node.id, SemanticsAction.tap);
    expect(toggles, 1);
    handle.dispose();
  });

  testWidgets('collapsed expander is named Expand navigation', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpExpander(tester, isExpanded: false);

    expect(find.bySemanticsLabel('Expand navigation'), findsOneWidget);
    handle.dispose();
  });
}
