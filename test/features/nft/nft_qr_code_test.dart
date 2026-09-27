import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rbx_wallet/features/nft/components/nft_qr_code.dart';
import 'package:rbx_wallet/l10n/generated/app_localizations.dart';

Future<void> pumpDialogQr(WidgetTester tester, {bool withOpen = false}) async {
  tester.binding.window.physicalSizeTestValue = const Size(1400, 1000);
  tester.binding.window.devicePixelRatioTestValue = 1.0;
  addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
  addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);

  // Same shape as the receive screen's request dialog: a centred QR with
  // loose constraints as wide as the window.
  await tester.pumpWidget(MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Material(
      child: Center(
        child: NftQrCode(
          data: 'https://example.com/pay?amount=5',
          withClose: true,
          withOpen: withOpen,
          center: true,
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Save sits under the QR code, centred, in the request dialog', (tester) async {
    await pumpDialogQr(tester);

    final qrRect = tester.getRect(find.byType(QrImage));
    final saveCenter = tester.getCenter(find.byIcon(Icons.download));

    expect(saveCenter.dx, closeTo(qrRect.center.dx, 1));
    expect(saveCenter.dy, greaterThan(qrRect.bottom));
  });

  testWidgets('Save and Open span the QR width, not the window', (tester) async {
    await pumpDialogQr(tester, withOpen: true);

    final qrRect = tester.getRect(find.byType(QrImage));
    final saveRect = tester.getRect(find.byIcon(Icons.download));
    final openRect = tester.getRect(find.byIcon(Icons.open_in_new));

    expect(saveRect.left, greaterThanOrEqualTo(qrRect.left));
    expect(openRect.right, lessThanOrEqualTo(qrRect.right));
  });
}
