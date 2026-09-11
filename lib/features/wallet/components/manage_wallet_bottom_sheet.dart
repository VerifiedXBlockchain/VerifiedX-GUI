import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/core/dialogs.dart';
import '../../../core/theme/colors.dart';
import '../../btc/models/btc_account.dart';
import '../../btc/providers/btc_account_list_provider.dart';
import '../../btc/services/btc_service.dart';
import '../../reserve/providers/reserve_account_provider.dart';
import '../models/wallet.dart';

import '../../../core/base_component.dart';
import '../../../core/components/buttons.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/singletons.dart';
import '../../../core/storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/toast.dart';
import '../../encrypt/utils.dart';
import '../providers/wallet_detail_provider.dart';
import '../providers/wallet_list_provider.dart';

class ManageWalletBottomSheet extends BaseComponent {
  const ManageWalletBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallets = ref.watch(walletListProvider);
    final btcAccounts = ref.watch(btcAccountListProvider);
    // final List<Wallet> wallets = [];

    final btcOrange = Theme.of(context).colorScheme.btcOrange;

    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: wallets.isEmpty && btcAccounts.isEmpty
              ? _Header()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListView.builder(
                      itemCount: wallets.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final wallet = wallets[index];
                        final isLast = index >= wallets.length - 1 && btcAccounts.isEmpty;
                        final isFirst = index == 0;

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isFirst) Center(child: _Header()),
                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: isLast ? 0 : 1,
                                    color: isLast ? Colors.transparent : Colors.white24,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: ManageWalletListTile(wallet: wallet),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    ListView.builder(
                      itemCount: btcAccounts.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final account = btcAccounts[index];
                        final isLast = index >= btcAccounts.length - 1;
                        final isFirst = index == 0 && wallets.isEmpty;

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isFirst) Center(child: _Header()),
                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: isLast ? 0 : 1,
                                    color: isLast ? Colors.transparent : Colors.white24,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: ManageWalletBtcListTile(account: account),
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  ],
                ),
        ),
      ),
    );
  }
}

class ManageWalletBtcListTile extends BaseComponent {
  const ManageWalletBtcListTile({
    super.key,
    required this.account,
  });

  final BtcAccount account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final btcOrange = AppColors.getBtc();

    final isSelected = ref.watch(sessionProvider.select((v) => v.btcSelected)) &&
        account.address == ref.watch(sessionProvider.select((v) => v.currentBtcAccount?.address));

