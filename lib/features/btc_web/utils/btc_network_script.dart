import 'package:flutter/foundation.dart';

import '../../../core/env.dart';
import '../../../utils/html_helpers.dart';

/// Cache-bust for btc-testnet.js and btc-mainnet.js. Bump it when either file
/// changes; it versions independently of APP_V.
const kBtcNetworkScriptVersion = '5.0.5';

/// The web wallet's network-specific Bitcoin bridge. Both scripts define the
/// same `window.btc*` functions on top of btc.js, differing in which network
/// btc.js's services are built for, so exactly one may load.
///
/// Chosen here rather than in index.html so it follows the build's network
/// (`--dart-define TESTNET=true`) instead of a hand-edited script tag.
String btcNetworkScriptSrc({required bool isTestnet}) {
  final name = isTestnet ? 'btc-testnet' : 'btc-mainnet';
  return 'assets/assets/js/$name.js?v=$kBtcNetworkScriptVersion';
}

/// Loads the Bitcoin bridge for this build's network. Web only; call before
/// runApp so the `window.btc*` functions exist before any BTC screen needs
/// them.
Future<void> loadBtcNetworkScript() async {
  if (!kIsWeb) {
    return;
  }
  final src = btcNetworkScriptSrc(isTestnet: Env.btcIsTestNet);
  final loaded = await HtmlHelpers().loadScript(src);
  if (!loaded) {
    print('Failed to load $src; web BTC features will not work until reload');
  }
}
