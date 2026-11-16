import 'package:dio/dio.dart';

import '../../../core/services/base_service.dart';
import '../utils/p2p_amount.dart';
import 'p2p_chain_error.dart';

/// Quotes the network fee of a transaction with these fields.
abstract class P2pFeeQuoter {
  /// The fee for a transaction of [type] from [from] to [to] moving
  /// [amount], carrying [data] and stamped [timestamp] (Unix seconds).
  /// Throws a [P2pChainError] when no fee can be quoted.
  Future<P2pAmount> quote({
    required String from,
    required String to,
    required P2pAmount amount,
    required int type,
    required Map<String, dynamic> data,
    required int timestamp,
  });
}

/// Core's own quote (`TXV1 GetRawTxFee`): the fee Core computes from the
/// size of the transaction with these fields. A calculation: Core builds
/// nothing it keeps, signs nothing and sends nothing, and it answers while
/// the wallet is locked.
class P2pCoreFeeQuoter extends BaseService implements P2pFeeQuoter {
  P2pCoreFeeQuoter() : super(apiBasePathOverride: "/txapi/TXV1");

  @override
  Future<P2pAmount> quote({
    required String from,
    required String to,
    required P2pAmount amount,
    required int type,
    required Map<String, dynamic> data,
    required int timestamp,
  }) async {
    final Map<String, dynamic> response;
    try {
      response = await postJson(
        '/GetRawTxFee',
        params: {
          'Timestamp': timestamp,
          'FromAddress': from,
          'ToAddress': to,
          'Amount': amount.toJsonNumber(),
          'Fee': 0,
          'Nonce': 0,
          'TransactionType': type,
          // Core serialises this object into the transaction's Data string.
          'Data': data,
        },
      );
    } on DioException {
      throw const P2pChainError(P2pChainFailure.feeUnavailable);
    } on FormatException {
      throw const P2pChainError(P2pChainFailure.feeUnavailable);
    }
    final answer = response['data'];
    final fee = answer is Map ? answer['Fee'] : null;
    if (answer is! Map || answer['Result'] != 'Success' || fee is! num || fee <= 0) {
      throw const P2pChainError(P2pChainFailure.feeUnavailable);
    }
    return P2pAmount.fromDoubleRoundedUp(fee.toDouble());
  }
}
