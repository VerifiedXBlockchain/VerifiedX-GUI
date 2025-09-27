import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/core/components/buttons.dart';
import 'package:rbx_wallet/features/smart_contracts/components/sc_creator/common/modal_container.dart';
import '../../../app.dart';
import '../../../core/base_component.dart';
import '../../../core/breakpoints.dart';
import '../../../core/dialogs.dart';
import '../../../core/models/web_session_model.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/web_router.gr.dart';
import '../../auth/auth_utils.dart';
import '../../btc_web/services/btc_web_service.dart';
import '../../keygen/models/keypair.dart';
import '../../../utils/toast.dart';
import '../../../utils/validation.dart';

import '../../btc_web/components/web_btc_create_wallet_modal.dart';

class WebWalletTypeSwitcher extends BaseComponent {
  const WebWalletTypeSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(webSessionProvider);
    final primaryAddress = session.keypair?.address;
    final raAddress = session.raKeypair?.address;
    final btcAddress = session.btcKeypair?.address;

    final selectedWalletType = session.selectedWalletType;

    if (primaryAddress == null || raAddress == null) {
      return SizedBox();
    }
    // final color = usingRa ? Colors.deepPurple.shade200 : Colors.white;

    late final Color color;
    switch (selectedWalletType) {
      case WalletType.rbx:
        color = Colors.white;
        break;
      case WalletType.ra:
        color = Colors.deepPurple.shade200;
        break;
      case WalletType.btc:
        color = Color(0xfff7931a);
        break;
    }

    late final String selectedAddress;
    switch (selectedWalletType) {
      case WalletType.rbx:
        selectedAddress = primaryAddress;
        break;
      case WalletType.ra:
        selectedAddress = raAddress;
        break;
      case WalletType.btc:
        selectedAddress = btcAddress ?? "";
        break;
    }

    final fontSize = BreakPoints.useMobileLayout(context) ? 12.0 : 14.0;

    final start = selectedAddress.substring(0, 5);
    final end = selectedAddress.substring(
        selectedAddress.length - 5, selectedAddress.length);
    final truncatedAddress = "$start...$end";

