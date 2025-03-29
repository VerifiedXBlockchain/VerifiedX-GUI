import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/core/app_constants.dart';
import 'package:rbx_wallet/core/base_screen.dart';
import 'package:rbx_wallet/core/components/buttons.dart';
import 'package:rbx_wallet/core/dialogs.dart';
import 'package:rbx_wallet/core/providers/session_provider.dart';
import 'package:rbx_wallet/core/providers/web_session_provider.dart';
import 'package:rbx_wallet/core/theme/app_theme.dart';
import 'package:rbx_wallet/core/theme/components.dart';
import 'package:rbx_wallet/features/btc/providers/tokenized_bitcoin_list_provider.dart';
import 'package:collection/collection.dart';
import 'package:rbx_wallet/features/smart_contracts/components/sc_creator/common/modal_container.dart';
import 'package:rbx_wallet/utils/toast.dart';
import '../../../core/base_component.dart';
import '../../../utils/validation.dart';
import '../../bridge/models/log_entry.dart';
import '../../bridge/providers/log_provider.dart';
import '../../btc_web/providers/btc_web_vbtc_token_list_provider.dart';
import '../../global_loader/global_loading_provider.dart';
import '../../token/providers/web_token_actions_manager.dart';
import '../providers/bulk_vbtc_transfer_provider.dart';
import '../services/btc_service.dart';

class BulkVbtcTransferScreen extends BaseScreen {
  const BulkVbtcTransferScreen({super.key});

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: Text("Bulk vBTC Transfer"),
      backgroundColor: Colors.black,
      shadowColor: Colors.transparent,
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final tokens = ref.watch(tokenizedBitcoinListProvider).where((element) => element.balance > 0).toList();
    final webTokens = ref.watch(btcWebVbtcTokenListProvider).where((element) => element.globalBalance > 0).toList();

    final provider = ref.read(bulkVbtcTransferProvider.notifier);
    final inputs = ref.watch(bulkVbtcTransferProvider);

    final maximumAmount = inputs.fold<double>(0.0, (prev, item) => prev + item.amount);

    return Column(
      children: [
        Text(
          "Select the tokens you'd like to transfer from:",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        kIsWeb
            ? Expanded(
                child: ListView.builder(
                    itemCount: webTokens.length,
                    itemBuilder: (context, index) {
                      final token = webTokens[index];

                      final isSelected = inputs.firstWhereOrNull((input) => input.scId == token.scIdentifier) != null;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: AppCard(
                          padding: 0,
                          child: ListTile(
                            leading: Checkbox(
                              value: isSelected,
                              onChanged: (value) {
                                if (!isSelected) {
                                  provider.add(scId: token.scIdentifier, amount: token.globalBalance, ownerAddress: token.ownerAddress);
                                } else {
                                  provider.remove(token.scIdentifier);
                                }
                              },
                            ),
                            title: Text(token.name),
                            subtitle: Text(token.ownerAddress),
                            trailing: Text(
                              "${token.globalBalance} vBTC",
                              style: TextStyle(color: Theme.of(context).colorScheme.btcOrange),
                            ),
                          ),
                        ),
                      );
                    }),
              )
            : Expanded(
                child: ListView.builder(
                    itemCount: tokens.length,
                    itemBuilder: (context, index) {
                      final token = tokens[index];

                      final isSelected = inputs.firstWhereOrNull((input) => input.scId == token.smartContractUid) != null;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: AppCard(
                          padding: 0,
                          child: ListTile(
                            leading: Checkbox(
                              value: isSelected,
                              onChanged: (value) {
                                if (!isSelected) {
                                  provider.add(scId: token.smartContractUid, amount: token.myBalance, ownerAddress: token.rbxAddress);
                                } else {
                                  provider.remove(token.smartContractUid);
                                }
                              },
                            ),
                            title: Text(token.tokenName),
                            subtitle: Text(token.rbxAddress),
                            trailing: Text(
                              "${token.myBalance} vBTC",
                              style: TextStyle(color: Theme.of(context).colorScheme.btcOrange),
                            ),
                          ),
                        ),
                      );
                    }),
              ),
        AppCard(
          fullWidth: true,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Maximum Transfer Amount:"),
                  Text(
                    "$maximumAmount vBTC",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.btcOrange,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              AppButton(
                label: "Continue",
                onPressed: () {
                  if (inputs.isEmpty) {
                    Toast.message("No tokens selected.");
                    return;
                  }

                  if (inputs.length < 2) {
                    Toast.message("At least two tokens are required to do a bulk vBTC transaction");
                    return;
                  }
                  provider.setAllToZero();

                  showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (context) {
                        return _ConfirmBottomSheet();
                      });
                },
                variant: AppColorVariant.Btc,
              )
            ],
          ),
        ),
        SizedBox(
          height: 32,
        )
      ],
    );
  }
}

class _ConfirmBottomSheet extends BaseComponent {
  const _ConfirmBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.read(bulkVbtcTransferProvider.notifier);
    final inputs = ref.watch(bulkVbtcTransferProvider);

    final totalAmount = inputs.fold<double>(0.0, (prev, item) => prev + item.amount);

    final inputScIds = inputs.map((e) => e.scId).toList();
    final tokens = ref.watch(tokenizedBitcoinListProvider).where((element) => inputScIds.contains(element.smartContractUid)).toList();
    final webTokens = ref.watch(btcWebVbtcTokenListProvider).where((element) => inputScIds.contains(element.scIdentifier)).toList();

