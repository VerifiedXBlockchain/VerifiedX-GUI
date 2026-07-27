import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/core/services/explorer_service.dart';
import 'package:rbx_wallet/core/theme/app_theme.dart';
import 'package:rbx_wallet/features/global_loader/global_loading_provider.dart';
import 'package:rbx_wallet/features/payment/services/butterfly_service.dart';
import '../../app.dart';
import '../../core/app_constants.dart';
import '../../core/components/buttons.dart';
import '../../core/dialogs.dart';
import '../../core/providers/session_provider.dart';
import '../../core/providers/web_session_provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/components.dart';
import '../btc/models/btc_address_type.dart';
import '../btc/providers/btc_account_list_provider.dart';
import '../btc/utils.dart' as btc_utils;
import '../btc_web/services/btc_web_service.dart';
import '../btc_web/providers/btc_web_transaction_list_provider.dart';
import '../encrypt/utils.dart';
import '../moonpay/services/moonpay_service.dart';
import '../payment/components/payment_disclaimer.dart';
import 'package:rbx_wallet/features/payment/components/payment_iframe_container.dart'
    if (dart.library.io) 'package:rbx_wallet/features/payment/components/payment_iframe_container_mock.dart';
import 'package:rbx_wallet/features/wallet/components/bulk_import_wallet_modal.dart';
import 'package:rbx_wallet/features/wallet/providers/wallet_list_provider.dart';
import 'package:rbx_wallet/utils/guards.dart';
import 'package:rbx_wallet/utils/toast.dart';
import 'package:rbx_wallet/utils/validation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../core/breakpoints.dart';
import '../../core/env.dart';
import '../payment/components/payment_iframe_container_crypto_dot_com.dart'
    if (dart.library.io) '../payment/components/payment_iframe_container_crypto_dot_com_mock.dart';
import '../payment/payment_utils.dart';
import '../price/providers/price_detail_providers.dart';
import '../smart_contracts/components/sc_creator/common/modal_container.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../l10n/l10n_helper.dart';

enum VfxOrBtcOption {
  vfx,
  btc,
}

enum _NewOrImportOption {
  create,
  import,
}

