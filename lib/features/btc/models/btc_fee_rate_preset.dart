import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/l10n_helper.dart';

enum BtcFeeRatePreset {
  minimum("minimumFee"),
  economy("economyFee"),
  hour("hourFee"),
  halfHour("halfHourFee"),
  fastest("fastestFee"),
  custom(""),
  ;

  final String apiValue;
  const BtcFeeRatePreset(this.apiValue);

  String get label => labelWith(globalL10n);

  /// Label from an explicit localizations instance, for widgets that already
  /// hold one (and for tests, which have no root navigator to resolve).
  String labelWith(AppLocalizations l10n) {
    switch (this) {
      case BtcFeeRatePreset.minimum:
        return l10n.r3fFeePresetMinimum;
      case BtcFeeRatePreset.economy:
        return l10n.r3fFeePresetEconomy;
      case BtcFeeRatePreset.hour:
        return l10n.r3fFeePresetHour;
      case BtcFeeRatePreset.halfHour:
        return l10n.r3fFeePresetHalfHour;
      case BtcFeeRatePreset.fastest:
        return l10n.r3fFeePresetFastest;
      case BtcFeeRatePreset.custom:
        return l10n.r3fFeePresetCustom;
    }
  }
}
