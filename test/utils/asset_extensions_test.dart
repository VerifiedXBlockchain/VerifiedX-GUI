import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/app_constants.dart';
import 'package:rbx_wallet/utils/asset_extensions.dart';

void main() {
  group('isBlockedAssetExtension', () {
    test('refuses every default rejected extension', () {
      for (final ext in DEFAULT_REJECTED_EXTENIONS) {
        expect(isBlockedAssetExtension(ext), isTrue, reason: ext);
      }
    });

    test('refuses known malware extensions whatever the configured list is', () {
      expect(isBlockedAssetExtension('vbx', rejectedExtensions: const []), isTrue);
      expect(isBlockedAssetExtension('exe_', rejectedExtensions: const []), isTrue);
    });

    test('ignores case and surrounding whitespace', () {
      expect(isBlockedAssetExtension('EXE'), isTrue);
      expect(isBlockedAssetExtension(' Zip '), isTrue);
      expect(isBlockedAssetExtension('VBX'), isTrue);
    });

    test('allows common media extensions', () {
      for (final ext in ['png', 'jpg', 'jpeg', 'gif', 'mp4', 'pdf', 'webp']) {
        expect(isBlockedAssetExtension(ext), isFalse, reason: ext);
      }
    });

    test('allows a missing or empty extension', () {
      expect(isBlockedAssetExtension(null), isFalse);
      expect(isBlockedAssetExtension(''), isFalse);
    });

    test('uses the configured list in place of the defaults', () {
      expect(isBlockedAssetExtension('zip', rejectedExtensions: const ['png']), isFalse);
      expect(isBlockedAssetExtension('png', rejectedExtensions: const ['PNG']), isTrue);
    });
  });
}