    final selectedAddressLabel = BreakPoints.useMobileLayout(context)
        ? truncatedAddress
        : selectedAddress;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () async {
            await Clipboard.setData(
              ClipboardData(text: selectedAddress),
            );
            Toast.message("$selectedAddress copied to clipboard");
          },
          child: Icon(
            Icons.copy,
            size: 12,
            color: color,
          ),
        ),
        SizedBox(width: 4),
        PopupMenuButton(
          constraints: const BoxConstraints(
            minWidth: 2.0 * 56.0,
            maxWidth: 8.0 * 56.0,
          ),
          color: Color(0xFF080808),
          child: Row(
            children: [
              Text(
                selectedAddressLabel,
                style: TextStyle(color: color, fontSize: fontSize),
              ),
              Icon(
                Icons.arrow_drop_down,
                size: 18,
                color: color,
              ),
            ],
          ),
          itemBuilder: (context) {
            final list = <PopupMenuEntry<int>>[];

            list.add(PopupMenuItem(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    selectedWalletType == WalletType.rbx
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_outlined,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  SizedBox(width: 6),
                  Text(
                    primaryAddress,
                    style: TextStyle(
                        fontSize: fontSize,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ],
              ),
              onTap: () {
                ref
                    .read(webSessionProvider.notifier)
                    .setSelectedWalletType(WalletType.rbx);
              },
            ));

            list.add(PopupMenuItem(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    selectedWalletType == WalletType.ra
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_outlined,
                    color: Colors.deepPurple.shade200,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      raAddress,
                      style: TextStyle(
                          color: Colors.deepPurple.shade200,
                          fontSize: fontSize),
                    ),
                  ),
                ],
              ),
              onTap: () {
                ref
                    .read(webSessionProvider.notifier)
                    .setSelectedWalletType(WalletType.ra);
              },
            ));

            if (session.btcKeypair != null && btcAddress != null) {
              list.add(PopupMenuItem(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      selectedWalletType == WalletType.btc
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_outlined,
                      color: Color(0xfff7931a),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        btcAddress,
                        style: TextStyle(
                            color: Color(0xfff7931a), fontSize: fontSize),
                      ),
                    ),
                    SizedBox(width: 6),
                  ],
                ),
                onTap: () {
                  ref
                      .read(webSessionProvider.notifier)
                      .setSelectedWalletType(WalletType.btc);
                },
              ));
            } else {
              list.add(PopupMenuItem(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      color: Color(0xfff7931a),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Add BTC Account",
                        style: TextStyle(
                            color: Color(0xfff7931a), fontSize: fontSize),
                      ),
                    ),
                    SizedBox(width: 6),
                  ],
                ),
                onTap: () async {
                  final NewBtcWalletOption? option = await showModalBottomSheet(
                    context: rootNavigatorKey.currentContext!,
                    builder: (context) {
                      return WebCreateBtcWalletModal();
                    },
                  );

                  if (option == null) {
                    return;
                  }

                  if (option == NewBtcWalletOption.generate) {
                    final account =
                        await BtcWebService().keypairFromRandomMnemonic();

                    if (account == null) {
                      Toast.error();
                      return;
                    }

                    ref
                        .read(webSessionProvider.notifier)
                        .updateBtcKeypair(account, true);

                    final keypair = Keypair(
                      private: account.privateKey,
                      address: account.address,
                      public: account.publicKey,
                      mneumonic: account.mnemonic,
                      btcWif: account.wif,
                    );
                    showKeys(context, keypair);
                    return;
                  }

                  if (option == NewBtcWalletOption.import) {
                    final wif = await PromptModal.show(
                        title: "Import BTC WIF Private Key",
                        labelText: "WIF Private Key",
                        confirmText: "Import",
                        cancelText: "Cancel",
                        labelColor: Theme.of(context).colorScheme.btcOrange,
                        validator: (val) =>
                            formValidatorNotEmpty(val, "WIF Private Key"));

                    if (wif == null) {
                      return;
                    }

                    final account =
                        await BtcWebService().keypairFromWif(wif, 'bech32');

                    if (account == null) {
                      Toast.error();
                      return;
                    }

                    ref
                        .read(webSessionProvider.notifier)
                        .updateBtcKeypair(account, true);

                    Toast.message("BTC Account Imported");
                  }
                },
              ));
            }

            if (BreakPoints.useMobileLayout(context)) {
              list.add(PopupMenuDivider());

              list.add(
                PopupMenuItem(
                  child: Center(
                    child: AppButton(
                      label: "Manage Accounts",
                      type: AppButtonType.Text,
                      variant: AppColorVariant.Light,
                      onPressed: () {
                        Navigator.of(context).pop();
                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return ModalContainer(children: [
                                _ManageAccountRow(
                                  address: primaryAddress,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  handleReveal: () {
                                    if (ref.read(webSessionProvider).keypair !=
                                        null) {
                                      showKeys(
                                          context,
                                          ref.read(webSessionProvider).keypair!,
                                          true);
                                    }
                                  },
                                ),
                                _ManageAccountRow(
                                  address: raAddress,
                                  color: Theme.of(context).colorScheme.reserve,
                                  handleReveal: () {
                                    if (ref
                                            .read(webSessionProvider)
                                            .raKeypair !=
                                        null) {
                                      showRaKeys(
                                          context,
                                          ref
                                              .read(webSessionProvider)
                                              .raKeypair!,
                                          true);
                                    }
                                  },
                                ),
                                if (btcAddress != null)
                                  _ManageAccountRow(
                                    address: btcAddress,
                                    color:
                                        Theme.of(context).colorScheme.btcOrange,
                                    handleReveal: () {
                                      final btcKeypair = ref
                                          .read(webSessionProvider)
                                          .btcKeypair;

                                      if (btcKeypair != null) {
                                        final kp = Keypair(
                                          private: btcKeypair.privateKey,
                                          address: btcKeypair.address,
                                          public: btcKeypair.publicKey,
                                          btcWif: btcKeypair.wif,
                                        );
                                        showKeys(context, kp, true);
                                        return;
                                      }
                                    },
                                  ),
                              ]);
                            });
                      },
                    ),
                  ),
                ),
              );
            }

            return list;
          },
        ),
        SizedBox(width: 4),
      ],
    );
  }
}

class _ManageAccountRow extends StatelessWidget {
  final String address;
  final Color color;
  final VoidCallback handleReveal;

  const _ManageAccountRow({
    super.key,
    required this.address,
    required this.color,
    required this.handleReveal,
    this.primaryAddress,
  });

  final String? primaryAddress;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(
        address,
        style: TextStyle(fontSize: 13, color: color),
      ),
      IconButton(
        onPressed: () async {
          final confirmed = await ConfirmDialog.show(
            title: "Reveal Private Key?",
            body:
                "Are you sure you want to reveal your private key for this account?",
            confirmText: "Reveal",
            cancelText: "Cancel",
          );

          if (confirmed != true) {
            return;
          }
          handleReveal();
        },
        icon: Icon(Icons.remove_red_eye),
      )
    ]);
  }
}
