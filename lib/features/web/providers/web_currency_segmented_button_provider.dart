import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/core/providers/web_session_provider.dart';
import 'package:rbx_wallet/features/web/providers/web_selected_account_provider.dart';

enum WebCurrencyType {
  any,
  vfx,
  vault,
  btc,
}

class CurrencySegementedButtonProvider extends StateNotifier<WebCurrencyType> {
  final Ref ref;
  CurrencySegementedButtonProvider(this.ref) : super(WebCurrencyType.any);

  set(WebCurrencyType type) {
    state = type;

    final session = ref.read(webSessionProvider);

    switch (type) {
      case WebCurrencyType.any:
        if (session.keypair != null) {
          ref.read(webSelectedAccountProvider.notifier).setVfx(session.keypair!, session.balance ?? 0, session.adnr);
        }
        break;
      case WebCurrencyType.vfx:
        if (session.keypair != null) {
          ref.read(webSelectedAccountProvider.notifier).setVfx(session.keypair!, session.balance ?? 0, session.adnr);
        }
        break;
      case WebCurrencyType.vault:
        if (session.raKeypair != null) {
          ref.read(webSelectedAccountProvider.notifier).setVault(session.raKeypair!, session.raBalance ?? 0);
        }
        break;
      case WebCurrencyType.btc:
        if (session.btcKeypair != null) {
          ref.read(webSelectedAccountProvider.notifier).setBtc(session.btcKeypair!, session.btcBalanceInfo?.btcBalance ?? 0);
        }

        break;
    }
  }
}

final webCurrencySegementedButtonProvider = StateNotifierProvider<CurrencySegementedButtonProvider, WebCurrencyType>((ref) {
  return CurrencySegementedButtonProvider(ref);
});