    return ModalContainer(
      children: [
        Text(
          "Input Amounts for each token:",
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(
          height: 8,
        ),
        Form(
          key: provider.formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (kIsWeb)
                ...webTokens.asMap().entries.map((entry) {
                  final index = entry.key;
                  final token = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: AppCard(
                      padding: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(token.name),
                          subtitle: Text(token.ownerAddress),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 200,
                                child: TextFormField(
                                  controller: provider.controllers[index],
                                  validator: (value) {
                                    if (value == null) {
                                      return "Amount required";
                                    }
                                    final d = double.tryParse(value);
                                    if (d == null) {
                                      return "Invalid Amount";
                                    }

                                    if (d > token.globalBalance) {
                                      return "Maximum amount is ${token.globalBalance} vBTC";
                                    }

                                    return null;
                                  },
                                  decoration: InputDecoration(hintText: "Amount", suffixText: "vBTC"),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp("[0-9.]"),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    print(value);
                                    final d = double.tryParse(value);
                                    if (d != null) {
                                      provider.updateAmount(index, d);
                                    }
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              AppButton(
                                label: "(MAX: ${token.globalBalance} vBTC)",
                                type: AppButtonType.Text,
                                underlined: true,
                                onPressed: () {
                                  provider.controllers[index].text = "${token.globalBalance}";
                                  provider.updateAmount(index, token.globalBalance);
                                },
                                variant: AppColorVariant.Btc,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              if (!kIsWeb)
                ...tokens.asMap().entries.map((entry) {
                  final index = entry.key;
                  final token = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: AppCard(
                      padding: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(token.tokenName),
                          subtitle: Text(token.rbxAddress),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 200,
                                child: TextFormField(
                                  controller: provider.controllers[index],
                                  validator: (value) {
                                    if (value == null) {
                                      return "Amount required";
                                    }
                                    final d = double.tryParse(value);
                                    if (d == null) {
                                      return "Invalid Amount";
                                    }

                                    if (d > token.myBalance) {
                                      return "Maximum amount is ${token.myBalance} vBTC";
                                    }

                                    return null;
                                  },
                                  decoration: InputDecoration(hintText: "Amount", suffixText: "vBTC"),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp("[0-9.]"),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    print(value);
                                    final d = double.tryParse(value);
                                    if (d != null) {
                                      provider.updateAmount(index, d);
                                    }
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              AppButton(
                                label: "(MAX: ${token.myBalance} vBTC)",
                                type: AppButtonType.Text,
                                underlined: true,
                                onPressed: () {
                                  provider.controllers[index].text = "${token.myBalance}";
                                  provider.updateAmount(index, token.myBalance);
                                },
                                variant: AppColorVariant.Btc,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text("Total: $totalAmount vBTC"),
                ),
              ),
              TextFormField(
                controller: provider.addressController,
                validator: (value) => formValidatorRbxAddress(value, false),
                decoration: InputDecoration(
                  label: Text("Transfer To VFX Address"),
                  hintText: "Recipient's VFX Account Address",
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp('[a-zA-Z0-9.]'),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 16,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppButton(
              label: "Cancel",
              onPressed: () {
                Navigator.of(context).pop();
              },
              variant: AppColorVariant.Light,
              type: AppButtonType.Text,
            ),
            AppButton(
              label: "Send",
              onPressed: () async {
                if (!provider.formKey.currentState!.validate()) {
                  return;
                }

                final validInputs = inputs.where((element) => element.amount > 0).toList();

                if (validInputs.length < 2) {
                  Toast.message("At least two tokens are required to do a bulk vBTC transaction");
                  return;
                }

                final toAddress = provider.addressController.text.trim();

                final message = "Would you like to send a total of $totalAmount vBTC to $toAddress";

                final confirmed = await ConfirmDialog.show(title: "Confirm Bulk Tx", body: message, confirmText: "Send", cancelText: "Cancel");
                if (confirmed != true) {
                  return;
                }

                if (kIsWeb) {
                  final balance = ref.read(webSessionProvider).balance;

                  if (balance == null || balance < MIN_RBX_FOR_SC_ACTION) {
                    Toast.error("Selected VFX account doesn't have enough balance");
                    return;
                  }

                  final manager = ref.read(webTokenActionsManager);

                  final success = await manager.transferVbtcMulti(toAddress, validInputs);

                  if (success == true) {
                    Toast.message("vBTC Bulk Transfer TX broadcasted");
                    for (var element in provider.controllers) {
                      element.clear();
                    }
                    provider.addressController.clear();
                    ref.invalidate(bulkVbtcTransferProvider);

                    Toast.message("$totalAmount vBTC has been sent to $toAddress.");
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  }
                } else {
                  final currentWallet = ref.read(sessionProvider).currentWallet;
                  if (currentWallet == null) {
                    Toast.error("No VFX account selected");
                    return;
                  }
                  if (currentWallet.balance < MIN_RBX_FOR_SC_ACTION) {
                    Toast.error("Selected VFX account doesn't have enough balance");
                    return;
                  }

                  ref.read(globalLoadingProvider.notifier).start();

                  final hash = await BtcService().transferCoinMulti(
                    currentWallet.address,
                    toAddress,
                    validInputs,
                  );

                  ref.read(globalLoadingProvider.notifier).complete();

                  if (hash != null) {
                    final message = "vBTC Bulk Transfer TX broadcasted with hash of $hash";

                    ref.read(logProvider.notifier).append(
                          LogEntry(
                            message: message,
                            textToCopy: hash,
                            variant: AppColorVariant.Btc,
                          ),
                        );

                    for (var element in provider.controllers) {
                      element.clear();
                    }
                    provider.addressController.clear();
                    ref.invalidate(bulkVbtcTransferProvider);

                    Toast.message("$totalAmount vBTC has been sent to $toAddress.");
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  }
                }
              },
              variant: AppColorVariant.Btc,
            )
          ],
        ),
      ],
    );
  }
}
