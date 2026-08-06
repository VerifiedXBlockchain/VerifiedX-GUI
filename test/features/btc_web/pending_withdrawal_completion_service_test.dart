import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/singletons.dart';
import 'package:rbx_wallet/core/storage.dart';
import 'package:rbx_wallet/features/btc_web/models/btc_web_vbtc_token.dart';
import 'package:rbx_wallet/features/btc_web/services/pending_withdrawal_completion_service.dart';

/// In-memory [Storage] so the service can be exercised without Hive or
/// SharedPreferences.
class _FakeStorage extends Storage {
  final Map<String, dynamic> _data = {};

  @override
  Future<void> init() async {
    isInitialized = true;
  }

  @override
  void remove(String key) => _data.remove(key);

  @override
  String? getString(String key) => _data[key];
  @override
  void setString(String key, String value) => _data[key] = value;

  @override
  bool? getBool(String key) => _data[key];
  @override
  void setBool(String key, bool value) => _data[key] = value;

  @override
  int? getInt(String key) => _data[key];
  @override
  void setInt(String key, int value) => _data[key] = value;

  @override
  Map<String, dynamic>? getMap(String key) => _data[key];
  @override
  Future<void> setMap(String key, Map<String, dynamic> value) async =>
      _data[key] = value;

  @override
  List<dynamic>? getList(String key) => _data[key];
  @override
  void setList(String key, List<dynamic> value) => _data[key] = value;

  @override
  List<String>? getStringList(String key) => _data[key];
  @override
  void setStringList(String key, List<String> value) => _data[key] = value;
}

/// Storage that rejects the write synchronously.
class _UnwritableStorage extends _FakeStorage {
  @override
  Future<void> setMap(String key, Map<String, dynamic> value) {
    throw StateError('storage unavailable');
  }
}

/// Storage that accepts the call and rejects afterwards, which is how
/// IndexedDB reports a quota or private-browsing failure. Without an await on
/// the write this rejection escapes unobserved and the record reads as saved.
class _AsyncUnwritableStorage extends _FakeStorage {
  @override
  Future<void> setMap(String key, Map<String, dynamic> value) {
    return Future.delayed(
      const Duration(milliseconds: 1),
      () => throw StateError('quota exceeded'),
    );
  }
}

PendingWithdrawalCompletion _entry({
  String requestHash = 'req-1',
  String btcTxHash = 'btc-1',
  String fromAddress = 'RAddress1',
  double amount = 0.5,
  DateTime? createdAt,
}) {
  return PendingWithdrawalCompletion(
    scIdentifier: 'sc-1',
    requestHash: requestHash,
    btcTxHash: btcTxHash,
    amount: amount,
    btcDestination: 'bc1qdestination',
    fromAddress: fromAddress,
    createdAt: createdAt ?? DateTime(2026, 7, 31, 12),
  );
}

