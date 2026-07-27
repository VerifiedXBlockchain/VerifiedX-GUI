import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bridge_lock_record.dart';
import 'bridge_lock_list_provider.dart';

/// Non-terminal bridge operations for a given owner.
///
/// Derived from [bridgeLockListProvider] — keyed by `ownerAddress` so this can
/// be watched anywhere the active wallet's address is known (badge counts,
/// global "you have bridges in flight" indicators, notification triggers).
///
/// Returns an empty list if `ownerAddress` is empty so callers can pass a
/// nullable address with `?? ''` without an extra guard.
final activeBridgeOperationsProvider =
    Provider.family<List<BridgeLockRecord>, String>((ref, ownerAddress) {
  if (ownerAddress.isEmpty) return const [];
  final list = ref.watch(bridgeLockListProvider(ownerAddress));
  return list.where((r) => !r.isTerminal).toList(growable: false);
});
