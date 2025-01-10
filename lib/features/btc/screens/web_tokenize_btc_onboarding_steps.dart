part of './web_tokenize_btc_onboarding_screen.dart';

class _WebTransferBtcToVbtcStep extends BaseComponent {
  const _WebTransferBtcToVbtcStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.read(webVBtcOnboardProvider.notifier);
    final state = ref.watch(webVBtcOnboardProvider);

    if (state.btcAccount == null || state.tokenizedBtc == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("No BTC account / Token Found."),
          AppButton(
            label: "Start Over",
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
              Text("From: ${state.btcAccount!.address}"),
              SizedBox(
                height: 8,
              ),
              Text("To: ${state.tokenizedBtc!.depositAddress}"),
              SizedBox(
                height: 8,
              ),
              TextFormField(
                controller: provider.btcTransferAmountController,
                validator: (val) => formValidatorNumber(val, "Amount"),
                decoration: InputDecoration(label: Text("Amount to Send (BTC)")),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9.]"))],
              ),
              SizedBox(
                height: 8,
              ),
              Builder(
                builder: (context) {
                  final recommendedFees = ref.watch(sessionProvider.select((v) => v.btcRecommendedFees)) ?? BtcRecommendedFees.fallback();

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
                        leading: const SizedBox(width: 100, child: Text("Fee Rate:")),
                        title: Row(
                          children: [
                            PopupMenuButton<BtcFeeRatePreset>(
                              color: Color(0xFF080808),
                              onSelected: (value) {
                                provider.setBtcFeeRatePreset(value);
                              },
                              itemBuilder: (context) {
                                return BtcFeeRatePreset.values.where((type) => type != BtcFeeRatePreset.custom).map((preset) {
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
                                    style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.btcOrange),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    size: 24,
                                    color: Theme.of(context).colorScheme.btcOrange,
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
                        "Fee Estimate: ~$feeEstimate SATS | ~$feeEstimateBtc BTC    ($fee SATS /byte | $feeBtc BTC /byte)",
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
                    label: "Initiate Transfer",
                    variant: AppColorVariant.Btc,
                    onPressed: () async {
                      if (!provider.btcTransferFormKey.currentState!.validate()) {
                        return;
                      }
                      final amountParsed = double.tryParse(provider.btcTransferAmountController.text.trim());
                      if (amountParsed == null) {
                        Toast.error("Invalid Amount");
                        return;
                      }

                      if (amountParsed > (ref.read(webSessionProvider).btcBalanceInfo?.balance ?? 0)) {
                        Toast.error("Not enough balance in BTC account to send $amountParsed BTC");
                        return;
                      }

                      final success = await provider.transferBtcToVbtc(amountParsed, fee);

                      if (success) {
                        provider.setProcessingState(VBtcProcessingState.waitingForBtcToVbtcTransfer);
                      }
                    },
                  ),
                ),
              ),
            ],
            if (!state.transferToTokenManually) ...[
              Divider(),
              Text("Alternatively, you can send the BTC manually to your token's deposit address."),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: AppButton(
                  label: state.transferToTokenManually ? "Send Automatically" : "Send Manually",
                  type: AppButtonType.Text,
                  underlined: true,
                  onPressed: () {
                    provider.setTransferToTokenManually(!state.transferToTokenManually);
                  },
                  variant: AppColorVariant.Light,
                ),
              ),
            ),
            if (state.transferToTokenManually) ...[
              TextFormField(
                initialValue: state.tokenizedBtc!.depositAddress,
                readOnly: true,
                decoration: InputDecoration(
                  label: Text("BTC Address"),
                  suffix: IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: state.tokenizedBtc!.depositAddress));
                      Toast.message("Address copied to clipboard!");
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Center(
                child: AppButton(
                  label: "I've sent this manually!",
                  type: AppButtonType.Text,
                  underlined: true,
                  onPressed: () {
                    provider.setProcessingState(VBtcProcessingState.waitingForBtcToVbtcTransfer);
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
    final provider = ref.read(webVBtcOnboardProvider.notifier);
    final state = ref.watch(webVBtcOnboardProvider);

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
    final provider = ref.read(webVBtcOnboardProvider.notifier);
    final state = ref.watch(webVBtcOnboardProvider);

    if (state.btcAccount == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("No BTC Account Found."),
          AppButton(
            label: "Start Over",
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
              label: Text("BTC Address"),
              suffix: IconButton(
                icon: Icon(Icons.copy),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: state.btcAccount!.address));
                  Toast.message("WIF private key copied to clipboard");
                },
              ),
            ),
          ),
        ),
        SizedBox(
          height: 12,
        ),
        AppButton(
          label: "Done!",
          onPressed: () {
            provider.setProcessingState(VBtcProcessingState.waitingForBtcTransfer);
          },
          variant: AppColorVariant.Btc,
        )
      ],
    );
  }
}

class _FaucetWithdrawlStep extends BaseComponent {
  const _FaucetWithdrawlStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.read(webVBtcOnboardProvider.notifier);
    final state = ref.watch(webVBtcOnboardProvider);

    if (state.vfxWallet == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("No VFX Account Found."),
          AppButton(
            label: "Start Over",
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
          label: "Use Faucet",
          onPressed: () async {
            final phone = await PromptModal.show(
              title: "Phone Number",
              validator: formValidatorPhoneNumber,
              labelText: "Your Phone Number",
            );

            if (phone != null) {
              final cleanPhone = cleanPhoneNumber(phone);
              if (cleanPhone == null) {
                Toast.error("Invalid Phone Number");
                return;
              }

              try {
                print("Address: ${state.vfxWallet!.address}");
                final uuid = await ExplorerService().faucetRequest(cleanPhone, VBTC_ONBOARD_VFX_AMOUNT, state.vfxWallet!.address);

                final code = await PromptModal.show(
                  title: "Enter verification code sent to $phone",
                  validator: (v) => formValidatorNumber(v, "Verification Code"),
                  labelText: "Verification Code",
                );

                if (code != null) {
                  final result = await ExplorerService().faucetVerify(uuid, code.trim());

                  Toast.message("Success! Funds are on their way. TX Hash: $result");
                  provider.setProcessingState(VBtcProcessingState.waitingForVfxTransfer);
                }
              } catch (e) {
                print(e);
              }
            }
          },
        ),
        AppButton(
          label: "Transfer Manually",
          onPressed: () async {
            provider.setProcessingState(VBtcProcessingState.waitingForVfxTransfer);
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
