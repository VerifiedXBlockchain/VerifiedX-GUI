import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rbx_wallet/features/btc/services/btc_fee_rate_service.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:crypto/crypto.dart' show sha256;

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
  return (satashis * BTC_TX_EXPECTED_BYTES * BTC_SATOSHI_MULTIPLIER)
      .toStringAsFixed(9);
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
            content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        subtitle: p == BtcFeeRatePreset.custom
                            ? null
                            : Text("$fee SATS | ${satashiToBtcLabel(fee)} BTC"),
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
                            customFeeLabel =
                                "$valueInt SATS /byte | ${(satashiToBtcLabel(valueInt))} BTC /byte";
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
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                      ],
                      decoration:
                          InputDecoration(hintText: "Fee rate in satoshis"),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: false),
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

/// Detect (and validate) a Bitcoin address.
/// - Supports Base58Check (P2PKH/P2SH) and Bech32/Bech32m (SegWit v0/v1+).
/// - Set `testnet: true` to only allow testnet formats (`tb1`, testnet Base58).
/// - Returns true only if the checksum is valid and the prefix matches the network.
///
/// Example:
///   isBitcoinAddress("bc1qw4...");                  // mainnet
///   isBitcoinAddress("tb1q....", testnet: true);    // testnet
bool isBitcoinAddress(String input, {bool testnet = false}) {
  final s = input.trim();

  // Quick structural filters to avoid heavy work
  if (s.isEmpty || s.length < 14 || s.length > 90) return false;

  // Try Bech32/Bech32m first (SegWit)
  if (_looksLikeBech32(s)) {
    try {
      final dec = _bech32Decode(s);
      final hrp = dec.hrp;
      final data = dec.data;

      // network HRP check
      if (testnet) {
        if (hrp != 'tb') return false; // add 'bcrt' if you want regtest too
      } else {
        if (hrp != 'bc') return false;
      }

      // Data must contain at least 1 (version) + 6 (checksum)
      if (data.length < 7) return false;

      // Strip the 6-char checksum from the end before parsing payload
      final payload = data.sublist(0, data.length - 6);

      // Witness version (first 5-bit value)
      final v = payload.first;
      if (v < 0 || v > 16) return false;

      // Check the correct checksum type per BIP-350
      final checksumOk = _bech32VerifyChecksum(s, expectBech32m: v >= 1);
      if (!checksumOk) return false;

      // Convert the witness program (payload without version) from 5-bit to 8-bit
      final program = _bech32ConvertBits(payload.sublist(1), 5, 8, false);
      if (program == null) return false;

      // Length checks (BIP-173/350)
      if (program.length < 2 || program.length > 40) return false;
      if (v == 0 && !(program.length == 20 || program.length == 32))
        return false;

      return true;
    } catch (_) {
      return false;
    }
  }

  // Try Base58Check (legacy)
  if (_looksLikeBase58(s)) {
    try {
      final payload = _base58Decode(s);
      if (payload.length < 5) return false; // version(1) + data + checksum(4)

      // Split
      final body = payload.sublist(0, payload.length - 4);
      final checksum = payload.sublist(payload.length - 4);
      final expect = _doubleSha256(body).sublist(0, 4);
      for (var i = 0; i < 4; i++) {
        if (checksum[i] != expect[i]) return false;
      }

      // Version byte network/type check
      final version = body[0];
      if (testnet) {
        // testnet: P2PKH = 0x6F (m/n...), P2SH = 0xC4 (2...)
        if (version != 0x6F && version != 0xC4) return false;
      } else {
        // mainnet: P2PKH = 0x00 (1...), P2SH = 0x05 (3...)
        if (version != 0x00 && version != 0x05) return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  return false;
}

/* ----------------------------- Bech32 helpers ----------------------------- */

bool _looksLikeBech32(String s) {
  final lower = s.toLowerCase();
  return lower.startsWith('bc1') ||
      lower.startsWith('tb1'); // (add 'bcrt1' if desired)
}

class _Bech32Decoded {
  final String hrp;
  final List<int> data;
  _Bech32Decoded(this.hrp, this.data);
}

// Bech32 charset
const _b32 = 'qpzry9x8gf2tvdw0s3jn54khce6mua7l';
final _b32Rev = {for (var i = 0; i < _b32.length; i++) _b32[i]: i};

_Bech32Decoded _bech32Decode(String bech) {
  // BIP-173 casing rule: all lowercase or all uppercase
  final hasLower = bech.toLowerCase() == bech;
  final hasUpper = bech.toUpperCase() == bech;
  if (!(hasLower || hasUpper)) throw FormatException('Mixed case');

  final s = bech.toLowerCase();
  final pos = s.lastIndexOf('1');
  if (pos < 1 || pos + 7 > s.length) throw FormatException('Invalid separator');

  final hrp = s.substring(0, pos);
  final dataPart = s.substring(pos + 1);
  final data = <int>[];
  for (final ch in dataPart.split('')) {
    final v = _b32Rev[ch];
    if (v == null) throw FormatException('Non bech32 char');
    data.add(v);
  }
  return _Bech32Decoded(hrp, data);
}

bool _bech32VerifyChecksum(String bech, {required bool expectBech32m}) {
  final dec = _bech32Decode(bech);
  final hrp = dec.hrp;
  final data = dec.data;
  final constVal = _bech32Polymod(_bech32HrpExpand(hrp) + data) ^ 1;
  // Bech32: constant = 1; Bech32m: constant = 0x2bc830a3
  // We already xor'ed with 1 above; so compare raw polymod:
  final polymod = _bech32Polymod(_bech32HrpExpand(hrp) + data);
  if (expectBech32m) {
    return polymod == 0x2bc830a3;
  } else {
    return polymod == 1;
  }
}

List<int> _bech32HrpExpand(String hrp) {
  final ret = <int>[];
  for (final c in hrp.codeUnits) {
    ret.add(c >> 5);
  }
  ret.add(0);
  for (final c in hrp.codeUnits) {
    ret.add(c & 31);
  }
  return ret;
}

int _bech32Polymod(List<int> values) {
  var chk = 1;
  const gen = [0x3b6a57b2, 0x26508e6d, 0x1ea119fa, 0x3d4233dd, 0x2a1462b3];
  for (final v in values) {
    final b = chk >> 25;
    chk = (chk & 0x1ffffff) << 5 ^ v;
    for (var i = 0; i < 5; i++) {
      if (((b >> i) & 1) != 0) {
        chk ^= gen[i];
      }
    }
  }
  return chk;
}

/// Convert bit groups (used to turn 5-bit words into bytes)
List<int>? _bech32ConvertBits(List<int> data, int from, int to, bool pad) {
  var acc = 0;
  var bits = 0;
  final ret = <int>[];
  final maxv = (1 << to) - 1;
  for (final value in data) {
    if (value < 0 || (value >> from) != 0) return null;
    acc = (acc << from) | value;
    bits += from;
    while (bits >= to) {
      bits -= to;
      ret.add((acc >> bits) & maxv);
    }
  }
  if (pad) {
    if (bits > 0) ret.add((acc << (to - bits)) & maxv);
  } else if (bits >= from || ((acc << (to - bits)) & maxv) != 0) {
    return null;
  }
  return ret;
}

/* ---------------------------- Base58Check helpers ---------------------------- */

bool _looksLikeBase58(String s) {
  // Base58 chars with typical BTC first char hints: 1,3 (mainnet) or m/n/2 (testnet p2sh)
  final base58 = RegExp(
      r'^[123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]+$');
  return base58.hasMatch(s);
}

const _b58 = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
final _b58Map = {for (var i = 0; i < _b58.length; i++) _b58[i]: i};

List<int> _base58Decode(String s) {
  var num = BigInt.zero;
  for (final ch in s.split('')) {
    final val = _b58Map[ch];
    if (val == null) throw FormatException('Non-base58 char');
    num = num * BigInt.from(58) + BigInt.from(val);
  }

  // Count leading zeros
  var zeros = 0;
  for (final ch in s.split('')) {
    if (ch == '1') {
      zeros++;
    } else {
      break;
    }
  }

  // Convert BigInt to bytes
  final bytes = <int>[];
  while (num > BigInt.zero) {
    final mod = num & BigInt.from(0xff);
    bytes.insert(0, mod.toInt());
    num = num >> 8;
  }

  // Add leading zero bytes
  return List<int>.filled(zeros, 0) + bytes;
}

/* ------------------------------- SHA-256 (tiny) ------------------------------ */

List<int> _doubleSha256(List<int> data) {
  final first = sha256.convert(data).bytes;
  return sha256.convert(first).bytes;
}
