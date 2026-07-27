import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/base_component.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../providers/beacon_list_provider.dart';
import 'beacon_list_tile.dart';

class BeaconList extends BaseComponent {
  const BeaconList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final beacons = ref.watch(beaconListProvider);
    final l10n = AppLocalizations.of(context);

    if (beacons.isEmpty) {
      return Center(
        child: Text(l10n.beaconNoBeacons),
      );
    }

    return ListView.builder(
      itemCount: beacons.length,
      itemBuilder: (context, index) {
        final beacon = beacons[index];

        return BeaconListTile(beacon);
      },
    );
  }
}
