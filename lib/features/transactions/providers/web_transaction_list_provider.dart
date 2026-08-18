import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/env.dart';
import '../../btc_web/models/btc_web_transaction.dart';
import '../../btc_web/providers/btc_web_transaction_list_provider.dart';
import '../../btc_web/services/btc_web_service.dart';
import 'transaction_signal_provider.dart';

import '../../../core/services/explorer_service.dart';
import '../models/web_transaction.dart';
import 'package:collection/collection.dart';

class WebTransactionListModel {
  final List<WebTransaction> transactions;
  final bool isLoading;
  final bool canLoadMore;
  final int page;

  const WebTransactionListModel({
    this.transactions = const [],
    this.isLoading = false,
    this.canLoadMore = true,
    this.page = 1,
  });

  WebTransactionListModel copyWith({
    List<WebTransaction>? transactions,
    bool? isLoading,
    bool? canLoadMore,
    int? page,
  }) {
    return WebTransactionListModel(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      canLoadMore: canLoadMore ?? this.canLoadMore,
      page: page ?? this.page,
    );
  }
}

class WebTransactionListProvider extends StateNotifier<WebTransactionListModel> {
  final Ref ref;
  final String address;

  WebTransactionListProvider(
    this.ref,
    this.address, [
    WebTransactionListModel model = const WebTransactionListModel(),
  ]) : super(model) {
    load(address: address, page: 1, invokeLoop: true);
  }

  Future<void> load({
    required String address,
    required int page,
    required bool invokeLoop,
  }) async {
    state = state.copyWith(isLoading: true);
    final data = await ExplorerService().getTransactions(
      address: address,
      page: page,
    );

    state = state.copyWith(
      transactions: [...state.transactions, ...data.results],
      isLoading: false,
      canLoadMore: data.num_pages > data.page,
      page: page,
    );

    if (invokeLoop) {
      await Future.delayed(const Duration(seconds: 10));
      checkForNew(address);
    }
  }

  void insertPendingTx(WebTransaction tx) {
    state = state.copyWith(transactions: [
      tx.copyWith(isPending: true),
      ...state.transactions,
    ]);
  }

  void fetchNextPage() {
    print("Next");
    if (state.canLoadMore) {
      load(address: address, page: state.page + 1, invokeLoop: false);
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, transactions: []);
    load(address: address, page: 1, invokeLoop: false);
  }

  Future<void> checkForNew(String address) async {
    final data = await ExplorerService().getTransactions(
      address: address,
      page: 1,
    );

    final List<WebTransaction> newItems = [];
    for (final tx in data.results) {
      final exists = state.transactions.firstWhereOrNull((t) => t.hash == tx.hash) != null;
      final pendingIndex = state.transactions.indexWhere((t) => t.hash == tx.hash && t.isPending == true);

      if (pendingIndex >= 0) {
        state = state.copyWith(
            transactions: [...state.transactions]
              ..removeAt(pendingIndex)
              ..insert(pendingIndex, tx));

        handleNewTx(tx);
      } else if (!exists) {
        newItems.add(tx);
      }
    }
    if (newItems.isNotEmpty) {
      state = state.copyWith(transactions: [...newItems, ...state.transactions]);
      for (final tx in newItems) {
        handleNewTx(tx);
      }
    }

    await Future.delayed(const Duration(seconds: 10));
    checkForNew(address);
  }

  void handleNewTx(WebTransaction tx) {
    ref.read(transactionSignalProvider.notifier).insert(tx.toNative());
  }
}

final webTransactionListProvider = StateNotifierProvider.family<WebTransactionListProvider, WebTransactionListModel, String>((ref, address) {
  return WebTransactionListProvider(ref, address);
});

