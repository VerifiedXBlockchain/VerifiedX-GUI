import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/components/buttons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/toast.dart';
import '../models/p2p_listing.dart';
import '../utils/p2p_amount.dart';
import '../utils/p2p_error_text.dart';
import '../utils/p2p_view.dart';

/// Small pieces the P2P shop screens share.

const Color p2pSurface = Color(0xFF151718);
const Color p2pSurfaceRaised = Color(0xFF1f2225);
const Color p2pBorder = Color(0x1FFFFFFF);
const Color p2pMuted = Color(0x99FFFFFF);

Color p2pBrand() => AppColors.getBlue(ColorShade.s100);

BoxDecoration p2pCardDecoration({bool hovered = false}) {
  return BoxDecoration(
    color: hovered ? p2pSurfaceRaised : p2pSurface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: hovered ? Colors.white30 : p2pBorder),
  );
}

/// A grid of cards at most [maxCardWidth] wide whose height follows their
/// width: [cardHeight] gives a card's height for the width it gets. A card
/// with a picture as wide as itself and text under it needs that, where a
/// fixed aspect ratio would squeeze the text as the window changes.
SliverGridDelegate p2pCardGridDelegate(
  SliverConstraints constraints, {
  required double maxCardWidth,
  required double Function(double cardWidth) cardHeight,
  double spacing = 14,
}) {
  final width = constraints.crossAxisExtent;
  final columns = (width / (maxCardWidth + spacing)).ceil().clamp(1, 24);
  final cardWidth = (width - spacing * (columns - 1)) / columns;
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: columns,
    mainAxisExtent: cardHeight(cardWidth),
    crossAxisSpacing: spacing,
    mainAxisSpacing: spacing,
  );
}

/// The current time, for everything that counts down. Tests override it.
final p2pClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// "{amount} VFX" with the amount grouped for reading.
String p2pVfxText(AppLocalizations l10n, String? amount) {
  return l10n.p2pAmountVfx(formatP2pAmount(amount));
}

String p2pDateTimeText(BuildContext context, DateTime at) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMMMd(locale).add_jm().format(at.toLocal());
}

String p2pCountdownText(AppLocalizations l10n, P2pCountdown left) {
  switch (left.unit) {
    case P2pCountdownUnit.daysHours:
      return l10n.p2pCountdownDaysHours(left.days, left.hours);
    case P2pCountdownUnit.hoursMinutes:
      return l10n.p2pCountdownHoursMinutes(left.hours, left.minutes);
    case P2pCountdownUnit.minutesSeconds:
      return l10n.p2pCountdownMinutesSeconds(left.minutes, left.seconds);
    case P2pCountdownUnit.seconds:
      return l10n.p2pCountdownSeconds(left.seconds);
  }
}

String p2pStateText(AppLocalizations l10n, P2pListingState state) {
  switch (state) {
    case P2pListingState.live:
      return l10n.p2pStateLive;
    case P2pListingState.awaitingSaleStart:
      return l10n.p2pStateAwaitingSaleStart;
    case P2pListingState.salePending:
      return l10n.p2pStateSalePending;
    case P2pListingState.sold:
      return l10n.p2pStateSold;
    case P2pListingState.cancelled:
      return l10n.p2pStateCancelled;
    case P2pListingState.expired:
      return l10n.p2pStateExpired;
    case P2pListingState.unfulfilled:
      return l10n.p2pStateUnfulfilled;
    case P2pListingState.ended:
      return l10n.p2pStateEnded;
    case P2pListingState.unknown:
      return l10n.p2pStateUnknown;
  }
}

String p2pHeadlineLabel(AppLocalizations l10n, P2pHeadlineKind kind) {
  switch (kind) {
    case P2pHeadlineKind.soldFor:
      return l10n.p2pPriceSoldFor;
    case P2pHeadlineKind.winningBid:
      return l10n.p2pPriceWinningBid;
    case P2pHeadlineKind.currentBid:
      return l10n.p2pPriceCurrentBid;
    case P2pHeadlineKind.startingBid:
      return l10n.p2pPriceStartingBid;
    case P2pHeadlineKind.buyNow:
      return l10n.p2pPriceBuyNow;
  }
}

