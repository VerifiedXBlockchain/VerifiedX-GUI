part of './tokenize_btc_onboarding_screen.dart';

class _TransferBtcToVbtcStep extends BaseComponent {
  const _TransferBtcToVbtcStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = ref.read(vBtcOnboardProvider.notifier);
    final state = ref.watch(vBtcOnboardProvider);

    if (state.btcAccount == null || state.tokenizedBtc == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.btcNoBtcAccountOrToken),
          AppButton(
            label: l10n.btcStartOver,
            onPressed: () {
              provider.reset();
            },
          )
        ],
      );
    }

    int fee = 0;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 550),
      child: Form(
        key: provider.btcTransferFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!state.transferToTokenManually) ...[
              Text(l10n.btcFromAddress(state.btcAccount!.address)),
              SizedBox(
                height: 8,
              ),
              Text(l10n.btcToAddress(state.tokenizedBtc!.btcAddress ?? '')),
              SizedBox(
                height: 8,
              ),
              TextFormField(
                controller: provider.btcTransferAmountController,
                validator: (val) => formValidatorNumber(val, "Amount"),
                decoration:
                    InputDecoration(label: Text(l10n.btcAmountToSendLabel)),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[0-9.]"))
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Builder(
                builder: (context) {
                  final recommendedFees = ref.watch(sessionProvider
                          .select((v) => v.btcRecommendedFees)) ??
                      BtcRecommendedFees.fallback();

                  switch (state.btcFeeRatePreset) {
                    case BtcFeeRatePreset.custom:
                      fee = 0;
                      break;
                    case BtcFeeRatePreset.minimum:
                      fee = recommendedFees.minimumFee;
                      break;
                    case BtcFeeRatePreset.economy:
                      fee = recommendedFees.economyFee;
                      break;
                    case BtcFeeRatePreset.hour:
                      fee = recommendedFees.hourFee;
                      break;
                    case BtcFeeRatePreset.halfHour:
                      fee = recommendedFees.halfHourFee;
                      break;
                    case BtcFeeRatePreset.fastest:
                      fee = recommendedFees.fastestFee;
                      break;
                  }

                  final feeBtc = satashiToBtcLabel(fee);
                  final feeEstimate = satashiTxFeeEstimate(fee);
                  final feeEstimateBtc = btcTxFeeEstimateLabel(fee);

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: SizedBox(
                            width: 100, child: Text(l10n.btcFeeRateLabel)),
                        title: Row(
                          children: [
                            PopupMenuButton<BtcFeeRatePreset>(
                              color: Color(0xFF080808),
                              onSelected: (value) {
                                provider.setBtcFeeRatePreset(value);
                              },
                              itemBuilder: (context) {
                                return BtcFeeRatePreset.values
                                    .where((type) =>
                                        type != BtcFeeRatePreset.custom)
                                    .map((preset) {
                                  return PopupMenuItem(
                                    value: preset,
                                    child: Text(preset.label),
                                  );
                                }).toList();
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    state.btcFeeRatePreset.label,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .btcOrange),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    size: 24,
                                    color:
                                        Theme.of(context).colorScheme.btcOrange,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        l10n.tkbFeeEstimate(feeEstimate.toString(), feeEstimateBtc, fee.toString(), feeBtc),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  );
                },
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AppButton(
                    label: l10n.btcInitiateTransfer,
                    variant: AppColorVariant.Btc,
                    onPressed: () async {
                      if (!provider.btcTransferFormKey.currentState!
                          .validate()) {
                        return;
                      }

                      provider.refreshBtcAccount();

                      final amountParsed = double.tryParse(
                          provider.btcTransferAmountController.text.trim());
                      if (amountParsed == null) {
                        Toast.error(l10n.btcInvalidAmount);
                        return;
                      }

                      print(amountParsed);
                      print(state.btcAccount);

                      if (amountParsed > state.btcAccount!.balance) {
                        Toast.error(
                            l10n.btcNotEnoughBalance(amountParsed.toString()));
                        return;
                      }

                      final success =
                          await provider.transferBtcToVbtc(amountParsed, fee);

                      if (success) {
                        provider.setProcessingState(
                            VBtcProcessingState.waitingForBtcToVbtcTransfer);
                      }
                    },
                  ),
                ),
              ),
            ],
            if (!state.transferToTokenManually) ...[
              Divider(),
              Text(l10n.btcManualSendBody),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: AppButton(
                  label: state.transferToTokenManually
                      ? l10n.tkbSendAutomatically
                      : l10n.tkbSendManually,
                  type: AppButtonType.Text,
                  underlined: true,
                  onPressed: () {
                    provider.setTransferToTokenManually(
                        !state.transferToTokenManually);
                  },
                  variant: AppColorVariant.Light,
                ),
              ),
            ),
            if (state.transferToTokenManually) ...[
              TextFormField(
                initialValue: state.tokenizedBtc!.btcAddress,
                readOnly: true,
                decoration: InputDecoration(
                  label: Text(l10n.btcAddressLabel),
                  suffix: IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: () async {
                      await Clipboard.setData(
                          ClipboardData(text: state.tokenizedBtc!.btcAddress));
                      Toast.message(l10n.btcAddressCopiedToast);
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Center(
                child: AppButton(
                  label: l10n.btcSentManually,
                  type: AppButtonType.Text,
                  underlined: true,
                  onPressed: () {
                    provider.setProcessingState(
                        VBtcProcessingState.waitingForBtcToVbtcTransfer);
                  },
                  variant: AppColorVariant.Btc,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class _TokenizeBtcStep extends BaseComponent {
  const _TokenizeBtcStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.read(vBtcOnboardProvider.notifier);
    final state = ref.watch(vBtcOnboardProvider);

    return TokenizeBtcForm(
      onSuccess: () {
        provider.setProcessingState(VBtcProcessingState.waitingForTokenization);
      },
    );
  }
}

class _TransferBtcStep extends BaseComponent {
  const _TransferBtcStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = ref.read(vBtcOnboardProvider.notifier);
    final state = ref.watch(vBtcOnboardProvider);

    if (state.btcAccount == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.btcNoBtcAccount),
          AppButton(
            label: l10n.btcStartOver,
            onPressed: () {
              provider.reset();
            },
          )
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500),
          child: TextFormField(
            initialValue: state.btcAccount!.address,
            readOnly: true,
            decoration: InputDecoration(
              label: Text(l10n.btcAddressLabel),
              suffix: IconButton(
                icon: Icon(Icons.copy),
                onPressed: () async {
                  await Clipboard.setData(
                      ClipboardData(text: state.btcAccount!.address));
                  Toast.message(l10n.btcWifCopiedToast);
                },
              ),
            ),
          ),
        ),
        SizedBox(
          height: 12,
        ),
        AppButton(
          label: l10n.btcDoneExclamation,
          onPressed: () {
            provider
                .setProcessingState(VBtcProcessingState.waitingForBtcTransfer);
          },
          variant: AppColorVariant.Btc,
        )
      ],
    );
  }
}

class _CreateOrImportVfxWalletStep extends BaseComponent {
  const _CreateOrImportVfxWalletStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = ref.read(vBtcOnboardProvider.notifier);
    final state = ref.watch(vBtcOnboardProvider);

    final existingWallets =
        ref.watch(walletListProvider).where((w) => !w.isReserved).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 16,
          children: [
            AppButton(
              label: l10n.btcImportExisting,
              icon: Icons.upload,
              onPressed: () async {
                final pkey = await PromptModal.show(
                  title: l10n.walletImportTitle,
                  validator: (String? value) =>
                      formValidatorNotEmpty(value, l10n.walletPrivateKey),
                  labelText: l10n.walletPrivateKeyLabel,
                  onValidSubmission: (value) async {},
                );

                if (pkey != null) {
                  final w = await ref
                      .read(walletListProvider.notifier)
                      .import(pkey, false);
                  if (w != null) {
                    if (w.balance >= VBTC_ONBOARD_VFX_AMOUNT) {
                      await InfoDialog.show(
                        title: l10n.btcBalanceFoundTitle,
                        body: l10n.tkbBalanceFoundBody(w.balance.toString()),
                      );
                    }
                    provider.setVfxWallet(w);
                    Toast.message(l10n.btcVfxAccountImportedToast);
                  }
                }
              },
              variant: AppColorVariant.Secondary,
            ),
            AppButton(
              label: l10n.btcCreateNew,
              icon: Icons.add,
              onPressed: () async {
                final w = await ref.read(walletListProvider.notifier).create();
                if (w != null) {
                  provider.setVfxWallet(w);
                  Toast.message(l10n.btcVfxAccountCreatedToast);
                }
              },
              variant: AppColorVariant.Secondary,
            )
          ],
        ),
        if (existingWallets.isNotEmpty) ...[
          SizedBox(
            height: 16,
          ),
          Text(l10n.btcUseExistingVfxAccount),
          SizedBox(
            height: 8,
          ),
          ...existingWallets
              .map((w) => InkWell(
                  onTap: () {
                    provider.setVfxWallet(w);
                  },
                  child: Text(
                    w.address,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        decoration: TextDecoration.underline),
                  )))
              .toList(),
        ]
      ],
    );
  }
}