class AccountUtils {
  static Future<void> promptVfxOrBtc(
      BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final selection = await SpecialDialog<VfxOrBtcOption>().show(
      context,
      title: l10n.txpAddNewAccount,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            dense: true,
            // leading: Icon(Icons.add),
            title: Text(
              "VFX",
              style: TextStyle(color: AppColors.getBlue()),
            ),
            subtitle: Text(l10n.txpSetupVfxAccount),
            trailing: Icon(
              Icons.chevron_right,
              color: Colors.white54,
            ),
            onTap: () {
              Navigator.of(context).pop(VfxOrBtcOption.vfx);
            },
          ),
          Divider(),
          ListTile(
            dense: true,
            // leading: Icon(Icons.upload),
            title: Text(
              "BTC",
              style: TextStyle(color: AppColors.getBtc()),
            ),
            subtitle: Text(l10n.txpSetupBtcAccount),
            trailing: Icon(
              Icons.chevron_right,
              color: Colors.white54,
            ),
            onTap: () {
              Navigator.of(context).pop(VfxOrBtcOption.btc);
            },
          ),
        ],
      ),
    );

    switch (selection) {
      case null:
        return;

      case VfxOrBtcOption.vfx:
        return await promptVfxNewOrImport(context, ref);
      case VfxOrBtcOption.btc:
        return await promptBtcNewOrImport(context, ref);
    }
  }

  static Future<void> promptVfxNewOrImport(
      BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final selection = await SpecialDialog<_NewOrImportOption>().show(
      context,
      title: l10n.txpAddVfxAccount,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            dense: true,
            leading: Icon(Icons.add, color: AppColors.getBlue()),
            title: Text(l10n.txpCreate),
            subtitle: Text(l10n.txpCreateVfxAccountSub),
            trailing: Icon(
              Icons.chevron_right,
              color: Colors.white54,
            ),
            onTap: () {
              Navigator.of(context).pop(_NewOrImportOption.create);
            },
          ),
          Divider(),
          ListTile(
            dense: true,
            leading: Icon(Icons.upload, color: AppColors.getBlue()),
            title: Text(l10n.actionImport),
            subtitle: Text(l10n.txpImportVfxKeySub),
            trailing: Icon(
              Icons.chevron_right,
              color: Colors.white54,
            ),
            onTap: () {
              Navigator.of(context).pop(_NewOrImportOption.import);
            },
          ),
        ],
      ),
    );

    switch (selection) {
      case null:
        return;
      case _NewOrImportOption.create:
        return newVfxAccount(context, ref);
      case _NewOrImportOption.import:
        return importVfxAccount(context, ref);
    }
  }

  static Future<void> promptBtcNewOrImport(
      BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final selection = await SpecialDialog<_NewOrImportOption>().show(
      context,
      title: l10n.txpAddBtcAccount,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            dense: true,
            leading: Icon(
              Icons.add,
              color: AppColors.getBtc(),
            ),
            title: Text(l10n.txpCreate),
            subtitle: Text(l10n.txpCreateBtcAccountSub),
            trailing: Icon(
              Icons.chevron_right,
              color: Colors.white54,
            ),
            onTap: () {
              Navigator.of(context).pop(_NewOrImportOption.create);
            },
          ),
          Divider(),
          ListTile(
            dense: true,
            leading: Icon(
              Icons.upload,
              color: AppColors.getBtc(),
            ),
            title: Text(l10n.actionImport),
            subtitle: Text(l10n.txpImportBtcKeySub),
            trailing: Icon(
              Icons.chevron_right,
              color: Colors.white54,
            ),
            onTap: () {
              Navigator.of(context).pop(_NewOrImportOption.import);
            },
          ),
        ],
      ),
    );

    switch (selection) {
      case null:
        return;
      case _NewOrImportOption.create:
        return newBtcAccount(context, ref);
      case _NewOrImportOption.import:
        return importBtcAccount(context, ref);
    }
  }

  static Future<void> newVfxAccount(BuildContext context, WidgetRef ref) async {
    if (!await passwordRequiredGuard(context, ref)) return;

    await ref.read(walletListProvider.notifier).create();
  }

  static Future<void> importVfxAccount(
      BuildContext context, WidgetRef ref) async {
    if (!await passwordRequiredGuard(context, ref)) return;
    if (!widgetGuardWalletIsNotResyncing(ref)) return;

    final l10n = AppLocalizations.of(context);

    PromptModal.show(
      title: l10n.walletImportTitle,
      titleTrailing: InkWell(
        child: Text(
          l10n.walletBulkImportLabel,
          style: const TextStyle(
            fontSize: 12,
            // decoration: TextDecoration.underline,
            color: Colors.white70,
          ),
        ),
        onTap: () {
          Navigator.of(rootNavigatorKey.currentContext!).pop();

          showModalBottomSheet(
              context: rootNavigatorKey.currentContext!,
              builder: (context) {
                return const BulkImportWalletModal();
              });
        },
      ),
      validator: (String? value) => formValidatorNotEmpty(value, l10n.walletPrivateKeyValidatorLabel),
      labelText: l10n.walletPrivateKeyLabel,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]'))
      ],
      onValidSubmission: (value) async {
        final resync = await ConfirmDialog.show(
          title: l10n.walletRescanBlocksTitle,
          body: l10n.walletRescanBlocksBodyKey,
          confirmText: l10n.actionYes,
          cancelText: l10n.actionNo,
        );

        await ref
            .read(walletListProvider.notifier)
            .import(value, false, resync == true);
      },
    );
  }

  static Future<void> newBtcAccount(BuildContext context, WidgetRef ref) async {
    if (!await passwordRequiredGuard(context, ref)) return;

    final l10n = AppLocalizations.of(context);

    final account = await ref.read(btcAccountListProvider.notifier).create();
    if (account == null) {
      Toast.error();
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.walletBtcAccountCreatedTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(l10n.walletBtcAccountCreatedBody),
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: TextFormField(
                  initialValue: account.address,
                  decoration: InputDecoration(
                      label: Text(
                    l10n.walletAddressLabel,
                    style: TextStyle(color: AppColors.getBtc()),
                  )),
                  readOnly: true,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.security),
                title: TextFormField(
                  initialValue: account.privateKey,
                  decoration: InputDecoration(
                    label: Text(l10n.walletPrivateKeyLabel,
                        style: TextStyle(color: AppColors.getBtc())),
                  ),
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                  readOnly: true,
                ),
                trailing: IconButton(
                  icon: Icon(
                    Icons.copy,
                    color: AppColors.getBtc(),
                  ),
                  onPressed: () async {
                    await Clipboard.setData(
                        ClipboardData(text: account.privateKey));
                    Toast.message(l10n.walletPrivateKeyCopiedToast);
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  l10n.walletDoneLabel,
                  style: TextStyle(color: AppColors.getBtc()),
                ))
          ],
        );
      },
    );
  }

  static Future<void> importBtcAccount(
      BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final privateKeyController = TextEditingController();
    final List<String>? data = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.walletImportBtcDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(l10n.walletImportBtcDialogBody),
              ),
              ListTile(
                leading: const Icon(Icons.security),
                title: TextFormField(
                  controller: privateKeyController,
                  decoration: InputDecoration(
                      label: Text(
                    l10n.walletPrivateKeyLabel,
                    style: TextStyle(color: AppColors.getBtc()),
                  )),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                l10n.actionCancel,
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop([privateKeyController.text, "test"]);
              },
              child: Text(
                l10n.actionImport,
                style: TextStyle(color: AppColors.getBtc()),
              ),
            )
          ],
        );
      },
    );

    if (data != null) {
      if (data.length == 2) {
        final privateKey = data.first;
        const addressType = BtcAddressType.segwit;
        final success = await ref
            .read(btcAccountListProvider.notifier)
            .importPrivateKey(privateKey, addressType);
        final btcAccountSyncInfo = ref.read(sessionProvider).btcAccountSyncInfo;

        if (success) {
          if (btcAccountSyncInfo != null) {
            Toast.message(l10n.walletPrivateKeyImportedSyncToast(
                btcAccountSyncInfo.nextSyncFormatted));
          } else {
            Toast.message(l10n.walletPrivateKeyImportedToast);
          }
        } else {
          Toast.error();
        }
      }
    }
  }

  static Future<void> getCoin(
      BuildContext context, WidgetRef ref, VfxOrBtcOption? type,
      {String? btcAddressOverride}) async {
    final l10n = AppLocalizations.of(context);
    type ??= await showModalBottomSheet(
        context: context,
        builder: (context) {
          return ModalContainer(
            title: l10n.txpChooseCoinType,
            withDecor: false,
            withClose: true,
            children: [
              AppCard(
                padding: 0,
                child: ListTile(
                    title: Text(l10n.txpGetVfxNow),
                    onTap: () {
                      Navigator.of(context).pop(VfxOrBtcOption.vfx);
                    },
                    trailing: Icon(Icons.chevron_right, size: 16)),
              ),
              SizedBox(
                height: 12,
              ),
              AppCard(
                padding: 0,
                child: ListTile(
                    title: Text(l10n.txpGetBtcNow),
                    onTap: () {
                      Navigator.of(context).pop(VfxOrBtcOption.btc);
                    },
                    trailing: Icon(Icons.chevron_right, size: 16)),
              ),
            ],
          );
        });

    if (type == null) {
      return;
    }

    final vfxAddress = kIsWeb
        ? ref.read(webSessionProvider).keypair?.address
        : ref.read(sessionProvider).currentWallet?.address;
    final btcAddress = btcAddressOverride ??
        (kIsWeb
            ? ref.read(webSessionProvider).btcKeypair?.address
            : ref.read(sessionProvider).currentBtcAccount?.address);

    final address = type == VfxOrBtcOption.vfx ? vfxAddress : btcAddress;

    if (address == null) {
      Toast.error(l10n.txpNoAddressSelected);
      return;
    }

    PaymentGateway? paymentGateway = await showModalBottomSheet(
        context: context,
        builder: (context) {
          return ModalContainer(
            title: l10n.txpChoosePaymentGateway,
            withClose: true,
            children: [
              if (type == VfxOrBtcOption.vfx
                      ? Env.moonpayEnabledVFX
                      : Env.moonpayEnabled) ...[
                AppCard(
                  padding: 0,
                  child: ListTile(
                      title: Text("Moonpay"),
                      onTap: () {
                        Navigator.of(context).pop(PaymentGateway.moonpay);
                      },
                      trailing: Icon(Icons.chevron_right, size: 16)),
                ),
                SizedBox(
                  height: 12,
                ),
              ],
              if (ALLOW_BIDS_WITHOUT_BALANCE || type == VfxOrBtcOption.btc) ...[
                AppCard(
                  padding: 0,
                  child: ListTile(
                      title: Text("Crypto.com"),
                      onTap: () {
                        Navigator.of(context).pop(PaymentGateway.cryptoDotCom);
                      },
                      trailing: Icon(Icons.chevron_right, size: 16)),
                ),
                SizedBox(
                  height: 12,
                ),
              ],
              AppCard(
                padding: 0,
                child: ListTile(
                    title: Text("Banxa"),
                    onTap: () {
                      Navigator.of(context).pop(PaymentGateway.banxa);
                    },
                    trailing: Icon(Icons.chevron_right, size: 16)),
              ),
              if (INCLUDE_STRIPE_INTEGRATION) ...[
                SizedBox(
                  height: 12,
                ),
                AppCard(
                  padding: 0,
                  child: ListTile(
                      title: Text(l10n.txpStripeCreditCard),
                      onTap: () {
                        Navigator.of(context).pop(PaymentGateway.stripe);
                      },
                      trailing: Icon(Icons.chevron_right, size: 16)),
                ),
              ],
              if (Env.isTestNet) ...[
                SizedBox(
                  height: 12,
                ),
                AppCard(
                  padding: 0,
                  child: ListTile(
                      title: Text(l10n.txpTestnetFaucet),
                      onTap: () {
                        Navigator.of(context).pop(PaymentGateway.testnetFaucet);
                      },
                      trailing: Icon(Icons.chevron_right, size: 16)),
                ),
              ]
            ],
          );
        });
    if (paymentGateway == null) {
      return;
    }
    if (paymentGateway.hasTerms) {
      final agreed = await PaymentTermsDialog.show(context, paymentGateway);

      if (agreed != true) {
        return;
      }
    }

    if (type == VfxOrBtcOption.vfx) {
      switch (paymentGateway) {
        case PaymentGateway.banxa:
          if (kIsWeb) {
            final maxWidth =
                BreakPoints.useMobileLayout(context) ? 400.0 : 750.0;
            final maxHeight =
                BreakPoints.useMobileLayout(context) ? 500.0 : 700.0;
            double width = MediaQuery.of(context).size.width - 32;
            double height = MediaQuery.of(context).size.height - 64;

            if (width > maxWidth) {
              width = maxWidth;
            }

            if (height > maxHeight) {
              height = maxHeight;
            }
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  contentPadding: EdgeInsets.zero,
                  insetPadding: EdgeInsets.zero,
                  actionsPadding: EdgeInsets.zero,
                  buttonPadding: EdgeInsets.zero,
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      WebPaymentIFrameContainer(
                        walletAddress: address,
                        coinAmount: 100,
                        width: width,
                        height: height,
                        coinType: 'vfx',
                      ),
                      SizedBox(
                        width: width,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: PaymentDisclaimer(
                            paymentGateway: paymentGateway,
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        l10n.actionClose,
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                );
              },
            );
          } else {
            final url = banxaPaymentUrl(
                amount: 100, walletAddress: address, currency: "VFX");
            if (url != null) {
              launchUrl(Uri.parse(url));
            }
          }
          break;
        case PaymentGateway.moonpay:
          MoonpayService().buy(Env.isTestNet ? 'sandbox' : 'production',
              'btc', '100', address, true);
          break;
        case PaymentGateway.cryptoDotCom:
        case PaymentGateway.stripe:
          final amount = await promptForVfxPurchaseAmount(context, ref);

          if (amount == null) {
            Toast.error(l10n.btcInvalidAmount);
            return;
          }
          ref.read(globalLoadingProvider.notifier).start();

          final result = await ButterflyService()
              .getQuote(amount: amount, vfxAddress: address);
          ref.read(globalLoadingProvider.notifier).complete();

          if (result == null) {
            Toast.error();
            return;
          }

          final confirmed = await ConfirmDialog.show(
              title: l10n.txpVfxQuote,
              body: l10n.txpVfxQuoteBody(
                  "${result.amountVfx}", result.amountUsd.toStringAsFixed(2)),
              confirmText: l10n.actionContinue,
              cancelText: l10n.actionCancel);
          if (confirmed != true) {
            return;
          }

          if (paymentGateway == PaymentGateway.cryptoDotCom) {
            if (kIsWeb) {
              await showCryptoMerchantIframeEmbed(context,
                  result.cryptoDotComCheckoutUrl, result.purchaseUuid, false);
            } else {
              launchUrlString(result.cryptoDotComCheckoutUrl);
            }
          } else {
            launchUrlString(result.stripeCheckoutUrl);
          }

          break;

        case PaymentGateway.testnetFaucet:
          launchUrlString("https://testnet.rbx.network/faucet");
          break;
      }
    }

    if (type == VfxOrBtcOption.btc) {
      switch (paymentGateway) {
        case PaymentGateway.banxa:
          if (kIsWeb) {
            final maxWidth =
                BreakPoints.useMobileLayout(context) ? 400.0 : 750.0;
            final maxHeight =
                BreakPoints.useMobileLayout(context) ? 500.0 : 700.0;
            double width = MediaQuery.of(context).size.width - 32;
            double height = MediaQuery.of(context).size.height - 64;

            if (width > maxWidth) {
              width = maxWidth;
            }

            if (height > maxHeight) {
              height = maxHeight;
            }
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  contentPadding: EdgeInsets.zero,
                  insetPadding: EdgeInsets.zero,
                  actionsPadding: EdgeInsets.zero,
                  buttonPadding: EdgeInsets.zero,
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      WebPaymentIFrameContainer(
                        walletAddress: address,
                        coinAmount: 0.001,
                        width: width,
                        height: height,
                        coinType: 'btc',
                      ),
                      SizedBox(
                        width: width,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: PaymentDisclaimer(
                            paymentGateway: paymentGateway,
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        l10n.actionClose,
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                );
              },
            );
          } else {
            final url = banxaPaymentUrl(
                amount: 5000, walletAddress: address, currency: "BTC");
            if (url != null) {
              launchUrl(Uri.parse(url));
            }
          }
          break;
        case PaymentGateway.moonpay:
          MoonpayService().buy(Env.isTestNet ? 'sandbox' : 'production',
              'btc', '100', address, true);
          break;

        case PaymentGateway.cryptoDotCom:
          final url = await getCryptoDotComBtcOnRampUrl(
              amountFiat: 100, walletAddress: address);

          if (url != null) {
            if (kIsWeb) {
              final maxWidth =
                  BreakPoints.useMobileLayout(context) ? 400.0 : 750.0;
              final maxHeight =
                  BreakPoints.useMobileLayout(context) ? 500.0 : 700.0;
              double width = MediaQuery.of(context).size.width - 32;
              double height = MediaQuery.of(context).size.height - 64;

              if (width > maxWidth) {
                width = maxWidth;
              }

              if (height > maxHeight) {
                height = maxHeight;
              }
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    contentPadding: EdgeInsets.zero,
                    insetPadding: EdgeInsets.zero,
                    actionsPadding: EdgeInsets.zero,
                    buttonPadding: EdgeInsets.zero,
                    content: SizedBox(
                      width: width,
                      height: height,
                      child: WebPaymentIFrameContainerCryptoDotCom(
                        url: url,
                        width: width,
                        height: height,
                      ),
                    ),
                    actions: [
                      SizedBox(
                        width: width,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: PaymentDisclaimer(
                            paymentGateway: paymentGateway,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          l10n.actionClose,
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  );
                },
              );
            } else {
              launchUrlString(url);
            }
          }

          break;
        case PaymentGateway.stripe:
          Toast.error(l10n.sendBadgeNotActivated);
          break;
        case PaymentGateway.testnetFaucet:
          // launchUrlString("https://testnet.rbx.network/faucet");
          launchUrlString("https://mempool.space/testnet4/faucet");
          break;
      }
    }
  }

  static Future<void> sellCoin(
      BuildContext context, WidgetRef ref, VfxOrBtcOption? type) async {
    final l10n = AppLocalizations.of(context);
    type ??= await showModalBottomSheet(
        context: context,
        builder: (context) {
          return ModalContainer(
            title: l10n.txpChooseCoinType,
            withDecor: false,
            withClose: true,
            children: [
              AppCard(
                padding: 0,
                child: ListTile(
                    title: Text(l10n.txpGetVfxNow),
                    onTap: () {
                      Navigator.of(context).pop(VfxOrBtcOption.vfx);
                    },
                    trailing: Icon(Icons.chevron_right, size: 16)),
              ),
              SizedBox(
                height: 12,
              ),
              AppCard(
                padding: 0,
                child: ListTile(
                    title: Text(l10n.txpGetBtcNow),
                    onTap: () {
                      Navigator.of(context).pop(VfxOrBtcOption.btc);
                    },
                    trailing: Icon(Icons.chevron_right, size: 16)),
              ),
            ],
          );
        });

    if (type == null) {
      return;
    }

    final vfxAddress = kIsWeb
        ? ref.read(webSessionProvider).keypair?.address
        : ref.read(sessionProvider).currentWallet?.address;
    final btcAddress = kIsWeb
        ? ref.read(webSessionProvider).btcKeypair?.address
        : ref.read(sessionProvider).currentBtcAccount?.address;

    final address = type == VfxOrBtcOption.vfx ? vfxAddress : btcAddress;

    if (address == null) {
      Toast.error(l10n.txpNoAddressSelected);
      return;
    }

    final agreed =
        await PaymentTermsDialog.show(context, PaymentGateway.moonpay);

    if (agreed != true) {
      return;
    }

    if (type == VfxOrBtcOption.vfx) {
      Toast.message(l10n.txpVfxOffRampSoon);
    }

    if (type == VfxOrBtcOption.btc) {
      if (kIsWeb) {
        final btcKeypair = ref.read(webSessionProvider).btcKeypair;
        print("🌙 Starting MoonPay offramp flow");
        print("  btcKeypair available: ${btcKeypair != null}");

        MoonpayService().sell(
          Env.isTestNet ? 'sandbox' : 'production',
          'btc',
          '100',
          address,
          true,
          onDeposit: btcKeypair != null
              ? (cryptoCurrency, cryptoCurrencyAmount, depositWalletAddress) async {
                  print("🚀 onDeposit handler called in wallet utils");
                  print("  cryptoCurrency: $cryptoCurrency");
                  print("  cryptoCurrencyAmount: $cryptoCurrencyAmount");
                  print("  depositWalletAddress: $depositWalletAddress");

                  // Get BTC balance
                  final balance = ref.read(webSessionProvider).btcBalanceInfo?.btcBalance;
                  print("  Current BTC balance: $balance");

                  if (balance == null || balance <= 0) {
                    print("❌ Balance check failed: balance is null or zero");
                    Toast.error(globalL10n.txpBtcNoBalance);
                    return null;
                  }

                  if (balance <= cryptoCurrencyAmount) {
                    print("❌ Balance check failed: insufficient balance");
                    Toast.error(globalL10n.txpNotEnoughBtcFee);
                    return null;
                  }

                  print("✅ Balance check passed, showing confirmation dialog");
                  // Show confirmation dialog with 3 options
                  final choice = await showDialog<String>(
                    context: rootNavigatorKey.currentContext!,
                    barrierDismissible: false,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(globalL10n.txpCompleteMoonpayDeposit),
                        content: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                globalL10n.txpOffRampInstructions,
                                style: TextStyle(color: Colors.white70),
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                initialValue: cryptoCurrencyAmount.toString(),
                                readOnly: true,
                                decoration: InputDecoration(
                                  label: Text(
                                    globalL10n.labelAmount,
                                    style: TextStyle(color: Color(0xfff7931a)),
                                  ),
                                  suffix: IconButton(
                                    icon: Icon(Icons.copy),
                                    onPressed: () async {
                                      await Clipboard.setData(
                                          ClipboardData(text: cryptoCurrencyAmount.toString()));
                                      Toast.message(globalL10n.txpAmountCopied);
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 12),
                              TextFormField(
                                initialValue: depositWalletAddress,
                                readOnly: true,
                                decoration: InputDecoration(
                                  label: Text(
                                    globalL10n.txpDepositAddressMoonpay,
                                    style: TextStyle(color: Color(0xfff7931a)),
                                  ),
                                  suffix: IconButton(
                                    icon: Icon(Icons.copy),
                                    onPressed: () async {
                                      await Clipboard.setData(
                                          ClipboardData(text: depositWalletAddress));
                                      Toast.message(globalL10n.txpAddressCopied);
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      globalL10n.txpManualDeposit,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      globalL10n.txpManualDepositBody(
                                          "$cryptoCurrencyAmount", cryptoCurrency),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white60,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                globalL10n.btcFromAddress(btcKeypair.address),
                                style: TextStyle(fontSize: 13, color: Colors.white54),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop('cancel');
                            },
                            child: Text(
                              globalL10n.actionCancel,
                              style: TextStyle(color: Theme.of(context).colorScheme.info),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop('manual');
                            },
                            child: Text(
                              globalL10n.txpSendManually,
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop('send');
                            },
                            child: Text(
                              globalL10n.txpSendNow,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  print("Dialog result: $choice");

                  if (choice == 'cancel' || choice == null) {
                    print("❌ User cancelled");
                    return null;
                  }

                  if (choice == 'manual') {
                    print("✅ User chose manual send, returning 'manual' to MoonPay");
                    Toast.message(globalL10n.txpMoonpayManualMarked);
                    return 'manual';
                  }

                  print("✅ User confirmed, prompting for fee rate");
                  // Prompt for fee rate
                  final feeRate = await btc_utils.promptForFeeRate(rootNavigatorKey.currentContext!);

                  print("Fee rate selected: $feeRate");

                  if (feeRate == null) {
                    print("❌ User cancelled at fee rate selection");
                    return null;
                  }

                  print("✅ Fee rate confirmed, showing final confirmation");
                  // Final confirmation with fee
                  final finalConfirmed = await ConfirmDialog.show(
                    title: globalL10n.txpConfirmSend,
                    body: globalL10n.txpConfirmSendBody(
                        "$cryptoCurrencyAmount",
                        cryptoCurrency,
                        depositWalletAddress,
                        btcKeypair.address,
                        "$feeRate"),
                    confirmText: globalL10n.actionSend,
                    cancelText: globalL10n.actionCancel,
                  );

                  print("Final confirmation result: $finalConfirmed");

                  if (finalConfirmed != true) {
                    print("❌ User cancelled at final confirmation");
                    return null;
                  }

                  print("✅ User confirmed, sending BTC transaction");
                  // Send BTC transaction
                  final txHash = await BtcWebService().sendTransaction(
                    btcKeypair.wif,
                    depositWalletAddress,
                    cryptoCurrencyAmount,
                    feeRate,
                  );

                  print("Transaction result: $txHash");

                  if (txHash == null) {
                    print("❌ Transaction failed");
                    Toast.error(globalL10n.txpTransactionFailed);
                    return null;
                  }

                  print("✅ Transaction successful, txHash: $txHash");

                  // Refresh balance
                  ref.invalidate(btcWebTransactionListProvider(btcKeypair.address));
                  Future.delayed(Duration(seconds: 2), () {
                    ref.read(webSessionProvider.notifier).refreshBtcBalanceInfo();
                  });

                  Toast.message(globalL10n.txpSentToAddress(
                      "$cryptoCurrencyAmount", cryptoCurrency, depositWalletAddress));

                  // Show tx details
                  InfoDialog.show(
                    title: globalL10n.txpTransactionSent,
                    buttonColorOverride: Color(0xfff7931a),
                    content: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 600),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            initialValue: txHash,
                            readOnly: true,
                            decoration: InputDecoration(
                              label: Text(
                                globalL10n.txpTransactionHashLabel,
                                style: TextStyle(color: Color(0xfff7931a)),
                              ),
                              suffix: IconButton(
                                icon: Icon(Icons.copy),
                                onPressed: () async {
                                  await Clipboard.setData(ClipboardData(text: txHash));
                                  Toast.message(globalL10n.txpTxHashCopied);
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          AppButton(
                            label: globalL10n.btcOpenInExplorer,
                            variant: AppColorVariant.Btc,
                            type: AppButtonType.Text,
                            onPressed: () {
                              if (Env.btcIsTestNet) {
                                launchUrlString("https://mempool.space/testnet4/tx/$txHash");
                              } else {
                                launchUrlString("https://mempool.space/tx/$txHash");
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );

                  print("🎉 Returning txHash to JS: $txHash");
                  return txHash;
                }
              : null,
        );
      } else {
        Toast.error(l10n.txpNativeMoonpaySoon);
      }
    }
  }

  static Future<void> showCryptoDotComOnrampFlow(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context);
    final type = await showModalBottomSheet(
        context: context,
        builder: (context) {
          return ModalContainer(
            title: l10n.txpCryptoDotComOnRamp,
            withDecor: false,
            withClose: true,
            children: [
              SizedBox(
                height: 8,
              ),
              AppCard(
                padding: 0,
                child: ListTile(
                    title: Text(l10n.txpGetVfxNow),
                    onTap: () {
                      Navigator.of(context).pop(VfxOrBtcOption.vfx);
                    },
                    trailing: Icon(Icons.chevron_right, size: 16)),
              ),
              SizedBox(
                height: 12,
              ),
              AppCard(
                padding: 0,
                child: ListTile(
                    title: Text(l10n.txpGetBtcNow),
                    onTap: () {
                      Navigator.of(context).pop(VfxOrBtcOption.btc);
                    },
                    trailing: Icon(Icons.chevron_right, size: 16)),
              ),
            ],
          );
        });

    if (type == null) return;

    final vfxAddress = kIsWeb
        ? ref.read(webSessionProvider).keypair?.address
        : ref.read(sessionProvider).currentWallet?.address;
    final btcAddress = kIsWeb
        ? ref.read(webSessionProvider).btcKeypair?.address
        : ref.read(sessionProvider).currentBtcAccount?.address;

    final address = type == VfxOrBtcOption.vfx ? vfxAddress : btcAddress;

    if (address == null) {
      Toast.error(l10n.txpNoAddressSelected);
      return;
    }

    final agreed =
        await PaymentTermsDialog.show(context, PaymentGateway.cryptoDotCom);

    if (agreed != true) {
      return;
    }

    if (type == VfxOrBtcOption.vfx) {
      final amount =
          await AccountUtils.promptForVfxPurchaseAmount(context, ref);

      if (amount == null) return;

      ref.read(globalLoadingProvider.notifier).start();

      final result =
          await ButterflyService().getQuote(amount: amount, vfxAddress: address);
      ref.read(globalLoadingProvider.notifier).complete();

      if (result == null) {
        Toast.error();
        return;
      }

      final confirmed = await ConfirmDialog.show(
          title: l10n.txpVfxQuote,
          body: l10n.txpVfxQuoteBody(
              "${result.amountVfx}", "${result.amountUsd}"),
          confirmText: l10n.actionContinue,
          cancelText: l10n.actionCancel);
      if (confirmed != true) {
        return;
      }

      if (kIsWeb) {
        await showCryptoMerchantIframeEmbed(context,
            result.cryptoDotComCheckoutUrl, result.purchaseUuid, false);
      } else {
        launchUrlString(result.cryptoDotComCheckoutUrl);
      }
    } else {
      final url = await getCryptoDotComBtcOnRampUrl(
          amountFiat: 100, walletAddress: address);

      if (url != null) {
        if (kIsWeb) {
          final maxWidth = BreakPoints.useMobileLayout(context) ? 400.0 : 750.0;
          final maxHeight =
              BreakPoints.useMobileLayout(context) ? 500.0 : 700.0;
          double width = MediaQuery.of(context).size.width - 32;
          double height = MediaQuery.of(context).size.height - 64;

          if (width > maxWidth) {
            width = maxWidth;
          }

          if (height > maxHeight) {
            height = maxHeight;
          }
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                contentPadding: EdgeInsets.zero,
                insetPadding: EdgeInsets.zero,
                actionsPadding: EdgeInsets.zero,
                buttonPadding: EdgeInsets.zero,
                content: SizedBox(
                  width: width,
                  height: height,
                  child: WebPaymentIFrameContainerCryptoDotCom(
                    url: url,
                    width: width,
                    height: height,
                  ),
                ),
                actions: [
                  SizedBox(
                    width: width,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: PaymentDisclaimer(
                        paymentGateway: PaymentGateway.cryptoDotCom,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      l10n.actionClose,
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              );
            },
          );
        } else {
          launchUrlString(url);
        }
      }
    }
  }

  static Future<double?> promptForVfxPurchaseAmount(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context);
    final TextEditingController _controller = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey();

    void _submit(BuildContext context) {
      if (!_formKey.currentState!.validate()) return;

      final value = _controller.value.text;

      Navigator.of(context).pop(value);
    }

    final usdPrice = ref.read(vfxCurrentPriceDataDetailProvider);

    final valueStr = await showDialog(
      context: context,
      builder: (context) {
        String helpText = "";

        return AlertDialog(
          title: Text(l10n.txpVfxAmount),
          content: Form(
            key: _formKey,
            child: StatefulBuilder(builder: (context, setState) {
              return ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600, minWidth: 400),
                child: TextFormField(
                  controller: _controller,
                  autofocus: true,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      label: Text(
                        l10n.txpVfxAmount,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                      suffixText: "VFX",
                      helperText: helpText),
                  validator: (v) => formValidatorNumber(v, l10n.labelAmount),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp("[0-9.]"))
                  ],
                  onFieldSubmitted: (value) {
                    _submit(context);
                  },
                  onChanged: (v) {
                    final vDouble = double.tryParse(v);
                    if (vDouble != null) {
                      setState(() {
                        final helpValue = (usdPrice ?? 0) * vDouble;
                        if (helpValue > 0) {
                          final helpValueWithMarkup = helpValue * 1.03;
                          helpText =
                              "\$${helpValueWithMarkup.toStringAsFixed(2)} USD";
                        } else {
                          helpText = "";
                        }
                      });
                    }
                  },
                ),
              );
            }),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.info,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                l10n.actionCancel,
                style: TextStyle(color: Theme.of(context).colorScheme.info),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                primary: Theme.of(context).colorScheme.info,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                _submit(context);
              },
              child: Text(l10n.txpGetQuote,
                  style: TextStyle(color: Theme.of(context).colorScheme.info)),
            )
          ],
        );
      },
    );

    if (valueStr == null) {
      return null;
    }

    final amount = double.tryParse(valueStr);

    if (amount == null) {
      Toast.error(l10n.btcInvalidAmount);
      return null;
    }

    return amount;
  }
}
