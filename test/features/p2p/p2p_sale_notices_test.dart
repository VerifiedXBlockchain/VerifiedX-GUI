import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/env.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_error.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_listing.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_page.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_shop.dart';
import 'package:rbx_wallet/features/p2p/providers/p2p_sale_notices_provider.dart';
import 'package:rbx_wallet/features/p2p/providers/p2p_session_provider.dart';
import 'package:rbx_wallet/features/wallet/models/wallet.dart';
import 'package:rbx_wallet/features/wallet/providers/wallet_list_provider.dart';

import 'p2p_test_helpers.dart';

/// The wallet's accounts, fixed: nothing is asked of the node.
class StubWalletList extends WalletListProvider {
  StubWalletList(Ref ref, List<Wallet> wallets) : super(ref, wallets);
}

/// A registry whose first read of a shop's listings waits until let go.
class SlowListingsService extends FakeP2pService {
  final Completer<void> gate = Completer<void>();
  final Completer<void> reached = Completer<void>();

  @override
  Future<P2pPage<P2pListing>> listListings(String shopUrl, {int? collectionId, P2pListingState? state, int page = 1, int? limit}) async {
    if (!reached.isCompleted) {
      reached.complete();
      await gate.future;
    }
    return super.listListings(shopUrl, collectionId: collectionId, state: state, page: page, limit: limit);
  }
}

Wallet wallet(String address, {bool vault = false}) {
  return Wallet(id: 1, publicKey: 'pub', address: address, balance: 10, isValidating: false, recoveryAddress: vault ? 'xRecovery' : null);
}

