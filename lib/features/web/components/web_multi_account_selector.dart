import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/core/base_component.dart';
import 'package:rbx_wallet/core/components/buttons.dart';
import 'package:rbx_wallet/core/dialogs.dart';
import 'package:rbx_wallet/core/theme/app_theme.dart';
import 'package:rbx_wallet/core/theme/colors.dart';
import 'package:rbx_wallet/core/theme/components.dart';
import 'package:rbx_wallet/features/smart_contracts/components/sc_creator/common/modal_container.dart';
import 'package:rbx_wallet/features/web/models/multi_account_instance.dart';
import 'package:rbx_wallet/features/web/providers/multi_account_provider.dart';
import 'package:collection/collection.dart';
import 'package:rbx_wallet/utils/validation.dart';

import '../../../core/providers/web_session_provider.dart';
import '../../../core/utils.dart';
import '../../../core/web_router.gr.dart';
import '../../../utils/toast.dart';
import '../../auth/auth_utils.dart';
import '../../keygen/models/keypair.dart';

class WebMultiAccountSelector extends BaseComponent {
  final bool expanded;

  const WebMultiAccountSelector({
    super.key,
    required this.expanded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(multiAccountProvider);
    final selectedAccountId = ref.watch(selectedMultiAccountProvider);

    return PopupMenuButton<int>(
        color: Colors.black,
        child: Transform.translate(
          offset: expanded ? Offset(0, 0) : Offset(2, 0),
          child: Container(
            decoration: BoxDecoration(
                color: AppColors.getBlue().withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.getBlue().withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 8,
                  )
                ]),
            child: expanded
                ? Padding(
                    // padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                    padding: const EdgeInsets.only(top: 6, left: 8, bottom: 2, right: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Switch Account",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            height: 1,
                          ),
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        Transform.translate(
                          offset: Offset(0, -2),
                          child: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white.withOpacity(0.8),
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                    child: Icon(
                      Icons.wallet,
                      color: Colors.white.withOpacity(0.8),
                      size: 16,
                    ),
                  ),
          ),
        ),
        onSelected: (value) {
          if (value == 0) {
            showWebLoginModal(context, ref, allowPrivateKey: true, allowBtcPrivateKey: true, showRememberMe: false, onSuccess: () {
              Navigator.of(context).pop();
            });

            return;
          }

          if (value == -1) {
            showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return WebManageAccountsBottomSheet();
                });
            return;
          }

          if (value == selectedAccountId) {
            return;
          }

          ref.read(selectedMultiAccountProvider.notifier).setFromId(value);
        },
        itemBuilder: (context) {
          final items = <PopupMenuEntry<int>>[];

          for (final account in accounts) {
            final selected = selectedAccountId == account.id;

            items.add(PopupMenuItem(
              value: account.id,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(selected ? Icons.check_box : Icons.check_box_outline_blank),
                  SizedBox(width: 6),
                  Text(account.name ?? (accounts.length == 1 ? "Default Account" : "Account ${account.id}")),
                  if (accounts.length > 1) ...[
                    SizedBox(width: 6),
                    InkWell(
                      onTap: () async {
                        final newName = await PromptModal.show(
                          title: "Rename Account",
                          validator: (v) => formValidatorNotEmpty(v, "Account Name"),
                          labelText: "Account Name",
                          body: "What would you like to name this account?",
                          initialValue: account.name ?? "",
                        );

                        if (newName != null && newName.isNotEmpty) {
                          ref.read(multiAccountProvider.notifier).rename(account.id, newName);
                          Navigator.of(context).pop();
                        }
                      },
                      child: Icon(
                        Icons.edit,
                        size: 12,
                      ),
                    ),
                  ]
                ],
              ),
            ));
          }

          if (accounts.isNotEmpty) {
            items.add(PopupMenuDivider());
          }

          items.add(
            PopupMenuItem(
              value: 0,
              child: Text("Add Account"),
            ),
          );

          if (accounts.isNotEmpty) {
            items.add(
              PopupMenuItem(
                value: -1,
                child: Text("Manage Accounts"),
              ),
            );
          }

          return items;
        });
  }
}

class WebManageAccountsBottomSheet extends BaseComponent {
  const WebManageAccountsBottomSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(multiAccountProvider);
    final selectedAccountId = ref.watch(selectedMultiAccountProvider);

