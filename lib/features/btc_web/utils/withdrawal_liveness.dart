import '../../../core/services/explorer_service.dart';
import '../models/btc_web_vbtc_token.dart';

typedef LatestBlockHeightLookup = Future<int?> Function();
typedef TransactionHeightLookup = Future<int?> Function(String hash);

Future<int?> _explorerLatestBlockHeight() async => (await ExplorerService().getLatestBlock())?.height;

Future<int?> _explorerTransactionHeight(String hash) async =>
    (await ExplorerService().retrieveTransaction(hash))?.height;

/// [address]'s outstanding withdrawals on [token] that the chain still treats
/// as the contract's active one, judged by block height where the explorer can
/// supply it.
///
/// The explorer's withdrawal rows carry no height, so the current tip and each
/// request transaction's mined height are looked up here. Any lookup that
/// fails leaves that request on the wall-clock fallback in [withdrawalIsStale],
/// which errs toward keeping it resumable.
Future<List<Map<String, dynamic>>> fetchLiveResumableWithdrawals(
  BtcWebVbtcToken token,
  String? address, {
  LatestBlockHeightLookup latestBlockHeight = _explorerLatestBlockHeight,
  TransactionHeightLookup transactionHeight = _explorerTransactionHeight,
  DateTime? now,
}) async {
  final candidates = token.resumableWithdrawalRequestsFor(address);
  if (candidates.isEmpty) {
    return const [];
  }

  final currentBlockHeight = await latestBlockHeight();
  final requestBlockHeights = <String, int>{};
  if (currentBlockHeight != null) {
    for (final request in candidates) {
      final hash = request['request_transaction_hash'];
      if (hash is! String || hash.isEmpty) {
        continue;
      }
      final height = await transactionHeight(hash);
      if (height != null) {
        requestBlockHeights[hash] = height;
      }
    }
  }

  return token.liveResumableWithdrawalRequestsFor(
    address,
    now: now,
    currentBlockHeight: currentBlockHeight,
    requestBlockHeights: requestBlockHeights,
  );
}
