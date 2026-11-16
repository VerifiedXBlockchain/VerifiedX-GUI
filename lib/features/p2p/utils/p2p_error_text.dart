import '../../../l10n/generated/app_localizations.dart';
import '../chain/p2p_chain_error.dart';
import '../models/p2p_error.dart';
import '../services/p2p_session.dart';
import '../services/p2p_signer.dart';

/// [error] in the reader's words. A refusal the registry names by a code
/// this build knows is worded here; any other shows the registry's own
/// message, and failing that a line for its status.
String p2pErrorText(AppLocalizations l10n, Object error) {
  if (error is P2pSigningError) {
    switch (error.failure) {
      case P2pSigningFailure.notInWallet:
        return l10n.p2pErrorSignNotInWallet;
      case P2pSigningFailure.walletLocked:
        return l10n.errWalletLocked;
      case P2pSigningFailure.unreachable:
        return l10n.p2pErrorSignUnreachable;
      case P2pSigningFailure.unexpected:
        return l10n.p2pErrorSignUnexpected;
    }
  }
  if (error is P2pSignInMismatch) {
    return l10n.p2pErrorSignInRefused;
  }
  if (error is P2pChainError) {
    switch (error.failure) {
      case P2pChainFailure.priceZero:
        return l10n.p2pChainErrorPriceZero;
      case P2pChainFailure.noWinner:
        return l10n.p2pChainErrorNoWinner;
      case P2pChainFailure.royaltyTooHigh:
        return l10n.p2pChainErrorRoyaltyTooHigh;
      case P2pChainFailure.royaltyZero:
        return l10n.p2pChainErrorRoyaltyZero;
      case P2pChainFailure.feeUnavailable:
        return l10n.p2pChainErrorFee;
    }
  }
  if (error is! P2pError) {
    return l10n.p2pErrorUnknown;
  }

  final known = _knownCode(l10n, error);
  if (known != null) {
    return known;
  }
  if (error.isUnauthorized) {
    return l10n.p2pErrorSignInExpired;
  }
  final reason = error.message.trim();
  if (reason.isNotEmpty) {
    return l10n.p2pErrorRefused(reason.length > 200 ? "${reason.substring(0, 199)}…" : reason);
  }
  switch (error.status) {
    case 403:
      return l10n.p2pErrorForbidden;
    case 404:
      return l10n.p2pErrorNotFound;
    case 409:
      return l10n.p2pErrorConflict;
  }
  return l10n.p2pErrorInvalid;
}

String? _knownCode(AppLocalizations l10n, P2pError error) {
  switch (error.code) {
    // No usable answer.
    case P2pError.unreachable:
      return l10n.p2pErrorUnreachable;
    case P2pError.badResponse:
      return l10n.p2pErrorBadResponse;
    case 'server_error':
      return l10n.p2pErrorServer;
    case 'throttled':
      return l10n.p2pErrorThrottled;

    // Signing in.
    case P2pError.signInRefused:
      return l10n.p2pErrorSignInRefused;
    case P2pError.notAuthenticated:
    case P2pError.tokenInvalid:
    case P2pError.tokenExpired:
      return l10n.p2pErrorSignInExpired;

    // Reading.
    case 'shop_not_found':
      return l10n.p2pErrorShopNotFound;
    case 'not_found':
      return l10n.p2pErrorNotFound;

    // Bidding and buying now.
    case 'listing_not_live':
      return l10n.p2pErrorListingNotLive;
    case 'listing_unavailable':
      return l10n.p2pErrorListingUnavailable;
    case 'listing_not_started':
      return l10n.p2pErrorListingNotStarted;
    case 'listing_ended':
      return l10n.p2pErrorListingEnded;
    case 'seller_cannot_bid':
      return l10n.p2pErrorSellerCannotBid;
    case 'reserve_address':
      return l10n.p2pErrorReserveAddress;
    case 'no_buy_now':
      return l10n.p2pErrorNoBuyNow;
    case 'not_an_auction':
      return l10n.p2pErrorNotAnAuction;
    case 'amount_mismatch':
      return l10n.p2pErrorAmountMismatch;
    case 'bid_too_low':
      return l10n.p2pErrorBidTooLow;
    case 'use_buy_now':
      return l10n.p2pErrorUseBuyNow;
    case 'bad_signature':
      return l10n.p2pErrorBadSignature;
    case 'insufficient_balance':
      return l10n.p2pErrorInsufficientBalance;
    case 'duplicate_bid':
      return l10n.p2pErrorDuplicateBid;

    // Chain steps recorded as dry runs.
    case 'not_buyer':
      return l10n.p2pErrorNotBuyer;
    case 'not_seller':
      return l10n.p2pErrorNotSeller;
    case 'not_sender':
      return l10n.p2pErrorNotSender;
    case 'sale_on_chain':
      return l10n.p2pErrorSaleOnChain;
    case 'listing_not_sale_pending':
      return l10n.p2pErrorListingNotSalePending;
    case 'nft_moved':
      return l10n.p2pErrorNftMoved;
  }
  return null;
}
