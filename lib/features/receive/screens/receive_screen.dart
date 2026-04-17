import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/components/currency_segmented_button.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/components.dart';
import '../../btc/models/btc_address_type.dart';
import '../../btc/providers/btc_account_list_provider.dart';
import '../../../core/components/badges.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/components/back_to_home_button.dart';
import '../../../core/base_screen.dart';
import '../../../core/dialogs.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/theme/pretty_icons.dart';
import '../../../utils/toast.dart';
import '../../../utils/validation.dart';
import '../../encrypt/utils.dart';
import '../../wallet/components/invalid_wallet.dart';
import '../../wallet/providers/wallet_list_provider.dart';
import '../components/recieve_request_buttons.dart';

class ReceiveScreen extends BaseScreen {
  const ReceiveScreen({Key? key}) : super(key: key);

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    final isBtc = ref.watch(sessionProvider.select((v) => v.btcSelected));

    return AppBar(
      title: Text(AppLocalizations.of(context).receiveAppBarTitle(isBtc ? 'BTC' : 'VFX')),
      backgroundColor: Colors.black12,
      shadowColor: Colors.transparent,
      // leading: BackToHomeButton(),
    );
  }

  Future<void> _handleCopyAddress(BuildContext context, String address) async {
    await Clipboard.setData(ClipboardData(text: address));
    Toast.message(AppLocalizations.of(context).messageAddressCopied);
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    final currentWallet = !session.btcSelected ? session.currentWallet : null;
    final btcAccount = session.btcSelected ? session.currentBtcAccount : null;

    if (currentWallet == null && btcAccount == null) {
      return InvalidWallet(message: AppLocalizations.of(context).messageNoAccountSelected);
    }

    return Column(
      key: Key("RBX"),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: CurrencySegementedButton(includeAny: false),
        ),
        Builder(
          builder: (context) {
            if (currentWallet != null) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (currentWallet.isReserved &&
                      !currentWallet.isNetworkProtected)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AppBadge(
                        label: AppLocalizations.of(context).sendBadgeNotActivated,
                        variant: AppColorVariant.Danger,
                      ),
                    ),
                  AppCard(
                    padding: 8,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.account_balance_wallet),
                          subtitle: Text(
                            AppLocalizations.of(context).receiveSelectedVfxAddress(currentWallet.isReserved ? ' Vault Account' : ''),
                            style: TextStyle(
                              color: currentWallet.isReserved
                                  ? AppColors.getReserve()
                                  : AppColors.getBlue(),
                            ),
                          ),
                          // subtitle: currentWallet.friendlyName != null ? Text(currentWallet.friendlyName!) : null,
                          // title: TextFormField(
                          //   initialValue: currentWallet.address,
                          //   decoration: const InputDecoration(
                          //     label: Text("Wallet Address"),
                          //   ),
                          //   style: const TextStyle(fontSize: 13),
                          //   readOnly: true,
                          // ),
                          title: SelectableText(
                            currentWallet.address,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () async {
                                  if (currentWallet.isReserved &&
                                      !currentWallet.isNetworkProtected) {
                                    Toast.error(
                                        AppLocalizations.of(context).receiveVaultNotActivatedToast);
                                    return;
                                  }
                                  _handleCopyAddress(context, currentWallet.address);
                                },
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Divider(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            AppVerticalIconButton(
                              label: AppLocalizations.of(context).receiveActionCopyAddress,
                              prettyIconType: PrettyIconType.custom,
                              icon: Icons.copy,
                              onPressed: () {
                                if (currentWallet.isReserved &&
                                    !currentWallet.isNetworkProtected) {
                                  Toast.error(
                                      AppLocalizations.of(context).receiveVaultNotActivatedToast);
                                  return;
                                }
                                _handleCopyAddress(context, currentWallet.address);
                              },
                            ),
                            AppVerticalIconButton(
                              label: AppLocalizations.of(context).receiveActionNewAccount,
                              prettyIconType: PrettyIconType.custom,
                              icon: Icons.add,
                              onPressed: () async {
                                if (!await passwordRequiredGuard(context, ref))
                                  return;
                                await ref
                                    .read(walletListProvider.notifier)
                                    .create();
                              },
                            ),
                            AppVerticalIconButton(
                              label: AppLocalizations.of(context).receiveActionImportKey,
                              prettyIconType: PrettyIconType.custom,
                              icon: Icons.upload,
                              onPressed: () async {
                                if (!await passwordRequiredGuard(context, ref))
                                  return;

                                PromptModal.show(
                                  title: AppLocalizations.of(context).walletImport,
                                  validator: (String? value) =>
                                      formValidatorNotEmpty(
                                          value, AppLocalizations.of(context).walletPrivateKey),
                                  labelText: AppLocalizations.of(context).walletPrivateKey,
                                  onValidSubmission: (value) async {
                                    final resync = await ConfirmDialog.show(
                                      title: AppLocalizations.of(context).receiveRescanDialogTitle,
                                      body:
                                          AppLocalizations.of(context).receiveRescanDialogBody,
                                      confirmText: AppLocalizations.of(context).actionYes,
                                      cancelText: AppLocalizations.of(context).actionNo,
                                    );

                                    await ref
                                        .read(walletListProvider.notifier)
                                        .import(value, false, resync == true);
                                  },
                                );
                              },
                            ),
                            RecieveCopyLinkButton(
                              currency: "vfx",
                              address: currentWallet.address,
                              domain: currentWallet.adnr,
                            ),
                            RecieveGenerateQrCode(
                              currency: "vfx",
                              address: currentWallet.address,
                              domain: currentWallet.adnr,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              );
            }

            if (btcAccount != null) {
              return Column(
                key: Key("BTC"),
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppCard(
                    padding: 8,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.account_balance_wallet),
                          subtitle: Text(
                            AppLocalizations.of(context).receiveSelectedBtcAddress,
                            style: TextStyle(
                              color: AppColors.getBtc(),
                            ),
                          ),
                          title: SelectableText(
                            btcAccount.address,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () async {
                              _handleCopyAddress(context, btcAccount.address);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Divider(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            AppVerticalIconButton(
                              label: AppLocalizations.of(context).receiveActionCopyAddress,
                              icon: Icons.copy,
                              onPressed: () {
                                _handleCopyAddress(context, btcAccount.address);
                              },
                            ),
                            AppVerticalIconButton(
                              label: AppLocalizations.of(context).receiveActionNewAccount,
                              icon: Icons.add,
                              onPressed: () async {
                                if (!await passwordRequiredGuard(context, ref))
                                  return;

                                final account = await ref
                                    .read(btcAccountListProvider.notifier)
                                    .create();
                                if (account == null) {
                                  Toast.error();
                                  return;
                                }

                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(AppLocalizations.of(context).receiveBtcAccountCreatedTitle),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                                AppLocalizations.of(context).receiveBtcAccountCreatedBody),
                                          ),
                                          ListTile(
                                            leading: const Icon(
                                                Icons.account_balance_wallet),
                                            title: TextFormField(
                                              initialValue: account.address,
                                              decoration: InputDecoration(
                                                  label: Text(
                                                AppLocalizations.of(context).labelAddress,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .btcOrange),
                                              )),
                                              readOnly: true,
                                              style:
                                                  const TextStyle(fontSize: 13),
                                            ),
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.security),
                                            title: TextFormField(
                                              initialValue: account.privateKey,
                                              decoration: InputDecoration(
                                                label: Text(AppLocalizations.of(context).walletPrivateKey,
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .btcOrange)),
                                              ),
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                              readOnly: true,
                                            ),
                                            trailing: IconButton(
                                              icon: Icon(
                                                Icons.copy,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .btcOrange,
                                              ),
                                              onPressed: () async {
                                                await Clipboard.setData(
                                                    ClipboardData(
                                                        text: account
                                                            .privateKey));
                                                Toast.message(
                                                    AppLocalizations.of(context).messagePrivateKeyCopied);
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
                                              AppLocalizations.of(context).actionDone,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .btcOrange),
                                            ))
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            AppVerticalIconButton(
                              label: AppLocalizations.of(context).receiveActionImportKey,
                              icon: Icons.upload,
                              onPressed: () async {
                                if (!await passwordRequiredGuard(context, ref))
                                  return;
                                final privateKeyController =
                                    TextEditingController();
                                final List<String>? data = await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title:
                                          Text(AppLocalizations.of(context).receiveBtcImportKeyDialogTitle),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                                AppLocalizations.of(context).receiveBtcImportKeyDialogBody),
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.security),
                                            title: TextFormField(
                                              controller: privateKeyController,
                                              decoration: InputDecoration(
                                                  label: Text(
                                                AppLocalizations.of(context).walletPrivateKey,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .btcOrange),
                                              )),
                                              style:
                                                  const TextStyle(fontSize: 13),
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
                                            AppLocalizations.of(context).actionCancel,
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop([
                                              privateKeyController.text,
                                              "test"
                                            ]);
                                          },
                                          child: Text(
                                            AppLocalizations.of(context).actionImport,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .btcOrange),
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
                                        .importPrivateKey(
                                            privateKey, addressType);
                                    final btcAccountSyncInfo = ref.watch(
                                        sessionProvider.select(
                                            (v) => v.btcAccountSyncInfo));

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
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              );
            }

            return InvalidWallet(message: AppLocalizations.of(context).messageNoAccountSelected);
          },
        ),
      ],
    );
  }
}
