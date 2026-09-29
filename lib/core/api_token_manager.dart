import 'app_constants.dart';

/// Token every non-mainnet GUI launches its CLI with. A fixed value lets a GUI
/// that reattaches to a CLI a previous session launched still authenticate.
const NON_MAINNET_API_TOKEN = "testnet";

/// Chooses the apitoken the GUI launches its CLI with and sends on every call
/// to it. The node refuses private-key export on an unencrypted wallet unless
/// an API token is configured, so every network launches with one: testnet and
/// devnet use [NON_MAINNET_API_TOKEN], a mainnet debug build uses
/// [DEV_API_TOKEN], and a mainnet release build uses a fresh random token.
String cliApiToken({
  required bool isMainnet,
  required bool isDebug,
  required String Function() randomToken,
}) {
  if (!isMainnet) {
    return NON_MAINNET_API_TOKEN;
  }
  if (isDebug) {
    return DEV_API_TOKEN;
  }
  return randomToken();
}

abstract class ApiTokenManager {
  String token = "";

  void set(String value);
  String get();
}

class ApiTokenManagerImplementation extends ApiTokenManager {
  @override
  void set(String value) {
    token = value;
  }

  @override
  String get() {
    return token;
  }
}
