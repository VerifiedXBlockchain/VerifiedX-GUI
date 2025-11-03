import 'package:freezed_annotation/freezed_annotation.dart';

part 'vfx_shh_message.freezed.dart';

@freezed
class VfxShhMessage with _$VfxShhMessage {
  const VfxShhMessage._();

  const factory VfxShhMessage({
    required String recipientAddress,
    required String encryptedData,
    required String rawMessage,
  }) = _VfxShhMessage;

  /// Parses a VFX-SHH formatted message
  /// Supports multiple formats:
  /// 1. VFX-SHH:recipient_address\nencrypted_data\n/VFX-SHH
  /// 2. [VFX-SHH:recipient_address]{encrypted_data}[/VFX-SHH]
  /// 3. [VFX-SHH:recipient_address]\nencrypted_data\n[/VFX-SHH]
  static VfxShhMessage? parse(String text) {
    if (text.isEmpty) return null;

    // Try format 1: VFX-SHH:address\ndata\n/VFX-SHH (most common)
    // Updated to handle both actual newlines and literal \n strings
    // Also handles multiline base64 data with flexible line breaks
    final regex1 = RegExp(
      r'VFX-SHH:([^\s\n\\]+)(?:\\n|\s*\n\s*)([A-Za-z0-9+/=\n\s\\]+?)(?:\\n|\s*\n\s*)/VFX-SHH',
      caseSensitive: false,
      multiLine: true,
    );

    var match = regex1.firstMatch(text);
    if (match != null) {
      final recipientAddress = match.group(1)?.trim();
      // Remove literal \n strings first, then all whitespace from encrypted data
      final encryptedData = match.group(2)?.trim().replaceAll(r'\n', '').replaceAll(RegExp(r'\s'), '');

      if (recipientAddress != null && recipientAddress.isNotEmpty && encryptedData != null && encryptedData.isNotEmpty) {
        return VfxShhMessage(
          recipientAddress: recipientAddress,
          encryptedData: encryptedData,
          rawMessage: match.group(0) ?? '',
        );
      }
    }

    // Try format 2: [VFX-SHH:address]{data}[/VFX-SHH]
    final regex2 = RegExp(
      r'\[VFX-SHH:([^\]]+)\]\s*\{([^}]+)\}\s*\[/VFX-SHH\]',
      caseSensitive: false,
    );

    match = regex2.firstMatch(text);
    if (match != null) {
      final recipientAddress = match.group(1)?.trim();
      final encryptedData = match.group(2)?.trim();

      if (recipientAddress != null && recipientAddress.isNotEmpty && encryptedData != null && encryptedData.isNotEmpty) {
        return VfxShhMessage(
          recipientAddress: recipientAddress,
          encryptedData: encryptedData,
          rawMessage: match.group(0) ?? '',
        );
      }
    }

    // Try format 3: [VFX-SHH:address]\ndata\n[/VFX-SHH]
    // Updated to handle both actual newlines and literal \n strings
    // Also handles multiline base64 data with flexible line breaks
    final regex3 = RegExp(
      r'\[VFX-SHH:([^\]]+)\](?:\\n|\s*\n\s*)([A-Za-z0-9+/=\n\s\\]+?)(?:\\n|\s*\n\s*)\[/VFX-SHH\]',
      caseSensitive: false,
      multiLine: true,
    );

    match = regex3.firstMatch(text);
    if (match != null) {
      final recipientAddress = match.group(1)?.trim();
      // Remove literal \n strings first, then all whitespace from encrypted data
      final encryptedData = match.group(2)?.trim().replaceAll(r'\n', '').replaceAll(RegExp(r'\s'), '');

      if (recipientAddress != null && recipientAddress.isNotEmpty && encryptedData != null && encryptedData.isNotEmpty) {
        return VfxShhMessage(
          recipientAddress: recipientAddress,
          encryptedData: encryptedData,
          rawMessage: match.group(0) ?? '',
        );
      }
    }

    return null;
  }

  /// Checks if the given text contains a VFX-SHH formatted message
  static bool hasEncryptedMessage(String text) {
    return parse(text) != null;
  }
}
