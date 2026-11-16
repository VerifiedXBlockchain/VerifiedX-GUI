import 'package:flutter/material.dart';

import '../../../core/env.dart';
import '../../../core/theme/colors.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Says that the shop's chain steps are dry runs: recorded by the registry,
/// never signed into a transaction or sent. Shown on every shop screen while
/// `Env.p2pBroadcast` is off, and nothing once it is on.
class P2pDryRunBanner extends StatelessWidget {
  const P2pDryRunBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (Env.p2pBroadcast) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    final color = AppColors.gold[50]!;
    return Container(
      key: const Key('p2p:dry_run_banner'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.gold[400],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.science_outlined, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: "${l10n.p2pDryRunBadge}. ", style: const TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: l10n.p2pDryRunBanner),
                ],
              ),
              style: TextStyle(color: color, fontSize: 13, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
