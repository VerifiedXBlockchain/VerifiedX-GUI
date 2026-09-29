import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/l10n_helper.dart';
import '../../../bridge/providers/wallet_info_provider.dart';
import '../../../web/providers/web_latest_block_provider.dart';

/// The chain height evolve stages are checked against: the Core CLI's wallet
/// info on desktop, the latest Spyglass block on web. Null until it is known.
int? currentEvolveBlockHeight(Ref ref) {
  if (kIsWeb) {
    return ref.read(webLatestBlockProvider)?.height;
  }
  return ref.read(walletInfoProvider)?.blockHeight;
}

/// Validates a parsed evolve stage block height against [currentBlockHeight].
String? evolveBlockHeightError(int blockHeight, int? currentBlockHeight) {
  if (currentBlockHeight == null) {
    return globalL10n.r3aBlockHeightUnknown;
  }

  if (blockHeight <= currentBlockHeight) {
    return globalL10n.r3aBlockHeightMustBeGreaterThan(currentBlockHeight.toString());
  }

  return null;
}
