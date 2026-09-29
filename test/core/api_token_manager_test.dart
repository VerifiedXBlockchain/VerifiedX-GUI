import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/api_token_manager.dart';
import 'package:rbx_wallet/core/app_constants.dart';

void main() {
  group('cliApiToken', () {
    String random() => 'r4nd0m12';

    test('uses the fixed testnet token on every non-mainnet build', () {
      expect(cliApiToken(isMainnet: false, isDebug: false, randomToken: random), 'testnet');
      expect(cliApiToken(isMainnet: false, isDebug: true, randomToken: random), 'testnet');
    });

    test('uses the development token on a mainnet debug build', () {
      expect(cliApiToken(isMainnet: true, isDebug: true, randomToken: random), DEV_API_TOKEN);
    });

    test('uses a random token on a mainnet release build', () {
      expect(cliApiToken(isMainnet: true, isDebug: false, randomToken: random), 'r4nd0m12');
    });
  });

  test('the token manager returns the token it was given', () {
    final manager = ApiTokenManagerImplementation()..set('testnet');
    expect(manager.get(), 'testnet');
  });
}
