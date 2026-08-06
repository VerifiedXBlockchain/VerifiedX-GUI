import '../../../core/singletons.dart';
import '../../../core/storage.dart';

/// A FROST signing job that was started for a vBTC V2 withdrawal and has not
/// produced a broadcastable Bitcoin transaction yet.
///
/// Signing is asynchronous: the API hands back a job id and the wallet polls it
/// for up to three minutes. That id exists only in the tab that started the
/// ceremony, so closing the tab loses the only handle on a signing run that may
/// already have succeeded — leaving the withdrawal signed but unbroadcast,
/// with the validators refusing to sign it again for 24 hours. Persisting the
/// id lets a later session pick the same poll back up instead of asking for a
/// ceremony that will be refused.
class PendingFrostSigningJob {
  final String scIdentifier;
  final String requestHash;
  final String jobId;
  final double amount;
  final String btcDestination;
  final String fromAddress;
  final DateTime createdAt;

  const PendingFrostSigningJob({
    required this.scIdentifier,
    required this.requestHash,
    required this.jobId,
    required this.amount,
    required this.btcDestination,
    required this.fromAddress,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'sc_identifier': scIdentifier,
        'request_hash': requestHash,
        'job_id': jobId,
        'amount': amount,
        'btc_destination': btcDestination,
        'from_address': fromAddress,
        'created_at': createdAt.toIso8601String(),
      };

  factory PendingFrostSigningJob.fromJson(Map<String, dynamic> json) {
    return PendingFrostSigningJob(
      scIdentifier: json['sc_identifier'] ?? '',
      requestHash: json['request_hash'] ?? '',
      jobId: json['job_id'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      btcDestination: json['btc_destination'] ?? '',
      fromAddress: json['from_address'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class PendingFrostSigningJobService {
  static const _key = Storage.PENDING_VBTC_FROST_SIGNING_JOBS;

  Map<String, dynamic> _readRaw() {
    try {
      return singleton<Storage>().getMap(_key) ?? {};
    } catch (e) {
      print("Failed to read pending FROST signing jobs: $e");
      return {};
    }
  }

  Future<bool> _writeRaw(Map<String, dynamic> data) async {
    try {
      await singleton<Storage>().setMap(_key, data);
      return true;
    } catch (e) {
      print("Failed to persist pending FROST signing jobs: $e");
      return false;
    }
  }

  /// Record [entry] before polling starts, so the job survives the tab.
  ///
  /// Returns false if the write did not land. A withdrawal signed under a job
  /// id nobody kept cannot be resumed, so callers should tell the user to stay
  /// on the page rather than treat the ceremony as recoverable.
  Future<bool> record(PendingFrostSigningJob entry) {
    final data = _readRaw();
    data[entry.requestHash] = entry.toJson();
    return _writeRaw(data);
  }

  PendingFrostSigningJob? get(String requestHash) {
    final raw = _readRaw()[requestHash];
    if (raw == null) return null;
    try {
      return PendingFrostSigningJob.fromJson(Map<String, dynamic>.from(raw));
    } catch (e) {
      print("Failed to parse pending FROST signing job: $e");
      return null;
    }
  }

  /// Drop the job once it can no longer tell us anything — the Bitcoin
  /// transaction was broadcast, signing failed outright, or the API no longer
  /// knows the id.
  Future<void> clear(String requestHash) async {
    final data = _readRaw();
    if (data.remove(requestHash) != null) {
      await _writeRaw(data);
    }
  }
}
