import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/base_component.dart';
import '../../../core/components/badges.dart';
import '../../../core/theme/app_theme.dart';
import '../models/beacon.dart';
import 'beacon_context_menu.dart';
import '../../../l10n/generated/app_localizations.dart';

class BeaconListTile extends BaseComponent {
  final Beacon beacon;
  const BeaconListTile(this.beacon, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    String subtitle = beacon.ipAddressLabel;

    if (beacon.selfBeacon) {
      final assetCache = beacon.fileCachePeriodDays == 0
          ? l10n.r3bInfinite
          : "${beacon.fileCachePeriodDays} ${beacon.fileCachePeriodDays == 1 ? l10n.r3bDay : l10n.r3bDays}";
      subtitle =
          "${beacon.ipAddressLabel}\n${l10n.r3bAutoDeleteAssets}: ${beacon.autoDeleteAfterDownload ? l10n.actionYes : l10n.actionNo} | ${l10n.r3bAssetCache}: $assetCache";
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: glowingBox,
        ),
        child: Card(
          color: Colors.black,
          child: ListTile(
            leading: Icon(beacon.selfBeacon ? Icons.wifi : Icons.satellite_alt),
            title: Text("${beacon.name} ${beacon.isBeaconPrivate ? l10n.r3bPrivateTag : ''}"),
            subtitle: SelectableText(subtitle),
            isThreeLine: beacon.selfBeacon,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                beacon.selfBeacon
                    ? AppBadge(
                        label: beacon.selfBeaconActive ? l10n.beaconActiveBadge : l10n.beaconInactiveBadge,
                        variant: beacon.selfBeaconActive ? AppColorVariant.Success : AppColorVariant.Danger,
                      )
                    : AppBadge(
                        label: l10n.beaconRemoteBadge,
                        variant: AppColorVariant.Warning,
                      ),
                BeaconContextMenu(beacon)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
