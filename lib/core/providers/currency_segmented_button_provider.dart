import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final currencySegementedButtonProvider = StateNotifierProvider<CurrencySegementedButtonProvider, CurrencyType>((ref) {
  return CurrencySegementedButtonProvider(ref);
});
