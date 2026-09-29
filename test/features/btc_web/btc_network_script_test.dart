import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/btc_web/utils/btc_network_script.dart';
import 'package:rbx_wallet/utils/html_helpers.dart';

void main() {
  group('btcNetworkScriptSrc', () {
    test('a testnet build loads the testnet bridge', () {
      expect(
        btcNetworkScriptSrc(isTestnet: true),
        'assets/assets/js/btc-testnet.js?v=$kBtcNetworkScriptVersion',
      );
    });

    test('a mainnet build loads the mainnet bridge', () {
      expect(
        btcNetworkScriptSrc(isTestnet: false),
        'assets/assets/js/btc-mainnet.js?v=$kBtcNetworkScriptVersion',
      );
    });

    test('both chosen scripts ship as bundled assets', () {
      // Flutter serves assets/js/x.js at assets/assets/js/x.js.
      for (final isTestnet in [true, false]) {
        final src = btcNetworkScriptSrc(isTestnet: isTestnet);
        final bundled = src.replaceFirst('assets/', '').split('?').first;
        expect(File(bundled).existsSync(), isTrue, reason: bundled);
      }
    });
  });

  test('index.html no longer hard-codes a network bridge', () {
    // A static tag here would load one network's bridge in every build.
    final index = File('web/index.html').readAsStringSync();
    expect(index, isNot(contains('<script src="assets/assets/js/btc-testnet.js')));
    expect(index, isNot(contains('<script src="assets/assets/js/btc-mainnet.js')));
  });

  test('loading a script off web reports failure instead of pretending', () async {
    expect(await HtmlHelpers().loadScript('assets/assets/js/btc-testnet.js'), isFalse);
  });
}
