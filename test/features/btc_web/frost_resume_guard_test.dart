import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/btc_web/services/frost_resume_guard.dart';

Map<String, dynamic> _row({
  String status = 'requested',
  String? signedAt,
  String btcTransactionHash = '',
}) {
  return {
    'id': 1,
    'requestor_address': 'RAddress1',
    'btc_address': 'bc1qdestination',
    'amount': 0.25,
    'fee_rate': 4.0,
    'btc_transaction_hash': btcTransactionHash,
    'status': status,
    'signed_at': signedAt,
    'request_transaction_hash': 'req-1',
    'completion_transaction_hash': null,
    'created_at': '2026-08-01T09:00:00Z',
    'completed_at': null,
  };
}

void main() {
  group('frostResumeActionFor', () {
    // The scenario the guard exists for. Nothing local survives — different
    // device, or cleared storage — so the explorer's row is the only account
    // of what already happened, and it says FROST produced a signed Bitcoin
    // transaction. Starting another ceremony can pay the withdrawal twice.
    test('never starts a ceremony for a signed withdrawal on a fresh device',
        () {
      final action = frostResumeActionFor(
        _row(status: 'pending_btc', signedAt: '2026-08-01T09:04:12Z'),
      );

      expect(action, isNot(FrostResumeAction.ceremony));
      expect(action, FrostResumeAction.refuse);
    });

    test('fails closed when pending_btc carries no signed_at', () {
      // An explorer with the status but not yet the field. A missing timestamp
      // is not evidence that nothing was signed, so this must not fall through
      // to a ceremony.
      expect(
        frostResumeActionFor(_row(status: 'pending_btc')),
        isNot(FrostResumeAction.ceremony),
      );
      expect(
        frostResumeActionFor(_row(status: 'pending_btc', signedAt: '')),
        isNot(FrostResumeAction.ceremony),
      );
      expect(
        frostResumeActionFor({'status': 'pending_btc'}),
        FrostResumeAction.refuse,
      );
    });

    test('fails closed on signed_at alone, whatever the status says', () {
      // Either signal is sufficient on its own: a row that was signed but
      // whose status has not caught up must not be re-signed.
      expect(
        frostResumeActionFor(
          _row(status: 'requested', signedAt: '2026-08-01T09:04:12Z'),
        ),
        FrostResumeAction.refuse,
      );
    });

    test('reads the status case-insensitively', () {
      expect(
        frostResumeActionFor(_row(status: 'Pending_BTC')),
        FrostResumeAction.refuse,
      );
      expect(
        frostResumeActionFor(_row(status: ' pending_btc ')),
        FrostResumeAction.refuse,
      );
    });

    test('settles without signing when the row names the Bitcoin transaction',
        () {
      expect(
        frostResumeActionFor(_row(
          status: 'pending_btc',
          signedAt: '2026-08-01T09:04:12Z',
          btcTransactionHash: 'abc123',
        )),
        FrostResumeAction.completionOnly,
      );
    });

    test('allows a ceremony for a request that has not been signed', () {
      // The ordinary first-time path: the request is on chain, nothing local
      // exists yet because nothing has happened yet.
      expect(
        frostResumeActionFor(_row(status: 'requested')),
        FrostResumeAction.ceremony,
      );
    });

    test('allows a ceremony when the row could not be read', () {
      // Every first-time withdrawal arrives here with no local record, so a
      // transient explorer failure must not block the ordinary path.
      expect(frostResumeActionFor(null), FrostResumeAction.ceremony);
    });

    test('allows a ceremony for settled states and junk values', () {
      expect(
        frostResumeActionFor(_row(status: 'completed')),
        FrostResumeAction.ceremony,
      );
      expect(
        frostResumeActionFor(_row(status: 'cancelled')),
        FrostResumeAction.ceremony,
      );
      expect(frostResumeActionFor({}), FrostResumeAction.ceremony);
      expect(
        frostResumeActionFor({'status': 7, 'signed_at': 7}),
        FrostResumeAction.ceremony,
      );
    });
  });
}