    return ListTile(
      key: Key("btc_wallet_${account.address}_$isSelected"),
      onTap: isSelected
          ? null
          : () {
              ref.read(sessionProvider.notifier).setCurrentBtcAccount(account, false);
            },
      dense: true,
      leading: ref.watch(sessionProvider.select((v) => v.btcSelected)) &&
              account.address == ref.watch(sessionProvider.select((v) => v.currentBtcAccount?.address))
          ? Icon(Icons.check_box_rounded, color: btcOrange)
          : Icon(Icons.check_box_outline_blank_outlined, color: btcOrange),
      title: Row(
        children: [
          Text(
            account.label,
            style: TextStyle(color: btcOrange),
          ),
          Text(
            " [${account.balance} BTC]",
            style: TextStyle(color: btcOrange),
          ),
        ],
      ),
      subtitle: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(account.address),
          Padding(
            padding: const EdgeInsets.only(left: 6.0),
            child: InkWell(
              child: const Icon(
                Icons.copy,
                size: 12,
              ),
              onTap: () async {
                await Clipboard.setData(
                  ClipboardData(text: account.address),
                );
                Toast.message(AppLocalizations.of(context).messageAddressCopied);
              },
            ),
          ),
        ],
      ),
      trailing: AppButton(
        type: AppButtonType.Text,
        label: AppLocalizations.of(context).walletRevealPrivateKey,
        variant: AppColorVariant.Info,
        onPressed: () async {
          if (!await passwordRequiredGuard(context, ref)) return;

          final a = await BtcService().retrieveAccount(account.address, omitPrivateKey: false);
          if (a == null) {
            Toast.error();
            return;
          }

          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(AppLocalizations.of(context).walletPrivateKeyLabel),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.security),
                      title: SizedBox(
                        width: 500,
                        child: TextFormField(
                          initialValue: a.privateKey,
                          decoration: InputDecoration(
                            label: Text(AppLocalizations.of(context).walletPrivateKeyLabel),
                          ),
                          style: const TextStyle(fontSize: 12),
                          readOnly: true,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: a.privateKey));
                          Toast.message(AppLocalizations.of(context).walletPrivateKeyCopiedToast);
                        },
                      ),
                    ),
                    const Divider(),
                    AppButton(
                      label: AppLocalizations.of(context).actionClose,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ManageWalletListTile extends BaseComponent {
  const ManageWalletListTile({
    super.key,
    required this.wallet,
  });

  final Wallet wallet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = wallet.isReserved ? Colors.deepPurple.shade200 : Colors.white;

    final isSelected = !ref.watch(sessionProvider.select((v) => v.btcSelected)) &&
        wallet.address == ref.watch(sessionProvider.select((v) => v.currentWallet?.address));

    return ListTile(
      key: Key("vfx_wallet_${wallet.address}_$isSelected"),

      dense: true,
      onTap: isSelected
          ? null
          : () {
              ref.read(sessionProvider.notifier).setCurrentWallet(wallet, false);
            },
      // leading: Icon(Icons.account_balance_wallet_outlined, color: color),
      leading: isSelected ? Icon(Icons.check_box_rounded, color: color) : Icon(Icons.check_box_outline_blank_outlined, color: color),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            wallet.label,
            style: TextStyle(
              color: color,
              fontSize: 16,
            ),
          ),
          wallet.isReserved
              ? Text(
                  " [Available: ${wallet.availableBalance} VFX]",
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                  ),
                )
              : Text(
                  " [${wallet.balance} VFX]",
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                  ),
                ),
          if (wallet.isReserved || wallet.lockedBalance > 0)
            Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: InkWell(
                onTap: () {
                  ref.read(reserveAccountProvider.notifier).showBalanceInfo(context, wallet);
                },
                child: Icon(
                  Icons.help,
                  size: 14,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
        ],
      ),
      subtitle: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            wallet.address,
            style: TextStyle(fontSize: 16),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 6.0),
            child: InkWell(
              child: const Icon(
                Icons.copy,
                size: 16,
              ),
              onTap: () async {
                await Clipboard.setData(
                  ClipboardData(text: wallet.address),
                );
                Toast.message(AppLocalizations.of(context).messageAddressCopied);
              },
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (wallet.isReserved && wallet.isNetworkProtected)
            Text(
              AppLocalizations.of(context).walletStatusActivated,
              style: TextStyle(color: color),
            ),
          // if (wallet.isReserved && !wallet.isNetworkProtected)
          //   AppButton(
          //     label: "Publish",
          //     type: AppButtonType.Text,
          //     variant: AppColorVariant.Info,
          //     onPressed: () async {
          //       await ref.read(reserveAccountProvider.notifier).activate(wallet);
          //     },
          //   ),

          if (!wallet.isReserved)
            IconButton(
                onPressed: () async {
                  if (!await passwordRequiredGuard(context, ref)) return;

                  final decryptedWallet = ref.read(walletListProvider).firstWhereOrNull((w) => w.address == wallet.address);
                  if (decryptedWallet == null) {
                    return;
                  }
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(AppLocalizations.of(context).walletPrivateKeyLabel),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.security),
                              title: SizedBox(
                                width: 500,
                                child: TextFormField(
                                  initialValue: decryptedWallet.privateKey,
                                  decoration: InputDecoration(
                                    label: Text(AppLocalizations.of(context).walletPrivateKeyLabel),
                                  ),
                                  style: const TextStyle(fontSize: 12),
                                  readOnly: true,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () async {
                                  await Clipboard.setData(ClipboardData(text: decryptedWallet.privateKey));
                                  Toast.message(AppLocalizations.of(context).walletPrivateKeyCopiedToast);
                                },
                              ),
                            ),
                            const Divider(),
                            AppButton(
                              label: AppLocalizations.of(context).actionClose,
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
                iconSize: 16,
                icon: Icon(
                  Icons.remove_red_eye,
                )),
          IconButton(
              onPressed: () async {
                final l10n = AppLocalizations.of(context);
                final confirmed = await ConfirmDialog.show(
                  title: l10n.walletHideAccountTitle,
                  body: l10n.walletHideAccountBody,
                  confirmText: l10n.walletHideLabel,
                  cancelText: l10n.actionCancel,
                  destructive: true,
                );

                if (confirmed != true) {
                  return;
                }

                ref.read(walletDetailProvider(wallet).notifier).delete();
              },
              iconSize: 16,
              icon: Icon(
                Icons.delete,
              )),
          // AppButton(
          //   label: "Rescan",
          //   type: AppButtonType.Text,
          //   variant: AppColorVariant.Light,
          //   onPressed: () async {
          //     final resync = await ConfirmDialog.show(
          //       title: "Rescan Blocks?",
          //       body: "Would you like to rescan the chain to include any transactions relevant to this address?",
          //       confirmText: "Yes",
          //       cancelText: "No",
          //     );
          //     if (resync == true) {
          //       final success = await BridgeService().rescanAddress(wallet.address);
          //       if (success) {
          //         InfoDialog.show(title: "Rescan has started", body: "Updated TXs will show up shortly");
          //       } else {
          //         OverlayToast.error();
          //       }
          //     }
          //   },
          // ),
          // AppButton(
          //   type: AppButtonType.Text,
          //   variant: AppColorVariant.Danger,
          //   label: "Hide Account",
          //   onPressed: () async {
          //     final confirmed = await ConfirmDialog.show(
          //       title: "Hide wallet?",
          //       body: "Are you sure you want to hide this wallet from the GUI?",
          //       destructive: true,
          //       confirmText: "Hide",
          //       cancelText: "Cancel",
          //     );

          //     if (confirmed == true) {
          //       ref.read(walletDetailProvider(wallet).notifier).delete();
          //     }
          //   },
          // )
        ],
      ),
    );
  }
}

