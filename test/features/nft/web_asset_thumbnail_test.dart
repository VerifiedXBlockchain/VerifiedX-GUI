import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/asset/web_asset.dart';
import 'package:rbx_wallet/features/nft/components/web_asset_thumbnail.dart';

void main() {
  testWidgets('thumbnail is a button whose accessible name is the file name', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: WebAssetThumbnail(WebAsset(location: 'https://example.com/media/readme.txt')),
      ),
    ));
    await tester.pumpAndSettle();

    final wrapper = find
        .descendant(
          of: find.byType(WebAssetThumbnail),
          matching: find.byType(Semantics),
        )
        .first;
    final data = tester.getSemantics(wrapper).getSemanticsData();
    expect(data.label, 'readme.txt');
    expect(data.hasFlag(SemanticsFlag.isButton), isTrue);
    expect(data.hasAction(SemanticsAction.tap), isTrue);
  });
}
