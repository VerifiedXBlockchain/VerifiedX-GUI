import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/base_component.dart';
import '../../../core/components/centered_loader.dart';

import '../../../core/providers/web_session_provider.dart';
import '../providers/btc_web_transaction_list_provider.dart';
import 'web_btc_transaction_list_tile.dart';

class WebBtcTransactionList extends BaseComponent {
  final String? address;
  const WebBtcTransactionList({super.key, required this.address});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (address == null) {
      return Center(child: Text("No BTC Address"));
    }
    // final provider = ref.read(btcWebTransactionListProvider(address!).notifier);
    // final transactions = ref.watch(btcWebTransactionListProvider(address!));
    final transactions = ref.watch(btcWebCombinedTransactionListProvider);

    if (transactions.isEmpty) {
      return Center(
        child: Text("No Transactions found for $address."),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: WebBtcTransactionListTile(
              transaction: transaction,
            ),
          );
        },
      ),
    );
  }
}
