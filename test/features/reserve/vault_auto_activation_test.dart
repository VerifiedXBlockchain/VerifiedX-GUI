import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/reserve/providers/pending_activation_provider.dart';
import 'package:rbx_wallet/features/reserve/providers/ra_auto_activate_provider.dart';
import 'package:rbx_wallet/features/wallet/models/wallet.dart';

Wallet vault(String address, {double available = 0, bool activated = false}) {
  return Wallet(
    id: 0,
    publicKey: 'pub',
    address: address,
    balance: available,
    isValidating: false,
    recoveryAddress: 'xRecovery',
    availableBalance: available,
    isNetworkProtected: activated,
  );
}

void main() {
  final queuedAt = DateTime(2026, 9, 27, 12);

  Map<String, dynamic> entry(String address, [DateTime? at]) {
    return {'address': address, 'password': 'pw', 'queuedAt': at ?? queuedAt};
  }

  group('sweepAutoActivations', () {
    test('a funded Vault is due even though its funding tx was never matched', () {
      final result = sweepAutoActivations(
        {'fundHash': entry('xD')},
        [vault('xD', available: 5)],
        now: queuedAt.add(const Duration(seconds: 20)),
      );
      expect(result.due, ['fundHash']);
      expect(result.stale, isEmpty);
    });

    test('an unfunded Vault waits', () {
      final result = sweepAutoActivations(
        {'fundHash': entry('xD')},
        [vault('xD', available: 4.9)],
        now: queuedAt.add(const Duration(minutes: 5)),
      );
      expect(result.due, isEmpty);
      expect(result.stale, isEmpty);
    });

    test('a Vault not loaded yet waits', () {
      final result = sweepAutoActivations({'fundHash': entry('xD')}, [], now: queuedAt);
      expect(result.due, isEmpty);
      expect(result.stale, isEmpty);
    });

    test('an already activated Vault is stale', () {
      final result = sweepAutoActivations(
        {'fundHash': entry('xD')},
        [vault('xD', available: 5, activated: true)],
        now: queuedAt,
      );
      expect(result.due, isEmpty);
      expect(result.stale, ['fundHash']);
    });

    test('a Vault still unfunded after the expiry is stale', () {
      final result = sweepAutoActivations(
        {'fundHash': entry('xD')},
        [vault('xD')],
        now: queuedAt.add(AUTO_ACTIVATE_EXPIRY + const Duration(seconds: 1)),
      );
      expect(result.due, isEmpty);
      expect(result.stale, ['fundHash']);
    });
  });

  group('ReserveAccountAutoActivateProvider', () {
    test('sweep drops stale entries, keeps due ones for the caller and exposes queued addresses', () {
      final provider = ReserveAccountAutoActivateProvider(now: () => queuedAt);
      provider.add('dueHash', 'xD', 'pw');
      provider.add('waitHash', 'xE', 'pw');
      provider.add('doneHash', 'xF', 'pw');

      final due = provider.sweep([
        vault('xD', available: 5),
        vault('xE'),
        vault('xF', available: 5, activated: true),
      ]);

      expect(due, ['dueHash']);
      expect(provider.debugState.keys, unorderedEquals(['dueHash', 'waitHash']));
      expect(provider.queuedAddresses, {'xD', 'xE'});
    });

    test('entries queued without a password (web) keep their address', () {
      final provider = ReserveAccountAutoActivateProvider(now: () => queuedAt);
      provider.add('webHash', 'xW', '');
      expect(provider.debugState['webHash']['address'], 'xW');
      expect(provider.debugState['webHash']['password'], '');
    });
  });

  group('PendingActivationProvider', () {
    late DateTime now;
    late PendingActivationProvider provider;

    setUp(() {
      now = queuedAt;
      provider = PendingActivationProvider(now: () => now);
    });

    test('clears a Vault once it is activated', () {
      provider.addId('xD');
      provider.prune([vault('xD', activated: true)]);
      expect(provider.debugState, isEmpty);
    });

    test('keeps a recent id and a queued one past the expiry', () {
      provider.addId('xD');
      provider.addId('xE');

      now = queuedAt.add(const Duration(minutes: 1));
      provider.prune([vault('xD'), vault('xE')]);
      expect(provider.debugState, ['xD', 'xE']);

      now = queuedAt.add(PENDING_ACTIVATION_EXPIRY + const Duration(seconds: 1));
      provider.prune([vault('xD'), vault('xE')], queuedAddresses: {'xE'});
      expect(provider.debugState, ['xE']);
    });

    test('re-adding an id restarts its window without duplicating it', () {
      provider.addId('xD');
      now = queuedAt.add(PENDING_ACTIVATION_EXPIRY);
      provider.addId('xD');
      now = queuedAt.add(PENDING_ACTIVATION_EXPIRY + const Duration(minutes: 1));
      provider.prune([vault('xD')]);
      expect(provider.debugState, ['xD']);
    });

    test('removeId brings the manual activate path back at once', () {
      provider.addId('xD');
      provider.removeId('xD');
      expect(provider.debugState, isEmpty);
    });
  });
}
