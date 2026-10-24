import '../../../l10n/l10n_helper.dart';
import '../token_rules.dart';

/// The message for a mint [problem], naming the token's [decimalPlaces].
String tokenMintProblemMessage(TokenMintProblem problem, int decimalPlaces) {
  switch (problem) {
    case TokenMintProblem.paused:
      return globalL10n.tokenMintPaused;
    case TokenMintProblem.tooManyDecimals:
      return globalL10n.tokenMintTooManyDecimals(decimalPlaces);
    case TokenMintProblem.overflow:
      return globalL10n.tokenMintOverflow;
  }
}