void main() {
  const alice = 'xJwSHB75g85bfhPLBFJ7JS1QzkDRhNJksJ';
  const bob = 'xBobAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
  const waitingKey = 'dryrun-demo awaiting_sale_start';
  final start = DateTime.utc(2026, 11, 16, 17);

  late FakeP2pService service;
  late List<P2pListing> announced;

  P2pShop demoShop() => P2pShop.fromJson(p2pFixture('shop_detail'));

  P2pListing won(int id) => P2pListing.fromJson({...p2pFixture('listing_buy_now'), 'id': id, 'state': 'awaiting_sale_start'});

  ProviderContainer containerWith(List<Wallet> wallets) {
    final container = ProviderContainer(overrides: [
      p2pServiceProvider.overrideWithValue(service),
      walletListProvider.overrideWith((ref) => StubWalletList(ref, wallets)),
      p2pSaleNoticeSinkProvider.overrideWithValue(announced.add),
    ]);
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    announced = [];
    service = FakeP2pService()..shopsByOwner = {alice: demoShop()};
  });

  tearDown(Env.resetNetworkForTesting);

  test('where the P2P shop is off, nothing is asked', () async {
    final container = containerWith([wallet(alice)]);
    await container.read(p2pSaleNoticesProvider.notifier).poll(now: start);
    expect(service.calls, isEmpty);
    expect(container.read(p2pSaleNoticesProvider), isEmpty);
  });

  test('asks each account for its shop, then each shop for sales to start, with no sign-in', () async {
    Env.setTestnetFromArgs(['--testnet']);
    service.listingsByState[waitingKey] = [won(4)];
    final container = containerWith([wallet(alice), wallet(bob), wallet('xRBXvault', vault: true)]);

    await container.read(p2pSaleNoticesProvider.notifier).poll(now: start);

    // A Vault account cannot sell and is not asked about; Bob has no shop.
    expect(service.calls, unorderedEquals(['ownerShop($alice)', 'ownerShop($bob)', 'listListings(dryrun-demo, state: awaiting_sale_start)']));
    expect(service.calls.where((c) => c.startsWith('signToken')), isEmpty);
    expect(container.read(p2pSaleNoticesProvider).map((l) => l.id), [4]);
    expect(announced.map((l) => l.id), [4]);
  });

  test('a sale is announced once, however often it is seen', () async {
    Env.setTestnetFromArgs(['--testnet']);
    service.listingsByState[waitingKey] = [won(4)];
    final container = containerWith([wallet(alice)]);
    final notices = container.read(p2pSaleNoticesProvider.notifier);

    await notices.poll(now: start);
    await notices.poll(now: start.add(const Duration(minutes: 2)));
    service.listingsByState[waitingKey] = [won(4), won(7)];
    await notices.poll(now: start.add(const Duration(minutes: 4)));

    expect(announced.map((l) => l.id), [4, 7]);
    expect(container.read(p2pSaleNoticesProvider).map((l) => l.id), [4, 7]);
  });

  test('a sale that was started leaves the badge', () async {
    Env.setTestnetFromArgs(['--testnet']);
    service.listingsByState[waitingKey] = [won(4)];
    final container = containerWith([wallet(alice)]);
    final notices = container.read(p2pSaleNoticesProvider.notifier);
    await notices.poll(now: start);

    service.listingsByState[waitingKey] = [];
    await notices.poll(now: start.add(const Duration(minutes: 2)));
    expect(container.read(p2pSaleNoticesProvider), isEmpty);
  });

  test('the wallet\'s loop asks every 15 seconds; the registry is read once a minute', () async {
    Env.setTestnetFromArgs(['--testnet']);
    final container = containerWith([wallet(alice)]);
    final notices = container.read(p2pSaleNoticesProvider.notifier);

    await notices.poll(now: start);
    await notices.poll(now: start.add(const Duration(seconds: 15)));
    await notices.poll(now: start.add(const Duration(seconds: 45)));
    expect(service.calls.where((c) => c.startsWith('listListings')), hasLength(1));

    await notices.poll(now: start.add(const Duration(seconds: 61)));
    expect(service.calls.where((c) => c.startsWith('listListings')), hasLength(2));
    // Which accounts have a shop is not asked again that soon.
    expect(service.calls.where((c) => c.startsWith('ownerShop')), hasLength(1));
  });

  test('which accounts have a shop is read again after ten minutes, or when a shop changes', () async {
    Env.setTestnetFromArgs(['--testnet']);
    final container = containerWith([wallet(alice)]);
    final notices = container.read(p2pSaleNoticesProvider.notifier);
    await notices.poll(now: start);

    await notices.poll(now: start.add(const Duration(minutes: 11)));
    expect(service.calls.where((c) => c.startsWith('ownerShop')), hasLength(2));

    // The shop is closed: its sales are no longer asked about.
    service.shopsByOwner = {};
    service.calls.clear();
    await notices.shopsChanged();
    expect(service.calls, ['ownerShop($alice)']);
  });

  test('something that changes while a read is under way is read for once that read is in', () async {
    Env.setTestnetFromArgs(['--testnet']);
    final slow = SlowListingsService()
      ..shopsByOwner = {alice: demoShop()}
      ..listingsByState[waitingKey] = [won(4)];
    service = slow;
    final container = containerWith([wallet(alice)]);
    final notices = container.read(p2pSaleNoticesProvider.notifier);

    final first = notices.poll(now: start);
    await slow.reached.future;
    // The sale is started while the first read is still out.
    slow.listingsByState[waitingKey] = [];
    final forced = notices.poll(force: true, now: start);
    slow.gate.complete();
    await Future.wait([first, forced]);

    expect(slow.calls.where((c) => c.startsWith('listListings')), hasLength(2));
    expect(container.read(p2pSaleNoticesProvider), isEmpty);
  });

  test('a registry that cannot be reached keeps what was waiting', () async {
    Env.setTestnetFromArgs(['--testnet']);
    service.listingsByState[waitingKey] = [won(4)];
    final container = containerWith([wallet(alice)]);
    final notices = container.read(p2pSaleNoticesProvider.notifier);
    await notices.poll(now: start);

    service.error = const P2pError(status: null, code: P2pError.unreachable);
    await notices.poll(now: start.add(const Duration(minutes: 2)));
    expect(container.read(p2pSaleNoticesProvider).map((l) => l.id), [4]);
    expect(announced, hasLength(1));
  });
}
