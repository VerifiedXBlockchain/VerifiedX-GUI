import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/explorer_service.dart';
import '../models/web_block.dart';

class WebLatestBlockProvider extends StateNotifier<WebBlock?> {
  final Ref ref;

  /// When [state] was last read from the explorer.
  DateTime? fetchedAt;

  WebLatestBlockProvider(this.ref) : super(null) {
    _init();
  }

  void _init() {
    _update();
  }

  Future<void> _update() async {
    final block = await ExplorerService().getLatestBlock();

    if (block != null) {
      fetchedAt = DateTime.now();
      state = block;
    }

    await Future.delayed(const Duration(seconds: 30));
    _update();
  }
}

final webLatestBlockProvider = StateNotifierProvider<WebLatestBlockProvider, WebBlock?>(
  (ref) => WebLatestBlockProvider(ref),
);

/// How old the last polled block may be and still stand in for a fresh read:
/// about five blocks. Near an activation height an older one could make the
/// wallet sign for the rules before it, which the node then refuses.
const kMaxCachedBlockAge = Duration(seconds: 60);

/// [cachedHeight] when it was fetched within [kMaxCachedBlockAge] of [now],
/// otherwise null.
int? freshCachedHeight({required int? cachedHeight, required DateTime? fetchedAt, required DateTime now}) {
  if (cachedHeight == null || fetchedAt == null) return null;
  return now.difference(fetchedAt) <= kMaxCachedBlockAge ? cachedHeight : null;
}

/// The chain's latest block height, read fresh from the explorer and falling
/// back to the last polled block while it is recent. Null when neither is
/// known, which callers report as "height unknown".
Future<int?> fetchWebLatestBlockHeight(WidgetRef ref) async {
  final block = await ExplorerService().getLatestBlock();
  if (block != null) return block.height;
  return freshCachedHeight(
    cachedHeight: ref.read(webLatestBlockProvider)?.height,
    fetchedAt: ref.read(webLatestBlockProvider.notifier).fetchedAt,
    now: DateTime.now(),
  );
}