/// Full VFX history for both addresses, fetched page-by-page and then cached.
/// Split out of [combinedWebTransactionListProvider] so the network fetch only
/// re-runs when a NEW confirmed transaction lands on either address — the
/// newest-confirmed-hash selects below are the sole reactive keys. Previously
/// the fetch lived inline and re-ran on every upstream list-identity change
/// (the 10s checkForNew tick, the 30s vBTC token reload, the 90s BTC loop),
/// re-downloading the entire history each time — the constant churn behind
/// the choppy transactions tab and mobile tab crashes.
final _combinedVfxHistoryProvider = FutureProvider.family<List<WebTransaction>, String>((ref, String identifier) async {
  final parts = identifier.split(':');
  final vfxAddress = parts[0];
  final raAddress = parts[1];

  ref.watch(webTransactionListProvider(vfxAddress)
      .select((v) => v.transactions.firstWhereOrNull((t) => !t.isPending)?.hash ?? ''));
  ref.watch(webTransactionListProvider(raAddress)
      .select((v) => v.transactions.firstWhereOrNull((t) => !t.isPending)?.hash ?? ''));

  final List<WebTransaction> transactions = [];

  // Bounded: the old unbounded loop walked every page a whale account has,
  // which is part of what overwhelmed mobile tabs. Deeper history stays
  // reachable through the paginated per-address tabs.
  const maxPages = 30;
  int page = 1;
  while (page <= maxPages) {
    try {
      final data = await ExplorerService().getTransactionsFromMultipleAddresses(
        addresses: [vfxAddress, raAddress],
        page: page,
      );
      transactions.addAll(data.results);

      if (data.num_pages == data.page || data.results.isEmpty) {
        break;
      }
      page += 1;
    } catch (e) {
      print("Error getting combined transactions $e");
      break;
    }
  }

  return transactions;
});

final combinedWebTransactionListProvider = FutureProvider.family<List<dynamic>, String>((ref, String identifier) async {
  final parts = identifier.split(':');
  final vfxAddress = parts[0];
  final raAddress = parts[1];

  // All loaded per-address txs, not just pending: when checkForNew swaps a
  // pending tx for its confirmed version, the confirmed copy is here
  // immediately, so it can't drop out while the history cache catches up.
  // The groupBy below dedupes against history, first entry wins.
  final vfxTxs = ref.watch(webTransactionListProvider(vfxAddress).select((v) => v.transactions));
  final raTxs = ref.watch(webTransactionListProvider(raAddress).select((v) => v.transactions));

  // Cached unless a new confirmed tx arrived; the merge/sort below is the
  // only work that re-runs on the poll loops.
  final history = await ref.watch(_combinedVfxHistoryProvider(identifier).future);

  List<WebTransaction> vfxTransactions = [...vfxTxs, ...raTxs, ...history];

  final groups = groupBy(vfxTransactions, (WebTransaction tx) => "${tx.hash}_${tx.fromAddress}_${tx.toAddress}");
  vfxTransactions = groups.values.map((list) => list.first).toList();

  final btcTransactions = ref.watch(btcWebCombinedTransactionListProvider);

  final combined = [...vfxTransactions, ...btcTransactions];

  combined.sort((a, b) {
    late final int timestampA;
    late final int timestampB;

    if (a is WebTransaction) {
      timestampA = a.date.millisecondsSinceEpoch;
    } else if (a is BtcWebTransaction) {
      if (a.status.blockTime != null) {
        timestampA = a.status.blockTime! * 1000;
      } else {
        timestampA = DateTime.now().add(Duration(minutes: 20)).millisecondsSinceEpoch;
      }
    } else {
      timestampA = 0;
    }

    if (b is WebTransaction) {
      timestampB = b.date.millisecondsSinceEpoch;
    } else if (b is BtcWebTransaction) {
      if (b.status.blockTime != null) {
        timestampB = b.status.blockTime! * 1000;
      } else {
        timestampB = DateTime.now().add(Duration(minutes: 20)).millisecondsSinceEpoch;
      }
    } else {
      timestampB = 0;
    }

    return timestampA > timestampB ? -1 : 1;
  });

  return combined;
});
