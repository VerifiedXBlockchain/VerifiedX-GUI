import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rbx_wallet/core/theme/colors.dart';
import '../../../core/providers/currency_segmented_button_provider.dart';
import '../../../core/theme/components.dart';
import '../../../core/app_constants.dart';
import '../../../core/models/web_session_model.dart';
import '../../../core/theme/pretty_icons.dart';
import '../../btc/models/btc_account.dart';
import '../../btc/models/btc_fee_rate_preset.dart';
import '../../btc/models/btc_recommended_fees.dart';
import '../../btc/providers/btc_account_list_provider.dart';
import '../../btc/utils.dart';
import '../../btc_web/models/btc_web_account.dart';
import '../../keygen/models/ra_keypair.dart';
import '../../../core/providers/session_provider.dart';
import '../../wallet/providers/wallet_list_provider.dart';

import '../../../core/base_component.dart';
import '../../../core/breakpoints.dart';
import '../../../core/components/badges.dart';
import '../../../core/components/buttons.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../utils/toast.dart';
import '../../encrypt/utils.dart';
import '../../keygen/models/keypair.dart';
import '../../wallet/models/wallet.dart';
import '../../reserve/components/balance_indicator.dart';
import '../../web/components/new_web_wallet_selector.dart';
import '../../web/components/web_wallet_type_switcher.dart';
import '../../web/providers/web_currency_segmented_button_provider.dart';
import '../../web/providers/web_selected_account_provider.dart';
import '../providers/send_form_provider.dart';

class SendForm extends BaseComponent {
  final Wallet? wallet;
  final BtcAccount? btcAccount;
  final Keypair? keypair;
  final RaKeypair? raKeypair;
  final BtcWebAccount? btcWebAccount;

  const SendForm({
    this.wallet,
    this.keypair,
    this.raKeypair,
    this.btcAccount,
    this.btcWebAccount,
    super.key,
  });

