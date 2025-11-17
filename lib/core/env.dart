// ignore_for_file: constant_identifier_names, library_prefixes

import 'package:flutter/foundation.dart';

class Env {
  // Dynamic testnet flag - set from CLI args on desktop or dart-define
  static bool _isTestnet = const String.fromEnvironment('TESTNET') == 'true' ||
      const String.fromEnvironment('DEVNET') == 'true';
  static bool _isDevnet = const String.fromEnvironment('DEVNET') == 'true';

  static void setTestnetFromArgs(List<String> args) {
    // CLI args override dart-define
    if (args.contains('--testnet')) {
      _isTestnet = true;
    }

    if (args.contains('--devnet')) {
      _isTestnet = true;
      _isDevnet = true;
    }
  }

  static String get baseExplorerUrl {
    if (_isDevnet) return 'https://spyglass-devnet.verifiedx.io/';
    if (_isTestnet) return 'https://spyglass-testnet.verifiedx.io/';
    return 'https://spyglass.verifiedx.io/';
  }

  static String get appBaseUrl {
    if (kIsWeb) {
      if (_isDevnet) return 'https://wallet-devnet.verifiedx.io/';
      if (_isTestnet) return 'https://wallet-testnet.verifiedx.io/';
      return 'https://wallet.verifiedx.io/';
    } else {
      // Desktop always uses localhost
      return 'http://localhost:42069/';
    }
  }

  static String get envName {
    if (kIsWeb) {
      if (_isDevnet) {
        return 'web_devnet';
      }
      return _isTestnet ? 'web_testnet' : 'web';
    } else {
      if (_isDevnet) {
        return 'devnet';
      }
      return _isTestnet ? 'release_testnet' : 'release';
    }
  }

  static String get storagePrefix {
    if (kIsWeb) {
      if (_isDevnet) return 'web_devnet';
      return _isTestnet ? 'web_dev' : 'web';
    } else {
      if (_isDevnet) return 'release_devnet';

      return _isTestnet ? 'release_testnet' : 'release';
    }
  }

  static String get apiBaseUrl {
    if (kIsWeb) {
      // Web uses external API
      return 'https://data.verifiedx.io/api/v1';
    } else {
      // Desktop uses local CLI
      if (_isDevnet) return 'http://localhost:27292/api/V1';
      if (_isTestnet) return 'http://localhost:17292/api/V1';
      return 'http://localhost:7292/api/V1';
    }
  }

  static String get explorerApiBaseUrl {
    if (_isDevnet) return 'https://data-devnet.verifiedx.io/api';
    if (_isTestnet) return 'https://data-testnet.verifiedx.io/api';
    return 'https://data.verifiedx.io/api';
  }

  static String get explorerWebsiteBaseUrl {
    if (_isDevnet) return 'https://spyglass-devnet.verifiedx.io';
    if (_isTestnet) return 'https://spyglass-testnet.verifiedx.io';
    return 'https://spyglass.verifiedx.io';
  }

  static bool get launchCli {
    // Only launch CLI on desktop (non-web)
    return !kIsWeb;
  }

  static String? get cliPathOverride {
    // Not set by default - can be added later if needed
    return null;
  }

  static bool get isDevnet {
    return _isDevnet;
  }

  static bool get isTestNet {
    return _isTestnet;
  }

  static bool get btcIsTestNet {
    return _isTestnet;
  }

  static bool get promptForUpdates {
    // Only prompt for updates on mainnet release
    return !_isTestnet && !kIsWeb;
  }

  static String get validatorPort {
    if (_isDevnet) return '23338';
    if (_isTestnet) return '13338';
    return '3338';
  }

  static String get validatorSecondaryPort {
    if (_isDevnet) return '23339';
    if (_isTestnet) return '13339';
    return '3339';
  }

  static String get validatorTertiaryPort {
    if (_isDevnet) return '27294';
    if (_isTestnet) return '17294';
    return '7294';
  }

  static String get portCheckerUrl {
    return "https://us-central1-portpingr.cloudfunctions.net/pinger";
  }

  static bool get hideCliOutput {
    return false;
  }

  static bool get isWeb {
    return kIsWeb;
  }

  static bool get useWebMedia {
    // Not set in env files - keeping as false
    return false;
  }

  static String get shopBaseUrl {
    return "https://wallet.verifiedx.io";
  }

  static String get shopApiUrl {
    return "https://data.verifiedx.io/api";
  }

  static String get paymentEmbedUrl {
    return "https://rbx-payment-integration.vercel.app/";
  }

  static String? get banxaPaymentDomain {
    return _isTestnet
        ? 'https://rbx.banxa-sandbox.com'
        : 'https://rbx.banxa.com';
  }

  static bool get moonpayEnabled {
    return kIsWeb; // Only enabled on web
  }

  static bool get moonpayEnabledVFX {
    return false;
  }

  static String get onrampApiBaseUrl {
    return "https://api.onramp.verifiedx.io";
  }
}
