import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/btc_web/services/withdrawal_in_progress_notice.dart';

void main() {
  group('isWithdrawalAlreadyInProgress', () {
    test('matches the node message verbatim', () {
      const message =
          'Transaction verification failed: A withdrawal is already in progress '
          'for contract 9f30a25e581e44ffa447267820850700:1785606126; try again '
          'once it completes.';

      expect(isWithdrawalAlreadyInProgress(message), isTrue);
    });

    test('survives a reworded prefix and a different contract', () {
      // Matched on the stable clause, so the node can change how it frames the
      // rejection without this silently falling back to a red error screen.
      expect(
        isWithdrawalAlreadyInProgress(
          'Rejected: a withdrawal is already in progress for contract abc:1',
        ),
        isTrue,
      );
    });

    test('is case-insensitive', () {
      expect(
        isWithdrawalAlreadyInProgress('A WITHDRAWAL IS ALREADY IN PROGRESS'),
        isTrue,
      );
    });

    test('does not swallow unrelated failures', () {
      // These must still reach the failure screen with their own message.
      for (final message in const [
        'Insufficient reachable validators. Have: 2, Need: 5',
        'Withdrawal request already completed',
        'Invalid start signature',
        'Not enough balance',
        '',
      ]) {
        expect(isWithdrawalAlreadyInProgress(message), isFalse, reason: message);
      }
    });

    test('handles a missing message', () {
      expect(isWithdrawalAlreadyInProgress(null), isFalse);
    });
  });
}
