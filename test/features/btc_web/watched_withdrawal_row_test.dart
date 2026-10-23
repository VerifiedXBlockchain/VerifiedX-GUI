import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/btc_web/models/btc_web_vbtc_token.dart';

void main() {
  Map<String, dynamic> row({String status = 'requested', String? pinState, bool? releasing}) => {
        'status': status,
        'pin_state': pinState,
        'releasing': releasing,
      };

  group('withdrawalRowCanCancel', () {
    test('a watched request is cancellable only while it waits for its Bitcoin transaction', () {
      expect(withdrawalRowCanCancel(row(pinState: 'Waiting'), vaultIsWatched: true), isTrue);
      expect(withdrawalRowCanCancel(row(pinState: 'Pinned'), vaultIsWatched: true), isFalse);
      expect(withdrawalRowCanCancel(row(pinState: 'Pinned', releasing: true), vaultIsWatched: true), isFalse);
    });

    test('a watched request whose pin state is not known yet offers no cancel', () {
      expect(withdrawalRowCanCancel(row(), vaultIsWatched: true), isFalse);
    });

    test('a pin state alone marks the vault as watched', () {
      expect(withdrawalRowCanCancel(row(pinState: 'Pinned'), vaultIsWatched: false), isFalse);
    });

    test('a FROST vault keeps its cancel for an open request', () {
      expect(withdrawalRowCanCancel(row(), vaultIsWatched: false), isTrue);
      expect(withdrawalRowCanCancel(row(status: 'completed'), vaultIsWatched: false), isFalse);
    });
  });

  test('watchedRowState reads the pin state and a release', () {
    expect(watchedRowState(row(pinState: 'Waiting')), WatchedRowState.waiting);
    expect(watchedRowState(row(pinState: 'pinned')), WatchedRowState.pinned);
    expect(watchedRowState(row(pinState: 'Pinned', releasing: true)), WatchedRowState.releasing);
    expect(watchedRowState(row()), WatchedRowState.unknown);
  });
}