    return ModalContainer(
      withClose: true,
      title: "Manage Accounts",
      children: [
        ...accounts.map((account) {
          final keypair = account.keypair;
          final raKeypair = account.raKeypair;
          final btcKeypair = account.btcKeypair;
          final selected = selectedAccountId == account.id;

          return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: InkWell(
                onTap: () {
                  ref.read(selectedMultiAccountProvider.notifier).setFromId(account.id);
                },
                child: AppCard(
                  borderColor: selected ? Colors.white24 : null,
                  padding: 8,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 12,
                      ),
                      SizedBox(
                        width: 32,
                        child: Text(
                          "${account.id}.",
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (keypair != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: InkWell(
                                          onTap: () async {
                                            await Clipboard.setData(ClipboardData(text: keypair.address));
                                            Toast.message("Address copied to clipboard");
                                          },
                                          child: Icon(
                                            Icons.copy,
                                            size: 16,
                                            color: AppColors.getBlue(),
                                          )),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: InkWell(
                                        onTap: () async {
                                          showKeys(context, keypair);
                                        },
                                        child: Icon(
                                          Icons.remove_red_eye,
                                          size: 16,
                                          color: AppColors.getBlue(),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 4,
                                    ),
                                    Text(
                                      keypair.address,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: AppColors.getBlue(), fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            if (raKeypair != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: InkWell(
                                          onTap: () async {
                                            await Clipboard.setData(ClipboardData(text: raKeypair.address));
                                            Toast.message("Address copied to clipboard");
                                          },
                                          child: Icon(
                                            Icons.copy,
                                            size: 16,
                                            color: AppColors.getReserve(),
                                          )),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: InkWell(
                                        onTap: () async {
                                          showRaKeys(context, raKeypair);
                                        },
                                        child: Icon(
                                          Icons.remove_red_eye,
                                          size: 16,
                                          color: AppColors.getReserve(),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 4,
                                    ),
                                    Text(
                                      raKeypair.address,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: AppColors.getReserve(), fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            if (btcKeypair != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: InkWell(
                                          onTap: () async {
                                            await Clipboard.setData(ClipboardData(text: btcKeypair.address));
                                            Toast.message("Address copied to clipboard");
                                          },
                                          child: Icon(
                                            Icons.copy,
                                            size: 16,
                                            color: AppColors.getBtc(),
                                          )),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: InkWell(
                                        onTap: () async {
                                          final kp = Keypair(
                                            private: btcKeypair.privateKey,
                                            address: btcKeypair.address,
                                            public: btcKeypair.publicKey,
                                            btcWif: btcKeypair.wif,
                                          );
                                          showKeys(context, kp, true);
                                        },
                                        child: Icon(
                                          Icons.remove_red_eye,
                                          size: 16,
                                          color: AppColors.getBtc(),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 4,
                                    ),
                                    Text(
                                      btcKeypair.address,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: AppColors.getBtc(), fontSize: 16),
                                    ),
                                  ],
                                ),
                              )
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!selected)
                              AppButton(
                                label: "Set Active",
                                variant: AppColorVariant.Light,
                                type: AppButtonType.Outlined,
                                onPressed: () {
                                  ref.read(selectedMultiAccountProvider.notifier).setFromId(account.id);
                                },
                              ),
                            SizedBox(
                              width: 8,
                            ),
                            AppButton(
                              label: "Backup Keys",
                              variant: AppColorVariant.Secondary,
                              type: AppButtonType.Outlined,
                              onPressed: () async {
                                await backupWebKeys(context, ref);
                              },
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            AppButton(
                              label: "Forget",
                              type: AppButtonType.Outlined,
                              variant: AppColorVariant.Danger,
                              onPressed: () async {
                                MultiAccountInstance? otherAccount;

                                if (selected) {
                                  otherAccount = accounts.firstWhereOrNull((a) => a.id != account.id);

                                  if (otherAccount == null) {
                                    final confimed = await ConfirmDialog.show(
                                      title: "Forget Account ${account.id}",
                                      body:
                                          "Are you sure you want to remove this account from your wallet? Since you have no other accounts, you will be logged out.",
                                      destructive: true,
                                      confirmText: "Forget & Logout",
                                    );

                                    if (confimed == true) {
                                      await ref.read(webSessionProvider.notifier).logout();

                                      AutoRouter.of(context).replace(const WebAuthRouter());
                                    }
                                    return;
                                  }
                                }
                                final confimed = await ConfirmDialog.show(
                                  title: "Forget Account ${account.id}",
                                  body: "Are you sure you want to remove this account from your wallet?",
                                  destructive: true,
                                  confirmText: "Forget",
                                );
                                if (confimed == true) {
                                  ref.read(multiAccountProvider.notifier).remove(account.id);
                                  if (otherAccount != null) {
                                    ref.read(selectedMultiAccountProvider.notifier).setFromId(otherAccount.id);
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ));
        }),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: AppButton(
              label: "Add Account",
              variant: AppColorVariant.Light,
              onPressed: () {
                showWebLoginModal(context, ref, allowPrivateKey: true, allowBtcPrivateKey: true, showRememberMe: false, onSuccess: () {
                  Navigator.of(context).pop();
                });
              },
            ),
          ),
        )
      ],
    );
  }
}
