import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/btc_web/services/vbtc_media_detection.dart';
import 'package:rbx_wallet/features/nft/models/web_nft.dart';

WebNft _nft({required String assetName, required int assetSize}) {
  return WebNft.empty().copyWith(
    primaryAssetName: assetName,
    primaryAssetSize: assetSize,
  );
}

void main() {
  group('vbtcContractHasNoMedia', () {
    test('the default vBTC asset has no media', () {
      // What the mint actually stamps: asset name vbtc_v2_token, FileSize 0.
      expect(
        vbtcContractHasNoMedia(_nft(assetName: 'vbtc_v2_token', assetSize: 0)),
        isTrue,
      );
    });

    test('both placeholder image spellings are recognised', () {
      // The node emits defaultvBTC.png and defaultvBTC_V2.png; matching on the
      // prefix covers both, which an equality check would not.
      for (final name in ['defaultvBTC.png', 'defaultvBTC_V2.png']) {
        expect(
          vbtcContractHasNoMedia(_nft(assetName: name, assetSize: 0)),
          isTrue,
          reason: name,
        );
      }
    });

    test('matching is case-insensitive', () {
      expect(
        vbtcContractHasNoMedia(_nft(assetName: 'DEFAULTVBTC.PNG', assetSize: 0)),
        isTrue,
      );
    });

    test('a real asset has media', () {
      expect(
        vbtcContractHasNoMedia(_nft(assetName: 'artwork.png', assetSize: 51200)),
        isFalse,
      );
    });

    test('a non-zero size means media even under a placeholder name', () {
      // Size wins. A file that exists must be shipped whatever it is called.
      expect(
        vbtcContractHasNoMedia(_nft(assetName: 'vbtc_v2_token', assetSize: 2048)),
        isFalse,
      );
    });

    test('an unrecognised name is treated as media even at size zero', () {
      // Deciding "no media" wrongly strands the recipient's file, so anything
      // unfamiliar keeps requiring a beacon.
      expect(
        vbtcContractHasNoMedia(_nft(assetName: 'mystery.bin', assetSize: 0)),
        isFalse,
      );
    });

    test('an empty or missing name is treated as media', () {
      expect(vbtcContractHasNoMedia(_nft(assetName: '', assetSize: 0)), isFalse);
      expect(vbtcContractHasNoMedia(_nft(assetName: '   ', assetSize: 0)), isFalse);
    });

    test('a null nft is treated as media', () {
      expect(vbtcContractHasNoMedia(null), isFalse);
    });
  });
}