void main() {
  late PendingWithdrawalCompletionService service;

  setUp(() async {
    await singleton.reset();
    singleton.registerSingleton<Storage>(_FakeStorage());
    service = PendingWithdrawalCompletionService();
  });

  group('withdrawalIsResumable', () {
    test('accepts the explorer states that still need completing', () {
      expect(withdrawalIsResumable({'status': 'requested'}), isTrue);
      // Signed by FROST but not settled on chain — the state the resume flow
      // exists for.
      expect(withdrawalIsResumable({'status': 'pending_btc'}), isTrue);
    });

    test('rejects settled states', () {
      expect(withdrawalIsResumable({'status': 'completed'}), isFalse);
      expect(withdrawalIsResumable({'status': 'cancelled'}), isFalse);
    });

    test('rejects a contested withdrawal', () {
      // Offering "tap to resume" on a withdrawal under a cancellation vote
      // invites the user to push it through while it is being reversed.
      expect(
        withdrawalIsResumable({'status': 'cancellation_requested'}),
        isFalse,
      );
    });

    test('rejects unknown, missing and non-string states', () {
      expect(withdrawalIsResumable({}), isFalse);
      expect(withdrawalIsResumable({'status': null}), isFalse);
      expect(withdrawalIsResumable({'status': 3}), isFalse);
      // Never emitted by any layer; it was in the set and matched nothing.
      expect(withdrawalIsResumable({'status': 'pending'}), isFalse);
    });

    test('reads the status case-insensitively', () {
      expect(withdrawalIsResumable({'status': 'Pending_BTC'}), isTrue);
      expect(withdrawalIsResumable({'status': ' Requested '}), isTrue);
      expect(withdrawalIsResumable({'status': 'Cancellation_Requested'}),
          isFalse);
    });
  });

  group('PendingWithdrawalCompletion', () {
    test('survives a JSON round trip', () {
      final original = _entry();
      final restored =
          PendingWithdrawalCompletion.fromJson(original.toJson());

      expect(restored.scIdentifier, original.scIdentifier);
      expect(restored.requestHash, original.requestHash);
      expect(restored.btcTxHash, original.btcTxHash);
      expect(restored.amount, original.amount);
      expect(restored.btcDestination, original.btcDestination);
      expect(restored.fromAddress, original.fromAddress);
      expect(restored.createdAt, original.createdAt);
    });

    test('tolerates an integer amount from storage', () {
      final restored = PendingWithdrawalCompletion.fromJson({
        'sc_identifier': 'sc-1',
        'request_hash': 'req-1',
        'btc_tx_hash': 'btc-1',
        'amount': 2,
        'btc_destination': 'bc1q',
        'from_address': 'RAddress1',
        'created_at': '2026-07-31T12:00:00.000',
      });

      expect(restored.amount, 2.0);
    });
  });

  group('PendingWithdrawalCompletionService', () {
    test('returns null for a hash that was never recorded', () {
      expect(service.get('nope'), isNull);
    });

    test('records and reads back a broadcast BTC transaction', () async {
      await service.record(_entry());

      final stored = service.get('req-1');
      expect(stored, isNotNull);
      expect(stored!.btcTxHash, 'btc-1');
      expect(stored.amount, 0.5);
    });

    test('clear removes only the settled request', () async {
      await service.record(_entry(requestHash: 'req-1'));
      await service.record(_entry(requestHash: 'req-2', btcTxHash: 'btc-2'));

      await service.clear('req-1');

      expect(service.get('req-1'), isNull);
      expect(service.get('req-2'), isNotNull);
    });

    test('re-recording the same hash overwrites rather than duplicates',
        () async {
      await service.record(_entry(btcTxHash: 'btc-old'));
      await service.record(_entry(btcTxHash: 'btc-new'));

      expect(service.all().length, 1);
      expect(service.get('req-1')!.btcTxHash, 'btc-new');
    });

    test('all() returns newest first', () async {
      await service.record(_entry(
        requestHash: 'older',
        createdAt: DateTime(2026, 7, 30),
      ));
      await service.record(_entry(
        requestHash: 'newer',
        createdAt: DateTime(2026, 7, 31),
      ));

      expect(service.all().map((e) => e.requestHash), ['newer', 'older']);
    });

    test('forAddress filters to the signing wallet', () async {
      await service.record(_entry(requestHash: 'mine', fromAddress: 'RMine'));
      await service.record(_entry(requestHash: 'theirs', fromAddress: 'RTheirs'));

      expect(service.forAddress('RMine').map((e) => e.requestHash), ['mine']);
      expect(service.forAddress(null), isEmpty);
    });

    test('record reports success when the write lands', () async {
      expect(await service.record(_entry()), isTrue);
    });

    test('record reports failure instead of swallowing a write error', () async {
      await singleton.reset();
      singleton.registerSingleton<Storage>(_UnwritableStorage());
      final failing = PendingWithdrawalCompletionService();

      // Must be false: the caller has to know there is no durable reference to
      // the broadcast BTC, otherwise a later resume re-runs FROST against
      // spent inputs or reports an unsettled withdrawal as complete.
      expect(await failing.record(_entry()), isFalse);
      expect(failing.get('req-1'), isNull);
    });

    test('record reports failure when the write rejects asynchronously',
        () async {
      await singleton.reset();
      singleton.registerSingleton<Storage>(_AsyncUnwritableStorage());
      final failing = PendingWithdrawalCompletionService();

      expect(await failing.record(_entry()), isFalse);
      expect(failing.get('req-1'), isNull);
    });

    test('a malformed entry does not hide the valid ones', () async {
      await singleton<Storage>().setMap(
        Storage.PENDING_VBTC_WITHDRAWAL_COMPLETIONS,
        {
          'broken': 'not-a-map',
          'req-1': _entry().toJson(),
        },
      );

      final all = service.all();
      expect(all.length, 1);
      expect(all.first.requestHash, 'req-1');
    });
  });
}
