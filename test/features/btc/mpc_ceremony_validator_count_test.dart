import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/btc/models/mpc_ceremony.dart';

void main() {
  group('MpcCeremony.hasValidatorCount', () {
    test('a ceremony still running reports no count yet, as Core sends 0 until the DKG result', () {
      final running = MpcCeremony.fromJson({'CeremonyId': 'c1', 'Status': 'Round2InProgress', 'ValidatorCount': 0, 'RequiredThreshold': 51});
      expect(running.hasValidatorCount, isFalse);
      expect(MpcCeremony(ceremonyId: 'c1', status: MpcCeremonyStatus.initiated).hasValidatorCount, isFalse);
    });

    test('once the participants are known the count is shown', () {
      final done = MpcCeremony.fromJson({'CeremonyId': 'c1', 'Status': 'Completed', 'ValidatorCount': 7, 'RequiredThreshold': 51});
      expect(done.hasValidatorCount, isTrue);
    });
  });
}
