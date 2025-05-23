import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/app.dart';
import '../../../core/components/buttons.dart';
import '../../btc/models/btc_fee_rate_preset.dart';
import '../../btc/models/btc_recommended_fees.dart';
import '../../btc/services/btc_service.dart';
import '../../btc/utils.dart';
import '../../btc_web/providers/btc_web_transaction_list_provider.dart';
import '../../btc_web/services/btc_web_service.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../core/app_constants.dart';
import '../../global_loader/global_loading_provider.dart';
import '../../price/providers/price_detail_providers.dart';
import '../../reserve/services/reserve_account_service.dart';
import '../../wallet/models/wallet.dart';

import '../../../core/dialogs.dart';
import '../../../core/env.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../utils/guards.dart';
import '../../../utils/toast.dart';
import '../../../utils/validation.dart';
import '../../bridge/models/log_entry.dart';
import '../../bridge/providers/log_provider.dart';
import '../../bridge/services/bridge_service.dart';
import '../../web/providers/web_currency_segmented_button_provider.dart';
import '../../web/providers/web_selected_account_provider.dart';
import '../../web/utils/raw_transaction.dart';
import '../../raw/raw_service.dart';
// import 'package:rbx_wallet/features/wallet/models/wallet.dart';

class SendFormModel {
  final String amount;
  final String address;
  final bool isProcessing;
  final BtcFeeRatePreset btcFeeRatePreset;
  final int btcCustomFeeRate;
  final double usdValue;

  const SendFormModel({
    this.amount = "",
    this.address = "",
    this.isProcessing = false,
    this.btcFeeRatePreset = BtcFeeRatePreset.economy,
    this.btcCustomFeeRate = 0,
    this.usdValue = 0.0,
  });

  SendFormModel copyWith({
    String? amount,
    String? address,
    bool? isProcessing,
    BtcFeeRatePreset? btcFeeRatePreset,
    int? btcCustomFeeRate,
    double? usdValue,
  }) {
    return SendFormModel(
      amount: amount ?? this.amount,
      address: address ?? this.address,
      isProcessing: isProcessing ?? this.isProcessing,
      btcFeeRatePreset: btcFeeRatePreset ?? this.btcFeeRatePreset,
      btcCustomFeeRate: btcCustomFeeRate ?? this.btcCustomFeeRate,
      usdValue: usdValue ?? this.usdValue,
    );
  }
}

class SendFormProvider extends StateNotifier<SendFormModel> {
  final Ref ref;

  static const _initial = SendFormModel(
    address: "",
    amount: "",
  );

  final GlobalKey<FormState> formKey = GlobalKey();

  late final TextEditingController amountController;
  late final TextEditingController addressController;
  late final TextEditingController btcCustomFeeRateController;

  SendFormProvider(this.ref, [SendFormModel model = _initial]) : super(model) {
    amountController = TextEditingController(text: model.amount);
    addressController = TextEditingController(text: model.address);
    btcCustomFeeRateController = TextEditingController(text: '');

    amountController.addListener(_updateAmountState);
    addressController.addListener(_updateState);
    btcCustomFeeRateController.addListener(_updateState);

    setBtcFeeRatePreset(state.btcFeeRatePreset);
  }

  String get amount => amountController.value.text;
  String get address => addressController.value.text;

