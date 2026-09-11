import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/btc_utxo.dart';
import '../providers/combined_btc_utxo_list_provider.dart';
import '../../../core/base_component.dart';
import '../../../core/components/badges.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/components.dart';
import '../../../l10n/generated/app_localizations.dart';

class BtcUtxoList extends BaseComponent {
  const BtcUtxoList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final utxos = ref.watch(combinedBtcUtxoListProvider);

    if (utxos.isEmpty) {
      return Center(
        child: Text(l10n.tkbNoUtxos),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        itemCount: utxos.length,
        itemBuilder: (context, index) {
          final utxo = utxos[index];

          return Padding(
            padding: EdgeInsets.only(bottom: index == utxos.length - 1 ? 54 : 0),
            child: UtxoListTile(utxo: utxo),
          );
        },
      ),
    );
  }
}

class UtxoListTile extends StatelessWidget {
  const UtxoListTile({
    super.key,
    required this.utxo,
  });

  final BtcUtxo utxo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: AppCard(
        padding: 0,
        child: ListTile(
          dense: true,
          title: Text(l10n.tkbUtxoAddress(utxo.address)),
          subtitle: Text(l10n.tkbUtxoDetails(utxo.hash, utxo.valueBtcLabel)),
          trailing: utxo.isUsed
              ? AppBadge(
                  label: l10n.tkbUtxoUsed,
                  variant: AppColorVariant.Btc,
                )
              : AppBadge(
                  label: l10n.tkbUtxoUnused,
                  variant: AppColorVariant.Primary,
                ),
        ),
      ),
    );
  }
}
