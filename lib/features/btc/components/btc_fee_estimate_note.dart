import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../models/btc_recommended_fees.dart';

/// Shown with a fee-rate picker when [fees] are the fixed stand-ins used
/// because the fee API could not be reached, so the rates are not read as
/// what the network is asking for.
class BtcFeeEstimateNote extends StatelessWidget {
  final BtcRecommendedFees fees;

  const BtcFeeEstimateNote(this.fees, {super.key});

  @override
  Widget build(BuildContext context) {
    if (!fees.isEstimate) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        key: const Key('btcFeeRate:estimate-note'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 16, color: Color(0xFFE0A32E)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              AppLocalizations.of(context).btcFeeRatesAreEstimates,
              style: const TextStyle(color: Color(0xFFE0A32E), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
