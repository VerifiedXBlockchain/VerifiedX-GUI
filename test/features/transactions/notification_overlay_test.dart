import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/transactions/components/notification_overlay.dart';
import 'package:rbx_wallet/features/transactions/models/transaction_notification.dart';
import 'package:rbx_wallet/features/transactions/providers/transaction_notification_provider.dart';
import 'package:rbx_wallet/l10n/generated/app_localizations.dart';

void main() {
  Future<ProviderContainer> pump(WidgetTester tester, TransactionNotification notification) async {
    tester.binding.window.physicalSizeTestValue = const Size(1200, 800);
    tester.binding.window.devicePixelRatioTestValue = 1;
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: NotificationOverlay()),
      ),
    ));
    // Stays up for an hour, so the test ends it itself.
    container.read(transactionNotificationProvider.notifier).add(notification, 3600);
    await tester.pump();
    return container;
  }

  testWidgets('a long title and body wrap inside the card instead of running out of it', (tester) async {
    const body = '“E2E Bulk Mint A 08:32, the long edition with a very long name” has a winner in vfx://dryrun-demo. Start the sale within 48 hours.';
    final container = await pump(
      tester,
      TransactionNotification(
        identifier: 'long',
        title: 'A sale is waiting for you, and its title is long enough to need a second line as well',
        body: body,
        icon: Icons.storefront,
      ),
    );

    // An overflow would have failed the test by now; the text is all there,
    // on more than one line, inside the overlay's 400 pixels.
    expect(tester.takeException(), isNull);
    final text = find.text(body);
    expect(text, findsOneWidget);
    expect(tester.getSize(text).height, greaterThan(20));
    expect(tester.getRect(text).right, lessThanOrEqualTo(1200));
    expect(tester.getRect(text).left, greaterThanOrEqualTo(800));

    container.read(transactionNotificationProvider.notifier).remove('long');
    await tester.pump(const Duration(hours: 2));
  });

  testWidgets('a short one still shows its title, body and close button', (tester) async {
    final container = await pump(
      tester,
      TransactionNotification(identifier: 'short', title: 'Bridge complete', body: 'Minted 0.5 vBTC', icon: Icons.check_circle),
    );
    expect(find.text('Bridge complete'), findsOneWidget);
    expect(find.text('Minted 0.5 vBTC'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    expect(find.text('Bridge complete'), findsNothing);
    expect(container.read(transactionNotificationProvider), isEmpty);
    await tester.pump(const Duration(hours: 2));
  });
}
