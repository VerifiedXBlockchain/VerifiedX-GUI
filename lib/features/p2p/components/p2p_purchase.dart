import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../chain/p2p_chain_error.dart';
import '../chain/p2p_tx_builders.dart';
import '../models/p2p_listing.dart';
import '../providers/p2p_browse_providers.dart';
import '../providers/p2p_listing_providers.dart';
import '../utils/p2p_amount.dart';
import '../utils/p2p_error_text.dart';
import '../utils/p2p_view.dart';
import 'p2p_chain_step_dialog.dart';
import 'p2p_parts.dart';

/// Opens the confirmation for the buyer's `Sale_Complete()` on [listing] and
/// carries it out on Confirm. While chain steps are dry runs it is recorded
/// with the registry; nothing is signed or sent. Afterwards the listing's
/// page and the buyer's list show it as it now stands.
Future<void> completeP2pPurchase(WidgetRef ref, AppLocalizations l10n, P2pListing listing) async {
  final steps = ref.read(p2pChainStepsProvider);
  final price = p2pSalePrice(listing);
  final buyer = listing.winnerAddress;

  await P2pChainStepDialog.show(
    title: l10n.p2pChainCompleteTitle,
    rows: [
      P2pStepRow(l10n.p2pChainRowNft, listing.title),
      P2pStepRow(l10n.p2pChainRowSeller, shortP2pAddress(listing.sellerAddress), mono: true),
      if (price != null) P2pStepRow(l10n.p2pChainRowPrice, p2pVfxText(l10n, price.toDecimalString()), mono: true),
    ],
    describe: () => steps.describeCompletePurchase(listing),
    carryOut: (tx) async {
      final sold = await steps.completePurchase(listing, tx);
      ref.read(p2pListingDetailProvider(listing.id).notifier).replace(sold);
      if (buyer != null) {
        ref.invalidate(p2pMeProvider(buyer));
      }
    },
    doneBody: listing.title,
  );
}

/// How a purchase's price is paid: to the seller, and to the royalty address
/// when the NFT has a royalty, as Core splits it. A royalty Core would
/// refuse shows the reason in place of the split.
class P2pSaleSplitSummary extends StatelessWidget {
  final P2pListing listing;
  final P2pAmount price;

  const P2pSaleSplitSummary({super.key, required this.listing, required this.price});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final royalty = listing.nft?.royalty;
    final P2pSaleSplit split;
    try {
      split = p2pSaleSplit(price, royalty);
    } on P2pChainError catch (e) {
      return Text(
        p2pErrorText(l10n, e),
        key: const Key('p2p:split_error'),
        style: const TextStyle(color: Colors.white70, fontSize: 13),
      );
    }
    final percent = royalty == null ? null : p2pRoyaltyPercent(royalty);

    return Container(
      key: const Key('p2p:sale_split'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(color: p2pSurfaceRaised, borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          _row("${l10n.p2pSplitSeller} ${shortP2pAddress(listing.sellerAddress)}", p2pVfxText(l10n, split.seller.toDecimalString())),
          if (split.royalty != null && royalty != null)
            _row(
              "${l10n.p2pSplitRoyalty(percent ?? royalty.amount)} ${shortP2pAddress(royalty.payTo)}",
              p2pVfxText(l10n, split.royalty!.toDecimalString()),
            ),
          const Divider(height: 12, color: p2pBorder),
          _row(l10n.p2pSplitTotal, p2pVfxText(l10n, price.toDecimalString()), strong: true),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool strong = false}) {
    final weight = strong ? FontWeight.w700 : FontWeight.w400;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: strong ? Colors.white : p2pMuted, fontSize: 13, fontWeight: weight),
            ),
          ),
          Text(value, style: TextStyle(fontFamily: 'RobotoMono', fontSize: 13, fontWeight: weight)),
        ],
      ),
    );
  }
}
