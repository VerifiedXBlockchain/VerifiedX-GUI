import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../utils/toast.dart';
import '../bridge/services/bridge_service.dart';
import '../encrypt/utils.dart';

/// Fetches the VFX private key for [address] from the node for a flow that
/// must show or use it. Unlocks an encrypted wallet first, and shows the
/// node's reason when it refuses the export. Returns null when there is no key
/// to use.
Future<String?> fetchVfxPrivateKey(BuildContext context, WidgetRef ref, String address) async {
  final l10n = AppLocalizations.of(context);
  if (!await passwordRequiredGuard(context, ref)) {
    return null;
  }

  final export = await BridgeService().getPrivateKey(address);
  if (!export.isExported) {
    Toast.error(export.message ?? l10n.walletKeyExportUnavailable);
    return null;
  }
  return export.privateKey;
}
