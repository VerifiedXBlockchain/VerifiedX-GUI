import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/plonk_status.dart';
import '../services/privacy_service.dart';

part 'plonk_status_provider.g.dart';

@Riverpod(keepAlive: true)
class PlonkStatusNotifier extends _$PlonkStatusNotifier {
  @override
  PlonkStatus? build() {
    return null;
  }

  Future<void> load() async {
    state = await PrivacyService().getPlonkStatus();
  }

  bool get isPrivacyEnabled => state?.isPrivacyEnabled ?? false;
}
