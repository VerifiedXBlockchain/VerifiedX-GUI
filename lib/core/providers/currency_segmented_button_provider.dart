import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_provider.dart';

import '../../features/send/providers/send_form_provider.dart';

enum CurrencyType {
  any,
  vfx,
  btc,
}

class CurrencySegementedButtonProvider extends StateNotifier<CurrencyType> {
  final Ref ref;

  CurrencySegementedButtonProvider(this.ref) : super(CurrencyType.vfx);

  set(CurrencyType type) {
    state = type;
    ref.read(sendFormProvider.notifier).clear();
  }
}

/// The segment Send or Receive should show for the account they render (BTC
/// when [btcSelected]), or null when [current] already agrees with it. "All"
/// agrees with either where the screen offers it.
CurrencyType? currencyMatchingSession(CurrencyType current, {required bool btcSelected, required bool includeAny}) {
  final shown = btcSelected ? CurrencyType.btc : CurrencyType.vfx;
  if (current == shown || (includeAny && current == CurrencyType.any)) {
    return null;
  }
  return shown;
}

final currencySegementedButtonProvider = StateNotifierProvider<CurrencySegementedButtonProvider, CurrencyType>((ref) {
  return CurrencySegementedButtonProvider(ref);
});

/// The currency the desktop Send screen shows, which its account lists follow
/// too: the app-wide choice, or the selected account's currency when the two
/// disagree (see [currencyMatchingSession]).
final sendCurrencyProvider = Provider<CurrencyType>((ref) {
  final current = ref.watch(currencySegementedButtonProvider);
  final btcSelected = ref.watch(sessionProvider.select((v) => v.btcSelected));
  return currencyMatchingSession(current, btcSelected: btcSelected, includeAny: true) ?? current;
});
