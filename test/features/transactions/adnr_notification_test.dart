import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/app.dart';
import 'package:rbx_wallet/core/app_constants.dart';
import 'package:rbx_wallet/features/transactions/models/transaction.dart';
import 'package:rbx_wallet/features/transactions/providers/transaction_notification_provider.dart';
import 'package:rbx_wallet/features/transactions/providers/transaction_signal_provider.dart';
import 'package:rbx_wallet/features/wallet/providers/wallet_list_provider.dart';

Transaction domainTx(String hash, Map<String, String> data) => Transaction(
      hash: hash,
      toAddress: 'Adnr_Base',
      fromAddress: 'xVWNbcBXTtiiL7ZHCqxRP1q12tcgUTQA4m',
      type: TxType.adnr,
      amount: 5,
      nonce: 1,
      fee: 0.00001,
      timestamp: (DateTime.now().millisecondsSinceEpoch / 1000).round(),
      nftData: jsonEncode(data),
      height: 1178001,
    );

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    rootNavigatorKey = GlobalKey<NavigatorState>();
  });

  test('domain transactions as the chain records them raise their notifications', () {
    final container = ProviderContainer(overrides: [
      walletListProvider.overrideWith((ref) => WalletListProvider(ref, [])),
    ]);
    addTearDown(container.dispose);
    final signals = container.read(transactionSignalProvider.notifier);

    signals.insert(domainTx('create', {'Function': 'AdnrCreate()', 'Name': 'qa20261021aw1'}));
    signals.insert(domainTx('transfer', {'Function': 'AdnrTransfer()', 'Name': 'qa20261021aw1.vfx'}));
    signals.insert(domainTx('delete', {'Function': 'AdnrDelete()', 'Name': 'qa20261021aw1.vfx'}));
    signals.insert(domainTx('btc-create', {'Function': 'BTCAdnrCreate()', 'Name': 'qa20261021aw1'}));
    signals.insert(domainTx('btc-transfer', {'Function': 'BTCAdnrTransfer()', 'Name': 'qa20261021aw1.btc'}));
    signals.insert(domainTx('btc-delete', {'Function': 'BTCAdnrDelete()', 'Name': 'qa20261021aw1.btc'}));

    final notifications = container.read(transactionNotificationProvider);
    expect(notifications.map((n) => n.identifier), ['create', 'transfer', 'delete', 'btc-create', 'btc-transfer', 'btc-delete']);
    expect(notifications.first.title, 'Domain Name Created');
    expect(notifications.first.body, contains('qa20261021aw1'));
  });
}