  String? amountValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Amount required";
    }

    double parsed = 0;
    try {
      parsed = double.parse(value);
    } catch (e) {
      return "Not a valid amount";
    }

    if (parsed <= 0) {
      return "The amount has to be a positive value";
    }

    final isBtc = kIsWeb ? ref.read(webSelectedAccountProvider)?.type == WebCurrencyType.btc : ref.read(sessionProvider).btcSelected;

    if (isBtc) {
      if (kIsWeb) {
        final account = ref.read(webSessionProvider).btcKeypair;
        if (account == null) {
          return "No account selected";
        }

        final btcBalance = ref.read(webSessionProvider).btcBalanceInfo?.btcBalance ?? 0;

        if (btcBalance < parsed) {
          return "Not enough balance in BTC account";
        }

        if (parsed < BTC_MINIMUM_TX_AMOUNT) {
          return "The minimum transaction acmount is $BTC_MINIMUM_TX_AMOUNT BTC";
        }
        return null;
      } else {
        final account = ref.read(sessionProvider).currentBtcAccount;
        if (account == null) {
          return "No account selected";
        }

        final feeRateInt = getFeeRate();

        final btcFee = satashisToBtc(feeRateInt);
        if (account.balance < (parsed + btcFee)) {
          return "Not enough balance in BTC account";
        }

        if (parsed < BTC_MINIMUM_TX_AMOUNT) {
          return "The minimum transaction acmount is $BTC_MINIMUM_TX_AMOUNT BTC";
        }

        return null;
      }
    }

    if (kIsWeb) {
      final account = ref.read(webSelectedAccountProvider);

      if (account == null) {
        return "No account selected";
      }

      if (account.balance < parsed) {
        return "Not enough balance in account.";
      }
    } else {
      final currentWallet = ref.read(sessionProvider).currentWallet;
      if (currentWallet == null) {
        return "No account selected";
      }
      if (currentWallet.balance < parsed) {
        return "Not enough balance in account.";
      }
    }

    return null;
  }

  String? addressValidator(String? value) {
    final isBtc = kIsWeb ? ref.read(webSelectedAccountProvider)?.type == WebCurrencyType.btc : ref.read(sessionProvider).btcSelected;

    if (isBtc) {
      if (value == null || value.isEmpty) {
        return "BTC Address required";
      }
      return null;
    } else {
      if (value == null || value.isEmpty) {
        return "Address or VFX domain required";
      }

      return formValidatorRbxAddress(value, true);
    }
  }

  String? btcCustomFeeRateValidator(String? value) {
    if (value == null) {
      return "Fee Rate Required";
    }

    if ((int.tryParse(value) ?? 0) < 1) {
      return "Invalid Fee Rate. Must be atleast 1 satoshi.";
    }

    return null;
  }

  void _updateState() {
    state = state.copyWith(
      amount: amountController.value.text,
      address: addressController.value.text,
      btcCustomFeeRate: int.tryParse(btcCustomFeeRateController.text) ?? 0,
    );
  }

  void _updateAmountState() {
    final isBtc = kIsWeb ? ref.read(webSelectedAccountProvider)?.type == WebCurrencyType.btc : ref.read(sessionProvider).btcSelected;

    double usdValue = 0.0;

    final parsedAmount = double.tryParse(amountController.value.text);

    final usdPrice = isBtc ? ref.read(btcCurrentPriceDataDetailProvider) : ref.read(vfxCurrentPriceDataDetailProvider);

    if (parsedAmount != null && usdPrice != null) {
      usdValue = parsedAmount * usdPrice;
    }

    state = state.copyWith(
      amount: amountController.value.text,
      usdValue: usdValue,
    );
  }

  // void setWallet(Wallet wallet) {
  //   state = state.copyWith(wallet: wallet);
  // }

  void clear() {
    addressController.text = "";
    amountController.text = "";

    state = state.copyWith(
      amount: "",
      address: "",
      isProcessing: false,
    );
  }

  void setBtcFeeRatePreset(BtcFeeRatePreset preset) async {
    final recommendedFees = ref.read(sessionProvider).btcRecommendedFees ?? BtcRecommendedFees.fallback();

    int fee = 0;

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

    state = state.copyWith(btcFeeRatePreset: preset, btcCustomFeeRate: fee);
  }

  int getFeeRate() {
    int feeRateInt = 0;

    if (state.btcFeeRatePreset == BtcFeeRatePreset.custom) {
      feeRateInt = int.tryParse(btcCustomFeeRateController.text) ?? 0;
    } else {
      final recommendedFees = ref.read(sessionProvider).btcRecommendedFees ?? BtcRecommendedFees.fallback();

      switch (state.btcFeeRatePreset) {
        case BtcFeeRatePreset.custom:
          feeRateInt = 0;
          break;
        case BtcFeeRatePreset.minimum:
          feeRateInt = recommendedFees.minimumFee;
          break;
        case BtcFeeRatePreset.economy:
          feeRateInt = recommendedFees.economyFee;
          break;
        case BtcFeeRatePreset.hour:
          feeRateInt = recommendedFees.hourFee;
          break;
        case BtcFeeRatePreset.halfHour:
          feeRateInt = recommendedFees.halfHourFee;
          break;
        case BtcFeeRatePreset.fastest:
          feeRateInt = recommendedFees.fastestFee;
          break;
      }
    }
    return feeRateInt;
  }

  Future<void> submit() async {
    String senderAddress = "";
    Wallet? currentWallet;

    final isBtc = kIsWeb ? ref.read(webSelectedAccountProvider)?.type == WebCurrencyType.btc : ref.read(sessionProvider).btcSelected;

    if (isBtc) {
      if (kIsWeb) {
        final account = ref.read(webSessionProvider).btcKeypair;
        if (account == null) {
          Toast.error("No BTC Account");
          return;
        }

        final amountDouble = double.tryParse(amount);
        if (amountDouble == null) {
          Toast.error("Invalid amount");
          return;
        }

        final balance = ref.read(webSessionProvider).btcBalanceInfo?.btcBalance;
        if (balance == null || balance < amountDouble) {
          Toast.error("Not enough balance");
          return;
        }

        final senderWif = account.wif;
        senderAddress = account.address;

        final feeRate = await promptForFeeRate(rootNavigatorKey.currentContext!);

        if (feeRate == null) {
          return;
        }

        final confirmed = await ConfirmDialog.show(
          title: "Please Confirm",
          body: "Sending:\n$amount BTC\n\nTo:\n$address\n\nFrom:\n$senderAddress\n\nFeeRate:\n$feeRate SATS",
          confirmText: "Send",
          cancelText: "Cancel",
        );

        if (confirmed != true) {
          return;
        }

        final txHash = await BtcWebService().sendTransaction(senderWif, address, amountDouble, feeRate);

        if (txHash == null) {
          Toast.error();
          return;
        }

        Toast.message("$amount BTC has been sent to $address.");

        ref.invalidate(btcWebTransactionListProvider(senderAddress));

        Future.delayed(Duration(seconds: 2), () {
          ref.read(webSessionProvider.notifier).refreshBtcBalanceInfo();
        });

        InfoDialog.show(
            title: "Transaction Broadcasted",
            buttonColorOverride: Color(0xfff7931a),
            content: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    initialValue: txHash,
                    readOnly: true,
                    decoration: InputDecoration(
                      label: Text(
                        "Transaction Hash",
                        style: TextStyle(
                          color: Color(0xfff7931a),
                        ),
                      ),
                      suffix: IconButton(
                        icon: Icon(Icons.copy),
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: txHash));
                          Toast.message("Transaction Hash copied to clipboard");
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  AppButton(
                    label: "Open in BTC Explorer",
                    variant: AppColorVariant.Btc,
                    type: AppButtonType.Text,
                    onPressed: () {
                      if (Env.btcIsTestNet) {
                        launchUrlString("https://mempool.space/testnet4/tx/$txHash");
                      } else {
                        launchUrlString("https://mempool.space/tx/$txHash");
                      }
                    },
                  )
                ],
              ),
            ));

        clear();

        return;
      } else {
        int feeRateInt = getFeeRate();

        final account = ref.read(sessionProvider).currentBtcAccount;
        if (account == null) {
          Toast.error("No account selected");
          return;
        }

        final amountDouble = double.tryParse(amount);
        if (amountDouble == null) {
          Toast.error("Invalid amount");
          return;
        }

        if (amountDouble < BTC_MINIMUM_TX_AMOUNT) {
          Toast.error("The minimum transaction acmount is $BTC_MINIMUM_TX_AMOUNT BTC");
          return;
        }

        final calculatedFeeRate = await BtcService().getFee(account.address, address, amountDouble, feeRateInt);
        late double btcFee;

        if (calculatedFeeRate == null) {
          // Toast.error("Can't calculate fee.");
          return;
        }
        btcFee = calculatedFeeRate;

        if (account.balance < (amountDouble + btcFee)) {
          Toast.error("Not enough balance in BTC account");
          return;
        }

        final confirmed = await ConfirmDialog.show(
          title: "Please Confirm",
          body: "Sending:\n$amount BTC\n\nTo:\n$address\n\nFrom:\n${account.address}\n\nFee:\n${btcFee.toStringAsFixed(8)} BTC",
          confirmText: "Send",
          cancelText: "Cancel",
        );

        if (confirmed != true) {
          return;
        }

        final result = await BtcService().sendTransaction(
          fromAddress: account.address,
          toAddress: address,
          amount: amountDouble,
          feeRate: feeRateInt,
        );

        if (result.success) {
          final txHash = result.message;
          final message = "BTC TX broadcasted with hash of $txHash";

          ref.read(logProvider.notifier).append(
                LogEntry(
                  message: message,
                  textToCopy: txHash,
                  variant: AppColorVariant.Btc,
                ),
              );

          Toast.message("$amount BTC has been sent to $address.");
          clear();

          InfoDialog.show(
              title: "Transaction Broadcasted",
              buttonColorOverride: Color(0xfff7931a),
              content: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      initialValue: txHash,
                      readOnly: true,
                      decoration: InputDecoration(
                        label: Text(
                          "Transaction Hash",
                          style: TextStyle(
                            color: Color(0xfff7931a),
                          ),
                        ),
                        suffix: IconButton(
                          icon: Icon(Icons.copy),
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: txHash));
                            Toast.message("Transaction Hash copied to clipboard");
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    AppButton(
                      label: "Open in BTC Explorer",
                      variant: AppColorVariant.Btc,
                      type: AppButtonType.Text,
                      onPressed: () {
                        if (Env.btcIsTestNet) {
                          launchUrlString("https://mempool.space/testnet4/tx/$txHash");
                        } else {
                          launchUrlString("https://mempool.space/tx/$txHash");
                        }
                      },
                    )
                  ],
                ),
              ));
        } else {
          Toast.error(result.message);
        }

        return;
      }
    }

    if (!kIsWeb) {
      currentWallet = ref.read(sessionProvider).currentWallet;
      if (currentWallet == null) {
        Toast.error("No account selected");
        return;
      }

      if (currentWallet.isReserved && currentWallet.isNetworkProtected == false) {
        Toast.error("You must activate your Vault Account before proceeding.");
        return;
      }

      senderAddress = currentWallet.labelWithoutTruncation;

      if (!guardWalletIsSynced(ref)) return;
      if (!guardWalletIsNotResyncing(ref)) return;

      final addressIsValid = await BridgeService().validateSendToAddress(address.trim().replaceAll("\n", ""));

      if (!addressIsValid) {
        Toast.error("Invalid Address");
        return;
      }

      final amountDouble = double.tryParse(amount);
      if (amountDouble == null) {
        Toast.error("Invalid amount");
        return;
      }

      if (amountDouble > currentWallet.balance) {
        Toast.error("Insufficent balance to send");
        return;
      }

      if (currentWallet.isValidating) {
        if (amountDouble > currentWallet.balance - ASSURED_AMOUNT_TO_VALIDATE) {
          Toast.error("Insufficent balance since you are validating.");
          return;
        }
      }
    } else {
      final selectedAccount = ref.read(webSelectedAccountProvider);

      if (selectedAccount == null) {
        Toast.error("No account selected");
        return;
      }

      final amountDouble = double.tryParse(amount);
      if (amountDouble == null) {
        Toast.error("Invalid amount");
        return;
      }

      if (selectedAccount.balance < amountDouble) {
        Toast.error("Insufficent balance to send");
        return;
      }

      senderAddress = selectedAccount.address;
    }

    final confirmed = await ConfirmDialog.show(
      title: "Please Confirm",
      body: "Sending:\n$amount VFX\n\nTo:\n$address\n\nFrom:\n$senderAddress",
      confirmText: "Send",
      cancelText: "Cancel",
    );

    if (confirmed != true) {
      return;
    }

    if (!kIsWeb && currentWallet != null) {
      if (currentWallet.isReserved) {
        final password = await PromptModal.show(
          title: "Vault Account Password",
          validator: (_) => null,
          labelText: "Password",
          lines: 1,
          obscureText: true,
          revealObscure: true,
        );
        if (password == null) {
          return;
        }

        final hoursString = await PromptModal.show(
          title: "Timelock Duration",
          validator: (_) => null,
          labelText: "Hours (24 Minimum)",
          initialValue: "24",
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        );

        int hours = (hoursString != null ? int.tryParse(hoursString) : 24) ?? 24;
        if (hours < 24) {
          hours = 24;
        }

        state = state.copyWith(isProcessing: true);

        final message = await ReserveAccountService().sendTx(
          fromAddress: currentWallet.address,
          toAddress: address.trim().replaceAll("\n", ""),
          amount: double.parse(amount),
          password: password,
          unlockDelayHours: hours - 24,
        );

        if (message != null) {
          final hash = message.replaceAll("Success! TX ID: ", "");
          Toast.message("$amount VFX has been sent to $address. See dashboard for TX ID.");
          ref.read(logProvider.notifier).append(
                LogEntry(
                  message: message,
                  textToCopy: message.replaceAll("Success! TX ID: ", ""),
                  variant: AppColorVariant.Success,
                ),
              );

          clear();
        } else {
          state = state.copyWith(isProcessing: false);
        }

        return;
      }
    }

    state = state.copyWith(isProcessing: true);

    if (kIsWeb) {
      int? unlockHours;
      if (senderAddress.startsWith("xRBX")) {
        final hoursString = await PromptModal.show(
          title: "Timelock Duration",
          validator: (_) => null,
          labelText: "Hours (24 Minimum)",
          initialValue: "24",
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        );

        unlockHours = (hoursString != null ? int.tryParse(hoursString) : 24) ?? 24;
        if (unlockHours < 24) {
          unlockHours = 24;
        }
      }

      final amountDouble = double.parse(amount);
      final txData = await RawTransaction.generate(
        // keypair: ref.read(webSessionProvider).usingRa ? ref.read(webSessionProvider).raKeypair!.asKeypair : ref.read(webSessionProvider).keypair!,
        keypair: senderAddress.startsWith("xRBX") ? ref.read(webSessionProvider).raKeypair!.asKeypair : ref.read(webSessionProvider).keypair!,
        amount: amountDouble,
        toAddress: address,
        unlockHours: unlockHours,
        txType: TxType.rbxTransfer,
      );

      state = state.copyWith(isProcessing: false);

      if (txData != null) {
        final txFee = txData['Fee'];

        print("-----------");
        print(txData);
        print("-----------");

        final confirmed = await ConfirmDialog.show(
          title: "Valid Transaction",
          body:
              "This transaction is valid and is ready to send.\nAre you sure you want to proceed?\n\nTo: $address\n\nAmount: $amountDouble VFX${txFee != null ? '\nTX Fee: $txFee VFX\nTotal: ${amountDouble + txFee} VFX' : ''}",
          confirmText: "Send",
          cancelText: "Cancel",
        );

        if (confirmed == true) {
          ref.read(globalLoadingProvider.notifier).start();
          final tx = await RawService().sendTransaction(transactionData: txData, execute: true, ref: ref);

          ref.read(globalLoadingProvider.notifier).complete();

          if (tx != null) {
            if (tx['Result'] == "Success") {
              Toast.message("$amount VFX sent to $address");
              clear();
              return;
            }
          }

          Toast.error();
        }
      }
    } else {
      try {
        final message = await BridgeService().sendFunds(
          amount: double.parse(amount),
          to: address.trim().replaceAll("\n", ""),
          from: ref.read(sessionProvider).currentWallet!.address,
        );
        state = state.copyWith(isProcessing: false);

        if (message != null) {
          Toast.message("$amount VFX has been sent to $address. See dashboard for TX ID.");
          ref.read(logProvider.notifier).append(
                LogEntry(message: message, textToCopy: message.replaceAll("Success! TxId: ", ""), variant: AppColorVariant.Success),
              );
          clear();
        }
      } catch (e) {
        print(e);
        Toast.error();
        state = state.copyWith(isProcessing: false);
      }
    }
  }
}

final sendFormProvider = StateNotifierProvider<SendFormProvider, SendFormModel>((ref) {
  return SendFormProvider(ref);
});
