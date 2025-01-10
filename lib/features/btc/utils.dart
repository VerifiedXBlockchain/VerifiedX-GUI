import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rbx_wallet/features/btc/services/btc_fee_rate_service.dart';

import '../../app.dart';
import '../../core/app_constants.dart';
import 'models/btc_fee_rate_preset.dart';

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
  return (satashis * BTC_TX_EXPECTED_BYTES * BTC_SATOSHI_MULTIPLIER).toStringAsFixed(9);
}

Future<int?> promptForFeeRate(BuildContext context) async {
  final recommendedFees = await BtcFeeRateService().recommended();

  final int? feeRate = await showDialog(
    context: rootNavigatorKey.currentContext!,
    builder: (context) {
      BtcFeeRatePreset preset = BtcFeeRatePreset.economy;
      int fee = 0;
      bool isCustom = false;
      int customFee = 0;
      String customFeeLabel = "";

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Fee Rate"),
            content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              ...BtcFeeRatePreset.values.map((p) {
                switch (p) {
                  case BtcFeeRatePreset.custom:
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

                return ConstrainedBox(
                  key: Key("${p}_$fee"),
                  constraints: BoxConstraints(minWidth: 300),
                  child: CheckboxListTile(
                    value: p == preset,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (v) {
                      if (v == true) {
                        if (p == BtcFeeRatePreset.custom) {
                          setState(() {
                            preset = p;
                            isCustom = true;
                          });
                        } else {
                          print('ho');
                          setState(() {
                            preset = p;
                            isCustom = false;
                          });
                        }
                      }
                    },
                    title: Text(p.label),
                    subtitle: p == BtcFeeRatePreset.custom ? null : Text("$fee SATS | ${satashiToBtcLabel(fee)} BTC"),
                  ),
                );
              }).toList(),
              if (isCustom) ...[
                TextFormField(
                  autofocus: true,
                  // controller: formProvider.btcCustomFeeRateController,
                  onChanged: (v) {
                    final valueInt = int.tryParse(v);
                    print(v);
                    if (valueInt != null) {
                      setState(() {
                        fee = valueInt;
                        customFeeLabel = "$valueInt SATS /byte | ${(satashiToBtcLabel(valueInt))} BTC /byte";
                        customFee = fee;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null) {
                      return "Fee Rate Required";
                    }

                    if ((int.tryParse(value) ?? 0) < 1) {
                      return "Invalid Fee Rate. Must be atleast 1 satoshi.";
                    }

                    return null;
                  },
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9]"))],
                  decoration: InputDecoration(hintText: "Fee rate in satoshis"),
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
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
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (isCustom) {
                    Navigator.of(context).pop(customFee);
                  } else {
                    Navigator.of(context).pop(fee);
                  }
                },
                child: Text(
                  "Continue",
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