class _Header extends BaseComponent {
  const _Header({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        // mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppButton(
            label: AppLocalizations.of(context).walletRestoreHidden,
            type: AppButtonType.Text,
            variant: AppColorVariant.Info,
            onPressed: () {
              showDialog(
                  context: context,
                  builder: ((context) {
                    return WalletRestorer();
                  }));
            },
          ),
          AppButton(
            label: AppLocalizations.of(context).actionClose,
            type: AppButtonType.Text,
            variant: AppColorVariant.Info,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class WalletRestorer extends StatefulWidget {
  const WalletRestorer({
    super.key,
  });

  @override
  State<WalletRestorer> createState() => _WalletRestorerState();
}

class _WalletRestorerState extends State<WalletRestorer> {
  late List hiddenWallets;
  late List<bool> values;

  @override
  initState() {
    super.initState();
    hiddenWallets = singleton<Storage>().getList(Storage.DELETED_WALLETS_KEY) ?? [];

    values = hiddenWallets.map((e) => false).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return hiddenWallets.isEmpty
        ? AlertDialog(
            content: Text(l10n.walletNoHiddenAccounts),
            title: Text(l10n.walletNoHiddenAccountsTitle),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  l10n.walletOkay,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              )
            ],
          )
        : Consumer(builder: (context, ref, child) {
            return AlertDialog(
              actionsAlignment: MainAxisAlignment.spaceBetween,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.walletSelectToRestore,
                    style: const TextStyle(color: Colors.white),
                  ),
                  AppButton(
                    label: l10n.walletRestoreAll,
                    onPressed: () {
                      restoreWallets([], context, ref);
                    },
                  )
                ],
              ),
              content: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600, maxHeight: 800),
                child: SizedBox(
                  height: 30.0 * values.length,
                  width: 600,
                  child: ListView.builder(
                      itemCount: values.length,
                      itemBuilder: ((context, index) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                                value: values[index],
                                onChanged: (val) {
                                  setState(() {
                                    values[index] = val ?? false;
                                  });
                                }),
                            Text(hiddenWallets[index])
                          ],
                        );
                      })),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    l10n.actionCancel,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.light,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final nonRestoredWallets = hiddenWallets
                        .whereIndexed(
                          (index, element) => !values[index],
                        )
                        .toList();

                    restoreWallets(nonRestoredWallets, context, ref);
                  },
                  child: Text(
                    l10n.walletRestoreSelected,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                )
              ],
            );
          });
  }

  void restoreWallets(List<dynamic> nonRestoredWallets, BuildContext context, WidgetRef ref) {
    singleton<Storage>().setList(Storage.DELETED_WALLETS_KEY, nonRestoredWallets);
    ref.read(sessionProvider.notifier).init(false);
    Navigator.of(context).pop();
  }
}
