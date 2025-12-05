import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/session_provider.dart';
import '../../../core/providers/web_session_provider.dart';

part 'current_vfx_balance_provider.g.dart';

@Riverpod(keepAlive: true)
double currentVfxBalance(CurrentVfxBalanceRef ref) {
  if (kIsWeb) {
    return ref.watch(
        webSessionProvider.select((v) => v.currentWallet?.balance ?? 0.0));
  } else {
    return ref
        .watch(sessionProvider.select((v) => v.currentWallet?.balance ?? 0.0));
  }
}
