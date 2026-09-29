import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/misc/components/expand_balances_on_exit.dart';
import 'package:rbx_wallet/features/misc/providers/global_balances_expanded_provider.dart';

void main() {
  testWidgets('balances re-expand when the screen is popped by another widget', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        home: const Text('dashboard'),
      ),
    ));

    container.read(globalBalancesExpandedProvider.notifier).detract();
    navigatorKey.currentState!.push(MaterialPageRoute(
      builder: (_) => const ExpandBalancesOnExit(child: Text('all tokens')),
    ));
    await tester.pumpAndSettle();
    expect(find.text('all tokens'), findsOneWidget);
    expect(container.read(globalBalancesExpandedProvider), isFalse);

    // The side nav pops the tab to its root; the screen's own Back button
    // is never pressed.
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
    await tester.pumpAndSettle();

    expect(find.text('all tokens'), findsNothing);
    expect(container.read(globalBalancesExpandedProvider), isTrue);
  });

  testWidgets('balances stay collapsed while the screen is still shown', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: ExpandBalancesOnExit(child: Text('all tokens'))),
    ));
    container.read(globalBalancesExpandedProvider.notifier).detract();
    await tester.pumpAndSettle();

    expect(container.read(globalBalancesExpandedProvider), isFalse);
  });
}
