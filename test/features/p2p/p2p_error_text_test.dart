import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_error.dart';
import 'package:rbx_wallet/features/p2p/services/p2p_session.dart';
import 'package:rbx_wallet/features/p2p/services/p2p_signer.dart';
import 'package:rbx_wallet/features/p2p/utils/p2p_error_text.dart';
import 'package:rbx_wallet/l10n/generated/app_localizations.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final es = lookupAppLocalizations(const Locale('es'));

  String text(String code, {int? status = 400, String message = 'The server said this.'}) {
    return p2pErrorText(en, P2pError(status: status, code: code, message: message));
  }

  test('every refusal a bid or a buy-now offer can get is worded by this wallet', () {
    // p2p/services.py place_bid, in the order it checks.
    const bidCodes = {
      'listing_not_live': 409,
      'listing_unavailable': 409,
      'listing_not_started': 409,
      'listing_ended': 409,
      'seller_cannot_bid': 403,
      'reserve_address': 403,
      'no_buy_now': 400,
      'amount_mismatch': 400,
      'not_an_auction': 400,
      'bid_too_low': 400,
      'use_buy_now': 400,
      'bad_signature': 400,
      'insufficient_balance': 400,
      'duplicate_bid': 409,
    };
    final seen = <String>{};
    bidCodes.forEach((code, status) {
      final worded = text(code, status: status);
      expect(worded, isNot(contains('The server said this.')), reason: code);
      expect(worded, isNot(en.p2pErrorUnknown), reason: code);
      expect(seen.add(worded), isTrue, reason: '$code has the same words as another code');

      final spanish = p2pErrorText(es, P2pError(status: status, code: code, message: 'The server said this.'));
      expect(spanish, isNot(worded), reason: '$code is not translated');
    });
  });

  test('the refusals named in the plan read as written', () {
    expect(text('bid_too_low'), 'Your bid is below the next minimum bid. Someone may have bid just before you.');
    expect(text('use_buy_now'), 'At the buy-now price or more, use Buy now.');
    expect(text('insufficient_balance'), 'This account’s balance does not cover the amount.');
    expect(text('listing_not_live', status: 409), 'This listing is not taking bids any more.');
    expect(text('bad_signature'), 'The shop registry could not verify this account’s signature. Try again.');
  });

  test('a sign-in that is missing, unknown or expired asks to try again', () {
    for (final code in [P2pError.notAuthenticated, P2pError.tokenInvalid, P2pError.tokenExpired]) {
      expect(text(code, status: 401), en.p2pErrorSignInExpired, reason: code);
    }
    // A 401 with a code this build does not know is still a sign-in problem.
    expect(text('token_revoked', status: 401), en.p2pErrorSignInExpired);
    expect(text(P2pError.signInRefused), en.p2pErrorSignInRefused);
  });

  test('no answer, a bad answer, a server error and throttling are told apart', () {
    expect(text(P2pError.unreachable, status: null, message: ''), en.p2pErrorUnreachable);
    expect(text(P2pError.badResponse, status: null, message: ''), en.p2pErrorBadResponse);
    expect(text('server_error', status: 500, message: 'Server error'), en.p2pErrorServer);
    expect(text('throttled', status: 429), en.p2pErrorThrottled);
  });

  test('not found is worded for a shop and for anything else', () {
    expect(text('shop_not_found', status: 404), en.p2pErrorShopNotFound);
    expect(text('not_found', status: 404), en.p2pErrorNotFound);
  });

  test('a code this build does not know shows the registry\'s own message', () {
    expect(text('nft_on_loan', status: 409, message: 'This NFT is out on loan.'), 'The shop registry refused it: This NFT is out on loan.');
  });

  test('a seller\'s refusals for collections and listings are worded', () {
    expect(text('default_collection', status: 409), en.p2pErrorDefaultCollection);
    expect(text('collection_has_active_listings', status: 409), en.p2pErrorCollectionHasListings);
    expect(text('price_required'), en.p2pErrorPriceRequired);
    expect(text('nft_not_found'), en.p2pErrorNftNotFound);
    expect(text('nft_not_listable'), en.p2pErrorNftNotListable);
    expect(text('nft_already_listed', status: 409), en.p2pErrorNftAlreadyListed);
    expect(text('not_nft_owner', status: 403), en.p2pErrorNotNftOwner);
    expect(text('try_again', status: 409), en.p2pErrorTryAgain);
    expect(text('listing_has_bids', status: 409), en.p2pErrorListingHasBids);
    expect(text('listing_closed', status: 409), en.p2pErrorListingClosed);
    expect(text('sale_pending', status: 409), en.p2pErrorSalePending);
  });

  test('a very long message is cut', () {
    final worded = text('mystery', message: 'x' * 500);
    expect(worded.length, lessThan(260));
    expect(worded, endsWith('…'));
  });

  test('an unknown code with no message is worded by its status', () {
    expect(text('mystery', status: 403, message: ''), en.p2pErrorForbidden);
    expect(text('mystery', status: 404, message: ''), en.p2pErrorNotFound);
    expect(text('mystery', status: 409, message: ''), en.p2pErrorConflict);
    expect(text('mystery', status: 400, message: ''), en.p2pErrorInvalid);
  });

  test('a signing failure says what went wrong with the wallet', () {
    expect(p2pErrorText(en, const P2pSigningError(P2pSigningFailure.notInWallet)), en.p2pErrorSignNotInWallet);
    expect(p2pErrorText(en, const P2pSigningError(P2pSigningFailure.walletLocked)), en.errWalletLocked);
    expect(p2pErrorText(en, const P2pSigningError(P2pSigningFailure.unreachable)), en.p2pErrorSignUnreachable);
    expect(p2pErrorText(en, const P2pSigningError(P2pSigningFailure.unexpected)), en.p2pErrorSignUnexpected);
  });

  test('a sign-in for the wrong address and anything unexpected are worded too', () {
    expect(p2pErrorText(en, const P2pSignInMismatch()), en.p2pErrorSignInRefused);
    expect(p2pErrorText(en, StateError('boom')), en.p2pErrorUnknown);
  });
}
