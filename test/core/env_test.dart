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

  group('Env P2P shop flags', () {
    tearDown(Env.resetNetworkForTesting);

    // Tests run without the TESTNET dart-define: this is a mainnet build.
    test('the P2P shop is off on mainnet', () {
      expect(Env.isTestNet, isFalse);
      expect(Env.p2pEnabled, isFalse);
    });

    test('the P2P shop is on on testnet', () {
      Env.setTestnetFromArgs(['--testnet']);
      expect(Env.p2pEnabled, isTrue);
    });

    test('the P2P shop is off on devnet, which has no registry', () {
      Env.setTestnetFromArgs(['--devnet']);
      expect(Env.isTestNet, isTrue);
      expect(Env.p2pEnabled, isFalse);
    });

    test('shop transactions are never broadcast, on any network', () {
      expect(Env.p2pBroadcast, isFalse);
      Env.setTestnetFromArgs(['--testnet']);
      expect(Env.p2pBroadcast, isFalse);
      Env.setTestnetFromArgs(['--devnet']);
      expect(Env.p2pBroadcast, isFalse);
    });

    test('no command-line argument turns broadcasting on', () {
      Env.setTestnetFromArgs(['--testnet', '--p2p-broadcast', '--p2pBroadcast=true', '--broadcast']);
      expect(Env.p2pBroadcast, isFalse);
    });
  });
}
