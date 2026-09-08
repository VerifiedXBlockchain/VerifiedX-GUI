import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/base_component.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Shown while VFXCore reports IsResyncing. A full state rebuild zeros every
/// local balance and restores them block by block, so without this the
/// wallet simply looks empty for the duration.
class ChainRebuildBanner extends BaseComponent {
  const ChainRebuildBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRebuilding =
        ref.watch(sessionProvider.select((s) => s.blocksAreResyncing));
    if (!isRebuilding) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final gold = AppColors.getGold();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: gold.withOpacity(0.12),
        border: Border(bottom: BorderSide(color: gold.withOpacity(0.6))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3, right: 10),
            child: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: gold),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.chainRebuildBannerTitle,
                  style: TextStyle(fontWeight: FontWeight.w600, color: gold),
                ),
                Text(
                  l10n.chainRebuildBannerBody,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
