import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/asset/asset.dart';
import 'package:rbx_wallet/features/asset/asset_thumbnail.dart';
import 'package:rbx_wallet/l10n/generated/app_localizations.dart';

Future<void> pumpHost(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('thumbnail without a local file is a button named by the file name', (tester) async {
    await pumpHost(
      tester,
      AssetThumbnail(
        Asset(id: 'a1', name: 'readme.txt', fileSize: 12),
        nftId: 'nft-1',
        ownerAddress: 'RAbc123',
        isPrimaryAsset: true,
      ),
    );

    final wrapper = find
        .descendant(
          of: find.byType(AssetThumbnail),
          matching: find.byType(Semantics),
        )
        .first;
    final data = tester.getSemantics(wrapper).getSemanticsData();
    // The label is only supplied for the image branch; here the visible file
    // name is the accessible name.
    expect(data.label, 'readme.txt');
    expect(data.hasFlag(SemanticsFlag.isButton), isTrue);
    expect(data.hasAction(SemanticsAction.tap), isTrue);
  });
}
