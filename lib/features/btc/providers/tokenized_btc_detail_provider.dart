import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tokenized_bitcoin.dart';
import 'tokenized_bitcoin_list_provider.dart';

import 'package:collection/collection.dart';

/// Looks up a token by "smartContractUid|rbxAddress" key to avoid
/// ID collisions between V1 and V2 tokens.
final tokenizedBtcDetailProvider = Provider.family<TokenizedBitcoin?, String>((ref, arg) {
  final separatorIndex = arg.indexOf('|');
  if (separatorIndex == -1) return null;
  final scUid = arg.substring(0, separatorIndex);
  final address = arg.substring(separatorIndex + 1);
  return ref.watch(tokenizedBitcoinListProvider).firstWhereOrNull(
    (t) => t.smartContractUid == scUid && t.rbxAddress == address,
  );
});
