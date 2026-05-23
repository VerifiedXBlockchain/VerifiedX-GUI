import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/tx_refresh.dart';
import '../../validator/providers/validating_status_provider.dart';
import '../models/transaction.dart';
import '../services/local_transaction_service.dart';
import 'transaction_signal_provider.dart';

enum TransactionListType {
  All,
  Success,
  Failed,
  Pending,
  Validated,
  Reserved,
}

class TransactionListProvider extends StateNotifier<List<Transaction>> {
  final Ref ref;
  final TransactionListType type;
  StreamSubscription? _refreshSub;

  TransactionListProvider(
    this.ref,
    this.type, [
    List<Transaction> transactions = const [],
  ]) : super(transactions) {
    load();
    _refreshSub = onTransactionSubmitted.listen((_) {
      print('[TxRefresh] Stream fired for $type — reloading');
      load();
    });
  }

  @override
  void dispose() {
    _refreshSub?.cancel();
    super.dispose();
  }

  void set(List<Transaction> transactions) {
    state = transactions;
  }

  Future<void> load() async {
    if (kIsWeb) {
      return;
    }
    late List<Transaction> transactions;

    switch (type) {
      case TransactionListType.All:
        transactions = (await LocalTransactionService().transactionsAll()).where((tx) => tx.fromAddress != 'Coinbase_BlkRwd').toList();
        final pendingCount = transactions.where((tx) => tx.status == TransactionStatus.Pending).length;
        if (pendingCount > 0) {
          print('[TxRefresh] All list has $pendingCount pending TX(s)');
        }
        break;
      case TransactionListType.Success:
        transactions = (await LocalTransactionService().transactionsSuccess()).where((tx) => tx.fromAddress != 'Coinbase_BlkRwd').toList(); {}
        break;
      case TransactionListType.Failed:
        transactions = await LocalTransactionService().transactionsFailed();
        break;
      case TransactionListType.Pending:
        transactions = await LocalTransactionService().transactionsPending();
        break;
      case TransactionListType.Validated:
        transactions = await LocalTransactionService().transactionsMined();
        break;
      case TransactionListType.Reserved:
        transactions = await LocalTransactionService().transactionsReserved();
        break;
    }

    state = transactions;

    if (type == TransactionListType.Success) {
      final recentTimestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round() - (5 * 60); // 5 min

      late final List<Transaction> recentTransactions;
      if (ref.read(validatingStatusProvider)) {
        recentTransactions = transactions.where((t) => t.timestamp > recentTimestamp && t.height != 0).toList();
      } else {
        recentTransactions = transactions.where((t) => t.timestamp > recentTimestamp).toList();
      }

      ref.read(transactionSignalProvider.notifier).insertAll(recentTransactions);
    }
  }
}

final transactionListProvider = StateNotifierProvider.family<TransactionListProvider, List<Transaction>, TransactionListType>((ref, type) {
  return TransactionListProvider(ref, type);
});
