import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/explorer_service.dart';
import '../models/web_transaction.dart';

// autoDispose plus the invalidate in WebSessionProvider.loop() keep an open
// detail screen current (a pending tx moves to confirmed) and refetch on re-entry.
final webTransactionDetailProvider = FutureProvider.autoDispose.family<WebTransaction?, String>((ref, String hash) async {
  return ExplorerService().retrieveTransaction(hash);
});
