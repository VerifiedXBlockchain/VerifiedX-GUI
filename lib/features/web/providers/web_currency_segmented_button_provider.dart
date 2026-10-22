import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/core/providers/web_session_provider.dart';
import 'package:rbx_wallet/features/web/providers/web_selected_account_provider.dart';

import '../../send/providers/send_form_provider.dart';

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
          ref
              .read(webSelectedAccountProvider.notifier)
              .setVfx(session.keypair!, session.balance ?? 0, session.balanceLocked ?? 0.0, session.balanceTotal ?? 0.0, session.adnr);
        }
        break;
      case WebCurrencyType.vfx:
        if (session.keypair != null) {
          ref
              .read(webSelectedAccountProvider.notifier)
              .setVfx(session.keypair!, session.balance ?? 0, session.balanceLocked ?? 0.0, session.balanceTotal ?? 0.0, session.adnr);
        }
        break;
      case WebCurrencyType.vault:
        if (session.raKeypair != null) {
          ref
              .read(webSelectedAccountProvider.notifier)
              .setVault(session.raKeypair!, session.raBalance ?? 0, session.raBalanceLocked ?? 0.0, session.raBalanceTotal ?? 0.0);
        }
        break;
      case WebCurrencyType.btc:
        if (session.btcKeypair != null) {
          ref.read(webSelectedAccountProvider.notifier).setBtc(session.btcKeypair!, session.btcBalanceInfo?.btcBalance ?? 0);
        }

        break;
    }
    ref.read(sendFormProvider.notifier).clear();
  }

  /// For a login or an account switch, which select the account's VFX
  /// address: shows VFX without selecting it again or clearing the send form.
  void followVfxSelection() {
    state = currencyAfterVfxSelection(state);
  }
}

/// The segment to show once an account's VFX address is the selected account.
/// BTC or Vault left over from the previous account would label the VFX form,
/// address and domain as another currency; "All" covers VFX and stays.
WebCurrencyType currencyAfterVfxSelection(WebCurrencyType current) {
  return current == WebCurrencyType.any ? current : WebCurrencyType.vfx;
}

final webCurrencySegementedButtonProvider = StateNotifierProvider<CurrencySegementedButtonProvider, WebCurrencyType>((ref) {
  return CurrencySegementedButtonProvider(ref);
});
