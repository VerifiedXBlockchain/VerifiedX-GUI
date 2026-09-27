import 'dart:convert';


import '../../../core/services/base_service.dart';
import '../models/transaction.dart';

class LocalTransactionService extends BaseService {
  LocalTransactionService() : super(apiBasePathOverride: "/txapi/TXV1");

  Future<List<Transaction>> _transactions(String path) async {
    final response = await getText(path);

    if (response.isEmpty) {
      return [];
    }

    if (response == "FAIL") {
      return [];
    }

    if (response == "No TX") {
      return [];
    }

    final items = jsonDecode(response);

    final List<Transaction> transactions = [];
    for (final item in items) {
      transactions.add(Transaction.fromJson(item));
    }

    // Deduplicate by hash — prefer entries with a valid status
    final Map<String, Transaction> deduped = {};
    for (final tx in transactions) {
      final existing = deduped[tx.hash];
      if (existing == null || (existing.status == null && tx.status != null)) {
        deduped[tx.hash] = tx;
      }
    }

    return deduped.values.toList().reversed.toList();
  }

  Future<List<Transaction>> transactionsAll() async {
    return await _transactions('/GetAllLocalTX');
  }

  Future<List<Transaction>> transactionsSuccess() async {
    return await _transactions('/GetSuccessfulLocalTX');
  }

  Future<List<Transaction>> transactionsFailed() async {
    return await _transactions('/GetFailedLocalTX');
  }

  Future<List<Transaction>> transactionsPending() async {
    return await _transactions('/GetPendingLocalTX');
  }

  Future<List<Transaction>> transactionsMined() async {
    List<Transaction> mined = await _transactions('/GetMinedLocalTX');
    mined.sort((a, b) => b.height.compareTo(a.height));
    return mined;
  }

  Future<List<Transaction>> transactionsReserved() async {
    return await _transactions('/GetReserveLocalTX');
  }

  /// The fee the CLI charges for a plain VFX transfer of [amount]
  /// (TXV1 GetRawTxFee). The CLI sizes the fee from the serialized
  /// transaction, filling the nonce itself, so the quote matches what
  /// SendTransaction will charge. Null when the CLI cannot quote it.
  Future<double?> vfxTransferFee({
    required String fromAddress,
    required String toAddress,
    required double amount,
  }) async {
    try {
      final response = await postJson(
        '/GetRawTxFee',
        params: {
          'Timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'FromAddress': fromAddress,
          'ToAddress': toAddress,
          'Amount': amount,
          'Fee': 0,
          'Nonce': 0,
          'TransactionType': 0,
          'Data': null,
        },
      );
      final data = response['data'];
      if (data is Map && data['Result'] == 'Success' && data['Fee'] is num) {
        return (data['Fee'] as num).toDouble();
      }
      print("GetRawTxFee did not return a fee: $data");
      return null;
    } catch (e) {
      print("GetRawTxFee failed: $e");
      return null;
    }
  }
}
