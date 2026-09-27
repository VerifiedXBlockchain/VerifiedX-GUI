/// Bitcoin address validation for mainnet and testnet: Base58Check
/// (P2PKH, P2SH) and SegWit (BIP173 bech32 for v0, BIP350 bech32m for v1+).
/// Pure Dart so it can be unit tested without Flutter.
library btc_address_validator;

import 'package:crypto/crypto.dart';

/// Script type an address pays to.
enum BtcAddressType {
  /// Legacy pay-to-pubkey-hash: `1…` mainnet, `m…`/`n…` testnet.
  p2pkh,

  /// Pay-to-script-hash (including nested SegWit): `3…` mainnet, `2…` testnet.
  p2sh,

  /// Native SegWit v0 key hash (20-byte program): `bc1q…` / `tb1q…`.
  p2wpkh,

  /// Native SegWit v0 script hash (32-byte program): `bc1q…` / `tb1q…`.
  p2wsh,

  /// Taproot, SegWit v1 with a 32-byte program: `bc1p…` / `tb1p…`.
  p2tr,

  /// A valid SegWit v1–v16 address with no defined meaning yet (BIP350
  /// allows sending to it).
  witnessUnknown,
}

/// Why an address was refused.
enum BtcAddressIssue {
  /// Not a valid Bitcoin address on either network (bad format, checksum,
  /// version byte or witness program).
  invalid,

  /// A valid Bitcoin address for the other network.
  wrongNetwork,
}

/// The type of [address] when it is a valid Bitcoin address on the network
/// chosen by [testnet], otherwise null. Surrounding whitespace is ignored.
BtcAddressType? btcAddressType(String address, {required bool testnet}) {
  final s = address.trim();
  if (s.isEmpty) {
    return null;
  }
  return _decodeSegwit(s, testnet: testnet) ?? _decodeBase58(s, testnet: testnet);
}

/// True when [address] is a valid Bitcoin address on the network chosen by
/// [testnet].
bool isValidBtcAddress(String address, {required bool testnet}) {
  return btcAddressType(address, testnet: testnet) != null;
}

/// Null when [address] is valid on the network chosen by [testnet];
/// otherwise whether it is valid only on the other network or not at all.
BtcAddressIssue? btcAddressIssue(String address, {required bool testnet}) {
  if (isValidBtcAddress(address, testnet: testnet)) {
    return null;
  }
  if (isValidBtcAddress(address, testnet: !testnet)) {
    return BtcAddressIssue.wrongNetwork;
  }
  return BtcAddressIssue.invalid;
}

/* ------------------------------ Base58Check ------------------------------ */

const _base58Alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

const _mainnetP2pkhVersion = 0x00;
const _mainnetP2shVersion = 0x05;
const _testnetP2pkhVersion = 0x6f;
const _testnetP2shVersion = 0xc4;

BtcAddressType? _decodeBase58(String s, {required bool testnet}) {
  final bytes = _base58Decode(s);
  // 1 version byte + 20-byte hash + 4-byte checksum.
  if (bytes == null || bytes.length != 25) {
    return null;
  }
  final body = bytes.sublist(0, 21);
  final checksum = bytes.sublist(21);
  final expected = sha256.convert(sha256.convert(body).bytes).bytes;
  for (var i = 0; i < 4; i++) {
    if (checksum[i] != expected[i]) {
      return null;
    }
  }

  final version = body[0];
  if (version == (testnet ? _testnetP2pkhVersion : _mainnetP2pkhVersion)) {
    return BtcAddressType.p2pkh;
  }
  if (version == (testnet ? _testnetP2shVersion : _mainnetP2shVersion)) {
    return BtcAddressType.p2sh;
  }
  return null;
}

