import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/env.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/l10n_helper.dart';
import '../../transactions/models/transaction_notification.dart';
import '../../transactions/providers/transaction_notification_provider.dart';
import '../../wallet/providers/wallet_list_provider.dart';
import '../models/p2p_error.dart';
import '../models/p2p_listing.dart';
import '../models/p2p_page.dart';
import 'p2p_browse_providers.dart';
import 'p2p_session_provider.dart';

part 'p2p_sale_notices_provider.g.dart';

/// Tells the person that [listing], one of this wallet's, has a winner and
/// waits for its sale to be started.
typedef P2pSaleNoticeSink = void Function(P2pListing listing);

/// How a new sale to start is announced: the app's notification, which
/// stays up longer than a transaction's.
@Riverpod(keepAlive: true)
P2pSaleNoticeSink p2pSaleNoticeSink(P2pSaleNoticeSinkRef ref) {
  return (listing) {
    final l10n = globalL10n;
    ref.read(transactionNotificationProvider.notifier).add(
          TransactionNotification(
            identifier: "p2p_sale_to_start_${listing.id}",
            title: l10n.p2pNoticeSaleToStartTitle,
            body: l10n.p2pNoticeSaleToStartBody(listing.title, listing.shopUrl),
            icon: Icons.storefront,
            color: AppColorVariant.Primary,
          ),
          12,
        );
  };
}

/// The listings of this wallet's shops that have a winner and wait for
/// their seller to start the sale, for the badge on the shop's entry.
///
/// Found by polling the public `GET /p2p/shops/{url}/listings/
/// ?state=awaiting_sale_start` for each shop an account of this wallet owns.
/// Public reads need no sign-in, so the poll never asks for the wallet's
/// password. A listing is announced once, when it first shows up.
@Riverpod(keepAlive: true)
class P2pSaleNotices extends _$P2pSaleNotices {
  /// The wallet's loop asks every 15 seconds; the registry is read this often.
  static const Duration pollEvery = Duration(seconds: 60);

  /// How long an account's shop (or its having none) is taken as read.
  static const Duration shopsGoodFor = Duration(minutes: 10);

  // Each account's shop URL, or null for an account with no shop.
  final Map<String, String?> _shopByAddress = {};
  DateTime? _shopsReadAt;
  DateTime? _polledAt;

  // What each shop has waiting, so one failed read does not drop the rest.
  final Map<String, List<P2pListing>> _waitingByShop = {};

  // The listings already announced.
  final Set<int> _told = {};

  // The poll under way, shared by everyone who asks meanwhile, and whether
  // one more was asked for by something that changed while it ran.
  Future<void>? _polling;
  bool _pollAgain = false;

  @override
  List<P2pListing> build() => const [];

  /// Reads the registry again when the last read is older than [pollEvery],
  /// or at once with [force] (after this wallet started a sale, say). Does
  /// nothing where the P2P shop is off.
  Future<void> poll({bool force = false, DateTime? now}) {
    if (!Env.p2pEnabled) {
      return Future.value();
    }
    final at = now ?? DateTime.now();
    final running = _polling;
    if (running != null) {
      // A read under way may have been made before what [force] is about
      // (a sale just started): it reads once more when it is in.
      _pollAgain = _pollAgain || force;
      return running;
    }
    final last = _polledAt;
    if (!force && last != null && at.difference(last) < pollEvery) {
      return Future.value();
    }
    _polledAt = at;
    return _polling = _readUntilSettled(at).whenComplete(() {
      _polling = null;
    });
  }

  Future<void> _readUntilSettled(DateTime at) async {
    do {
      _pollAgain = false;
      await _read(at);
    } while (_pollAgain);
  }

  /// Forgets which accounts have a shop (one was opened or closed), and
  /// reads again.
  Future<void> shopsChanged() {
    _shopsReadAt = null;
    return poll(force: true);
  }

  Future<void> _read(DateTime at) async {
    final service = ref.read(p2pServiceProvider);
    final addresses = ref.read(walletListProvider).where((w) => !w.isReserved).map((w) => w.address).toSet();

    final shopsReadAt = _shopsReadAt;
    final shopsStale = shopsReadAt == null || at.difference(shopsReadAt) >= shopsGoodFor || !_shopByAddress.keys.toSet().containsAll(addresses);
    if (shopsStale) {
      var allRead = true;
      await Future.wait(addresses.map((address) async {
        try {
          _shopByAddress[address] = (await service.ownerShop(address))?.url;
        } on P2pError {
          // Keep what was known of this account: the next poll asks again.
          allRead = false;
        }
      }));
      _shopByAddress.removeWhere((address, _) => !addresses.contains(address));
      _shopsReadAt = allRead ? at : null;
    }

    final shops = _shopByAddress.values.whereType<String>().toSet();
    _waitingByShop.removeWhere((url, _) => !shops.contains(url));
    await Future.wait(shops.map((url) async {
      try {
        final page = await service.listListings(url, state: P2pListingState.awaitingSaleStart, limit: P2pPage.maxLimit);
        _waitingByShop[url] = page.results;
      } on P2pError {
        // Keep what this shop had waiting.
      }
    }));

    final waiting = [for (final listings in _waitingByShop.values) ...listings];
    final fresh = waiting.where((listing) => _told.add(listing.id)).toList();
    _told.removeWhere((id) => !waiting.any((l) => l.id == id));
    state = waiting;

    final announce = ref.read(p2pSaleNoticeSinkProvider);
    for (final listing in fresh) {
      announce(listing);
    }
    // The seller's own list, if it is on screen, shows the new winner too.
    for (final seller in fresh.map((l) => l.sellerAddress).toSet()) {
      ref.invalidate(p2pMeProvider(seller));
    }
  }
}
