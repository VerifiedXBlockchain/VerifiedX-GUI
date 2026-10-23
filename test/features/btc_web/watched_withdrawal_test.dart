import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/btc_web/models/watched_withdrawal.dart';

/// Core's `BtcVaultView.CompletionAnswer` for a pinned withdrawal, as Spyglass
/// passes a successful node answer through (Success renamed, the rest spread).
Map<String, dynamic> _pinnedAnswer({
  int feeRate = 4,
  bool canRaiseFee = true,
  bool canRelease = true,
  bool releasing = false,
}) {
  return {
    'success': true,
    'Paid': false,
    'Attested': true,
    'Message': '[AWAITING-BTC-CONFIRMATION] This withdrawal is paid by Bitcoin transaction abc, fixed by the chain.',
    'Status': 'Awaiting_BTC_Confirmation',
    'NothingToDo': true,
    'NotMinedYet': false,
    'VFXTransactionHash': null,
    'BTCTransactionHash': null,
    'PinnedBTCTransactionHash': 'abc',
    'SmartContractUID': 'sc-1',
    'WithdrawalRequestHash': 'req-1',
    'Withdrawal': {
      'SmartContractUID': 'sc-1',
      'RequestHash': 'req-1',
      'Kind': 'Withdrawal',
      'Requester': 'xRequester',
      'State': 'Pinned',
      'Summary': 'This withdrawal is paid by Bitcoin transaction abc, fixed by the chain.',
      'Amount': 0.001,
      'AmountSats': 100000,
      'FeeRate': feeRate,
      'CanCancel': false,
      'CanRaiseFee': canRaiseFee,
      'CanRelease': canRelease,
      'Releasing': releasing,
      'BitcoinTxid': 'abc',
      'SettledTxid': null,
      'Transactions': [
        {
          'Txid': 'abc',
          'Kind': 'Payment',
          'FeeRate': feeRate,
          'FeeSats': 616,
          'Superseded': false,
          'Dead': false,
          'Confirmed': false,
        },
      ],
    },
  };
}