List<int>? _base58Decode(String s) {
  var value = BigInt.zero;
  final base = BigInt.from(58);
  for (final char in s.split('')) {
    final digit = _base58Alphabet.indexOf(char);
    if (digit < 0) {
      return null;
    }
    value = value * base + BigInt.from(digit);
  }

  final bytes = <int>[];
  while (value > BigInt.zero) {
    bytes.insert(0, (value & BigInt.from(0xff)).toInt());
    value = value >> 8;
  }

  // Each leading '1' stands for a leading zero byte.
  var leadingZeros = 0;
  while (leadingZeros < s.length && s[leadingZeros] == '1') {
    leadingZeros++;
  }
  return List<int>.filled(leadingZeros, 0) + bytes;
}

/* ---------------------------- Bech32 / Bech32m ---------------------------- */

const _bech32Charset = 'qpzry9x8gf2tvdw0s3jn54khce6mua7l';
const _bech32Const = 1;
const _bech32mConst = 0x2bc830a3;

BtcAddressType? _decodeSegwit(String s, {required bool testnet}) {
  // BIP173: at most 90 characters, and never mixed case.
  if (s.length > 90) {
    return null;
  }
  if (s != s.toLowerCase() && s != s.toUpperCase()) {
    return null;
  }
  final lower = s.toLowerCase();
  final separator = lower.lastIndexOf('1');
  // HRP of at least one character, and a data part holding at least the
  // 6-character checksum.
  if (separator < 1 || separator + 7 > lower.length) {
    return null;
  }

  final hrp = lower.substring(0, separator);
  if (hrp != (testnet ? 'tb' : 'bc')) {
    return null;
  }

  final data = <int>[];
  for (final char in lower.substring(separator + 1).split('')) {
    final value = _bech32Charset.indexOf(char);
    if (value < 0) {
      return null;
    }
    data.add(value);
  }

  final checksumConst = _bech32Polymod([..._hrpExpand(hrp), ...data]);
  final values = data.sublist(0, data.length - 6);
  if (values.isEmpty) {
    return null;
  }

  // BIP350: witness v0 must use the bech32 checksum, v1–v16 bech32m.
  final witnessVersion = values.first;
  if (witnessVersion > 16) {
    return null;
  }
  final expectedConst = witnessVersion == 0 ? _bech32Const : _bech32mConst;
  if (checksumConst != expectedConst) {
    return null;
  }

  final program = _convertBits(values.sublist(1), 5, 8);
  if (program == null || program.length < 2 || program.length > 40) {
    return null;
  }

  if (witnessVersion == 0) {
    if (program.length == 20) return BtcAddressType.p2wpkh;
    if (program.length == 32) return BtcAddressType.p2wsh;
    return null;
  }
  if (witnessVersion == 1 && program.length == 32) {
    return BtcAddressType.p2tr;
  }
  return BtcAddressType.witnessUnknown;
}

List<int> _hrpExpand(String hrp) {
  final units = hrp.codeUnits;
  return [
    ...units.map((c) => c >> 5),
    0,
    ...units.map((c) => c & 31),
  ];
}

int _bech32Polymod(List<int> values) {
  const generator = [0x3b6a57b2, 0x26508e6d, 0x1ea119fa, 0x3d4233dd, 0x2a1462b3];
  var checksum = 1;
  for (final value in values) {
    final top = checksum >> 25;
    checksum = ((checksum & 0x1ffffff) << 5) ^ value;
    for (var i = 0; i < 5; i++) {
      if ((top >> i) & 1 == 1) {
        checksum ^= generator[i];
      }
    }
  }
  return checksum;
}

/// Regroups [data] from [fromBits]-bit to [toBits]-bit values without
/// padding, as SegWit decoding requires (BIP173). Null when leftover bits are
/// more than [fromBits]-1 or non-zero.
List<int>? _convertBits(List<int> data, int fromBits, int toBits) {
  var accumulator = 0;
  var bits = 0;
  final result = <int>[];
  final maxValue = (1 << toBits) - 1;
  for (final value in data) {
    accumulator = (accumulator << fromBits) | value;
    bits += fromBits;
    while (bits >= toBits) {
      bits -= toBits;
      result.add((accumulator >> bits) & maxValue);
    }
    accumulator &= (1 << bits) - 1;
  }
  if (bits >= fromBits || (accumulator << (toBits - bits)) & maxValue != 0) {
    return null;
  }
  return result;
}
