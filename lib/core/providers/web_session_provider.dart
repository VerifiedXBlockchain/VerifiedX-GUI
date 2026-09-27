import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/btc_web/providers/btc_web_transaction_list_provider.dart';
import '../../features/btc_web/providers/btc_web_vbtc_token_detail_provider.dart';
import '../../features/btc_web/providers/btc_web_vbtc_token_list_provider.dart';
import '../../features/misc/providers/global_balances_expanded_provider.dart';
import '../../features/price/providers/price_detail_providers.dart';
import '../../features/token/providers/web_token_list_provider.dart';
import '../../features/btc_web/models/btc_web_account.dart';
import '../../features/btc_web/services/btc_web_service.dart';
import '../../features/keygen/models/ra_keypair.dart';
import '../../features/nft/providers/minted_nft_list_provider.dart';
import 'package:collection/collection.dart';
import '../../features/web/models/multi_account_instance.dart';
import '../../features/web/models/web_address.dart';
import '../../features/web/providers/multi_account_provider.dart';
import '../../features/web/providers/web_selected_account_provider.dart';
import '../models/web_session_model.dart';
import '../../features/transactions/providers/web_transaction_detail_provider.dart';
import '../../features/transactions/providers/web_transaction_list_provider.dart';
import '../../features/web_shop/providers/web_listed_nfts_provider.dart';
import '../../utils/html_helpers.dart';
import '../../utils/web_route_paths.dart';
import '../services/encryption_service.dart';
import '../services/password_verification_service.dart';
import '../services/web_account_password_store.dart';

import '../../app.dart';
import '../../features/keygen/models/keypair.dart';
import '../../features/nft/providers/nft_list_provider.dart';
import '../app_constants.dart';
import '../services/explorer_service.dart';
import '../singletons.dart';
import '../storage.dart';
import '../web_router.gr.dart';
import 'package:auto_route/auto_route.dart';

class WebSessionProvider extends StateNotifier<WebSessionModel> {
  final Ref ref;

  late final Timer loopTimer;
  late final Timer btcLoopTimer;

  WebSessionProvider(this.ref, WebSessionModel model) : super(model) {
    if (!kIsWeb) {
      return;
    }

    init();

    loopTimer =
        Timer.periodic(const Duration(seconds: REFRESH_TIMEOUT_SECONDS), (_) {
      loop();
    });

    btcLoopTimer = Timer.periodic(
        const Duration(seconds: REFRESH_TIMEOUT_SECONDS_WEB_BTC), (_) {
      btcLoop();
    });
  }

  void init() {
    state = WebSessionModel();
    final storage = singleton<Storage>();
    final hasEncryptedKeys = storage.isEncryptionEnabled();
    final hasPasswordHash = storage.hasPasswordHash();

    if (hasEncryptedKeys && hasPasswordHash) {
      // Has encrypted keys - need password to decrypt
      state = state.copyWith(
        isAuthenticated: false,
        ready: true,
      );
      // Save the dashboard page the app was opened on (a reload or a
      // payment link) so unlocking returns to it. The URL is the one main()
      // captured, since the router has rewritten the hash by now.
      final initialRedirect = InitialWebUrl.takeDashboardRedirect();
      if (initialRedirect != null) {
        storage.setString(Storage.PENDING_REDIRECT_URL, initialRedirect);
      }

      // Redirect to auth screen for password entry
      Future.delayed(const Duration(milliseconds: 100), () {
        final context = rootNavigatorKey.currentContext;
        if (context != null) {
          AutoRouter.of(context).replace(const WebAuthRouter());
        }
      });
    } else {
      // Check for legacy unencrypted keys
      final savedKeypair = storage.getMap(Storage.WEB_KEYPAIR);
      if (savedKeypair != null &&
          !EncryptionService.isEncrypted(savedKeypair)) {
        // Legacy unencrypted keys found - load them
        _loadLegacyUnencryptedKeys(storage);
        state = state.copyWith(ready: true); // Make sure we set ready flag
      } else {
        // No keys at all
        state = state.copyWith(isAuthenticated: false, ready: true);
      }
    }

    final timezoneName = DateTime.now().timeZoneName.toString();
    state = state.copyWith(timezoneName: timezoneName);
    Future.delayed(const Duration(milliseconds: 500), () {
      final url = HtmlHelpers().getUrl();
      print("URL: $url");
      if (url.contains('/#dashboard/home') && !url.contains("all-tokens")) {
        ref.read(globalBalancesExpandedProvider.notifier).expand();
      } else {
        ref.read(globalBalancesExpandedProvider.notifier).detract();
      }
    });
  }

