import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/core/services/explorer_service.dart';
import '../../app.dart';
import '../../core/dialogs.dart';
import '../../core/providers/session_provider.dart';
import '../../core/providers/web_session_provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/components.dart';
import '../btc/models/btc_address_type.dart';
import '../btc/providers/btc_account_list_provider.dart';
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
import '../payment/components/payment_iframe_container_crypto_dot_com.dart';
import '../payment/payment_utils.dart';
import '../smart_contracts/components/sc_creator/common/modal_container.dart';

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
    final selection = await SpecialDialog<VfxOrBtcOption>().show(
      context,
      title: "Add New Account",
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
            subtitle: Text("Setup a VerifiedX account"),
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
            subtitle: Text("Setup a Bitcoin account"),
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
    final selection = await SpecialDialog<_NewOrImportOption>().show(
      context,
      title: "Add VFX Account",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            dense: true,
            leading: Icon(Icons.add, color: AppColors.getBlue()),
            title: Text("Create"),
            subtitle: Text("Create a new VFX account"),
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
            title: Text("Import"),
            subtitle: Text("Import an existing VFX private key"),
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
    final selection = await SpecialDialog<_NewOrImportOption>().show(
      context,
      title: "Add BTC Account",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            dense: true,
            leading: Icon(
              Icons.add,
              color: AppColors.getBtc(),
            ),
            title: Text("Create"),
            subtitle: Text("Create a new BTC account"),
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
            title: Text("Import"),
            subtitle: Text("Import an existing BTC private key"),
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

    PromptModal.show(
      title: "Import Wallet",
      titleTrailing: InkWell(
        child: const Text(
          "Bulk Import",
          style: TextStyle(
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
      validator: (String? value) => formValidatorNotEmpty(value, "Private Key"),
      labelText: "Private Key",
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]'))
      ],
      onValidSubmission: (value) async {
        final resync = await ConfirmDialog.show(
          title: "Rescan Blocks?",
          body:
              "Would you like to rescan the chain to include any transactions relevant to this key?",
          confirmText: "Yes",
          cancelText: "No",
        );

        await ref
            .read(walletListProvider.notifier)
            .import(value, false, resync == true);
      },
    );
  }

  static Future<void> newBtcAccount(BuildContext context, WidgetRef ref) async {
    if (!await passwordRequiredGuard(context, ref)) return;

    final account = await ref.read(btcAccountListProvider.notifier).create();
    if (account == null) {
      Toast.error();
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("BTC Account Created"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    "Here are your BTC account details. Please ensure to back up your private key in a safe place."),
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: TextFormField(
                  initialValue: account.address,
                  decoration: InputDecoration(
                      label: Text(
                    "Address",
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
                    label: Text("Private Key",
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
                    Toast.message("Private Key copied to clipboard");
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
                  "Done",
                  style: TextStyle(color: AppColors.getBtc()),
                ))
          ],
        );
      },
    );
  }

  static Future<void> importBtcAccount(
      BuildContext context, WidgetRef ref) async {
    final privateKeyController = TextEditingController();
    final List<String>? data = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Import BTC Private Key"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    "Paste in your BTC private key to import your account."),
              ),
              ListTile(
                leading: const Icon(Icons.security),
                title: TextFormField(
                  controller: privateKeyController,
                  decoration: InputDecoration(
                      label: Text(
                    "Private Key",
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
                "Cancel",
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop([privateKeyController.text, "test"]);
              },
              child: Text(
                "Import",
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
            Toast.message(
                "Private Key Imported! Please wait until ${btcAccountSyncInfo.nextSyncFormatted} for the balance to sync.");
          } else {
            Toast.message("Private Key Imported!");
          }
        } else {
          Toast.error();
        }
      }
    }
  }

  static Future<void> getCoin(
      BuildContext context, WidgetRef ref, VfxOrBtcOption? type) async {
    type ??= await showModalBottomSheet(
        context: context,
        builder: (context) {
          return ModalContainer(
            title: "Choose Coin Type",
            withDecor: false,
            withClose: true,
            children: [
              AppCard(
                padding: 0,
                child: ListTile(
                    title: Text("Get \$VFX Now"),
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
                    title: Text("Get \$BTC Now"),
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
      Toast.error("No address selected");
      return;
    }

    PaymentGateway? paymentGateway = await showModalBottomSheet(
        context: context,
        builder: (context) {
          return ModalContainer(
            title: "Choose Payment Gateway",
            withClose: true,
            children: [
              AppCard(
                padding: 0,
                child: ListTile(
                    title: Text("Banxa"),
                    onTap: () {
                      Navigator.of(context).pop(PaymentGateway.banxa);
                    },
                    trailing: Icon(Icons.chevron_right, size: 16)),
              ),
              if (kIsWeb &&
                  (type == VfxOrBtcOption.vfx
                      ? Env.moonpayEnabledVFX
                      : Env.moonpayEnabled)) ...[
                SizedBox(
                  height: 12,
                ),
                AppCard(
                  padding: 0,
                  child: ListTile(
                      title: Text("Moonpay"),
                      onTap: () {
                        Navigator.of(context).pop(PaymentGateway.moonpay);
                      },
                      trailing: Icon(Icons.chevron_right, size: 16)),
                ),
              ],
              if (kIsWeb && type == VfxOrBtcOption.btc) ...[
                SizedBox(
                  height: 12,
                ),
                AppCard(
                  padding: 0,
                  child: ListTile(
                      title: Text("Crypto.com"),
                      onTap: () {
                        Navigator.of(context).pop(PaymentGateway.cryptoDotCom);
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
                      title: Text("Testnet Faucet"),
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
                        "Close",
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
          if (kIsWeb) {
            MoonpayService().buy(Env.isTestNet ? 'sandbox' : 'production',
                'vfx', '100', address, true);
          } else {
            Toast.error("Native Moonpay Integration Activating Soon.");
          }

          break;
        case PaymentGateway.cryptoDotCom:
          Toast.error("Not Activated");
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
                        "Close",
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
          if (kIsWeb) {
            MoonpayService().buy(Env.isTestNet ? 'sandbox' : 'production',
                'btc', '100', address, true);
          } else {
            Toast.error("Native Moonpay Integration Activating Soon.");
          }
          break;

        case PaymentGateway.cryptoDotCom:
          final url = await getCryptoDotComBtcOnRampUrl(
              amountFiat: 100, walletAddress: address);

          if (url != null) {
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
                      WebPaymentIFrameContainerCryptoDotCom(
                        url: url,
                        width: width,
                        height: height,
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
                        "Close",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                );
              },
            );
          }

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
    type ??= await showModalBottomSheet(
        context: context,
        builder: (context) {
          return ModalContainer(
            title: "Choose Coin Type",
            withDecor: false,
            withClose: true,
            children: [
              AppCard(
                padding: 0,
                child: ListTile(
                    title: Text("Get \$VFX Now"),
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
                    title: Text("Get \$BTC Now"),
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
      Toast.error("No address selected");
      return;
    }

    final agreed =
        await PaymentTermsDialog.show(context, PaymentGateway.moonpay);

    if (agreed != true) {
      return;
    }

    if (type == VfxOrBtcOption.vfx) {
      Toast.message("VFX Off Ramp feature coming soon");
    }

    if (type == VfxOrBtcOption.btc) {
      if (kIsWeb) {
        MoonpayService().sell(Env.isTestNet ? 'sandbox' : 'production', 'btc',
            '100', address, true);
      } else {
        Toast.error("Native Moonpay Integration Activating Soon.");
      }
    }
  }
}
