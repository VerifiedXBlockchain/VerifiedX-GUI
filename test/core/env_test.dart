import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/env.dart';

void main() {
  group('Env.isAutomation', () {
    test('is false unless the AUTOMATION dart-define is set', () {
      expect(Env.isAutomation, isFalse);
    });
  });

  group('Env.explorerTransactionUrl', () {
    test('joins the explorer base and hash with a single slash', () {
      final url = Env.explorerTransactionUrl('abc123');
      expect(url, '${Env.explorerWebsiteBaseUrl}/transaction/abc123');
      expect(url.replaceFirst('https://', ''), isNot(contains('//')));
    });
  });

  group('Env BTC explorer', () {
    // setTestnetFromArgs changes process-wide state: put it back after each
    // case so the result never depends on test order.
    tearDown(Env.resetNetworkForTesting);

    // Tests run without the TESTNET dart-define, so these are the mainnet
    // URLs, which must stay exactly as they were before the signet move.
    test('mainnet keeps mempool.space', () {
      expect(Env.btcIsTestNet, isFalse);
      expect(Env.btcExplorerBaseUrl, 'https://mempool.space/');
      expect(Env.btcExplorerApiBaseUrl, 'https://mempool.space/api');
      expect(Env.btcExplorerTxUrl('abc123'), 'https://mempool.space/tx/abc123');
    });

    test('testnet uses the VerifiedX signet explorer', () {
      Env.setTestnetFromArgs(['--testnet']);
      expect(Env.btcExplorerBaseUrl, 'https://signet.verifiedx.io/');
      expect(Env.btcExplorerApiBaseUrl, 'https://signet.verifiedx.io/api');
      expect(Env.btcExplorerTxUrl('abc123'), 'https://signet.verifiedx.io/tx/abc123');
    });
  });
}
