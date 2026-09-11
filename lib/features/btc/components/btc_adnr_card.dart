import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_constants.dart';
import '../../../core/base_component.dart';
import '../../../core/components/badges.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/components.dart';
import '../../../core/utils.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/guards.dart';
import '../../../utils/toast.dart';
import '../../adnr/providers/adnr_pending_provider.dart';
import '../../encrypt/utils.dart';
import '../../smart_contracts/components/sc_creator/common/modal_container.dart';
import '../../wallet/providers/wallet_list_provider.dart';
import '../models/btc_account.dart';
import '../providers/btc_adnr_create_form_provider.dart';
import '../providers/btc_adnr_transfer_form_provider.dart';
import '../services/btc_service.dart';
import '../../../core/utils/tx_refresh.dart';

class BtcAdnrCard extends BaseComponent {
  const BtcAdnrCard({
    super.key,
    required this.account,
  });

  final BtcAccount account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Builder(
      builder: (context) {
        final isPendingCreate = ref.watch(adnrPendingProvider).contains("${account.address}.create.${account.adnr ?? 'null'}");
        final isPendingBurn = ref.watch(adnrPendingProvider).contains("${account.address}.burn.${account.adnr ?? 'null'}");
        final isPendingTransfer = ref.watch(adnrPendingProvider).contains("${account.address}.transfer.${account.adnr ?? 'null'}");
        return AppCard(
          padding: 4,
          child: ListTile(
            title: Text(account.address),
            leading: Icon(account.adnr != null ? Icons.link : Icons.link_off),
            subtitle: account.adnr != null && !isPendingCreate
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: AppBadge(
                          label: "@${account.adnr!}",
                          variant: AppColorVariant.Btc,
                        ),
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      if (account.adnrOwnerAddress != null)
                        Text(
                          l10n.tkbControlledBy(account.adnrOwnerAddress!),
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                    ],
                  )
                : Text(l10n.adnrNoDomain),
            trailing: Builder(builder: (context) {
              if (isPendingTransfer) {
                return AppBadge(
                  label: l10n.tkbTransferPending,
                  variant: AppColorVariant.Btc,
                );
              }

              if (isPendingBurn) {
                return AppBadge(
                  label: l10n.tkbDeletePending,
                  variant: AppColorVariant.Btc,
                );
              }
              if (isPendingCreate) {
                return AppBadge(
                  label: l10n.tkbCreationPending,
                  variant: AppColorVariant.Btc,
                );
              }
              if (account.adnr == null) {
                return AppButton(
                  label: l10n.btcCreateDomain,
                  variant: AppColorVariant.Btc,
                  onPressed: () async {
                    if (!await passwordRequiredGuard(context, ref)) return;
                    if (!widgetGuardWalletIsSynced(ref)) {
                      return;
                    }

                    if (ref.read(walletListProvider).isEmpty) {
                      Toast.error(l10n.tkbVfxWalletRequired);
                      return;
                    }

                    ref.read(btcAdnrCreateFormProvider.notifier).initWithData(
                          btcAddress: account.address,
                        );

                    final initialWallet = ref.read(walletListProvider).firstWhereOrNull((w) => w.balance >= ADNR_COST + MIN_RBX_FOR_SC_ACTION);
                    if (initialWallet != null) {
                      ref.read(btcAdnrCreateFormProvider.notifier).setSelectedAddress(initialWallet.address);
                    }

                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return CreateBtcAdnrModal();
                      },
                    );
                  },
                );
              }

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton(
                    label: l10n.btcTransferLabel,
                    onPressed: () async {
                      if (!await passwordRequiredGuard(context, ref)) return;
                      if (!widgetGuardWalletIsSynced(ref)) {
                        return;
                      }

                      ref
                          .read(btcAdnrTransferFormProvider.notifier)
                          .initWithFromBtcAddress(fromBtcAddress: account.address, domainName: account.adnr);

                      showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return TransferBtcAdnrModal();
                          });
                    },
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  AppButton(
                    label: l10n.actionDelete,
                    onPressed: () async {
                      final confirmed = await ConfirmDialog.show(
                        title: l10n.btcDeleteDomainTitle,
                        body: l10n.tkbDeleteBtcDomainBody(
                          ADNR_DELETE_COST == 0 ? l10n.tkbDeleteDomainNoCost : l10n.tkbDeleteDomainWithCost(ADNR_DELETE_COST.toString()),
                        ),
                        destructive: true,
                        cancelText: l10n.actionCancel,
                        confirmText: l10n.actionDelete,
                      );

                      if (confirmed != true) {
                        return;
                      }

                      final hash = await BtcService().deleteAdnr(btcAddress: account.address);
                      ref.read(adnrPendingProvider.notifier).addId(account.address, "burn", account.adnr!);
                      Toast.message(l10n.tkbTxBroadcasted);
                      notifyTransactionSubmitted();
                    },
                    variant: AppColorVariant.Danger,
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }
}

class TransferBtcAdnrModal extends BaseComponent {
  const TransferBtcAdnrModal({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final formProvider = ref.read(btcAdnrTransferFormProvider.notifier);
    final formState = ref.watch(btcAdnrTransferFormProvider);

    return Form(
      key: formProvider.formKey,
      child: ModalContainer(
        withClose: true,
        withDecor: false,
        children: [
          if (formState.fromBtcAddress != null)
            Text(
              l10n.tkbTransferDomainFrom(formState.fromBtcAddress!),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          SizedBox(
            height: 8,
          ),
          TextFormField(
            controller: formProvider.toBtcAddressController,
            validator: formProvider.toBtcAddressValidator,
            decoration: InputDecoration(
              label: Text(
                l10n.tkbToBtcAddress,
                style: TextStyle(color: Theme.of(context).colorScheme.btcOrange),
              ),
            ),
          ),
          SizedBox(
            height: 16,
          ),
          TextFormField(
            controller: formProvider.toRbxAddressController,
            validator: formProvider.toRbxAddressValidator,
            decoration: InputDecoration(
              suffix: AddressChoosingIconButton(controller: formProvider.toRbxAddressController),
              label: Text(
                l10n.tkbToVfxAddress,
              ),
            ),
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppButton(
                label: l10n.actionCancel,
                type: AppButtonType.Text,
                variant: AppColorVariant.Light,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              AppButton(
                label: l10n.btcTransferBtcDomain,
                variant: AppColorVariant.Btc,
                onPressed: () async {
                  final success = await formProvider.submit();

                  if (success == false) {
                    Toast.error();
                    return;
                  }

                  Toast.message(l10n.tkbTransactionBroadcastedBang);

                  Navigator.of(context).pop();
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}

class CreateBtcAdnrModal extends BaseComponent {
  const CreateBtcAdnrModal({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final formProvider = ref.read(btcAdnrCreateFormProvider.notifier);
    final formState = ref.watch(btcAdnrCreateFormProvider);

    final wallets = ref.watch(walletListProvider).where((w) => w.balance >= ADNR_COST + MIN_RBX_FOR_SC_ACTION);

    return Form(
      key: formProvider.formKey,
      child: ModalContainer(
        withClose: true,
        withDecor: false,
        children: [
          if (formState.btcAddress != null)
            Text(
              l10n.tkbCreateDomainFor(formState.btcAddress!),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          SizedBox(
            height: 8,
          ),
          Text(
            l10n.tkbDomainNameRule,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          TextFormField(
            controller: formProvider.nameController,
            validator: formProvider.nameValidator,
            decoration: InputDecoration(
              suffix: Text(".btc"),
              label: Text(
                l10n.tkbDomainName,
                style: TextStyle(color: Theme.of(context).colorScheme.btcOrange),
              ),
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Text(
            l10n.tkbSelectVfxAddress,
            style: TextStyle(color: Theme.of(context).colorScheme.btcOrange, fontSize: 12),
          ),
          Text(
            l10n.tkbWalletControlsDomain,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(
            height: 12,
          ),
          PopupMenuButton<String>(
            onSelected: (address) {
              formProvider.setSelectedAddress(address);
            },
            color: Color(0xFF080808),
            constraints: const BoxConstraints(
              minWidth: 2.0 * 56.0,
              maxWidth: 8.0 * 56.0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.tkbSelectedAddress),
                SizedBox(
                  width: 4,
                ),
                Text(
                  formState.selectedAddress ?? l10n.tkbNone,
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
                Transform.translate(
                  offset: Offset(0, 2),
                  child: Icon(
                    Icons.arrow_drop_down,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            itemBuilder: (context) {
              return wallets.map(
                (w) {
                  return PopupMenuItem(
                    value: w.address,
                    child: Text(
                      "${w.labelWithoutTruncation} (${w.balance} VFX)",
                      style: TextStyle(
                        fontSize: 12,
                        color: w.address == formState.selectedAddress ? Theme.of(context).colorScheme.secondary : Colors.white,
                      ),
                    ),
                  );
                },
              ).toList();
            },
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppButton(
                label: l10n.actionCancel,
                type: AppButtonType.Text,
                variant: AppColorVariant.Light,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              AppButton(
                label: l10n.tkbCreateBtcDomain,
                variant: AppColorVariant.Btc,
                onPressed: () async {
                  final success = await formProvider.submit();

                  if (success == false) {
                    return;
                  }

                  Toast.message(l10n.tkbTransactionBroadcastedBang);

                  Navigator.of(context).pop();
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
