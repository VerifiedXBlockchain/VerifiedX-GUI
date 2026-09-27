enum WebBtcAddressType {
  p2pkh("p2pkh", "P2PKH (Legacy)"),
  p2sh("p2sh", "P2SH (Nested SegWit)"),
  bech32("bech32", "Bech32 (Native SegWit - P2WPKH)"),
  bech32m("bech32m", "Bech32m (Taproot - P2TR)"),
  ;

  final String value;
  final String label;

  const WebBtcAddressType(this.value, this.label);
}

/// Infers the address type from a BTC address's prefix, or null when the
/// prefix is not recognised. Testnet prefixes (m/n, 2, tb1q, tb1p) are only
/// recognised when [isTestNet] is true.
WebBtcAddressType? btcAddressTypeFromAddress(String address, {required bool isTestNet}) {
  final trimmed = address.trim();
  final lower = trimmed.toLowerCase();

  if (lower.startsWith('bc1q')) return WebBtcAddressType.bech32;
  if (lower.startsWith('bc1p')) return WebBtcAddressType.bech32m;
  if (trimmed.startsWith('1')) return WebBtcAddressType.p2pkh;
  if (trimmed.startsWith('3')) return WebBtcAddressType.p2sh;

  if (isTestNet) {
    if (lower.startsWith('tb1q')) return WebBtcAddressType.bech32;
    if (lower.startsWith('tb1p')) return WebBtcAddressType.bech32m;
    if (trimmed.startsWith('m') || trimmed.startsWith('n')) return WebBtcAddressType.p2pkh;
    if (trimmed.startsWith('2')) return WebBtcAddressType.p2sh;
  }

  return null;
}
