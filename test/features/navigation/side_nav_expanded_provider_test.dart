import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/navigation/providers/side_nav_expanded_provider.dart';

void main() {
  test('starts expanded and toggles', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(sideNavExpandedProvider), isTrue);
    container.read(sideNavExpandedProvider.notifier).toggle();
    expect(container.read(sideNavExpandedProvider), isFalse);
    container.read(sideNavExpandedProvider.notifier).toggle();
    expect(container.read(sideNavExpandedProvider), isTrue);
  });

  test('keeps a collapsed nav collapsed with no listeners', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final sub = container.listen(sideNavExpandedProvider, (_, __) {});
    container.read(sideNavExpandedProvider.notifier).toggle();
    sub.close();
    await Future<void>.delayed(Duration.zero);

    expect(container.read(sideNavExpandedProvider), isFalse);
  });
}
