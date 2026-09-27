import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/models/web_session_model.dart';
import 'package:rbx_wallet/features/asset/asset.dart';
import 'package:rbx_wallet/features/btc_web/models/btc_web_account.dart';
import 'package:rbx_wallet/features/keygen/models/keypair.dart';
import 'package:rbx_wallet/features/keygen/models/ra_keypair.dart';
import 'package:rbx_wallet/features/smart_contracts/models/smart_contract.dart';

final _keypair = Keypair(private: 'vfx-private', address: 'xVfxAccountAddress', public: 'vfx-public');

final _raKeypair = RaKeypair(
  private: 'ra-private',
  address: 'xRBXVaultAddress',
  public: 'ra-public',
  recoveryPrivate: 'rec-private',
  recoveryAddress: 'xRecoveryAddress',
  recoveryPublic: 'rec-public',
  restoreCode: 'restore',
);

final _btcAccount = BtcWebAccount(
  address: 'tb1qbtcaddress',
  wif: 'btc-wif',
  privateKey: 'btc-private',
  publicKey: 'btc-public',
);

WebSessionModel _session(WalletType type) => WebSessionModel(
      keypair: _keypair,
      raKeypair: _raKeypair,
      btcKeypair: _btcAccount,
      balance: 12.5,
      selectedWalletType: type,
    );

void main() {
  group('WebSessionModel.vfxWallet', () {
    for (final type in WalletType.values) {
      test('is the VFX keypair account when ${type.name} is selected', () {
        final wallet = _session(type).vfxWallet!;

        expect(wallet.address, 'xVfxAccountAddress');
        expect(wallet.publicKey, 'vfx-public');
        expect(wallet.privateKey, 'vfx-private');
        expect(wallet.balance, 12.5);
      });
    }

    test('is null without a keypair', () {
      expect(WebSessionModel(selectedWalletType: WalletType.rbx).vfxWallet, isNull);
    });

    test('currentWallet still follows the selected wallet type', () {
      expect(_session(WalletType.btc).currentWallet!.address, 'tb1qbtcaddress');
      expect(_session(WalletType.ra).currentWallet!.address, 'xRBXVaultAddress');
      expect(_session(WalletType.rbx).currentWallet!.address, 'xVfxAccountAddress');
    });
  });

  test('a smart contract owned by vfxWallet sends the VFX address as MinterAddress with BTC selected', () {
    final sc = SmartContract(
      owner: _session(WalletType.btc).vfxWallet!,
      name: 'sc',
      minterName: 'QA',
      description: 'desc',
      primaryAsset: Asset(id: 'asset-1', name: 'a.png', extension: 'png', fileSize: 10),
    );

    final payload = sc.serializeForCompiler('America/New_York');

    expect(payload['MinterAddress'], 'xVfxAccountAddress');
  });
}
