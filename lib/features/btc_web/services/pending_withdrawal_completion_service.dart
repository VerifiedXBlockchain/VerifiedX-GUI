import '../../../core/singletons.dart';
import '../../../core/storage.dart';

/// A vBTC V2 withdrawal whose Bitcoin transaction has been broadcast but whose
/// Type 28 completion transaction has not yet been recorded on the VFX chain.
///
/// The BTC broadcast and the completion TX are two separate network calls. If
/// the browser tab dies between them — or the completion TX send fails — the
/// coins have left the vault with nothing on chain to settle the withdrawal.
/// Persisting the pair lets us finish the job on a later session instead of
/// re-running FROST against already-spent inputs.
class PendingWithdrawalCompletion {
  final String scIdentifier;
  final String requestHash;
  final String btcTxHash;
  final double amount;
  final String btcDestination;
  final String fromAddress;
  final DateTime createdAt;

  const PendingWithdrawalCompletion({
    required this.scIdentifier,
    required this.requestHash,
    required this.btcTxHash,
    required this.amount,
    required this.btcDestination,
    required this.fromAddress,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'sc_identifier': scIdentifier,
        'request_hash': requestHash,
        'btc_tx_hash': btcTxHash,
        'amount': amount,
        'btc_destination': btcDestination,
        'from_address': fromAddress,
        'created_at': createdAt.toIso8601String(),
      };

  factory PendingWithdrawalCompletion.fromJson(Map<String, dynamic> json) {
    return PendingWithdrawalCompletion(
      scIdentifier: json['sc_identifier'] ?? '',
      requestHash: json['request_hash'] ?? '',
      btcTxHash: json['btc_tx_hash'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      btcDestination: json['btc_destination'] ?? '',
      fromAddress: json['from_address'] ?? '',
      createdAt:
          DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class PendingWithdrawalCompletionService {
  static const _key = Storage.PENDING_VBTC_WITHDRAWAL_COMPLETIONS;

  Map<String, dynamic> _readRaw() {
    try {
      return singleton<Storage>().getMap(_key) ?? {};
    } catch (e) {
      print("Failed to read pending withdrawal completions: $e");
      return {};
    }
  }

  /// Awaits the write. Storage backends reject asynchronously — an IndexedDB
  /// quota or private-browsing failure surfaces after `setMap` returns — so
  /// without the await this reports success for a record that never landed.
  Future<bool> _writeRaw(Map<String, dynamic> data) async {
    try {
      await singleton<Storage>().setMap(_key, data);
      return true;
    } catch (e) {
      print("Failed to persist pending withdrawal completions: $e");
      return false;
    }
  }

  /// Record that [btcTxHash] was broadcast for [requestHash] but not yet
  /// settled on the VFX chain. Call this immediately after a successful BTC
  /// broadcast, before attempting the completion TX.
  ///
  /// Returns false if the record could not be persisted. Callers must not
  /// ignore that: without it there is no durable reference to the broadcast
  /// Bitcoin transaction, so the withdrawal cannot be recovered in a later
  /// session and must be finished — or at least surfaced — now.
  Future<bool> record(PendingWithdrawalCompletion entry) {
    final data = _readRaw();
    data[entry.requestHash] = entry.toJson();
    return _writeRaw(data);
  }

  PendingWithdrawalCompletion? get(String requestHash) {
    final raw = _readRaw()[requestHash];
    if (raw == null) return null;
    try {
      return PendingWithdrawalCompletion.fromJson(
          Map<String, dynamic>.from(raw));
    } catch (e) {
      print("Failed to parse pending withdrawal completion: $e");
      return null;
    }
  }

  /// All unrecorded completions, newest first.
  List<PendingWithdrawalCompletion> all() {
    final entries = <PendingWithdrawalCompletion>[];
    for (final raw in _readRaw().values) {
      try {
        entries.add(
            PendingWithdrawalCompletion.fromJson(Map<String, dynamic>.from(raw)));
      } catch (e) {
        print("Skipping malformed pending withdrawal completion: $e");
      }
    }
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }

  List<PendingWithdrawalCompletion> forAddress(String? address) {
    if (address == null) return [];
    return all().where((e) => e.fromAddress == address).toList();
  }

  /// Drop the record once the completion TX is on chain.
  Future<void> clear(String requestHash) async {
    final data = _readRaw();
    if (data.remove(requestHash) != null) {
      await _writeRaw(data);
    }
  }
}
