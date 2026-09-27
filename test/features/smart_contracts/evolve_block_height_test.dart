import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/app.dart';
import 'package:rbx_wallet/features/smart_contracts/features/evolve/evolve_block_height.dart';

void main() {
  // globalL10n falls back to English with a detached root navigator key.
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    rootNavigatorKey = GlobalKey<NavigatorState>();
  });

  group('evolveBlockHeightError', () {
    test('accepts a height above the current block height', () {
      expect(evolveBlockHeightError(1016164, 1015164), isNull);
      expect(evolveBlockHeightError(1015165, 1015164), isNull);
    });

    test('rejects the current height and anything below it', () {
      expect(evolveBlockHeightError(1015164, 1015164), 'Block height must be greater than 1015164.');
      expect(evolveBlockHeightError(10, 1015164), 'Block height must be greater than 1015164.');
    });

    test('explains an unknown current height instead of a bare "Error"', () {
      final error = evolveBlockHeightError(1016164, null);

      expect(error, 'The current block height is not known yet. Try again in a moment.');
    });
  });
}
