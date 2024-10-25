import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/web_session_provider.dart';
import '../../btc_web/providers/btc_web_vbtc_token_list_provider.dart';

final allBtcAddressesProvider = Provider((ref) {
  final List<String> addresses = [];

  final mainAddress = ref.watch(webSessionProvider.select((v) => v.btcKeypair?.address));

  if (mainAddress != null) {
    addresses.add(mainAddress);
  }

  final vbtcTokenAddresses = ref.watch(btcWebVbtcTokenListProvider).map((v) => v.depositAddress).toList();

  addresses.addAll(vbtcTokenAddresses);

  return addresses;
});