  /// Load legacy unencrypted keys (backward compatibility)
  void _loadLegacyUnencryptedKeys(Storage storage) {
    final savedKeypair = storage.getMap(Storage.WEB_KEYPAIR);
    if (savedKeypair != null) {
      final keypair = Keypair.fromJson(savedKeypair);

      final savedRaKeypair = storage.getMap(Storage.WEB_RA_KEYPAIR);
      final raKeypair =
          savedRaKeypair != null ? RaKeypair.fromJson(savedRaKeypair) : null;

      final savedBtcKeypair = storage.getMap(Storage.WEB_BTC_KEYPAIR);
      final btcKeyPair = savedBtcKeypair != null
          ? BtcWebAccount.fromJson(savedBtcKeypair)
          : null;

      login(keypair, raKeypair, btcKeyPair, andSave: false); // Legacy unencrypted keys - no encryption password

      final savedSelectedWalletType =
          storage.getString(Storage.WEB_SELECTED_WALLET_TYPE);
      if (savedSelectedWalletType != null) {
        final walletType = WalletType.values
            .firstWhereOrNull((t) => t.storageName == savedSelectedWalletType);
        if (walletType != null) {
          setSelectedWalletType(walletType, false);
        }
      }
    }
  }

  /// Unlocks the wallet with [password].
  ///
  /// Unlock targets the last active account: the password must be that
  /// account's own. A wallet saved before passwords were per account also
  /// opens with the password of its wallet-wide slot, which then loads and
  /// activates the account that slot holds. See [WebAccountPasswordStore].
  Future<bool> loginWithPassword(String password) async {
    final storage = singleton<Storage>();

    final unlocked = WebAccountPasswordStore(storage).unlock(password);
    if (unlocked == null) {
      return false;
    }

    final accountId = unlocked.accountId;
    if (accountId != null) {
      ref.read(selectedMultiAccountProvider.notifier).markActive(accountId);
    }

    // Load keys into session
    login(unlocked.keypair, unlocked.raKeypair, unlocked.btcKeypair,
        andSave: false, encryptionPassword: password);

    // Restore wallet type selection
    final savedSelectedWalletType =
        storage.getString(Storage.WEB_SELECTED_WALLET_TYPE);
    if (savedSelectedWalletType != null) {
      final walletType = WalletType.values
          .firstWhereOrNull((t) => t.storageName == savedSelectedWalletType);
      if (walletType != null) {
        setSelectedWalletType(walletType, false);
      }
    }

    return true;
  }

  /// Encrypts and saves the newest account's keys in the wallet-wide slot.
  ///
  /// Each account's own password lives with its entry in the multi-account
  /// store (written by [login]); this slot is the legacy unlock fallback and
  /// marks the wallet as password protected. See [WebAccountPasswordStore].
  void encryptAndSaveKeys(Keypair keypair, RaKeypair? raKeypair,
      BtcWebAccount? btcKeyPair, String password) {
    final storage = singleton<Storage>();

    try {
      // Store password hash for verification
      PasswordVerificationService.storePasswordHash(password);

      // Store primary address unencrypted for display on auth screen
      storage.setString(Storage.WEB_PRIMARY_ADDRESS, keypair.address);

      // Encrypt and store VFX keypair
      final encryptedVfx =
          EncryptionService.encrypt(keypair.toJson(), password);
      storage.setMap(Storage.WEB_KEYPAIR, encryptedVfx);

      // Encrypt and store RA keypair if exists
      if (raKeypair != null) {
        final encryptedRa =
            EncryptionService.encrypt(raKeypair.toJson(), password);
        storage.setMap(Storage.WEB_RA_KEYPAIR, encryptedRa);
      }

      // Encrypt and store BTC keypair if exists
      if (btcKeyPair != null) {
        final encryptedBtc =
            EncryptionService.encrypt(btcKeyPair.toJson(), password);
        storage.setMap(Storage.WEB_BTC_KEYPAIR, encryptedBtc);
      }

      // Mark encryption as enabled
      storage.setBool(Storage.ENCRYPTION_ENABLED, true);
      storage.setInt(Storage.ENCRYPTION_VERSION, 1);
    } catch (e) {
      rethrow;
    }
  }

