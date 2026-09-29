import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/models/web_session_model.dart';
import 'package:rbx_wallet/features/transactions/providers/web_transactions_tab_provider.dart';
import 'package:rbx_wallet/features/transactions/screens/web_transactions_screen.dart';

Widget _tabs() {
  return MaterialApp(
    home: Scaffold(
      body: WebTransactionsTabs(
        tabs: const [Tab(text: 'All'), Tab(text: 'VFX'), Tab(text: 'Vault'), Tab(text: 'BTC')],
        views: const [Text('all-view'), Text('vfx-view'), Text('vault-view'), Text('btc-view')],
      ),
    ),
  );
}

void main() {
  test('wallet types map to their tabs', () {
    expect(webTransactionsTabFor(WalletType.rbx), WebTransactionsTab.vfx);
    expect(webTransactionsTabFor(WalletType.ra), WebTransactionsTab.vault);
    expect(webTransactionsTabFor(WalletType.btc), WebTransactionsTab.btc);
  });

  testWidgets('opens on All without a request', (tester) async {
    await tester.pumpWidget(ProviderScope(child: _tabs()));
    expect(find.text('all-view'), findsOneWidget);
  });

  testWidgets('opens on the requested tab and clears the request', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(webTransactionsTabRequestProvider.notifier).state = WebTransactionsTab.vfx;

    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: _tabs()));
    await tester.pump();

    expect(find.text('vfx-view'), findsOneWidget);
    expect(container.read(webTransactionsTabRequestProvider), isNull);
  });

  testWidgets('switches tabs when a request arrives while it is open', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: _tabs()));
    expect(find.text('all-view'), findsOneWidget);

    container.read(webTransactionsTabRequestProvider.notifier).state = WebTransactionsTab.btc;
    await tester.pumpAndSettle();

    expect(find.text('btc-view'), findsOneWidget);
    expect(container.read(webTransactionsTabRequestProvider), isNull);
  });
}
