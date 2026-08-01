import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/singletons.dart';
import 'package:rbx_wallet/core/storage.dart';
import 'package:rbx_wallet/features/btc_web/services/pending_frost_signing_job_service.dart';

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

/// Storage that accepts the call and rejects afterwards, which is how
/// IndexedDB reports a quota or private-browsing failure.
class _AsyncUnwritableStorage extends _FakeStorage {
  @override
  Future<void> setMap(String key, Map<String, dynamic> value) {
    return Future.delayed(
      const Duration(milliseconds: 1),
      () => throw StateError('quota exceeded'),
    );
  }
}

PendingFrostSigningJob _job({
  String requestHash = 'req-1',
  String jobId = 'job-1',
  double amount = 0.25,
}) {
  return PendingFrostSigningJob(
    scIdentifier: 'sc-1',
    requestHash: requestHash,
    jobId: jobId,
    amount: amount,
    btcDestination: 'bc1qdestination',
    fromAddress: 'RAddress1',
    createdAt: DateTime(2026, 8, 1, 9),
  );
}

void main() {
  late PendingFrostSigningJobService service;

  setUp(() async {
    await singleton.reset();
    singleton.registerSingleton<Storage>(_FakeStorage());
    service = PendingFrostSigningJobService();
  });

  group('PendingFrostSigningJob', () {
    test('survives a JSON round trip', () {
      final original = _job();
      final restored = PendingFrostSigningJob.fromJson(original.toJson());

      expect(restored.scIdentifier, original.scIdentifier);
      expect(restored.requestHash, original.requestHash);
      expect(restored.jobId, original.jobId);
      expect(restored.amount, original.amount);
      expect(restored.btcDestination, original.btcDestination);
      expect(restored.fromAddress, original.fromAddress);
      expect(restored.createdAt, original.createdAt);
    });

    test('tolerates an integer amount from storage', () {
      final restored = PendingFrostSigningJob.fromJson({
        'sc_identifier': 'sc-1',
        'request_hash': 'req-1',
        'job_id': 'job-1',
        'amount': 1,
        'btc_destination': 'bc1q',
        'from_address': 'RAddress1',
        'created_at': '2026-08-01T09:00:00.000',
      });

      expect(restored.amount, 1.0);
    });
  });

  group('PendingFrostSigningJobService', () {
    test('returns null for a request with no signing job', () {
      expect(service.get('nope'), isNull);
    });

    test('records the job id a resumed poll needs', () async {
      await service.record(_job());

      final stored = service.get('req-1');
      expect(stored, isNotNull);
      // Amount and destination come back too: a resumed poll settles the
      // withdrawal without re-running prepare, which would start a second
      // ceremony the validators refuse for 24 hours.
      expect(stored!.jobId, 'job-1');
      expect(stored.amount, 0.25);
      expect(stored.btcDestination, 'bc1qdestination');
    });

    test('clear removes only the finished request', () async {
      await service.record(_job(requestHash: 'req-1'));
      await service.record(_job(requestHash: 'req-2', jobId: 'job-2'));

      await service.clear('req-1');

      expect(service.get('req-1'), isNull);
      expect(service.get('req-2'), isNotNull);
    });

    test('re-recording the same hash overwrites rather than duplicates',
        () async {
      await service.record(_job(jobId: 'job-old'));
      await service.record(_job(jobId: 'job-new'));

      expect(service.get('req-1')!.jobId, 'job-new');
    });

    test('record reports success when the write lands', () async {
      expect(await service.record(_job()), isTrue);
    });

    test('record reports failure when the write rejects asynchronously',
        () async {
      await singleton.reset();
      singleton.registerSingleton<Storage>(_AsyncUnwritableStorage());
      final failing = PendingFrostSigningJobService();

      // Must be false: without a durable job id the caller has to keep the
      // user on the page, because nothing can resume the signing poll.
      expect(await failing.record(_job()), isFalse);
      expect(failing.get('req-1'), isNull);
    });

    test('a malformed entry does not break the readable ones', () async {
      await singleton<Storage>().setMap(
        Storage.PENDING_VBTC_FROST_SIGNING_JOBS,
        {
          'broken': 'not-a-map',
          'req-1': _job().toJson(),
        },
      );

      expect(service.get('broken'), isNull);
      expect(service.get('req-1')!.jobId, 'job-1');
    });
  });
}
