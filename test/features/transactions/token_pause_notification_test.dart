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

Transaction pauseTx(String hash, {required bool pause}) => Transaction(
      hash: hash,
      toAddress: 'Token_Base',
      fromAddress: 'xVWNbcBXTtiiL7ZHCqxRP1q12tcgUTQA4m',
      type: TxType.tokenTx,
      amount: 0,
      nonce: 1,
      fee: 0.00001,
      timestamp: (DateTime.now().millisecondsSinceEpoch / 1000).round(),
      nftData: jsonEncode({'Function': 'TokenPause()', 'ContractUID': 'sc-1', 'Pause': pause}),
      height: 1178001,
    );

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    rootNavigatorKey = GlobalKey<NavigatorState>();
  });

  test('a resume is announced as a resume, a pause as a pause', () {
    final container = ProviderContainer(overrides: [
      walletListProvider.overrideWith((ref) => WalletListProvider(ref, [])),
    ]);
    addTearDown(container.dispose);
    final signals = container.read(transactionSignalProvider.notifier);

    signals.insert(pauseTx('pause', pause: true));
    signals.insert(pauseTx('resume', pause: false));

    final notifications = container.read(transactionNotificationProvider);
    expect(notifications.map((n) => '${n.title} / ${n.body}'), ['Token Pause / Paused', 'Token Resume / Resumed']);
  });
}
