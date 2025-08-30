import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/btc_web/providers/btc_web_transaction_list_provider.dart';
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
import '../../features/web/providers/multi_account_provider.dart';
import '../../features/web/providers/web_selected_account_provider.dart';
import '../models/web_session_model.dart';
import '../../features/transactions/providers/web_transaction_list_provider.dart';
import '../../features/web_shop/providers/web_listed_nfts_provider.dart';
import '../../utils/html_helpers.dart';
import '../services/encryption_service.dart';
import '../services/password_verification_service.dart';

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

      login(keypair, raKeypair, btcKeyPair, andSave: false);

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

  /// Login with encrypted keys using password
  Future<bool> loginWithPassword(String password) async {
    final storage = singleton<Storage>();

    // Verify password first
    print("🔓 Verifying password...");
    if (!PasswordVerificationService.verifyPassword(password)) {
      print("🔓 Password verification FAILED");
      return false;
    }
    print("🔓 Password verification SUCCESS");

    try {
      // Decrypt VFX keypair
      final encryptedVfx = storage.getMap(Storage.WEB_KEYPAIR);
      print("🔓 Encrypted VFX data: $encryptedVfx");
      if (encryptedVfx != null) {
        print("🔓 VFX data has keys: ${encryptedVfx.keys.toList()}");
        print("Using password: $password");
        final decryptedVfx = EncryptionService.decrypt(encryptedVfx, password);
        final keypair = Keypair.fromJson(decryptedVfx);

        // Decrypt RA keypair if exists
        RaKeypair? raKeypair;
        final encryptedRa = storage.getMap(Storage.WEB_RA_KEYPAIR);
        if (encryptedRa != null) {
          final decryptedRa = EncryptionService.decrypt(encryptedRa, password);
          raKeypair = RaKeypair.fromJson(decryptedRa);
        }

        // Decrypt BTC keypair if exists
        BtcWebAccount? btcKeypair;
        final encryptedBtc = storage.getMap(Storage.WEB_BTC_KEYPAIR);
        if (encryptedBtc != null) {
          final decryptedBtc =
              EncryptionService.decrypt(encryptedBtc, password);
          btcKeypair = BtcWebAccount.fromJson(decryptedBtc);
        }

        // Load keys into session
        login(keypair, raKeypair, btcKeypair, andSave: false);

        // Restore wallet type selection
        final savedSelectedWalletType =
            storage.getString(Storage.WEB_SELECTED_WALLET_TYPE);
        if (savedSelectedWalletType != null) {
          final walletType = WalletType.values.firstWhereOrNull(
              (t) => t.storageName == savedSelectedWalletType);
          if (walletType != null) {
            setSelectedWalletType(walletType, false);
          }
        }

        return true;
      }
    } catch (e, st) {
      print("Failed to decrypt keys: $e");
      print(st);
      return false;
    }

    return false;
  }

  /// Encrypt and save keys with password
  void encryptAndSaveKeys(Keypair keypair, RaKeypair? raKeypair,
      BtcWebAccount? btcKeyPair, String password) {
    print("🔐 Starting encryptAndSaveKeys...");
    final storage = singleton<Storage>();

    try {
      // Store password hash for verification
      print("🔐 Storing password hash...");
      PasswordVerificationService.storePasswordHash(password);
      print("🔐 Password hash stored successfully");

      // Encrypt and store VFX keypair
      print("🔐 Encrypting VFX keypair...");
      final encryptedVfx =
          EncryptionService.encrypt(keypair.toJson(), password);
      storage.setMap(Storage.WEB_KEYPAIR, encryptedVfx);
      print("🔐 VFX keypair encrypted and stored");

      // Encrypt and store RA keypair if exists
      if (raKeypair != null) {
        print("🔐 Encrypting RA keypair...");
        final encryptedRa =
            EncryptionService.encrypt(raKeypair.toJson(), password);
        storage.setMap(Storage.WEB_RA_KEYPAIR, encryptedRa);
        print("🔐 RA keypair encrypted and stored");
      }

      // Encrypt and store BTC keypair if exists
      if (btcKeyPair != null) {
        print("🔐 Encrypting BTC keypair...");
        final encryptedBtc =
            EncryptionService.encrypt(btcKeyPair.toJson(), password);
        storage.setMap(Storage.WEB_BTC_KEYPAIR, encryptedBtc);
        print("🔐 BTC keypair encrypted and stored");
      }

      // Mark encryption as enabled
      print("🔐 Setting encryption flags...");
      storage.setBool(Storage.ENCRYPTION_ENABLED, true);
      storage.setInt(Storage.ENCRYPTION_VERSION, 1);
      print("🔐 Encryption flags set successfully");

      print("🔐 encryptAndSaveKeys completed successfully!");
    } catch (e) {
      print("🔐 ERROR in encryptAndSaveKeys: $e");
      rethrow;
    }
  }

  void login(Keypair keypair, RaKeypair? raKeypair, BtcWebAccount? btcKeyPair,
      {bool andSave = true}) async {
    print("🔑 login() called with andSave: $andSave");

    if (andSave) {
      final storage = singleton<Storage>();
      // Only save unencrypted keys if encryption is NOT enabled (legacy mode)
      if (!storage.isEncryptionEnabled()) {
        print("🔑 Saving unencrypted keys to storage (legacy mode)");
        storage.setMap(Storage.WEB_KEYPAIR, keypair.toJson());
        if (raKeypair != null) {
          storage.setMap(Storage.WEB_RA_KEYPAIR, raKeypair.toJson());
        }
        if (btcKeyPair != null) {
          storage.setMap(Storage.WEB_BTC_KEYPAIR, btcKeyPair.toJson());
        }
      } else {
        print("🔑 Encryption enabled - NOT saving unencrypted keys to storage");
      }
    } else {
      print("🔑 NOT saving keys to storage (andSave=$andSave)");
    }

    state = state.copyWith(
      keypair: keypair,
      raKeypair: raKeypair,
      btcKeypair: btcKeyPair,
      isAuthenticated: true,
    );

    final webAddress = await ExplorerService().getWebAddress(keypair.address);

    ref.read(webSelectedAccountProvider.notifier).setVfx(
        keypair,
        webAddress.balance,
        webAddress.balanceLocked,
        webAddress.balanceTotal,
        webAddress.adnr);

    refreshBtcBalanceInfo();

    ref.read(multiAccountProvider.notifier).add(
          keypair: keypair,
          raKeypair: raKeypair,
          btcKeypair: btcKeyPair,
          setAsCurrent: true,
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
      final webAddress =
          await ExplorerService().getWebAddress(account.keypair!.address);

      ref.read(webSelectedAccountProvider.notifier).setVfx(
          account.keypair!,
          webAddress.balance,
          webAddress.balanceLocked,
          webAddress.balanceTotal,
          webAddress.adnr);
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
  }

  void btcLoop() async {
    getBtcBalances();
  }

  Future<void> getAddress() async {
    if (state.keypair == null) {
      return;
    }
    final webAddress =
        await ExplorerService().getWebAddress(state.keypair!.address);

    state = state.copyWith(
      balance: webAddress.balance,
      balanceLocked: webAddress.balanceLocked,
      balanceTotal: webAddress.balanceTotal,
      adnr: webAddress.adnr,
    );
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
    final webAddress =
        await ExplorerService().getWebAddress(state.raKeypair!.address);

    state = state.copyWith(
      raBalance: webAddress.balance,
      raBalanceLocked: webAddress.balanceLocked,
      raBalanceTotal: webAddress.balanceTotal,
      raActivated: webAddress.activated,
      raDeactivated: webAddress.deactivated,
    );
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
