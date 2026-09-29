import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/web_session_model.dart';

/// Tabs of the web Transactions screen, in display order.
enum WebTransactionsTab { all, vfx, vault, btc }

WebTransactionsTab webTransactionsTabFor(WalletType type) {
  switch (type) {
    case WalletType.rbx:
      return WebTransactionsTab.vfx;
    case WalletType.ra:
      return WebTransactionsTab.vault;
    case WalletType.btc:
      return WebTransactionsTab.btc;
  }
}

/// A one-off request to open the Transactions screen on a tab, set by the
/// balance cards' View All Txs. The screen applies it and clears it, so
/// opening Transactions from the nav still shows the tab the user left.
final webTransactionsTabRequestProvider = StateProvider<WebTransactionsTab?>((ref) => null);