  void login(Keypair keypair, RaKeypair? raKeypair, BtcWebAccount? btcKeyPair,
      {bool andSave = true, String? encryptionPassword}) async {
    if (andSave) {
      final storage = singleton<Storage>();
      // Only save unencrypted keys if encryption is NOT enabled (legacy mode)
      if (!storage.isEncryptionEnabled()) {
        storage.setMap(Storage.WEB_KEYPAIR, keypair.toJson());
        if (raKeypair != null) {
          storage.setMap(Storage.WEB_RA_KEYPAIR, raKeypair.toJson());
        }
        if (btcKeyPair != null) {
          storage.setMap(Storage.WEB_BTC_KEYPAIR, btcKeyPair.toJson());
        }
      }
    }

    // Store primary address for display on auth screen (addresses are public info)
    final storage = singleton<Storage>();
    storage.setString(Storage.WEB_PRIMARY_ADDRESS, keypair.address);

    state = state.copyWith(
      keypair: keypair,
      raKeypair: raKeypair,
      btcKeypair: btcKeyPair,
      isAuthenticated: true,
    );

    // Zero until the lookup succeeds; the refresh loop fills in the real
    // balances via syncBalances once Spyglass answers.
    final webAddress = await _fetchWebAddress(keypair.address);

    ref.read(webSelectedAccountProvider.notifier).setVfx(
        keypair,
        webAddress?.balance ?? 0,
        webAddress?.balanceLocked ?? 0,
        webAddress?.balanceTotal ?? 0,
        webAddress?.adnr);

    refreshBtcBalanceInfo();

    ref.read(multiAccountProvider.notifier).add(
          keypair: keypair,
          raKeypair: raKeypair,
          btcKeypair: btcKeyPair,
          setAsCurrent: true,
          encryptionPassword: encryptionPassword,
        );

    loop();
    btcLoop();

    // ref.read(webTransactionListProvider(keypair.address).notifier).init();
  }

  // void setUsingRa(bool value) {
  //   state = state.copyWith(selectedWalletType: value ?  );
  //   ref.read(mintedNftListProvider.notifier).load(1);
  //   ref.read(nftListProvider.notifier).load(1);
  // }

