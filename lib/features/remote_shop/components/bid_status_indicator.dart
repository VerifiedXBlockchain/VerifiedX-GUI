import 'package:flutter/material.dart';
import '../../../core/components/badges.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../dst/models/bid.dart';

class BidStatusIndicator extends StatelessWidget {
  final Bid bid;
  const BidStatusIndicator(
    this.bid, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        if (bid.bidStatus == BidStatus.Sent) {
          return AppBadge(
            label: l10n.shopBidSent,
            variant: AppColorVariant.Primary,
          );
        }

        if (bid.bidStatus == BidStatus.Received) {
          return AppBadge(
            label: l10n.shopBidReceived,
            variant: AppColorVariant.Primary,
          );
        }

        if (bid.bidStatus == BidStatus.Accepted) {
          if (bid.isBuyNow) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBadge(
                  label: l10n.shopBidPurchased,
                  variant: AppColorVariant.Success,
                ),
                SizedBox(height: 4),
                Text("[Buy Now]")
              ],
            );
          }

          return AppBadge(
            label: l10n.shopBidAccepted,
            variant: AppColorVariant.Success,
          );
        }

        if (bid.bidStatus == BidStatus.Rejected) {
          return AppBadge(
            label: l10n.shopBidRejected,
            variant: AppColorVariant.Danger,
          );
        }

        return SizedBox();
      },
    );
  }
}
