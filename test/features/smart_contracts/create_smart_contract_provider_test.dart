import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/providers/session_provider.dart';
import 'package:rbx_wallet/features/asset/asset.dart';
import 'package:rbx_wallet/features/smart_contracts/features/multi_asset/multi_asset_provider.dart';
import 'package:rbx_wallet/features/smart_contracts/models/multi_asset.dart';
import 'package:rbx_wallet/features/smart_contracts/providers/create_smart_contract_provider.dart';
import 'package:rbx_wallet/features/wallet/models/wallet.dart';

/// A session that never starts the CLI.
class _StubSession extends SessionProvider {
  _StubSession(Ref ref, SessionModel model) : super(ref, model);

  @override
  Future<void> init(bool inLoop) async {}
}

final _wallet = Wallet(
  id: 1,
  publicKey: 'pub-main',
  address: 'RBxMainWalletAddress0001',
  friendlyName: 'Main wallet',
  balance: 12.5,
  isValidating: false,
);

ProviderContainer _container() {
  final container = ProviderContainer(overrides: [
    sessionProvider.overrideWith((ref) => _StubSession(ref, SessionModel(currentWallet: _wallet))),
  ]);
  addTearDown(() async {
    // MultiAssetFormProvider.clear() resets its state after a 300ms delay;
    // let that land before disposing.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    container.dispose();
  });
  return container;
}

void main() {
  group('CreateSmartContractProvider text setters', () {
    test('setMinterName and setDescription leave the contract name alone', () {
      final container = _container();
      final notifier = container.read(createSmartContractProvider.notifier);

      notifier.setName('My Contract');
      notifier.setMinterName('Alice');
      notifier.setDescription('A description');

      final state = container.read(createSmartContractProvider);
      expect(state.name, 'My Contract');
      expect(state.minterName, 'Alice');
      expect(state.description, 'A description');
    });
  });

  group('removeMultiAsset', () {
    test('is a no-op for a Multi Asset that was never added', () {
      final container = _container();
      final notifier = container.read(createSmartContractProvider.notifier);
      notifier.saveMultiAsset(const MultiAsset(id: 'kept'));

      notifier.removeMultiAsset(const MultiAsset(id: 'never-added'));

      expect(container.read(createSmartContractProvider).multiAssets.map((m) => m.id), ['kept']);
    });

    test('removes a Multi Asset that was added', () {
      final container = _container();
      final notifier = container.read(createSmartContractProvider.notifier);
      notifier.saveMultiAsset(const MultiAsset(id: 'a'));
      notifier.saveMultiAsset(const MultiAsset(id: 'b'));

      notifier.removeMultiAsset(const MultiAsset(id: 'a'));

      expect(container.read(createSmartContractProvider).multiAssets.map((m) => m.id), ['b']);
    });
  });

  group('MultiAssetFormProvider.complete', () {
    test('saving an empty sheet adds no card and does not throw', () {
      final container = _container();
      container.read(createSmartContractProvider);
      final form = container.read(multiAssetFormProvider.notifier);
      form.setMultiAsset(const MultiAsset(id: 'empty'));

      expect(form.complete, returnsNormally);
      expect(container.read(createSmartContractProvider).multiAssets, isEmpty);
    });

    test('saving a sheet with assets adds its card', () {
      final container = _container();
      container.read(createSmartContractProvider);
      final form = container.read(multiAssetFormProvider.notifier);
      form.setMultiAsset(const MultiAsset(id: 'filled'));
      form.addAsset(Asset(id: 'asset-1', fileSize: 10, name: 'one.png'));

      form.complete();

      expect(container.read(createSmartContractProvider).multiAssets.map((m) => m.id), ['filled']);
    });
  });
}
