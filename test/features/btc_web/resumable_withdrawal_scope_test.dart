import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/btc_web/models/btc_web_vbtc_token.dart';
import 'package:rbx_wallet/features/nft/models/web_nft.dart';

const _owner = 'ROwnerAddress0000000000000000000';
const _holder = 'RHolderAddress000000000000000000';

Map<String, dynamic> _request({
  required String requestor,
  String status = 'requested',
  String hash = 'req-hash',
}) {
  return {
    'id': 1,
    'requestor_address': requestor,
    'btc_address': 'bc1qdestination',
    'amount': 0.0001,
    'fee_rate': 2.0,
    'status': status,
    'request_transaction_hash': hash,
    'btc_tx_hash': null,
    'completion_tx_hash': null,
  };
}

BtcWebVbtcToken _token(List<Map<String, dynamic>> requests) {
  return BtcWebVbtcToken(
    name: 'vBTC',
    description: 'test token',
    addresses: const {_owner: 0.0005, _holder: 0.0001},
    address: _owner,
    scIdentifier: 'sc:1',
    ownerAddress: _owner,
    imageUrl: '',
    depositAddress: 'bc1pdeposit',
    globalBalance: 0.0006,
    createdAt: DateTime.utc(2026, 8, 2),
    nft: WebNft.empty(),
    version: 2,
    withdrawalRequests: requests,
  );
}

void main() {
  group('resumable withdrawals are scoped to the requestor', () {
    // The bug: a shared contract holds every holder's withdrawals in one list.
    // Offering another holder's request to whoever is logged in makes the FROST
    // leader address (taken from the stored RequestorAddress) disagree with the
    // signature (made by the active wallet), so validators reject the ceremony
    // and it hangs instead of failing.
    test('a holder\'s outstanding request is not offered to the owner', () {
      final token = _token([_request(requestor: _holder)]);

      expect(token.resumableWithdrawalRequestsFor(_owner), isEmpty);
      expect(token.hasResumableWithdrawalFor(_owner), isFalse);
    });

    test('the holder is still offered their own request', () {
      final token = _token([_request(requestor: _holder)]);

      final mine = token.resumableWithdrawalRequestsFor(_holder);
      expect(mine, hasLength(1));
      expect(mine.first['requestor_address'], _holder);
      expect(token.hasResumableWithdrawalFor(_holder), isTrue);
    });

    test('each party sees only their own when both have one outstanding', () {
      final token = _token([
        _request(requestor: _owner, hash: 'owner-req'),
        _request(requestor: _holder, hash: 'holder-req'),
      ]);

      expect(
        token.resumableWithdrawalRequestsFor(_owner).single['request_transaction_hash'],
        'owner-req',
      );
      expect(
        token.resumableWithdrawalRequestsFor(_holder).single['request_transaction_hash'],
        'holder-req',
      );
    });

    test('a settled request is not resumable even for its own requestor', () {
      final token = _token([_request(requestor: _holder, status: 'completed')]);

      expect(token.resumableWithdrawalRequestsFor(_holder), isEmpty);
    });

    test('pending_btc stays resumable for its requestor', () {
      // FROST has signed but the completion is unrecorded — precisely the state
      // the requestor needs to come back and finish.
      final token = _token([_request(requestor: _holder, status: 'pending_btc')]);

      expect(token.hasResumableWithdrawalFor(_holder), isTrue);
      expect(token.hasResumableWithdrawalFor(_owner), isFalse);
    });

    test('a locked session offers nothing rather than someone else\'s request', () {
      final token = _token([_request(requestor: _holder)]);

      expect(token.resumableWithdrawalRequestsFor(null), isEmpty);
      expect(token.resumableWithdrawalRequestsFor(''), isEmpty);
    });
  });

  group('a stale request stops capturing the withdraw button', () {
    // The chain stops treating a request as the contract's active one after
    // EXPIRY_BLOCKS (360, ~72 min) and lets the next request overwrite it. Until
    // then resuming is the only way forward; after it, forcing resume traps the
    // holder on a request that may never finish.
    Map<String, dynamic> aged(Duration age) => {
          ..._request(requestor: _holder),
          'created_at': DateTime.utc(2026, 8, 2, 12, 0)
              .subtract(age)
              .toIso8601String()
              .replaceFirst('.000', ''),
        };
    final now = DateTime.utc(2026, 8, 2, 12, 0);

    test('a fresh request is still resumed', () {
      final token = _token([aged(const Duration(minutes: 5))]);

      expect(token.liveResumableWithdrawalRequestsFor(_holder, now: now), hasLength(1));
    });

    test('a request past the window no longer captures the button', () {
      final token = _token([aged(const Duration(hours: 8))]);

      expect(token.liveResumableWithdrawalRequestsFor(_holder, now: now), isEmpty);
      // Still listed, so it is not hidden — only no longer forced.
      expect(token.resumableWithdrawalRequestsFor(_holder), hasLength(1));
    });

    test('the boundary errs toward keeping it resumable', () {
      // 72 min is the real chain window; the client waits longer so it can
      // never refuse to resume a request the chain still considers live.
      final token = _token([aged(const Duration(minutes: 75))]);

      expect(token.liveResumableWithdrawalRequestsFor(_holder, now: now), hasLength(1));
    });

    test('a missing or unparseable created_at is treated as live', () {
      for (final value in [null, 'not-a-date', 42]) {
        final row = {..._request(requestor: _holder), 'created_at': value};
        expect(withdrawalIsStale(row, now: now), isFalse, reason: '$value');
      }
    });
  });
}
