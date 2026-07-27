import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/core/base_component.dart';
import 'package:rbx_wallet/core/components/buttons.dart';
import 'package:rbx_wallet/core/dialogs.dart';
import 'package:rbx_wallet/core/providers/locale_provider.dart';
import 'package:rbx_wallet/core/theme/app_theme.dart';
import 'package:rbx_wallet/core/theme/colors.dart';
import 'package:rbx_wallet/core/theme/components.dart';
import 'package:rbx_wallet/features/smart_contracts/components/sc_creator/common/modal_container.dart';
import 'package:rbx_wallet/features/web/models/multi_account_instance.dart';
import 'package:rbx_wallet/features/web/providers/multi_account_provider.dart';
import 'package:rbx_wallet/l10n/generated/app_localizations.dart';
import 'package:collection/collection.dart';
import 'package:rbx_wallet/utils/validation.dart';

import '../../../core/providers/web_session_provider.dart';
import '../../../core/services/multi_account_password_service.dart';
import '../../../core/utils.dart';
import '../../../core/web_router.gr.dart';
import '../../../utils/html_helpers.dart';
import '../../../utils/toast.dart';
import '../../../core/utils.dart';
import '../../auth/auth_utils.dart';

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
                          AppLocalizations.of(context).webSelectAccount,
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
        onSelected: (value) async {
          if (value == 0) {
            final migrationRequired = await checkEncryptionMigrationRequired(context, ref);
            if (migrationRequired) return;
            
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

          if (value == -2) {
            // Lock Wallet - hard redirect to "/" (clears memory but keeps encrypted storage)
            HtmlHelpers().redirect("/");
            return;
          }

          if (value == -3) {
            _showLanguagePicker(context, ref);
            return;
          }

          if (value == selectedAccountId) {
            return;
          }

          // Use MultiAccountPasswordService to handle encrypted accounts
          MultiAccountPasswordService.switchToAccountById(context, ref, value);
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
                  Text(account.name ?? (accounts.length == 1 ? AppLocalizations.of(context).webDefaultAccount : AppLocalizations.of(context).webAccountN(account.id.toString()))),
                  if (accounts.length > 1) ...[
                    SizedBox(width: 6),
                    InkWell(
                      onTap: () async {
                        final newName = await PromptModal.show(
                          title: AppLocalizations.of(context).webRenameAccountTitle,
                          validator: (v) => formValidatorNotEmpty(v, AppLocalizations.of(context).webAccountName),
                          labelText: AppLocalizations.of(context).webAccountName,
                          body: AppLocalizations.of(context).webRenameAccountBody,
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
              child: Text(AppLocalizations.of(context).webAddAccount),
            ),
          );

          if (accounts.isNotEmpty) {
            items.add(
              PopupMenuItem(
                value: -1,
                child: Text(AppLocalizations.of(context).webManageAccounts),
              ),
            );
          }

          // Add Language and Lock Wallet options
          items.add(PopupMenuDivider());

          final currentLocale = ref.read(localeProvider);
          final langLabel = currentLocale == null
              ? 'Auto'
              : currentLocale.languageCode == 'es'
                  ? 'ES'
                  : 'EN';

          items.add(
            PopupMenuItem(
              value: -3,
              child: Row(
                children: [
                  Icon(Icons.language, size: 16),
                  SizedBox(width: 8),
                  Text(AppLocalizations.of(context).webLanguageLabel),
                  Spacer(),
                  Text(
                    langLabel,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );

          items.add(
            PopupMenuItem(
              value: -2,
              child: Row(
                children: [
                  Icon(Icons.lock, size: 16),
                  SizedBox(width: 8),
                  Text(AppLocalizations.of(context).webLockWallet),
                ],
              ),
            ),
          );

          return items;
        });
  }
}

void _showLanguagePicker(BuildContext context, WidgetRef ref) {
  final currentLocale = ref.read(localeProvider);
  final l10n = AppLocalizations.of(context);

  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        color: AppColors.getGray(ColorShade.s200),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.settingsLanguageSection,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.check,
                  color: currentLocale == null ? AppColors.getBlue() : Colors.transparent,
                ),
                title: Text(l10n.settingsLanguageSystemDefault),
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale(null);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.check,
                  color: currentLocale?.languageCode == 'en' ? AppColors.getBlue() : Colors.transparent,
                ),
                title: Text(l10n.settingsLanguageEnglish),
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.check,
                  color: currentLocale?.languageCode == 'es' ? AppColors.getBlue() : Colors.transparent,
                ),
                title: Text(l10n.settingsLanguageSpanish),
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale(const Locale('es'));
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}

class WebManageAccountsBottomSheet extends BaseComponent {
  const WebManageAccountsBottomSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(multiAccountProvider);
    final selectedAccountId = ref.watch(selectedMultiAccountProvider);

    final l10n = AppLocalizations.of(context);

    return ModalContainer(
      withClose: true,
      title: l10n.webManageAccounts,
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
                  MultiAccountPasswordService.switchToAccountById(context, ref, account.id);
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
                                            Toast.message(l10n.messageAddressCopied);
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
                                          showKeysForAccount(context, ref, account, KeypairType.vfx);
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
                                            Toast.message(l10n.messageAddressCopied);
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
                                          showKeysForAccount(context, ref, account, KeypairType.ra);
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
                                            Toast.message(l10n.messageAddressCopied);
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
                                          showKeysForAccount(context, ref, account, KeypairType.btc, true);
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
                                label: l10n.webSetActive,
                                variant: AppColorVariant.Light,
                                type: AppButtonType.Outlined,
                                onPressed: () {
                                  MultiAccountPasswordService.switchToAccountById(context, ref, account.id);
                                },
                              ),
                            SizedBox(
                              width: 8,
                            ),
                            AppButton(
                              label: l10n.webBackupKeys,
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
                              label: l10n.webForget,
                              type: AppButtonType.Outlined,
                              variant: AppColorVariant.Danger,
                              onPressed: () async {
                                MultiAccountInstance? otherAccount;

                                if (selected) {
                                  otherAccount = accounts.firstWhereOrNull((a) => a.id != account.id);

                                  if (otherAccount == null) {
                                    final confimed = await ConfirmDialog.show(
                                      title: l10n.webForgetTitle(account.id.toString()),
                                      body: l10n.webForgetBodyLastAccount,
                                      destructive: true,
                                      confirmText: l10n.webForgetAndLogout,
                                    );

                                    if (confimed == true) {
                                      await ref.read(webSessionProvider.notifier).logout();

                                      AutoRouter.of(context).replace(const WebAuthRouter());
                                    }
                                    return;
                                  }
                                }
                                final confimed = await ConfirmDialog.show(
                                  title: l10n.webForgetTitle(account.id.toString()),
                                  body: l10n.webForgetBody,
                                  destructive: true,
                                  confirmText: l10n.webForget,
                                );
                                if (confimed == true) {
                                  ref.read(multiAccountProvider.notifier).remove(account.id);
                                  if (otherAccount != null) {
                                    MultiAccountPasswordService.switchToAccountById(context, ref, otherAccount.id);
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
              label: l10n.webAddAccount,
              variant: AppColorVariant.Light,
              onPressed: () async {
                final migrationRequired = await checkEncryptionMigrationRequired(context, ref);
                if (migrationRequired) return;
                
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
