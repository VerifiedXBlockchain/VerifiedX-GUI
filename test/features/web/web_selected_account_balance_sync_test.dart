import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/models/web_session_model.dart';
import 'package:rbx_wallet/features/btc_web/models/btc_web_account.dart';
import 'package:rbx_wallet/features/btc_web/models/btc_web_balance_info.dart';
import 'package:rbx_wallet/features/keygen/models/keypair.dart';
import 'package:rbx_wallet/features/keygen/models/ra_keypair.dart';
import 'package:rbx_wallet/features/web/providers/web_currency_segmented_button_provider.dart';
import 'package:rbx_wallet/features/web/providers/web_selected_account_provider.dart';

final _keypair = Keypair(private: 'p', address: 'xMain', public: 'pub');
final _raKeypair = RaKeypair(
  private: 'p',
  address: 'xRBXVault',
  public: 'pub',
  recoveryPrivate: 'rp',
  recoveryAddress: 'xRecovery',
  recoveryPublic: 'rpub',
  restoreCode: 'code',
);
final _btcAccount = BtcWebAccount(address: 'tb1qme', wif: 'w', privateKey: 'p', publicKey: 'pub');

WebSelectedAccount _account(String address, WebCurrencyType type, double balance) {
  return WebSelectedAccount(
    address: address,
    privateKey: 'p',
    publicKey: 'pub',
    type: type,
    balance: balance,
    lockedBalance: 0,
    totalBalance: balance,
    domain: 'me.vfx',
  );
}

void main() {
  test('a VFX account picks up the refreshed session balance', () {
    final session = WebSessionModel(keypair: _keypair, balance: 198.99999396, balanceLocked: 0, balanceTotal: 198.99999396);
    final updated = selectedAccountWithSessionBalances(_account('xMain', WebCurrencyType.vfx, 200), session);

    expect(updated, isNotNull);
    expect(updated!.balance, 198.99999396);
    expect(updated.totalBalance, 198.99999396);
    expect(updated.address, 'xMain');
    expect(updated.type, WebCurrencyType.vfx);
    expect(updated.domain, 'me.vfx');
  });

  test('a Vault account picks up the Vault balance, not the main one', () {
    final session = WebSessionModel(
      keypair: _keypair,
      raKeypair: _raKeypair,
      balance: 50,
      raBalance: 9,
      raBalanceLocked: 1,
      raBalanceTotal: 10,
    );
    final updated = selectedAccountWithSessionBalances(_account('xRBXVault', WebCurrencyType.vault, 12), session);

    expect(updated!.balance, 9);
    expect(updated.lockedBalance, 1);
    expect(updated.totalBalance, 10);
  });

  test('a BTC account picks up the refreshed BTC balance', () {
    final session = WebSessionModel(
      btcKeypair: _btcAccount,
      btcBalanceInfo: BtcWebBalanceInfo(totalRecieved: 0, totalSent: 0, balance: 50000, txCount: 1),
    );
    final updated = selectedAccountWithSessionBalances(_account('tb1qme', WebCurrencyType.btc, 0), session);

    expect(updated!.balance, closeTo(0.0005, 1e-12));
  });

  test('no update when the balance is unchanged, not loaded, or for another account', () {
    final account = _account('xMain', WebCurrencyType.vfx, 200);

    expect(selectedAccountWithSessionBalances(account, WebSessionModel(keypair: _keypair, balance: 200, balanceLocked: 0, balanceTotal: 200)), isNull);
    expect(selectedAccountWithSessionBalances(account, WebSessionModel(keypair: _keypair)), isNull);
    expect(
      selectedAccountWithSessionBalances(account, WebSessionModel(keypair: Keypair(private: 'p', address: 'xOther', public: 'pub'), balance: 5)),
      isNull,
    );
  });

  test('syncBalances updates the provider state in place', () {
    final notifier = WebSelectedAccountProvider();
    notifier.setVfx(_keypair, 200, 0, 200, null);

    notifier.syncBalances(WebSessionModel(keypair: _keypair, balance: 150, balanceLocked: 0, balanceTotal: 150));

    expect(notifier.debugState!.balance, 150);
    expect(notifier.debugState!.address, 'xMain');
  });
}
