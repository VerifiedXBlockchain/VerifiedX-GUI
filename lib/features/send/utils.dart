import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/features/send/providers/send_form_provider.dart';

import '../../core/dialogs.dart';
import '../../core/env.dart';
import '../../utils/validation.dart';
import '../btc/utils.dart';
import '../web/providers/web_currency_segmented_button_provider.dart';

Future<void> handleQrScan(
    BuildContext context, WidgetRef ref, String? value) async {
  if (value == null) {
    return;
  }

  String? toAddress;
  String? amount;
  WebCurrencyType? currency;

  final parsedCryptoLink = parseCryptoLink(value);
  final parsedVfxLink = parseVerifiedXSendLink(value);

  if (parsedVfxLink != null) {
    if (parsedVfxLink.currency == "btc") {
      currency = WebCurrencyType.btc;
      toAddress = parsedVfxLink.address;
      amount = parsedVfxLink.amountRaw;
    } else if (parsedVfxLink.currency == 'vfx') {
      currency = WebCurrencyType.vfx;
      toAddress = parsedVfxLink.address;
      amount = parsedVfxLink.amountRaw;
    }
  } else if (parsedCryptoLink != null) {
    if (parsedCryptoLink.currency == "bitcoin") {
      currency = WebCurrencyType.btc;
      toAddress = parsedCryptoLink.address;
      amount = parsedCryptoLink.amount;
    } else if (parsedCryptoLink.currency == "vfx") {
      currency = WebCurrencyType.vfx;
      toAddress = parsedCryptoLink.address;
      amount = parsedCryptoLink.amount;
    }
  } else if (isBitcoinAddress(value, testnet: Env.isTestNet)) {
    toAddress = value;
    currency = WebCurrencyType.btc;
  } else if (isValidRbxAddress(value)) {
    toAddress = value;
    currency = WebCurrencyType.vfx;
  }

  // Set Stuff
  if (currency != null && toAddress != null) {
    ref.read(webCurrencySegementedButtonProvider.notifier).set(currency);
    ref.read(sendFormProvider.notifier).addressController.text = toAddress;

    if (amount != null) {
      ref.read(sendFormProvider.notifier).amountController.text = amount;
    }
  }
}

/// Result of parsing a crypto payment link.
///
///
class ParsedPayment {
  final String currency; // e.g., "bitcoin", "ltc", "eth"
  final String address; // address string as-is
  final String? amount; // decimal string (ETH/BTC/etc.) or null if absent

  ParsedPayment({required this.currency, required this.address, this.amount});

  @override
  String toString() =>
      'ParsedPayment(currency: $currency, address: $address, amount: $amount)';
}

/// Try to parse a crypto payment link and extract currency, address, and amount.
/// Returns null if it doesn't look like a supported payment link.
///
/// Supported forms:
/// - BIP21:     bitcoin:<addr>?amount=1.23
/// - Generic:   ltc:<addr>?amount=12.3
/// - EIP-681:   ethereum:<addr>?value=1230000000000000000  (wei)
///              ethereum:pay-<addr>?value=0x11c37937e08000 (hex wei)
ParsedPayment? parseCryptoLink(String input) {
  final s = input.trim();

  // Quick precheck: must look like "<scheme>:"
  final schemeMatch = RegExp(r'^([a-zA-Z][a-zA-Z0-9+.-]*):').firstMatch(s);
  if (schemeMatch == null) return null;

  final scheme = schemeMatch.group(1)!.toLowerCase();

  // Parse URI using Dart's Uri parser. For "opaque" URIs like "bitcoin:addr?x=y",
  // Uri.parse keeps everything after the scheme as `path` when using `Uri.parse`
  // on a non-hierarchical (no //) reference.
  late final Uri uri;
  try {
    uri = Uri.parse(s);
  } catch (_) {
    return null;
  }

  // Extract opaque part after "scheme:" (before query)
  // For e.g. "bitcoin:addr?amount=1.2" => opaqueOrPath = "addr"
  String opaqueOrPath = '';
  if (uri.hasAuthority || s.contains('://')) {
    // Not typical for BIP21/EIP-681, but handle defensively
    opaqueOrPath = uri.path;
  } else {
    // For opaque: scheme:opaque?query
    final afterColon = s.substring(s.indexOf(':') + 1);
    final qIdx = afterColon.indexOf('?');
    opaqueOrPath = qIdx >= 0 ? afterColon.substring(0, qIdx) : afterColon;
  }
  opaqueOrPath = opaqueOrPath.trim();

  // Common query params
  final qp = uri.queryParameters.map((k, v) => MapEntry(k.toLowerCase(), v));

  switch (scheme) {
    case 'bitcoin':
      // BIP21: address sits in opaque part; amount is decimal BTC
      // Example: bitcoin:tb1q066a...?...&amount=0.015
      final address = opaqueOrPath;
      if (address.isEmpty) return null;

      // amount can be e.g. "0.0012345"
      final amt =
          _firstNonEmpty(qp['amount'], qp['value']); // some wallets use value
      return ParsedPayment(
        currency: 'bitcoin',
        address: address,
        amount: amt,
      );

    case 'vfx':
      final address = opaqueOrPath;
      if (address.isEmpty) return null;

      // amount can be e.g. "0.0012345"
      final amt =
          _firstNonEmpty(qp['amount'], qp['value']); // some wallets use value
      return ParsedPayment(
        currency: 'vfx',
        address: address,
        amount: amt,
      );

    case 'ethereum':
    case 'eth':
      // EIP-681 (basic): ethereum:<addr>?value=<wei>
      // Also accepts "ethereum:pay-<addr>"
      var address = opaqueOrPath;
      if (address.startsWith('pay-')) {
        address = address.substring(4);
      }
      if (address.isEmpty) return null;

      // Value may be in wei (decimal or 0x-hex).
      final valueWei = qp['value'];
      String? amountEth;
      if (valueWei != null && valueWei.isNotEmpty) {
        amountEth = _weiToEthDecimal(valueWei);
      }
      return ParsedPayment(
        currency: 'eth',
        address: address,
        amount: amountEth,
      );

    // A few common alt symbols that use the BIP21-like pattern.
    case 'litecoin':
    case 'ltc':
    case 'dogecoin':
    case 'doge':
    case 'dash':
    case 'bch':
    case 'bitcoincash':
      final address = opaqueOrPath;
      if (address.isEmpty) return null;
      final amt = _firstNonEmpty(qp['amount'], qp['value']);
      return ParsedPayment(
        currency: scheme,
        address: address,
        amount: amt,
      );

    default:
      // Generic fallback: treat as "<symbol>:<address>?amount=..."
      final address = opaqueOrPath;
      if (address.isEmpty) return null;
      final amt = _firstNonEmpty(qp['amount'], qp['value']);
      return ParsedPayment(
        currency: scheme,
        address: address,
        amount: amt,
      );
  }
}

