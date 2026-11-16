import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/env.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_error.dart';
import 'package:rbx_wallet/features/p2p/providers/p2p_listed_nfts_provider.dart';
import 'package:rbx_wallet/features/p2p/providers/p2p_session_provider.dart';
import 'package:rbx_wallet/features/wallet/models/wallet.dart';
import 'package:rbx_wallet/features/wallet/providers/wallet_list_provider.dart';

import 'p2p_test_helpers.dart';

/// The wallet's accounts, fixed: nothing is asked of the node.
class StubWalletList extends WalletListProvider {
  StubWalletList(Ref ref, List<Wallet> wallets) : super(ref, wallets);
}

/// A registry that cannot answer for some owners.
class PartlyDownService extends FakeP2pService {
  final Set<String> down = {};

  @override
  Future<Set<String>> listedNftIds(String owner) {
    if (down.contains(owner)) {
      calls.add('listedNftIds($owner)');
      throw const P2pError(status: null, code: P2pError.unreachable);
    }
    return super.listedNftIds(owner);
  }
}

void main() {
  Wallet wallet(String address, {bool vault = false}) {
    return Wallet(id: 1, publicKey: 'pub', address: address, balance: 1, isValidating: false, recoveryAddress: vault ? 'xRecovery' : null);
  }

  late PartlyDownService service;

  ProviderContainer containerWith(List<Wallet> wallets) {
    final container = ProviderContainer(overrides: [
      p2pServiceProvider.overrideWithValue(service),
      walletListProvider.overrideWith((ref) => StubWalletList(ref, wallets)),
    ]);
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    service = PartlyDownService()
      ..listedByOwner = {
        'xAlice': {'nft:1', 'nft:2'},
        'xBob': {'nft:3'},
      };
  });

  tearDown(Env.resetNetworkForTesting);

  test('where the P2P shop is on, it reads each local address once and joins what they have listed', () async {
    Env.setTestnetFromArgs(['--testnet']);
    final container = containerWith([wallet('xAlice'), wallet('xBob'), wallet('xCarol')]);

    await container.read(p2pListedNftsProvider.notifier).refresh();

    expect(container.read(p2pListedNftsProvider), {'nft:1', 'nft:2', 'nft:3'});
    expect(service.calls, unorderedEquals(['listedNftIds(xAlice)', 'listedNftIds(xBob)', 'listedNftIds(xCarol)']));
  });

  test('a Vault account is not asked about: it cannot sell', () async {
    Env.setTestnetFromArgs(['--testnet']);
    final container = containerWith([wallet('xAlice'), wallet('xRBXvault', vault: true)]);
    await container.read(p2pListedNftsProvider.notifier).refresh();
    expect(service.calls, ['listedNftIds(xAlice)']);
  });

  test('an address whose read fails keeps what it had, and the others still update', () async {
    Env.setTestnetFromArgs(['--testnet']);
    final container = containerWith([wallet('xAlice'), wallet('xBob')]);
    final listed = container.read(p2pListedNftsProvider.notifier);
    await listed.refresh();

    service.down.add('xAlice');
    service.listedByOwner['xBob'] = {};
    await listed.refresh();

    expect(container.read(p2pListedNftsProvider), {'nft:1', 'nft:2'});
  });

  test('an NFT whose listing closed loses its flag on the next read', () async {
    Env.setTestnetFromArgs(['--testnet']);
    final container = containerWith([wallet('xAlice')]);
    final listed = container.read(p2pListedNftsProvider.notifier);
    await listed.refresh();
    service.listedByOwner['xAlice'] = {'nft:2'};
    await listed.refresh();
    expect(container.read(p2pListedNftsProvider), {'nft:2'});
  });

  test('where the P2P shop is off (mainnet), nothing is read and nothing is flagged', () async {
    expect(Env.p2pEnabled, isFalse);
    final container = containerWith([wallet('xAlice')]);
    await container.read(p2pListedNftsProvider.notifier).refresh();
    expect(service.calls, isEmpty);
    expect(container.read(p2pListedNftsProvider), isEmpty);
  });
}