class _FaucetWithdrawlStep extends BaseComponent {
  const _FaucetWithdrawlStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = ref.read(vBtcOnboardProvider.notifier);
    final state = ref.watch(vBtcOnboardProvider);

    if (state.vfxWallet == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.btcNoVfxAccount),
          AppButton(
            label: l10n.btcStartOver,
            onPressed: () {
              provider.reset();
            },
          )
        ],
      );
    }

    return Wrap(
      spacing: 16,
      children: [
        AppButton(
          label: l10n.btcUseFaucet,
          onPressed: () async {
            final phone = await PromptModal.show(
              title: l10n.btcPhoneNumberTitle,
              validator: formValidatorPhoneNumber,
              labelText: l10n.btcPhoneNumberLabel,
            );

            if (phone != null) {
              final cleanPhone = cleanPhoneNumber(phone);
              if (cleanPhone == null) {
                Toast.error(l10n.btcInvalidPhoneToast);
                return;
              }

              try {
                final uuid = await ExplorerService().faucetRequest(cleanPhone,
                    VBTC_ONBOARD_VFX_AMOUNT, state.vfxWallet!.address);

                final code = await PromptModal.show(
                  title: l10n.btcVerificationCodeTitle(phone),
                  validator: (v) =>
                      formValidatorNumber(v, l10n.btcVerificationCodeLabel),
                  labelText: l10n.btcVerificationCodeLabel,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp("[0-9.]"))
                  ],
                );

                if (code != null) {
                  final result =
                      await ExplorerService().faucetVerify(uuid, code.trim());

                  Toast.message(
                      l10n.btcFundsSuccessToast(result));
                  provider.setProcessingState(
                      VBtcProcessingState.waitingForVfxTransfer);
                }
              } catch (e) {
                print(e);
              }
            }
          },
        ),
        GetVfxButton(
          address: state.vfxWallet!.address,
          vfxOnly: true,
        ),
      ],
    );
  }
}

