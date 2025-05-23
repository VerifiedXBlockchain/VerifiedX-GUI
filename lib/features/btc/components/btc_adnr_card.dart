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

class BtcAdnrCard extends BaseComponent {
  const BtcAdnrCard({
    super.key,
    required this.account,
  });

  final BtcAccount account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                          "Controlled by: ${account.adnrOwnerAddress!}",
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                    ],
                  )
                : Text("No Domain"),
            trailing: Builder(builder: (context) {
              if (isPendingTransfer) {
                return AppBadge(
                  label: "Transfer Pending",
                  variant: AppColorVariant.Btc,
                );
              }

              if (isPendingBurn) {
                return AppBadge(
                  label: "Delete Pending",
                  variant: AppColorVariant.Btc,
                );
              }
              if (isPendingCreate) {
                return AppBadge(
                  label: "Creation Pending",
                  variant: AppColorVariant.Btc,
                );
              }
              if (account.adnr == null) {
                return AppButton(
                  label: "Create Domain",
                  variant: AppColorVariant.Btc,
                  onPressed: () async {
                    if (!await passwordRequiredGuard(context, ref)) return;
                    if (!widgetGuardWalletIsSynced(ref)) {
                      return;
                    }

                    if (ref.read(walletListProvider).isEmpty) {
                      Toast.error("An VFX wallet is required for this functionality.");
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
                    label: "Transfer",
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
                    label: "Delete",
                    onPressed: () async {
                      final confirmed = await ConfirmDialog.show(
                        title: "Delete BTC Domain?",
                        body:
                            "Are you sure you want to delete this BTC Domain?\n${ADNR_DELETE_COST == 0 ? 'There is no cost to delete and VFX Domain (aside from the TX fee).' : 'There is a cost of $ADNR_DELETE_COST VFX to delete an RBX Domain.'}\n\nOnce deleted, this ADNR will no longer be able to receive any transactions.",
                        destructive: true,
                        cancelText: "Cancel",
                        confirmText: "Delete",
                      );

                      if (confirmed != true) {
                        return;
                      }

                      final hash = await BtcService().deleteAdnr(btcAddress: account.address);
                      ref.read(adnrPendingProvider.notifier).addId(account.address, "burn", account.adnr!);
                      Toast.message("TX broadcasted!");
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
              "Transfer Domain from ${formState.fromBtcAddress}",
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
                "To BTC Address",
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
                "To VFX Address",
              ),
            ),
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppButton(
                label: "Cancel",
                type: AppButtonType.Text,
                variant: AppColorVariant.Light,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              AppButton(
                label: "Transfer BTC Domain",
                variant: AppColorVariant.Btc,
                onPressed: () async {
                  final success = await formProvider.submit();

                  if (success == false) {
                    Toast.error();
                    return;
                  }

                  Toast.message("Transaction Broadcasted!");

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
              "Create Domain for ${formState.btcAddress}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          SizedBox(
            height: 8,
          ),
          Text(
            "Your domain must only contain letters and numbers and will automatically be appended with \".btc\" upon verification",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          TextFormField(
            controller: formProvider.nameController,
            validator: formProvider.nameValidator,
            decoration: InputDecoration(
              suffix: Text(".btc"),
              label: Text(
                "Domain Name",
                style: TextStyle(color: Theme.of(context).colorScheme.btcOrange),
              ),
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Text(
            "Select VFX Address",
            style: TextStyle(color: Theme.of(context).colorScheme.btcOrange, fontSize: 12),
          ),
          Text(
            "This wallet will control transfer/delete ownership over this new domain.",
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
                Text("Selected Address:"),
                SizedBox(
                  width: 4,
                ),
                Text(
                  formState.selectedAddress ?? "None",
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
                label: "Cancel",
                type: AppButtonType.Text,
                variant: AppColorVariant.Light,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              AppButton(
                label: "Create BTC Domain",
                variant: AppColorVariant.Btc,
                onPressed: () async {
                  final success = await formProvider.submit();

                  if (success == false) {
                    return;
                  }

                  Toast.message("Transaction Broadcasted!");

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
