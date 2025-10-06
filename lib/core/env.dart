// ignore_for_file: constant_identifier_names, library_prefixes

import 'package:flutter/foundation.dart';

class Env {
  // Dynamic testnet flag - set from CLI args on desktop or dart-define
  static bool _isTestnet = const String.fromEnvironment('TESTNET') == 'true';

  static void setTestnetFromArgs(List<String> args) {
    // CLI args override dart-define
    if (args.contains('--testnet')) {
      _isTestnet = true;
    }
  }

  static String get baseExplorerUrl {
    return _isTestnet
        ? 'https://spyglass-testnet.verifiedx.io/'
        : 'https://spyglass.verifiedx.io/';
  }

  static String get appBaseUrl {
    if (kIsWeb) {
      return _isTestnet
          ? 'https://wallet-testnet.verifiedx.io/'
          : 'https://wallet.verifiedx.io/';
    } else {
      // Desktop always uses localhost
      return 'http://localhost:42069/';
    }
  }

  static String get envName {
    if (kIsWeb) {
      return _isTestnet ? 'web_testnet' : 'web';
    } else {
      return _isTestnet ? 'release_testnet' : 'release';
    }
  }

  static String get storagePrefix {
    if (kIsWeb) {
      return _isTestnet ? 'web_dev' : 'web';
    } else {
      return _isTestnet ? 'release_testnet' : 'release';
    }
  }

  static String get apiBaseUrl {
    if (kIsWeb) {
      // Web uses external API
      return 'https://rbx-transaction-service.herokuapp.com/api/v1';
    } else {
      // Desktop uses local CLI
      return _isTestnet
          ? 'http://localhost:17292/api/V1'
          : 'https://localhost:7293/api/V1';
    }
  }

  static String get explorerApiBaseUrl {
    return _isTestnet
        ? 'https://data-testnet.verifiedx.io/api'
        : 'https://data.verifiedx.io/api';
  }

  static String get explorerWebsiteBaseUrl {
    return _isTestnet
        ? 'https://spyglass-testnet.verifiedx.io'
        : 'https://spyglass.verifiedx.io';
  }

  static bool get launchCli {
    // Only launch CLI on desktop (non-web)
    return !kIsWeb;
  }

  static String? get cliPathOverride {
    // Not set by default - can be added later if needed
    return null;
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
    return _isTestnet ? '13338' : '3338';
  }

  static String get validatorSecondaryPort {
    return _isTestnet ? '13339' : '3339';
  }

  static String get validatorTertiaryPort {
    return _isTestnet ? '17294' : '7294';
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
