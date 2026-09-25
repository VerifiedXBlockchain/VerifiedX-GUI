import 'dart:convert';

import 'wallet.dart';

/// The node's answer to GET /api/V1/GetPrivateKey/{address}: the one route
/// that exports a VFX key since account listings stopped carrying keys.
/// It replies {Success, Address, PrivateKey} or {Success: false, Message}.
class PrivateKeyExport {
  final String address;
  final String? privateKey;
  final String? message;

  const PrivateKeyExport._(this.address, this.privateKey, this.message);

  const PrivateKeyExport.refused(this.address, this.message) : privateKey = null;

  bool get isExported => privateKey != null;

  factory PrivateKeyExport.fromResponse(String address, String body) {
    final Object? data;
    try {
      data = jsonDecode(body);
    } on FormatException {
      return PrivateKeyExport.refused(address, body.trim().isEmpty ? null : body.trim());
    }

    if (data is! Map<String, dynamic>) {
      return PrivateKeyExport.refused(address, null);
    }

    final key = data['PrivateKey'];
    if (data['Success'] == true && key is String && key.trim().isNotEmpty) {
      return PrivateKeyExport._(address, key.trim(), null);
    }

    final message = data['Message'];
    return PrivateKeyExport.refused(address, message is String && message.trim().isNotEmpty ? message.trim() : null);
  }
}

/// Builds the VFX part of the key backup file. An account whose key the node
/// refused to export shows the node's reason, and only exported keys go in the
/// bulk import block, so the file never carries a placeholder where a key
/// should be.
String vfxKeyBackupText(List<Wallet> wallets, Map<String, PrivateKeyExport> exports) {
  final buffer = StringBuffer();

  for (final w in wallets) {
    final export = exports[w.address];
    final keyText = export?.privateKey ?? "Not exported: ${export?.message ?? 'the node did not return a key'}";
    buffer.write("Address:\n${w.address}\n\n");
    buffer.write("Public Key:\n${w.publicKey}\n\n");
    buffer.write("Private Key:\n$keyText\n\n");
    buffer.write("===================================\n\n");
  }

  buffer.write("FOR BULK IMPORT:\n\n");
  for (final w in wallets) {
    final key = exports[w.address]?.privateKey;
    if (key != null) {
      buffer.write("$key\n");
    }
  }
  buffer.write("\n===================================\n\n");

  return buffer.toString();
}
