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
    final session = WebSessionModel(keypair: _keypair, balance: 198.99999396, balanceLocked: 0, balanceTotal: 198.99999396, adnr: 'me.vfx');
    final updated = selectedAccountSyncedWithSession(_account('xMain', WebCurrencyType.vfx, 200), session);

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
    final updated = selectedAccountSyncedWithSession(_account('xRBXVault', WebCurrencyType.vault, 12), session);

    expect(updated!.balance, 9);
    expect(updated.lockedBalance, 1);
    expect(updated.totalBalance, 10);
  });

  test('a BTC account picks up the refreshed BTC balance', () {
    final session = WebSessionModel(
      btcKeypair: _btcAccount,
      btcBalanceInfo: BtcWebBalanceInfo(totalRecieved: 0, totalSent: 0, balance: 50000, txCount: 1),
    );
    final updated = selectedAccountSyncedWithSession(_account('tb1qme', WebCurrencyType.btc, 0), session);

    expect(updated!.balance, closeTo(0.0005, 1e-12));
  });

  test('no update when the balance is unchanged, not loaded, or for another account', () {
    final account = _account('xMain', WebCurrencyType.vfx, 200);

    expect(selectedAccountSyncedWithSession(account, WebSessionModel(keypair: _keypair, balance: 200, balanceLocked: 0, balanceTotal: 200, adnr: 'me.vfx')), isNull);
    expect(selectedAccountSyncedWithSession(account, WebSessionModel(keypair: _keypair)), isNull);
    expect(
      selectedAccountSyncedWithSession(account, WebSessionModel(keypair: Keypair(private: 'p', address: 'xOther', public: 'pub'), balance: 5)),
      isNull,
    );
  });

  test('syncWithSession updates the provider state in place', () {
    final notifier = WebSelectedAccountProvider();
    notifier.setVfx(_keypair, 200, 0, 200, null);

    notifier.syncWithSession(WebSessionModel(keypair: _keypair, balance: 150, balanceLocked: 0, balanceTotal: 150));

    expect(notifier.debugState!.balance, 150);
    expect(notifier.debugState!.address, 'xMain');
  });

  test('a VFX domain that confirms while selected reaches the account (TC-ADNR-011)', () {
    final notifier = WebSelectedAccountProvider();
    notifier.setVfx(_keypair, 200, 0, 200, null);

    // Same balance; only the domain is new.
    notifier.syncWithSession(WebSessionModel(keypair: _keypair, balance: 200, balanceLocked: 0, balanceTotal: 200, adnr: 'qa.vfx'));

    expect(notifier.debugState!.domain, 'qa.vfx');
    expect(notifier.debugState!.address, 'xMain');
    expect(notifier.debugState!.privateKey, _keypair.privateCorrected);
    expect(notifier.debugState!.type, WebCurrencyType.vfx);
  });

  test('a deleted or transferred VFX domain is cleared', () {
    final updated = selectedAccountSyncedWithSession(
      _account('xMain', WebCurrencyType.vfx, 200),
      WebSessionModel(keypair: _keypair, balance: 200, balanceLocked: 0, balanceTotal: 200),
    );

    expect(updated!.domain, isNull);
    expect(updated.balance, 200);
  });

  test('a VFX domain is not cleared before the session has loaded the address', () {
    expect(selectedAccountSyncedWithSession(_account('xMain', WebCurrencyType.vfx, 200), WebSessionModel(keypair: _keypair)), isNull);
  });

  test('a BTC account picks up its BTC domain even before a balance loads', () {
    final account = WebSelectedAccount(
      address: 'tb1qme',
      privateKey: 'p',
      publicKey: 'pub',
      type: WebCurrencyType.btc,
      balance: 0,
      lockedBalance: 0,
      totalBalance: 0,
    );
    final updated = selectedAccountSyncedWithSession(account, WebSessionModel(btcKeypair: _btcAccount.copyWith(adnr: 'qa.btc')));

    expect(updated!.domain, 'qa.btc');
    expect(updated.balance, 0);
    expect(updated.address, 'tb1qme');
  });

  test('a Vault keeps its domain and ignores the main account domain', () {
    final session = WebSessionModel(
      keypair: _keypair,
      raKeypair: _raKeypair,
      adnr: 'main.vfx',
      balance: 50,
      raBalance: 12,
      raBalanceLocked: 0,
      raBalanceTotal: 12,
    );
    final account = WebSelectedAccount(
      address: 'xRBXVault',
      privateKey: 'p',
      publicKey: 'pub',
      type: WebCurrencyType.vault,
      balance: 12,
      lockedBalance: 0,
      totalBalance: 12,
    );

    expect(selectedAccountSyncedWithSession(account, session), isNull);
  });
}
