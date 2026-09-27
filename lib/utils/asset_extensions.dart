import '../core/app_constants.dart';

/// Whether [extension] is refused as an NFT asset on every platform.
///
/// Known malware extensions are always refused. [rejectedExtensions] is the
/// configurable block list; the desktop passes the CLI config value and the
/// web uses the same defaults, so both platforms refuse the same files.
bool isBlockedAssetExtension(
  String? extension, {
  Iterable<String> rejectedExtensions = DEFAULT_REJECTED_EXTENIONS,
}) {
  if (extension == null) {
    return false;
  }
  final normalized = extension.trim().toLowerCase();
  if (normalized.isEmpty) {
    return false;
  }
  return MALWARE_FILE_EXTENSIONS.contains(normalized) || rejectedExtensions.map((e) => e.toLowerCase()).contains(normalized);
}
