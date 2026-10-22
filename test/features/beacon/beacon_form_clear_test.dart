import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/beacon/providers/add_beacon_form_provider.dart';
import 'package:rbx_wallet/features/beacon/providers/beacon_form_provider.dart';

void main() {
  test('Cancel on Add Remote Beacon empties the port with the other fields', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final form = container.read(addBeaconFormProvider.notifier);

    form.nameController.text = 'QA beacon';
    form.ipController.text = '10.0.0.1';
    form.portController.text = '80';
    expect(container.read(addBeaconFormProvider).port, 80);

    form.clear();

    expect(form.portController.text, isEmpty);
    expect(form.nameController.text, isEmpty);
    expect(container.read(addBeaconFormProvider).port, 0);
  });

  test('Cancel on Create / Host Beacon empties the port with the other fields', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final form = container.read(beaconFormProvider.notifier);

    form.nameController.text = 'QA host';
    form.portController.text = '12';
    expect(container.read(beaconFormProvider).port, 12);

    form.clear();

    expect(form.portController.text, isEmpty);
    expect(container.read(beaconFormProvider).port, 0);
  });
}
