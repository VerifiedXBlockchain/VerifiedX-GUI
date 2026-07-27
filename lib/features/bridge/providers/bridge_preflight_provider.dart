import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bridge_preflight.dart';
import '../services/vbtc_bridge_service.dart';

/// Composite argument for [bridgePreflightProvider].
///
/// Dart 2.x doesn't have records (records require Dart 3, this project is
/// pinned to `>=2.17.3 <3.0.0`), so we hand-roll equality. Riverpod's family
/// caching relies on `==`/`hashCode` to match keys, so this is required for
/// the provider to dedupe correctly.
@immutable
class BridgePreflightArgs {
  final String ownerAddress;
  final String scUid;

  const BridgePreflightArgs({
    required this.ownerAddress,
    required this.scUid,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BridgePreflightArgs &&
          other.ownerAddress == ownerAddress &&
          other.scUid == scUid);

  @override
  int get hashCode => Object.hash(ownerAddress, scUid);

  @override
  String toString() => 'BridgePreflightArgs($ownerAddress, $scUid)';
}

/// One-shot fetch of bridge preflight info for a given owner + contract.
///
/// Re-invoking with the same key returns the cached value; call
/// `ref.refresh(bridgePreflightProvider(args))` to force a re-fetch
/// (used by the dialog's "Retry" state when preflight fails).
final bridgePreflightProvider =
    FutureProvider.family<BridgePreflight?, BridgePreflightArgs>(
  (ref, args) async {
    debugPrint('[vBTC-Bridge] preflightProvider fetch for $args');
    return VbtcBridgeService().preflight(args.ownerAddress, args.scUid);
  },
);