  void setMultiAccountInstance(MultiAccountInstance account) async {
    state = state.copyWith(
      keypair: account.keypair,
      raKeypair: account.raKeypair,
      btcKeypair: account.btcKeypair,
    );

    // Only save unencrypted keys if encryption is NOT enabled (legacy mode)
    final storage = singleton<Storage>();
    if (!storage.isEncryptionEnabled()) {
      if (account.keypair != null) {
        storage.setMap(Storage.WEB_KEYPAIR, account.keypair!.toJson());
      }
      if (account.raKeypair != null) {
        storage.setMap(Storage.WEB_RA_KEYPAIR, account.raKeypair!.toJson());
      }
      if (account.btcKeypair != null) {
        storage.setMap(Storage.WEB_BTC_KEYPAIR, account.btcKeypair!.toJson());
      }
    }

    if (account.keypair != null) {
      final webAddress = await _fetchWebAddress(account.keypair!.address);

      ref.read(webSelectedAccountProvider.notifier).setVfx(
          account.keypair!,
          webAddress?.balance ?? 0,
          webAddress?.balanceLocked ?? 0,
          webAddress?.balanceTotal ?? 0,
          webAddress?.adnr);
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      refreshBtcBalanceInfo();
      loop();
      btcLoop();
    });
  }

  void setSelectedWalletType(WalletType type, [bool save = true]) {
    state = state.copyWith(selectedWalletType: type);

    if (type != WalletType.btc) {
      ref.read(mintedNftListProvider.notifier).load(1, state.keypair?.address);
      ref
          .read(nftListProvider.notifier)
          .load(1, [state.keypair?.address, state.raKeypair?.address]);
    }

    if (save) {
      singleton<Storage>()
          .setString(Storage.WEB_SELECTED_WALLET_TYPE, type.storageName);
    }
  }

  void setRaKeypair(RaKeypair keypair) {
    state = state.copyWith(raKeypair: keypair);
  }

  void loop() async {
    getAddress();
    getRaAddress();
    lookupBtcAdnr();
    getFungibleTokens();
    getVbtcTokens();
    getNfts();

    ref.invalidate(vfxPriceDataDetailProvider);
    ref.invalidate(btcPriceDataDetailProvider);
    // The vBTC detail screen has no list to ride along with, so its balance
    // only moves when this fires. autoDispose keeps it free when no detail
    // screen is open.
    ref.invalidate(btcWebVbtcTokenDetailProvider);
    // Same for the transaction detail screen, so a pending status updates.
    ref.invalidate(webTransactionDetailProvider);
  }

  void btcLoop() async {
    getBtcBalances();
  }

  Future<void> getAddress() async {
    if (state.keypair == null) {
      return;
    }
    final address = state.keypair!.address;
    final webAddress = await _fetchWebAddress(address);

    // The account may have changed while the request was in flight; a stale
    // answer must not overwrite the new account's balance. A failed lookup
    // keeps the last known values rather than zeroing them.
    if (webAddress == null || state.keypair?.address != address) {
      return;
    }

    state = state.copyWith(
      balance: webAddress.balance,
      balanceLocked: webAddress.balanceLocked,
      balanceTotal: webAddress.balanceTotal,
      adnr: webAddress.adnr,
    );
    ref.read(webSelectedAccountProvider.notifier).syncBalances(state);
  }

  Future<void> lookupBtcAdnr() async {
    if (state.btcKeypair == null) {
      return;
    }

    // if (state.btcKeypair!.adnr != null) {
    //   return;
    // }

    final domain =
        await ExplorerService().btcAdnrLookup(state.btcKeypair!.address);
    if (state.btcKeypair!.adnr == null && domain != null) {
      state = state.copyWith(
        btcKeypair: state.btcKeypair!.copyWith(adnr: domain),
      );
    } else if (state.btcKeypair!.adnr != null && domain == null) {
      state = state.copyWith(
        btcKeypair: state.btcKeypair!.copyWith(adnr: null),
      );
    }
  }

  Future<void> getRaAddress() async {
    if (state.raKeypair == null) {
      return;
    }
    final raAddress = state.raKeypair!.address;
    final webAddress = await _fetchWebAddress(raAddress);

    if (state.raKeypair?.address != raAddress) {
      return;
    }

    // Without an answer the Vault's activated/deactivated flags are unknown;
    // flag that instead of guessing, so the Vault screen does not offer to
    // fund or recover a Vault that may already be recovered.
    if (webAddress == null) {
      state = state.copyWith(raStatusUnavailable: true);
      return;
    }

    state = state.copyWith(
      raBalance: webAddress.balance,
      raBalanceLocked: webAddress.balanceLocked,
      raBalanceTotal: webAddress.balanceTotal,
      raActivated: webAddress.activated,
      raDeactivated: webAddress.deactivated,
      raStatusUnavailable: false,
    );
    ref.read(webSelectedAccountProvider.notifier).syncBalances(state);
  }

  /// [ExplorerService.getWebAddress] already logs the failure; null tells the
  /// caller the address state is unknown.
  Future<WebAddress?> _fetchWebAddress(String address) async {
    try {
      return await ExplorerService().getWebAddress(address);
    } catch (_) {
      return null;
    }
  }

  Future<void> getFungibleTokens() async {
    if (state.keypair == null && state.raKeypair == null) {
      return;
    }

    ref
        .read(webTokenListProvider.notifier)
        .load([state.keypair?.address, state.raKeypair?.address]);
  }

  Future<void> getVbtcTokens() async {
    if (state.keypair == null && state.raKeypair == null) {
      return;
    }

    ref
        .read(btcWebVbtcTokenListProvider.notifier)
        .load(state.keypair!.address, raAddress: state.raKeypair?.address);
  }

  // Future<void> getBalance() async {
  //   if (state.keypair == null) {
  //     return;
  //   }
  //   final balance = await ExplorerService().getBalance(state.keypair!.address);

  //   state = state.copyWith(balance: balance);
  // }

  Future<void> getNfts() async {
    if (state.keypair == null) {
      return;
    }
    ref.read(nftListProvider.notifier).reloadCurrentPage(
        address: [state.keypair?.address, state.raKeypair?.address]);
    ref.read(webListedNftsProvider.notifier).refresh(state.keypair!.address);
  }

  void updateBtcKeypair(BtcWebAccount? account, bool andSave) {
    state = state.copyWith(
      btcKeypair: account,
      selectedWalletType: WalletType.btc,
    );

    refreshBtcBalanceInfo();

    if (andSave) {
      final storage = singleton<Storage>();
      // Only save unencrypted keys if encryption is NOT enabled (legacy mode)
      if (!storage.isEncryptionEnabled()) {
        if (account != null) {
          storage.setMap(Storage.WEB_BTC_KEYPAIR, account.toJson());
        } else {
          storage.remove(Storage.WEB_BTC_KEYPAIR);
        }
      }
    }
  }

  void refreshBtcBalanceInfo() async {
    if (state.btcKeypair != null) {
      final btcBalanceInfo =
          await BtcWebService().addressInfo(state.btcKeypair!.address);

      print("${state.btcKeypair!.address}: ");
      print(btcBalanceInfo?.balance);

      state = state.copyWith(
        btcBalanceInfo: btcBalanceInfo,
      );
      ref.read(webSelectedAccountProvider.notifier).syncBalances(state);
    }
  }

  /// Soft lock: clears in-memory sensitive data without reloading the page.
  /// Storage (encrypted keys, password hash) remains intact so the user
  /// can unlock again by entering their password.
  void softLock() {
    state = state.copyWith(
      keypair: null,
      raKeypair: null,
      btcKeypair: null,
      isAuthenticated: false,
      balance: null,
      balanceTotal: null,
      balanceLocked: null,
      raBalance: null,
      raBalanceTotal: null,
      raBalanceLocked: null,
      adnr: null,
      btcBalanceInfo: null,
    );

    // Navigate to auth screen using Flutter router (no page reload)
    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      AutoRouter.of(context).replace(const WebAuthRouter());
    }
  }

  Future<void> logout() async {
    singleton<Storage>().remove(Storage.WEB_KEYPAIR);
    singleton<Storage>().remove(Storage.WEB_RA_KEYPAIR);
    singleton<Storage>().remove(Storage.WEB_BTC_KEYPAIR);
    singleton<Storage>().remove(Storage.MULTIPLE_ACCOUNTS);
    singleton<Storage>().remove(Storage.MULTIPLE_ACCOUNT_SELECTED);
    singleton<Storage>().remove(Storage.STORED_PASSWORD_HASH);
    singleton<Storage>().remove(Storage.ENCRYPTION_ENABLED);
    singleton<Storage>().remove(Storage.ENCRYPTION_VERSION);
    singleton<Storage>().remove(Storage.WEB_AUTH_TOKEN);
    // A page saved for after unlock belongs to the session being logged out.
    singleton<Storage>().remove(Storage.PENDING_REDIRECT_URL);

    // state = WebSessionModel();

    await Future.delayed(const Duration(milliseconds: 150));

    HtmlHelpers().redirect("/");
    await Future.delayed(const Duration(milliseconds: 150));

    HtmlHelpers().reload();
  }

  void getBtcBalances() {
    if (state.btcKeypair != null) {
      ref
          .read(
              btcWebTransactionListProvider(state.btcKeypair!.address).notifier)
          .load();
      refreshBtcBalanceInfo();
    }
  }
}

final webSessionProvider =
    StateNotifierProvider<WebSessionProvider, WebSessionModel>(
  (ref) => WebSessionProvider(ref, WebSessionModel()),
);