String p2pBidCountText(AppLocalizations l10n, int count) {
  if (count <= 0) {
    return l10n.p2pBidCountNone;
  }
  return count == 1 ? l10n.p2pBidCountOne : l10n.p2pBidCountOther(count);
}

/// A small rounded label.
class P2pTag extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const P2pTag({super.key, required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w600, height: 1.2),
            ),
          ),
        ],
      ),
    );
  }
}

Color p2pStateColor(P2pListingState state) {
  switch (state) {
    case P2pListingState.live:
      return AppColors.getSpringGreen(ColorShade.s50);
    case P2pListingState.awaitingSaleStart:
    case P2pListingState.salePending:
      return AppColors.gold[50]!;
    case P2pListingState.sold:
      return AppColors.getBlue(ColorShade.s100);
    case P2pListingState.cancelled:
    case P2pListingState.expired:
    case P2pListingState.unfulfilled:
    case P2pListingState.ended:
    case P2pListingState.unknown:
      return Colors.white60;
  }
}

/// A listing's state as the server gave it.
class P2pStateBadge extends StatelessWidget {
  final P2pListingState state;

  const P2pStateBadge({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return P2pTag(
      key: Key('p2p:state:${state.name}'),
      label: p2pStateText(AppLocalizations.of(context), state),
      color: p2pStateColor(state),
    );
  }
}

/// A labelled VFX amount.
class P2pPrice extends StatelessWidget {
  final String? label;
  final String amount;
  final bool large;
  final CrossAxisAlignment alignment;

