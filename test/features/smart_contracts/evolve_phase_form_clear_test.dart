import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/sc_property/models/sc_property.dart';
import 'package:rbx_wallet/features/smart_contracts/features/evolve/evolve_phase.dart';
import 'package:rbx_wallet/features/smart_contracts/features/evolve/evolve_phase_form_provider.dart';

void main() {
  test('clearing a stage leaves nothing of it for the next contract', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final stage = container.read(evolvePhaseFormProvider(0).notifier);

    stage.setPhase(EvolvePhase(name: 'Stage 1', description: 'First', dateTime: DateTime(2030, 1, 1), properties: const []));
    stage.addProperty(const ScProperty(name: 'Mood', value: 'Happy'));
    expect(container.read(evolvePhaseFormProvider(0)).properties, hasLength(1));

    stage.clear();

    expect(container.read(evolvePhaseFormProvider(0)), const EvolvePhase());
    expect(stage.nameController.text, isEmpty);
    expect(stage.descriptionController.text, isEmpty);
  });
}
