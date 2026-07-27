import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/plonk_status.dart';
import '../services/privacy_service.dart';

part 'plonk_status_provider.g.dart';

@Riverpod(keepAlive: true)
class PlonkStatusNotifier extends _$PlonkStatusNotifier {
  Timer? _pollTimer;
  static const _pollInterval = Duration(seconds: 15);

  @override
  PlonkStatus? build() {
    ref.onDispose(() => _pollTimer?.cancel());
    return null;
  }

  Future<void> load() async {
    state = await PrivacyService().getPlonkStatus();

    if (state?.isPrivacyEnabled != true) {
      _startPolling();
    }
  }

  Future<void> refresh() async {
    final result = await PrivacyService().getPlonkStatus();
    if (result != null) {
      state = result;
    }

    if (state?.isPrivacyEnabled != true) {
      _startPolling();
    }
  }

  void _startPolling() {
    if (_pollTimer?.isActive == true) return;

    _pollTimer = Timer.periodic(_pollInterval, (_) async {
      final result = await PrivacyService().getPlonkStatus();
      if (result != null) {
        state = result;
      }

      if (state?.isPrivacyEnabled == true) {
        _pollTimer?.cancel();
        _pollTimer = null;
      }
    });
  }

  bool get isPrivacyEnabled => state?.isPrivacyEnabled ?? false;
}
