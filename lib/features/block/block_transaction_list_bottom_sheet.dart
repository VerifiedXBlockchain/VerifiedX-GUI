import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/base_component.dart';
import '../../l10n/generated/app_localizations.dart';
import '../transactions/models/transaction.dart';

class BlockTransactionListBottomSheet extends BaseComponent {
  final List<Transaction> transactions;
  const BlockTransactionListBottomSheet({Key? key, required this.transactions})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final tx = transactions[index];
              return ListTile(
                title: Text("${tx.fromAddress} => ${tx.toAddress}"),
                subtitle: Text(AppLocalizations.of(context).tkbHashLabel(tx.hash)),
                trailing: Text("${tx.amount} VFX"),
              );
            },
          ),
        ),
      ),
    );
  }
}