void main() {
  group('WatchedWithdrawal.fromCompletionAnswer', () {
    test('reads a pinned withdrawal from the spread success shape', () {
      final watched = WatchedWithdrawal.fromCompletionAnswer(_pinnedAnswer())!;

      expect(watched.isPinned, isTrue);
      expect(watched.paid, isFalse);
      expect(watched.isClosed, isFalse);
      expect(watched.feeRate, 4);
      expect(watched.canRaiseFee, isTrue);
      expect(watched.canRelease, isTrue);
      expect(watched.bitcoinTxHash, 'abc');
      expect(watched.transactions.single.feeSats, 616);
      // The node's marker is for callers, not for the user.
      expect(watched.message, startsWith('This withdrawal is paid'));
    });

    test('reads a closed withdrawal Spyglass nests under raw (HTTP 500)', () {
      final response = {
        'success': false,
        'message': 'This withdrawal was given up by its requester.',
        'raw': {
          'Success': false,
          'Paid': false,
          'Attested': true,
          'Status': 'Closed',
          'NotMinedYet': false,
          'Withdrawal': {'State': 'Released', 'FeeRate': 9, 'CanRaiseFee': false, 'CanRelease': false},
        },
      };

      final watched = WatchedWithdrawal.fromCompletionAnswer(response)!;

      expect(watched.status, 'Closed');
      expect(watched.isClosed, isTrue);
      expect(watched.canRaiseFee, isFalse);
    });

    test('a request the node has not mined yet stays open', () {
      final response = {
        'success': false,
        'raw': {'Attested': true, 'NotMinedYet': true, 'Status': 'Unknown', 'Withdrawal': null},
      };

      final watched = WatchedWithdrawal.fromCompletionAnswer(response)!;

      expect(watched.notMinedYet, isTrue);
      expect(watched.isClosed, isFalse);
    });

    test('a paid withdrawal is closed and names the paying transaction', () {
      final answer = _pinnedAnswer()
        ..['Paid'] = true
        ..['Status'] = 'Completed'
        ..['PinnedBTCTransactionHash'] = null
        ..['BTCTransactionHash'] = 'paid-tx';
      (answer['Withdrawal'] as Map<String, dynamic>)['State'] = 'Settled';

      final watched = WatchedWithdrawal.fromCompletionAnswer(answer)!;

      expect(watched.isClosed, isTrue);
      expect(watched.bitcoinTxHash, 'paid-tx');
    });

    test('a FROST preparation for a vault the chain does not watch is not a watched withdrawal', () {
      final preparation = {
        'success': true,
        'SessionId': 's-1',
        'StartMessage': 's-1.xOwner.1',
        'StartTimestamp': 1,
        'ShareDistributionMessage': 's-1.xOwner.2',
        'ShareDistributionTimestamp': 2,
      };

      expect(WatchedWithdrawal.fromCompletionAnswer(preparation), isNull);
      expect(WatchedWithdrawal.fromCompletionAnswer({'success': false, 'message': 'x', 'raw': {'Success': false}}), isNull);
      expect(WatchedWithdrawal.fromCompletionAnswer(null), isNull);
    });
  });

  group('WatchedWithdrawal.samePinAs', () {
    test('an action stays unapplied until the rate, state or transaction changes', () {
      final before = WatchedWithdrawal.fromCompletionAnswer(_pinnedAnswer(feeRate: 4))!;

      expect(WatchedWithdrawal.fromCompletionAnswer(_pinnedAnswer(feeRate: 4))!.samePinAs(before), isTrue);
      expect(WatchedWithdrawal.fromCompletionAnswer(_pinnedAnswer(feeRate: 9))!.samePinAs(before), isFalse);
      expect(WatchedWithdrawal.fromCompletionAnswer(_pinnedAnswer(feeRate: 4, releasing: true))!.samePinAs(before), isFalse);
    });

    test('reads the requester', () {
      expect(WatchedWithdrawal.fromCompletionAnswer(_pinnedAnswer())!.requester, 'xRequester');
    });
  });

  group('WatchedWithdrawal.isFrostPreparation', () {
    test('only a successful FROST preparation marks a vault as not watched', () {
      expect(WatchedWithdrawal.isFrostPreparation({'success': true, 'StartMessage': 's.x.1'}), isTrue);
      // A watched answer, a refusal or an error says nothing permanent.
      expect(WatchedWithdrawal.isFrostPreparation(_pinnedAnswer()), isFalse);
      expect(WatchedWithdrawal.isFrostPreparation({'success': false, 'message': 'Error: timeout', 'raw': {'Success': false}}), isFalse);
      expect(WatchedWithdrawal.isFrostPreparation(null), isFalse);
    });
  });

  group('WatchedWithdrawal.settlesChangeSentAgainst', () {
    final sent = WatchedWithdrawal.fromCompletionAnswer(_pinnedAnswer(feeRate: 4))!;

    test('a change that lands after the wait still clears the note', () {
      expect(WatchedWithdrawal.fromCompletionAnswer(_pinnedAnswer(feeRate: 9))!.settlesChangeSentAgainst(sent), isTrue);
    });

    test('a closed withdrawal never keeps the note', () {
      final closed = WatchedWithdrawal.fromCompletionAnswer({
        'success': false,
        'raw': {'Attested': true, 'Status': 'Closed', 'Withdrawal': {'State': 'Released'}},
      })!;
      expect(closed.settlesChangeSentAgainst(sent), isTrue);
      expect(closed.settlesChangeSentAgainst(null), isTrue);
    });

    test('the same pin settles nothing', () {
      expect(WatchedWithdrawal.fromCompletionAnswer(_pinnedAnswer(feeRate: 4))!.settlesChangeSentAgainst(sent), isFalse);
      expect(sent.settlesChangeSentAgainst(null), isFalse);
    });
  });

  group('watchedActionWaitIsOver', () {
    final sentAt = DateTime(2026, 10, 19, 15, 0);

    test('actions stay off while a sent change may still be mined', () {
      expect(watchedActionWaitIsOver(sentAt, sentAt.add(const Duration(minutes: 1))), isFalse);
    });

    test('they come back once the change has had its time', () {
      expect(watchedActionWaitIsOver(sentAt, sentAt.add(kWatchedActionWait)), isTrue);
      expect(watchedActionWaitIsOver(null, sentAt), isFalse);
    });
  });

  group('WatchedWithdrawal.feeRateProblem', () {
    final watched = WatchedWithdrawal.fromCompletionAnswer(_pinnedAnswer(feeRate: 4))!;

    test('must be above the rate the newest transaction pays', () {
      expect(watched.minimumNextFeeRate, 5);
      expect(watched.feeRateProblem(4), WatchedFeeRateProblem.notAboveCurrent);
      expect(watched.feeRateProblem(5), isNull);
    });

    test('refuses empty, zero and above Core\'s maximum', () {
      expect(watched.feeRateProblem(null), WatchedFeeRateProblem.invalid);
      expect(watched.feeRateProblem(0), WatchedFeeRateProblem.invalid);
      expect(watched.feeRateProblem(kWatchedWithdrawalMaxFeeRate), isNull);
      expect(watched.feeRateProblem(kWatchedWithdrawalMaxFeeRate + 1), WatchedFeeRateProblem.aboveMaximum);
    });
  });

  group('watchedWithdrawalFeeBumpData', () {
    test('a fee raise names VBTCWithdrawalFeeBump() as Core builds it', () {
      expect(
        watchedWithdrawalFeeBumpData(scIdentifier: 'sc-1', withdrawalRequestHash: 'req-1', feeRate: 12, release: false),
        {
          'Function': 'VBTCWithdrawalFeeBump()',
          'ContractUID': 'sc-1',
          'WithdrawalRequestHash': 'req-1',
          'FeeRate': 12,
        },
      );
    });

    test('a release names VBTCWithdrawalRelease()', () {
      expect(
        watchedWithdrawalFeeBumpData(scIdentifier: 'sc-1', withdrawalRequestHash: 'req-1', feeRate: 12, release: true)['Function'],
        'VBTCWithdrawalRelease()',
      );
    });
  });

  group('fromPinAnswer (CLI GetWithdrawalPin)', () {
    Map<String, dynamic> pinAnswer(Map<String, dynamic>? withdrawal) => {
          'Success': withdrawal != null,
          'Attested': true,
          'Message': 'Withdrawal retrieved',
          'Withdrawal': withdrawal,
        };

    test('a pinned withdrawal carries its txid as the pinned one and is not paid', () {
      final w = WatchedWithdrawal.fromPinAnswer(pinAnswer({
        'State': 'Pinned',
        'Requester': 'xA',
        'FeeRate': 8,
        'CanRaiseFee': true,
        'CanRelease': true,
        'BitcoinTxid': 'abc',
        'SettledTxid': null,
      }))!;
      expect(w.status, 'Awaiting_BTC_Confirmation');
      expect(w.paid, isFalse);
      expect(w.pinnedBtcTxHash, 'abc');
      expect(w.paidBtcTxHash, isNull);
      expect(w.feeRate, 8);
      expect(w.canRaiseFee && w.canRelease, isTrue);
    });

    test('a settled withdrawal is paid by its settled txid', () {
      final w = WatchedWithdrawal.fromPinAnswer(pinAnswer({'State': 'Settled', 'BitcoinTxid': 'def', 'SettledTxid': 'def'}))!;
      expect(w.paid, isTrue);
      expect(w.status, 'Completed');
      expect(w.bitcoinTxHash, 'def');
      expect(w.isClosed, isTrue);
    });

    test('a request not mined yet', () {
      final w = WatchedWithdrawal.fromPinAnswer(pinAnswer(null))!;
      expect(w.notMinedYet, isTrue);
      expect(w.status, 'Unknown');
    });

    test('a vault the chain does not watch', () {
      expect(WatchedWithdrawal.fromPinAnswer({'Success': false, 'Attested': false}), isNull);
    });
  });
}
