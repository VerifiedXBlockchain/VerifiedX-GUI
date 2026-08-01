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
  void setMap(String key, Map<String, dynamic> value) => _data[key] = value;

  @override
  List<dynamic>? getList(String key) => _data[key];
  @override
  void setList(String key, List<dynamic> value) => _data[key] = value;

  @override
  List<String>? getStringList(String key) => _data[key];
  @override
  void setStringList(String key, List<String> value) => _data[key] = value;
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
    test('accepts both spellings the API has used', () {
      expect(withdrawalIsResumable({'status': 'pending'}), isTrue);
      expect(withdrawalIsResumable({'status': 'requested'}), isTrue);
    });

    test('rejects settled and unknown states', () {
      expect(withdrawalIsResumable({'status': 'completed'}), isFalse);
      expect(withdrawalIsResumable({'status': 'cancelled'}), isFalse);
      expect(withdrawalIsResumable({}), isFalse);
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

    test('records and reads back a broadcast BTC transaction', () {
      service.record(_entry());

      final stored = service.get('req-1');
      expect(stored, isNotNull);
      expect(stored!.btcTxHash, 'btc-1');
      expect(stored.amount, 0.5);
    });

    test('clear removes only the settled request', () {
      service.record(_entry(requestHash: 'req-1'));
      service.record(_entry(requestHash: 'req-2', btcTxHash: 'btc-2'));

      service.clear('req-1');

      expect(service.get('req-1'), isNull);
      expect(service.get('req-2'), isNotNull);
    });

    test('re-recording the same hash overwrites rather than duplicates', () {
      service.record(_entry(btcTxHash: 'btc-old'));
      service.record(_entry(btcTxHash: 'btc-new'));

      expect(service.all().length, 1);
      expect(service.get('req-1')!.btcTxHash, 'btc-new');
    });

    test('all() returns newest first', () {
      service.record(_entry(
        requestHash: 'older',
        createdAt: DateTime(2026, 7, 30),
      ));
      service.record(_entry(
        requestHash: 'newer',
        createdAt: DateTime(2026, 7, 31),
      ));

      expect(service.all().map((e) => e.requestHash), ['newer', 'older']);
    });

    test('forAddress filters to the signing wallet', () {
      service.record(_entry(requestHash: 'mine', fromAddress: 'RMine'));
      service.record(_entry(requestHash: 'theirs', fromAddress: 'RTheirs'));

      expect(service.forAddress('RMine').map((e) => e.requestHash), ['mine']);
      expect(service.forAddress(null), isEmpty);
    });

    test('a malformed entry does not hide the valid ones', () {
      singleton<Storage>().setMap(
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
