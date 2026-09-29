import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rbx_wallet/features/btc/services/btc_fee_rate_service.dart';

import '../../app.dart';
import '../../core/app_constants.dart';
import '../../core/env.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../l10n/l10n_helper.dart';
import 'btc_address_validator.dart';
import 'models/btc_fee_rate_preset.dart';
import 'models/btc_recommended_fees.dart';

double satashisToBtc(int satashis) {
  return satashis * BTC_SATOSHI_MULTIPLIER;
}

String satashiToBtcLabel(int satashis) {
  return satashisToBtc(satashis).toStringAsFixed(9);
}

int satashiTxFeeEstimate(int satashis) {
  return satashis * BTC_TX_EXPECTED_BYTES;
}

String btcTxFeeEstimateLabel(int satashis) {
  return (satashis * BTC_TX_EXPECTED_BYTES * BTC_SATOSHI_MULTIPLIER)
      .toStringAsFixed(9);
}

/// Fee rate in sats/vB for a preset, read from the fee table at the moment it
/// is needed. The picker used to keep one `fee` variable that every row wrote
/// to while the list was built, so Continue on the default (Economy) returned
/// whatever the last row had written: the Fastest rate.
int feeRateForPreset(BtcFeeRatePreset preset, BtcRecommendedFees fees) {
  switch (preset) {
    case BtcFeeRatePreset.minimum:
      return fees.minimumFee;
    case BtcFeeRatePreset.economy:
      return fees.economyFee;
    case BtcFeeRatePreset.hour:
      return fees.hourFee;
    case BtcFeeRatePreset.halfHour:
      return fees.halfHourFee;
    case BtcFeeRatePreset.fastest:
      return fees.fastestFee;
    case BtcFeeRatePreset.custom:
      return 0;
  }
}

/// Fetches the recommended fees and shows the picker on the root navigator.
/// [context] is accepted for callers' convenience only: the dialog and its
/// strings resolve from the root navigator, which is always mounted. Callers
/// that had already popped their own route (the vBTC Fund sheet) used to hand
/// in a dead context, and the string lookup on it killed the flow silently.
Future<int?> promptForFeeRate(BuildContext context) async {
  final recommendedFees = await BtcFeeRateService().recommended();
  return showFeeRatePicker(rootNavigatorKey.currentContext!, recommendedFees);
}

/// The fee-rate dialog for a known fee table. Returns the chosen sats/vB, or
/// null when cancelled. [dialogContext] must be mounted and under a
/// MaterialApp with the app's localizations.
Future<int?> showFeeRatePicker(BuildContext dialogContext, BtcRecommendedFees recommendedFees) async {
  final l10n = AppLocalizations.of(dialogContext);

  final int? feeRate = await showDialog(
    context: dialogContext,
    builder: (context) {
      BtcFeeRatePreset preset = BtcFeeRatePreset.economy;
      bool isCustom = false;
      int customFee = 0;
      String customFeeLabel = "";
      final customFeeFormKey = GlobalKey<FormState>();

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(l10n.btcRbfFeeRateTitle),
            // Scrollable so six preset rows plus the custom field fit a short
            // window instead of overflowing the dialog.
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...BtcFeeRatePreset.values.map((p) {
                    final rowFee = feeRateForPreset(p, recommendedFees);

                    return ConstrainedBox(
                      key: Key("${p}_$rowFee"),
                      constraints: BoxConstraints(minWidth: 300),
                      child: CheckboxListTile(
                        value: p == preset,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (v) {
                          if (v == true) {
                            setState(() {
                              preset = p;
                              isCustom = p == BtcFeeRatePreset.custom;
                            });
                          }
                        },
                        title: Text(p.labelWith(l10n)),
                        subtitle: p == BtcFeeRatePreset.custom
                            ? null
                            : Text("$rowFee SATS | ${satashiToBtcLabel(rowFee)} BTC"),
                      ),
                    );
                  }).toList(),
                  if (isCustom) ...[
                    Form(
                      key: customFeeFormKey,
                      child: TextFormField(
                        key: const Key('btcFeeRate:custom'),
                        autofocus: true,
                        onChanged: (v) {
                          final valueInt = int.tryParse(v);
                          setState(() {
                            customFee = valueInt ?? 0;
                            customFeeLabel = valueInt == null
                                ? ""
                                : "$valueInt SATS /byte | ${(satashiToBtcLabel(valueInt))} BTC /byte";
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.tkbFeeRateRequired;
                          }

                          if ((int.tryParse(value) ?? 0) < 1) {
                            return l10n.tkbInvalidFeeRate;
                          }

                          return null;
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                        ],
                        decoration:
                            InputDecoration(hintText: l10n.tkbFeeRateHint),
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: false),
                      ),
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      customFeeLabel,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  )
                ]),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
                child: Text(
                  l10n.actionCancel,
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (isCustom) {
                    // Run the field's validator so an empty or 0 sat/vB rate
                    // keeps the dialog open instead of being broadcast.
                    if (customFeeFormKey.currentState?.validate() != true) {
                      return;
                    }
                    Navigator.of(context).pop(customFee);
                  } else {
                    Navigator.of(context).pop(feeRateForPreset(preset, recommendedFees));
                  }
                },
                child: Text(
                  l10n.actionContinue,
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          );
        },
      );
    },
  );

  return feeRate;
}

