import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/app.dart';
import 'package:rbx_wallet/features/transactions/models/transaction.dart';
import 'package:rbx_wallet/features/transactions/models/web_transaction.dart';

String _coinPinData(String function) => jsonEncode({
      'Function': function,
      'ContractUID': 'sc-1',
      'WithdrawalRequestHash': 'req-1',
      'FeeRate': 12,
    });

Transaction _desktop(int type, {String? data}) => Transaction.fromJson({
      'Hash': 'h$type',
      'ToAddress': 'BTC_Attestation',
      'FromAddress': 'BTC_Attestation',
      'TransactionType': type,
      'Amount': 0.0,
      'Nonce': 0,
      'Fee': 0.0,
      'Timestamp': 1760000000,
      'Data': data,
      'Height': 1,
    });

WebTransaction _web(int type, {String? data}) => WebTransaction.fromJson({
      'hash': 'h$type',
      'to_address': 'BTC_Attestation',
      'from_address': 'BTC_Attestation',
      'type': type,
      'total_amount': 0.0,
      'total_fee': 0.0,
      'date_crafted': '2026-10-19T00:00:00Z',
      'height': 1,
      'data': data,
    });

void main() {
  // Labels read through `globalL10n`, which falls back to English with a
  // detached navigator key (see vbtc_multi_amount_validator_test.dart).
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    rootNavigatorKey = GlobalKey<NavigatorState>();
  });

  const expected = {
    43: 'Bitcoin Report',
    45: 'Bitcoin Reorg',
    46: 'vBTC Vault Rekey',
  };

  test('types 43, 45 and 46 have names, not numbers (desktop and web)', () {
    expected.forEach((type, label) {
      expect(_desktop(type).typeLabel, label);
      expect(_web(type).typeLabel, label);
    });
  });

  test('type 44 names a fee raise or a release from its function', () {
    expect(_desktop(44, data: _coinPinData('VBTCWithdrawalFeeBump()')).typeLabel, 'vBTC Withdrawal Fee Raise');
    expect(_desktop(44, data: _coinPinData('VBTCWithdrawalRelease()')).typeLabel, 'vBTC Withdrawal Release');
    expect(_web(44, data: _coinPinData('VBTCWithdrawalFeeBump()')).typeLabel, 'vBTC Withdrawal Fee Raise');
    expect(_web(44, data: _coinPinData('VBTCWithdrawalRelease()')).typeLabel, 'vBTC Withdrawal Release');
    // Unreadable data still gets a name.
    expect(_desktop(44).typeLabel, 'vBTC Withdrawal Fee Raise');
    expect(_web(44).typeLabel, 'vBTC Withdrawal Fee Raise');
  });

  test('type 44 is a vBTC transaction', () {
    expect(_desktop(44, data: _coinPinData('VBTCWithdrawalFeeBump()')).isVbtcTx, isTrue);
    expect(_web(44, data: _coinPinData('VBTCWithdrawalFeeBump()')).isVbtcTx, isTrue);
  });
}
