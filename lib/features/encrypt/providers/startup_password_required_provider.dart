import 'package:flutter_riverpod/flutter_riverpod.dart';

class StartupPasswordRequiredProvider extends StateNotifier<bool> {
  StartupPasswordRequiredProvider() : super(false);

  // Future<void> check() async {
  //   state = await BridgeService().startupPasswordRequired();
  // }

  void set(bool value) {
    state = value;
  }
}

final startupPasswordRequiredProvider = StateNotifierProvider<StartupPasswordRequiredProvider, bool>((ref) {
  return StartupPasswordRequiredProvider();
});