/// True when [input] is a valid Bitcoin address (P2PKH, P2SH, SegWit v0 or
/// Taproot/v1+) on mainnet, or on testnet when [testnet] is true. Checks the
/// Base58Check checksum and version byte, or the bech32/bech32m checksum,
/// HRP and witness program (see btc_address_validator.dart).
bool isBitcoinAddress(String input, {bool testnet = false}) {
  return isValidBtcAddress(input, testnet: testnet);
}

/// Form validator for a Bitcoin destination address on whichever network the
/// app is pointed at.
///
/// Worth validating at entry rather than trusting the backend: a vBTC V2
/// withdrawal request is committed on chain before any Bitcoin moves, and a
/// typo'd destination can only be undone by a 75% validator governance vote.
String? formValidatorBtcAddress(String? value) {
  if (value == null || value.trim().isEmpty) {
    return globalL10n.svcBtcAddressRequired;
  }

  final issue = btcAddressIssue(value, testnet: Env.btcIsTestNet);
  if (issue == null) {
    return null;
  }
  if (issue == BtcAddressIssue.wrongNetwork) {
    return Env.btcIsTestNet ? globalL10n.sendBtcAddressTestnetRequired : globalL10n.sendBtcAddressMainnetRequired;
  }
  return globalL10n.sendBtcAddressInvalid;
}

/// Validates the total for a multi-contract vBTC transfer. The CLI allocates
/// the amount across contracts itself, so the client only checks that the
/// value is a positive number with at most 8 decimals that does not exceed
/// [available], the wallet's combined spendable vBTC across its V2 tokens.
String? formValidatorVbtcMultiAmount(String? value, double available) {
  if (value == null || value.trim().isEmpty) {
    return globalL10n.svcAmountRequired;
  }

  final trimmed = value.trim();
  final amount = double.tryParse(trimmed);
  if (amount == null || amount <= 0) {
    return globalL10n.btcInvalidAmountToast;
  }

  if (vbtcAmountHasTooManyDecimals(trimmed)) {
    return globalL10n.btcBulkMaxDecimals;
  }

  if (amount > available) {
    return globalL10n.r3fMaxAmountIs(available.toString());
  }

  return null;
}

/// Returns the node's reason when it refused a Bitcoin replace-by-fee because
/// the replacement's total fee is more than 10% of the amount (VX-18),
/// without the node's "Pass allowHighFee=true" instruction. Returns null for
/// any other reply.
String? rbfHighFeeReason(String? message) {
  if (message == null) {
    return null;
  }
  final instruction = message.indexOf('Pass allowHighFee=true');
  if (instruction < 0) {
    return null;
  }
  return message.substring(0, instruction).trim();
}

/// True when a typed vBTC [amount] has more than the 8 decimal places the
/// node accepts for vBTC transfers and withdrawals (VX-01).
bool vbtcAmountHasTooManyDecimals(String amount) {
  final parts = amount.trim().split('.');
  return parts.length == 2 && parts[1].length > 8;
}

/// True when [senderAddress], the wallet sending or withdrawing vBTC, is a
/// Vault (reserve) account. Pass the sender, never the contract owner
/// (`token.rbxAddress`).
bool vbtcSenderIsVault(String? senderAddress) {
  return senderAddress?.startsWith("xRBX") ?? false;
}

/// The VFX address a vBTC transfer is sent from.
///
/// V2 holders spend their own balance, so the sender is the wallet pressing
/// the button ([currentWalletAddress]). [ownerAddress] (`token.rbxAddress`) is
/// the contract's OwnerAddress for V2 and must not be used: a non-owner holder
/// would get 'Account not found', or move the owner's vBTC on a node that also
/// holds the owner's key. V1 tokens are held by the NFT owner, so the owner is
/// the sender. Returns null when V2 has no current wallet to send from.
String? vbtcTransferSenderAddress({
  required int version,
  required String ownerAddress,
  required String? currentWalletAddress,
}) {
  if (version >= 2) {
    return currentWalletAddress;
  }
  return ownerAddress;
}