  const P2pPrice({
    super.key,
    this.label,
    required this.amount,
    this.large = false,
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Text(label!, style: const TextStyle(color: p2pMuted, fontSize: 12)),
        Text(
          p2pVfxText(l10n, amount),
          style: TextStyle(
            fontSize: large ? 26 : 15,
            fontWeight: FontWeight.w700,
            fontFamily: 'RobotoMono',
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

/// Rebuilds once a second with the current time (from [p2pClockProvider]).
class P2pNowBuilder extends ConsumerStatefulWidget {
  final Widget Function(BuildContext context, DateTime now) builder;

  const P2pNowBuilder({super.key, required this.builder});

  @override
  ConsumerState<P2pNowBuilder> createState() => _P2pNowBuilderState();
}

class _P2pNowBuilderState extends ConsumerState<P2pNowBuilder> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, ref.watch(p2pClockProvider)());
  }
}

/// Where a listing's clock stands, in a line: "Ends in 2d 4h".
class P2pClockLine extends StatelessWidget {
  final P2pListing listing;
  final double fontSize;

  const P2pClockLine({super.key, required this.listing, this.fontSize = 12.5});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return P2pNowBuilder(
      builder: (context, now) {
        final clock = P2pListingClock.of(listing, now);
        if (clock.kind == P2pClockKind.none) {
          return const SizedBox.shrink();
        }
        final until = clock.until;
        final left = until == null ? null : P2pCountdown.of(until.difference(now));
        String text;
        var urgent = false;
        if (clock.kind == P2pClockKind.closing || left == null) {
          text = l10n.p2pClockClosing;
        } else {
          final time = p2pCountdownText(l10n, left);
          urgent = until!.difference(now) < p2pEndingSoon;
          switch (clock.kind) {
            case P2pClockKind.upcoming:
              text = l10n.p2pClockOpensIn(time);
              urgent = false;
              break;
            case P2pClockKind.awaitingSeller:
              text = l10n.p2pClockSellerHas(time);
              break;
            default:
              text = l10n.p2pClockEndsIn(time);
          }
        }
        final color = urgent ? AppColors.gold[50]! : p2pMuted;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule, size: fontSize + 2, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                key: const Key('p2p:clock'),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: color, fontSize: fontSize, fontWeight: urgent ? FontWeight.w600 : FontWeight.w400),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The NFT's picture, or a placeholder when Spyglass holds no image for it.
class P2pListingThumb extends StatelessWidget {
  final P2pListing listing;
  final BoxFit fit;

  const P2pListingThumb({super.key, required this.listing, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    final url = listing.nft?.thumbnailUrl;
    final placeholder = Container(
      color: p2pSurfaceRaised,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: Colors.white24, size: 32),
    );
    if (url == null || url.isEmpty) {
      return placeholder;
    }
    return Image.network(
      url,
      fit: fit,
      // The name is on the card beside every picture.
      excludeFromSemantics: true,
      errorBuilder: (_, __, ___) => placeholder,
      loadingBuilder: (context, child, progress) => progress == null ? child : placeholder,
    );
  }
}

/// A round mark with the first letter of a shop's name.
class P2pShopAvatar extends StatelessWidget {
  final String name;
  final double size;

  const P2pShopAvatar({super.key, required this.name, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final letter = trimmed.isEmpty ? '?' : String.fromCharCode(trimmed.runes.first).toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.getBlue(ColorShade.s400),
        border: Border.all(color: AppColors.getBlue(ColorShade.s200), width: 2),
      ),
      child: ExcludeSemantics(
        child: Text(
          letter,
          style: TextStyle(color: p2pBrand(), fontSize: size * 0.45, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// Nothing to show, with why.
class P2pEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? body;

  const P2pEmptyState({super.key, required this.icon, required this.title, this.body});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: Colors.white38),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            if (body != null) ...[
              const SizedBox(height: 6),
              Text(body!, textAlign: TextAlign.center, style: const TextStyle(color: p2pMuted)),
            ],
          ],
        ),
      ),
    );
  }
}

/// A load that failed, in words, with a way to try again.
class P2pErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const P2pErrorView({super.key, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 44, color: Theme.of(context).colorScheme.danger),
            const SizedBox(height: 12),
            Text(
              p2pErrorText(l10n, error),
              key: const Key('p2p:error'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 12),
            AppButton(
              key: const Key('p2p:retry'),
              label: l10n.p2pRetry,
              icon: Icons.refresh,
              variant: AppColorVariant.Light,
              type: AppButtonType.Outlined,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

/// Previous / "Page N" / Next for a list the API pages by number.
class P2pPager extends StatelessWidget {
  final int page;
  final bool hasNext;
  final ValueChanged<int> onPage;

  const P2pPager({super.key, required this.page, required this.hasNext, required this.onPage});

  @override
  Widget build(BuildContext context) {
    if (page <= 1 && !hasNext) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppButton(
            key: const Key('p2p:page_previous'),
            label: l10n.actionPrevious,
            icon: Icons.chevron_left,
            type: AppButtonType.Text,
            variant: AppColorVariant.Light,
            disabled: page <= 1,
            onPressed: () => onPage(page - 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(l10n.p2pPageNumber(page), style: const TextStyle(color: p2pMuted)),
          ),
          AppButton(
            key: const Key('p2p:page_next'),
            label: l10n.actionNext,
            icon: Icons.chevron_right,
            iconTrails: true,
            type: AppButtonType.Text,
            variant: AppColorVariant.Light,
            disabled: !hasNext,
            onPressed: () => onPage(page + 1),
          ),
        ],
      ),
    );
  }
}

/// An icon button that copies [value] and says so.
class P2pCopyButton extends StatelessWidget {
  final String value;
  final String tooltip;

  const P2pCopyButton({super.key, required this.value, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      iconSize: 14,
      color: p2pMuted,
      icon: const Icon(Icons.copy),
      onPressed: () async {
        final l10n = AppLocalizations.of(context);
        await Clipboard.setData(ClipboardData(text: value));
        Toast.message(l10n.p2pCopied);
      },
    );
  }
}