  Future<void> _pasteAddress(SendFormProvider formProvider) async {
    ClipboardData? clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text != null) {
      final normalizedText = clipboardData.text!.replaceAll(RegExp('[^a-zA-Z0-9]'), "");
      formProvider.addressController.text = normalizedText;
    } else {
      Toast.error("Clipboard text is invalid");
    }
  }

  Future<void> chooseAddress(BuildContext context, WidgetRef ref, SendFormProvider formProvider) async {
    List<String> addresses = [];

    if (ref.read(currencySegementedButtonProvider) == CurrencyType.btc || ref.read(currencySegementedButtonProvider) == CurrencyType.any) {
      addresses.addAll(ref.read(btcAccountListProvider).map((a) => a.address));
    }
    if (ref.read(currencySegementedButtonProvider) == CurrencyType.vfx || ref.read(currencySegementedButtonProvider) == CurrencyType.any) {
      addresses.addAll(ref.read(walletListProvider).map((a) => a.address));
    }

    final address = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Choose an address"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white60),
                ),
              )
            ],
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: addresses
                  .map(
                    (a) => TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(a);
                      },
                      child: Text(
                        a,
                        style: const TextStyle(color: Colors.white, decoration: TextDecoration.underline),
                      ),
                    ),
                  )
                  .toList(),
            ),
          );
        });
    if (address != null) {
      formProvider.addressController.text = address;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final webAccountType = kIsWeb ? ref.watch(webSelectedAccountProvider) : null;

    bool isWeb = kIsWeb;
    bool isBtc = kIsWeb ? webAccountType?.type == WebCurrencyType.btc : ref.watch(sessionProvider.select((v) => v.btcSelected));

    const leadingWidth = 70.0;

    final formProvider = ref.read(sendFormProvider.notifier);
    final formState = ref.watch(sendFormProvider);

    String pasteMessage = "Use ctrl+v to paste or click ";

    if (!kIsWeb && Platform.isMacOS) {
      pasteMessage = pasteMessage.replaceAll("ctrl+v", "cmd+v");
    }

    final isMobile = BreakPoints.useMobileLayout(context);
    final btcColor = Theme.of(context).colorScheme.btcOrange;

    double balance = 0.0;
    double lockedBalance = 0.0;
    double totalBalance = 0.0;
    Color color = Colors.white;

    if (isWeb) {
      final selectedAccount = ref.watch(webSelectedAccountProvider);
      print(selectedAccount?.balance);

      balance = selectedAccount?.balance ?? 0.0;
      lockedBalance = selectedAccount?.lockedBalance ?? 0.0;
      totalBalance = selectedAccount?.totalBalance ?? 0.0;
      switch (webAccountType?.type) {
        case WebCurrencyType.btc:
          color = AppColors.getBtc();
          break;
        case WebCurrencyType.vault:
          color = AppColors.getReserve();
          break;
        default:
          color = AppColors.getBlue();
      }
    } else {
      if (isBtc) {
        balance = btcAccount?.balance ?? 0.0;
        color = AppColors.getBtc();
      }
      balance = wallet?.balance ?? 0;
      totalBalance = wallet?.totalBalance ?? 0.0;
      lockedBalance = wallet?.lockedBalance ?? 0.0;
      color = wallet?.isReserved == true ? Colors.deepPurple.shade200 : Colors.white;
    }

    return Form(
      key: formProvider.formKey,
      child: AppCard(
        padding: 0,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (!BreakPoints.useMobileLayout(context))
                      SizedBox(
                        width: 72,
                        child: Text("From:"),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isBtc && wallet!.isReserved && !wallet!.isNetworkProtected)
                            AppBadge(
                              label: 'Not Activated',
                              variant: AppColorVariant.Danger,
                            ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isWeb) NewWebWalletSelector(),
                              if (!isWeb)
                                PopupMenuButton(
                                  color: Color(0xFF080808),
                                  constraints: BoxConstraints(maxWidth: 500),
                                  itemBuilder: (context) {
                                    final currentWallet = ref.watch(sessionProvider.select((v) => v.currentWallet));
                                    final allWallets = ref.watch(walletListProvider);
                                    final allBtcAccounts = ref.watch(btcAccountListProvider);

                                    final currencyType = ref.watch(currencySegementedButtonProvider);

                                    final list = <PopupMenuEntry<int>>[];
                                    if (currencyType != CurrencyType.btc) {
                                      for (final wallet in allWallets) {
                                        final isSelected = !isBtc && currentWallet != null && wallet.address == currentWallet.address;

                                        final color = wallet.isReserved ? Colors.deepPurple.shade200 : Theme.of(context).textTheme.bodyLarge!.color!;

                                        list.add(
                                          PopupMenuItem(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (isSelected)
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 4.0),
                                                    child: Icon(Icons.check),
                                                  ),
                                                Text(
                                                  wallet.labelWithoutTruncation,
                                                  style: TextStyle(color: color),
                                                ),
                                              ],
                                            ),
                                            onTap: () {
                                              ref.read(sessionProvider.notifier).setCurrentWallet(wallet);
                                            },
                                          ),
                                        );
                                      }
                                    }

                                    if (currencyType != CurrencyType.vfx) {
                                      for (final account in allBtcAccounts) {
                                        final isSelected = isBtc && btcAccount != null && btcAccount!.address == account.address;

                                        final color = btcColor;
                                        list.add(
                                          PopupMenuItem(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (isSelected)
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 4.0),
                                                    child: Icon(Icons.check),
                                                  ),
                                                Text(
                                                  account.address,
                                                  style: TextStyle(color: color),
                                                ),
                                              ],
                                            ),
                                            onTap: () {
                                              ref.read(sessionProvider.notifier).setCurrentBtcAccount(account);
                                            },
                                          ),
                                        );
                                      }
                                    }
                                    return list;
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        isBtc ? btcAccount?.address ?? '' : wallet!.address,
                                        style: TextStyle(color: isBtc ? btcColor : color, fontSize: 16),
                                      ),
                                      Icon(
                                        Icons.arrow_drop_down,
                                        size: 24,
                                        color: isBtc
                                            ? btcColor
                                            : wallet!.isReserved
                                                ? Colors.deepPurple.shade200
                                                : Theme.of(context).textTheme.bodyLarge!.color!,
                                      ),
                                    ],
                                  ),
                                )
                            ],
                          ),
                        ],
                      ),
                    ),
                    !isBtc
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (lockedBalance == 0.0)
                                AppBadge(
                                  label: "$balance VFX",
                                  variant: AppColorVariant.Light,
                                ),
                              if (lockedBalance > 0) ...[
                                BalanceIndicator(
                                  label: "Available",
                                  value: balance,
                                  bgColor: wallet!.isReserved ? Colors.deepPurple.shade400 : Colors.white,
                                  fgColor: wallet!.isReserved ? Colors.white : Colors.black,
                                ),
                                BalanceIndicator(
                                  label: "Locked",
                                  value: lockedBalance,
                                  bgColor: Colors.red.shade700,
                                  fgColor: Colors.white,
                                ),
                                BalanceIndicator(
                                  label: "Total",
                                  value: totalBalance,
                                  bgColor: Colors.green.shade700,
                                  fgColor: Colors.white,
                                ),
                              ]
                            ],
                          )
                        : isBtc
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  AppBadge(
                                    label: kIsWeb
                                        ? "${ref.watch(webSessionProvider.select((v) => v.btcBalanceInfo?.btcBalance)) ?? 0} BTC"
                                        : "${btcAccount!.balance} BTC",
                                    variant: AppColorVariant.Btc,
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  BalanceIndicator(
                                    label: "Available",
                                    value: wallet!.availableBalance,
                                    bgColor: wallet!.isReserved ? Colors.deepPurple.shade400 : Colors.white,
                                    fgColor: wallet!.isReserved ? Colors.white : Colors.black,
                                  ),
                                  BalanceIndicator(
                                    label: "Locked",
                                    value: wallet!.lockedBalance,
                                    bgColor: Colors.red.shade700,
                                    fgColor: Colors.white,
                                  ),
                                  BalanceIndicator(
                                    label: "Total",
                                    value: wallet!.balance,
                                    bgColor: Colors.green.shade700,
                                    fgColor: Colors.white,
                                  ),
                                ],
                              ),
                  ],
                ),
              ),
              ListTile(
                leading: isMobile ? null : const SizedBox(width: leadingWidth, child: Text("To:")),
                title: TextFormField(
                  controller: formProvider.addressController,
                  validator: formProvider.addressValidator,
                  decoration: const InputDecoration(hintText: "Recipient's Account Address"),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9.]')),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(pasteMessage),
                      InkWell(
                        onTap: () {
                          _pasteAddress(formProvider);
                        },
                        child: Text(
                          "here",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                      const Text("."),
                    ],
                  ),
                ),
                trailing: isMobile
                    ? null
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PrettyIconButton(
                            type: PrettyIconType.custom,
                            customIcon: Icons.paste,
                            onPressed: () {
                              _pasteAddress(formProvider);
                            },
                          ),
                          if (!kIsWeb)
                            PrettyIconButton(
                              type: PrettyIconType.custom,
                              iconScale: .75,
                              customIcon: FontAwesomeIcons.folderOpen,
                              onPressed: () {
                                chooseAddress(context, ref, formProvider);
                              },
                            ),
                        ],
                      ),
              ),
              ListTile(
                leading: isMobile ? null : const SizedBox(width: leadingWidth, child: Text("Amount:")),
                title: TextFormField(
                  controller: formProvider.amountController,
                  validator: formProvider.amountValidator,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9.]"))],
                  decoration: InputDecoration(
                      hintText: "Amount of ${isBtc ? 'BTC' : 'VFX'} to send",
                      helperText: formState.usdValue > 0 ? "\$${formState.usdValue.toStringAsFixed(2)} USD" : null),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              if (isBtc && !kIsWeb)
                Consumer(builder: (context, ref, _) {
                  final recommendedFees = ref.watch(sessionProvider.select((v) => v.btcRecommendedFees)) ?? BtcRecommendedFees.fallback();

                  int fee = 0;

                  switch (formState.btcFeeRatePreset) {
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
                        leading: const SizedBox(width: leadingWidth, child: Text("Fee Rate:")),
                        title: Row(
                          children: [
                            PopupMenuButton<BtcFeeRatePreset>(
                              color: Color(0xFF080808),
                              onSelected: (value) {
                                formProvider.setBtcFeeRatePreset(value);
                              },
                              itemBuilder: (context) {
                                return BtcFeeRatePreset.values.map((preset) {
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
                                    formState.btcFeeRatePreset.label,
                                    style: TextStyle(fontSize: 16, color: btcColor),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    size: 24,
                                    color: btcColor,
                                  ),
                                ],
                              ),
                            ),
                            if (formState.btcFeeRatePreset == BtcFeeRatePreset.custom)
                              Expanded(
                                child: TextFormField(
                                  controller: formProvider.btcCustomFeeRateController,
                                  validator: formProvider.btcCustomFeeRateValidator,
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9]"))],
                                  decoration: InputDecoration(hintText: "Fee rate in satoshis"),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (formState.btcFeeRatePreset != BtcFeeRatePreset.custom)
                        Padding(
                          padding: const EdgeInsets.only(left: leadingWidth + 30),
                          child: Text(
                            "Fee Rate: $fee SATS /byte [$feeBtc BTC /byte]\nFee Estimate: ~$feeEstimate SATS [~$feeEstimateBtc BTC]    ",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      if (formState.btcFeeRatePreset == BtcFeeRatePreset.custom)
                        Padding(
                          padding: const EdgeInsets.only(left: leadingWidth + 30),
                          child: Text(
                            "Fee Rate: ${formState.btcCustomFeeRate} SATS /byte [${(formState.btcCustomFeeRate * BTC_SATOSHI_MULTIPLIER).toStringAsFixed(9)} BTC /byte]\nFee Estimate: ${(formState.btcCustomFeeRate * BTC_TX_EXPECTED_BYTES)} SATS [~${(formState.btcCustomFeeRate * BTC_TX_EXPECTED_BYTES * BTC_SATOSHI_MULTIPLIER).toStringAsFixed(9)} BTC]",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                    ],
                  );
                }),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Divider(),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0).copyWith(right: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppButton(
                      label: "Clear",
                      type: AppButtonType.Text,
                      variant: AppColorVariant.Info,
                      onPressed: () {
                        formProvider.formKey.currentState!.reset();
                        formProvider.clear();
                      },
                    ),
                    Consumer(builder: (context, ref, _) {
                      return AppButton(
                        label: "Send",
                        type: AppButtonType.Elevated,
                        variant: isBtc ? AppColorVariant.Btc : AppColorVariant.Primary,
                        processing: formState.isProcessing,
                        disabled: !isBtc && (wallet!.isReserved && !wallet!.isNetworkProtected),
                        onPressed: () async {
                          if (!await passwordRequiredGuard(context, ref)) return;

                          if (!formProvider.formKey.currentState!.validate()) {
                            return;
                          }

                          formProvider.submit();
                        },
                      );
                    }),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