class _CreateOrImportBtcAccountStep extends BaseComponent {
  const _CreateOrImportBtcAccountStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = ref.read(vBtcOnboardProvider.notifier);
    final state = ref.watch(vBtcOnboardProvider);

    final existingAccounts = ref.watch(btcAccountListProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 16,
          children: [
            AppButton(
              label: l10n.btcImportExisting,
              icon: Icons.upload,
              variant: AppColorVariant.Btc,
              onPressed: () async {
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
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .btcOrange),
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
                            Navigator.of(context)
                                .pop([privateKeyController.text, "test"]);
                          },
                          child: Text(
                            l10n.actionImport,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.btcOrange),
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
                    final btcAccountSyncInfo =
                        ref.read(sessionProvider).btcAccountSyncInfo;

                    if (success) {
                      if (btcAccountSyncInfo != null) {
                        Toast.message(
                            l10n.walletPrivateKeyImportedSyncToast(btcAccountSyncInfo.nextSyncFormatted));
                      } else {
                        Toast.message(l10n.walletPrivateKeyImportedToast);
                      }
                      final account = ref
                          .read(btcAccountListProvider)
                          .firstWhereOrNull((a) => a.privateKey == privateKey);
                      if (account != null) {
                        provider.setBtcAccount(account);
                      }
                    } else {
                      Toast.error();
                    }
                  }
                }
              },
            ),
            AppButton(
              label: l10n.btcCreateNew,
              icon: Icons.add,
              onPressed: () async {
                final account =
                    await ref.read(btcAccountListProvider.notifier).create();
                if (account == null) {
                  Toast.error();
                  return;
                }

                await showDialog(
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
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .btcOrange),
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
                                color: Theme.of(context).colorScheme.btcOrange,
                              ),
                              onPressed: () async {
                                await Clipboard.setData(
                                    ClipboardData(text: account.privateKey));
                                Toast.message(
                                    l10n.walletPrivateKeyCopiedToast);
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
                              l10n.actionDone,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.btcOrange),
                            ))
                      ],
                    );
                  },
                );

                provider.setBtcAccount(account);
              },
              variant: AppColorVariant.Btc,
            )
          ],
        ),
        if (existingAccounts.isNotEmpty) ...[
          SizedBox(
            height: 16,
          ),
          Text(l10n.btcUseExistingBtcAccount),
          SizedBox(
            height: 8,
          ),
          ...existingAccounts
              .map((a) => InkWell(
                  onTap: () {
                    provider.setBtcAccount(a);
                  },
                  child: Text(
                    a.address,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        decoration: TextDecoration.underline),
                  )))
              .toList(),
        ]
      ],
    );
  }
}
