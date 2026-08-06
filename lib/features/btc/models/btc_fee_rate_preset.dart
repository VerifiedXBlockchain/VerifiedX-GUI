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

  String get label {
    switch (this) {
      case BtcFeeRatePreset.minimum:
        return globalL10n.r3fFeePresetMinimum;
      case BtcFeeRatePreset.economy:
        return globalL10n.r3fFeePresetEconomy;
      case BtcFeeRatePreset.hour:
        return globalL10n.r3fFeePresetHour;
      case BtcFeeRatePreset.halfHour:
        return globalL10n.r3fFeePresetHalfHour;
      case BtcFeeRatePreset.fastest:
        return globalL10n.r3fFeePresetFastest;
      case BtcFeeRatePreset.custom:
        return globalL10n.r3fFeePresetCustom;
    }
  }
}