/* --------------------------- Helpers & utilities --------------------------- */

String? _firstNonEmpty(String? a, String? b) {
  if (a != null && a.trim().isNotEmpty) return a.trim();
  if (b != null && b.trim().isNotEmpty) return b.trim();
  return null;
}

/// Convert wei (decimal string or 0x-hex) → ETH decimal string without scientific notation.
/// Returns the original input on parse failure (so you still get *something*).
String _weiToEthDecimal(String weiStr) {
  try {
    BigInt wei;
    final s = weiStr.trim().toLowerCase();
    if (s.startsWith('0x')) {
      wei = BigInt.parse(s.substring(2), radix: 16);
    } else {
      wei = BigInt.parse(s);
    }

    const decimals = 18;
    final base = BigInt.from(10).pow(decimals);
    final whole = wei ~/ base;
    final frac = (wei % base).toString().padLeft(decimals, '0');

    // Trim trailing zeros in fractional part
    final fracTrimmed = frac.replaceFirst(RegExp(r'0+$'), '');
    return fracTrimmed.isEmpty
        ? whole.toString()
        : '${whole.toString()}.$fracTrimmed';
  } catch (_) {
    // If we fail to parse, just surface the raw value
    return weiStr;
  }
}

/// Parsed result for a VerifiedX "send" link.
class VerifiedXSendLink {
  final String currency; // e.g. "btc", "vfx", etc.
  final String address; // decoded, not percent-encoded
  final String amountRaw; // as string, exactly as in the URL
  final double? amount; // parsed double if it parses cleanly
  final bool isTestnet; // true if host is wallet-testnet.verifiedx.io
  final Uri uri; // original parsed URI

  VerifiedXSendLink({
    required this.currency,
    required this.address,
    required this.amountRaw,
    required this.amount,
    required this.isTestnet,
    required this.uri,
  });

  @override
  String toString() =>
      'VerifiedXSendLink(currency: $currency, address: $address, amount: $amountRaw, '
      'isTestnet: $isTestnet, uri: $uri)';
}

/// Detect and parse:
///   https://wallet.verifiedx.io/#dashboard/send/<currency>/<address>/<amount>
///   https://wallet-testnet.verifiedx.io/#dashboard/send/<currency>/<address>/<amount>
///
/// By default it accepts any origin (useful for dev tunnels); set [restrictToVerifiedXHosts]
/// to true if you want to require the official hosts.
VerifiedXSendLink? parseVerifiedXSendLink(
  String input, {
  bool restrictToVerifiedXHosts = false,
}) {
  final raw = input.trim();
  if (raw.isEmpty) return null;

  late final Uri uri;
  try {
    uri = Uri.parse(raw);
  } catch (_) {
    return null;
  }

  // Optionally require official hosts
  final host = uri.host.toLowerCase();
  final isTestnetHost = host == 'wallet-testnet.verifiedx.io';
  final isMainnetHost = host == 'wallet.verifiedx.io';
  if (restrictToVerifiedXHosts && !(isTestnetHost || isMainnetHost)) {
    return null;
  }

  // We route via the URL fragment (after the #)
  // Expected: "dashboard/send/<currency>/<address>/<amount>[?...]"
  final frag = uri.fragment; // everything after '#'
  if (frag.isEmpty) return null;

  // Drop any fragment query params if present (not in your generator, but defensive)
  final fragPath = frag.split('?').first;

  // Normalize & split
  final parts = fragPath.split('/').where((p) => p.isNotEmpty).toList();
  // Need: ["dashboard", "send", "<currency>", "<address>", "<amount>"]
  if (parts.length < 5) return null;
  if (parts[0] != 'dashboard' || parts[1] != 'send') return null;

  final currency = parts[2];
  // Address could be percent-encoded; decode it safely
  final address = Uri.decodeComponent(parts[3]);
  final amountRaw = parts[4];

  if (currency.isEmpty || address.isEmpty || amountRaw.isEmpty) return null;

  // Try parsing amount as double (you still have amountRaw if you need exact string)
  final amtDouble = double.tryParse(amountRaw);

  return VerifiedXSendLink(
    currency: currency,
    address: address,
    amountRaw: amountRaw,
    amount: amtDouble,
    isTestnet: isTestnetHost,
    uri: uri,
  );
}
