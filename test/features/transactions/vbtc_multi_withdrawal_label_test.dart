import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/app.dart';
import 'package:rbx_wallet/features/transactions/models/transaction.dart';
import 'package:rbx_wallet/features/transactions/models/web_transaction.dart';

final _multiData = jsonEncode({
  'Function': 'VBTCWithdrawalRequestMultiV2()',
  'RequestorAddress': 'xA',
  'BTCAddress': 'tb1qdest',
  'TotalAmount': 0.00007,
  'FeeRate': 3,
  'Inputs': [
    {'SCUID': 'big:2', 'Amount': 0.00005},
    {'SCUID': 'small:1', 'Amount': 0.00002},
  ],
});

final _singleData = jsonEncode({
  'Function': 'VBTCWithdrawalRequest()',
  'ContractUID': 'big:2',
  'RequestorAddress': 'xA',
  'BTCAddress': 'tb1qdest',
  'Amount': 0.00005,
  'FeeRate': 3,
});

Transaction _desktop(String? data) => Transaction.fromJson({
      'Hash': 'req',
      'ToAddress': 'xA',
      'FromAddress': 'xA',
      'TransactionType': 27,
      'Amount': 0.0,
      'Nonce': 0,
      'Fee': 0.0,
      'Timestamp': 1760000000,
      'Data': data,
      'Height': 1,
    });

WebTransaction _web(String? data) => WebTransaction.fromJson({
      'hash': 'req',
      'to_address': 'xA',
      'from_address': 'xA',
      'type': 27,
      'total_amount': 0.0,
      'total_fee': 0.0,
      'date_crafted': '2026-10-24T00:00:00Z',
      'height': 1,
      'data': data,
    });

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    rootNavigatorKey = GlobalKey<NavigatorState>();
  });

  test('a multi-vault request is one row named with its vault count and total', () {
    expect(_desktop(_multiData).typeLabel, 'vBTC Withdrawal Request (2 vaults) (0.00007 vBTC)');
    expect(_web(_multiData).typeLabel, 'vBTC Withdrawal Request (2 vaults) (0.00007 vBTC)');
  });

  test('a single-vault request keeps its label', () {
    expect(_desktop(_singleData).typeLabel, 'vBTC Withdrawal Request (0.00005 vBTC)');
    expect(_web(_singleData).typeLabel, 'vBTC Withdrawal Request');
    expect(_desktop(null).typeLabel, 'vBTC Withdrawal Request');
  });
}
