import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScWizardMintingProgress {
  final double percent;
  final String label;

  /// Set when minting stopped on an error; the run is over either way.
  final String? error;

  const ScWizardMintingProgress({this.percent = 0, this.label = "Initializing", this.error});

  bool get failed => error != null;

  ScWizardMintingProgress copyWith({double? percent, String? label}) {
    return ScWizardMintingProgress(
      percent: percent ?? this.percent,
      label: label ?? this.label,
      error: error,
    );
  }
}

class ScWizardMintingProgressProvider extends StateNotifier<ScWizardMintingProgress> {
  ScWizardMintingProgressProvider([ScWizardMintingProgress initial = const ScWizardMintingProgress()]) : super(initial);

  /// Resets the progress (including any previous error) for a new run.
  void start() {
    state = const ScWizardMintingProgress();
  }

  setLabel(String label) {
    state = state.copyWith(label: label);
  }

  setPercent(double percent) {
    state = state.copyWith(percent: percent);
  }

  /// Ends the run on an error, keeping the percent reached so far.
  void fail(String message) {
    state = ScWizardMintingProgress(percent: state.percent, label: state.label, error: message);
  }
}

final scWizardMintingProgress = StateNotifierProvider<ScWizardMintingProgressProvider, ScWizardMintingProgress>((ref) {
  return ScWizardMintingProgressProvider();
});
