import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/base_component.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../providers/minted_nft_list_provider.dart';
import '../providers/nft_list_provider.dart';
import 'nft_list_tile.dart';
import 'nft_navigator.dart';

class NftList extends BaseComponent {
  final bool minted;

  const NftList({Key? key, this.minted = false}) : super(key: key);

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final _model = ref.watch(minted ? mintedNftListProvider : nftListProvider);
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: NftNavigator(minted: minted),
        ),
        Expanded(
          child: Builder(builder: (context) {
            if (_model.data.results.isEmpty) {
              return Center(
                child: Text(minted ? l10n.r3gNoMintedNfts : l10n.r3gNoNftsFound),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(8),
              child: ListView.builder(
                itemCount: _model.data.results.length,
                itemBuilder: (context, index) {
                  final nft = _model.data.results[int.parse(index.toString())];

                  return NftListTile(
                    nft,
                    key: Key(nft.id),
                    manageOnPress: minted,
                    showListedStatus: true,
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}
