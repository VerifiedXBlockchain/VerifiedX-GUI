import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../../../core/components/buttons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/p2p_bid_summary.dart';
import '../models/p2p_error.dart';
import '../models/p2p_listing.dart';
import '../providers/p2p_browse_providers.dart';
import '../providers/p2p_listing_providers.dart';
import '../services/p2p_session.dart';
import '../services/p2p_signer.dart';
import '../utils/p2p_amount.dart';
import '../utils/p2p_error_text.dart';
import 'p2p_parts.dart';

enum P2pBidMode { bid, buyNow }

/// Bids on a listing, or takes its buy-now price. Either is a message the
/// selected account signs through Core, not a transaction: the dialog says so
/// before the signature and shows the result after it.
class P2pBidDialog extends ConsumerStatefulWidget {
  final int listingId;
  final String address;
  final P2pBidMode mode;

  const P2pBidDialog({
    super.key,
    required this.listingId,
    required this.address,
    required this.mode,
  });

  static Future<void> show({
    required int listingId,
    required String address,
    required P2pBidMode mode,
  }) {
    return showDialog<void>(
      context: rootNavigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (_) => P2pBidDialog(listingId: listingId, address: address, mode: mode),
    );
  }

  @override
  ConsumerState<P2pBidDialog> createState() => _P2pBidDialogState();
}

class _P2pBidDialogState extends ConsumerState<P2pBidDialog> {
  final TextEditingController _amountController = TextEditingController();
  bool _isSubmitting = false;

  /// Whether Submit was pressed: the field's error shows from then on.
  bool _tried = false;
  Object? _error;
  P2pBidResult? _result;

  bool get _isBid => widget.mode == P2pBidMode.bid;

  @override
  void initState() {
    super.initState();
    if (_isBid) {
      final listing = ref.read(p2pListingDetailProvider(widget.listingId)).valueOrNull;
      final minimum = P2pAmount.tryParse(listing?.nextMinBid ?? listing?.floorPrice);
      if (minimum != null) {
        _amountController.text = minimum.toDecimalString();
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  P2pAmount? get _balance {
    final balance = ref.read(p2pViewerBalanceProvider);
    return balance == null || !balance.isFinite || balance < 0 ? null : P2pAmount.fromDouble(balance);
  }

  /// The typed bid checked against [listing]: the amount, or why not.
  _TypedBid _typed(AppLocalizations l10n, P2pListing listing) {
    final input = P2pAmountInput.read(_amountController.text);
    final minimum = P2pAmount.tryParse(listing.nextMinBid ?? listing.floorPrice);
    final buyNow = P2pAmount.tryParse(listing.buyNowPrice);
    final tooLow = minimum == null ? l10n.p2pBidErrorFormat : l10n.p2pBidErrorTooLow(p2pVfxText(l10n, minimum.toDecimalString()));
    switch (input.error) {
      case P2pAmountInputError.empty:
        return _TypedBid.error(l10n.p2pBidErrorEmpty);
      case P2pAmountInputError.format:
        return _TypedBid.error(l10n.p2pBidErrorFormat);
      case P2pAmountInputError.decimals:
        return _TypedBid.error(l10n.p2pBidErrorDecimals);
      case P2pAmountInputError.zero:
        return _TypedBid.error(tooLow);
      case null:
        break;
    }
    final amount = input.amount!;
    if (minimum != null && amount < minimum) {
      return _TypedBid.error(tooLow);
    }
    if (buyNow != null && amount >= buyNow) {
      return _TypedBid.error(l10n.p2pBidErrorUseBuyNow(p2pVfxText(l10n, buyNow.toDecimalString())));
    }
    final balance = _balance;
    if (balance != null && amount > balance) {
      return _TypedBid.error(l10n.p2pBidErrorBalance);
    }
    return _TypedBid.amount(amount);
  }

  /// Whether the buy-now price is more than the selected account can spend.
  bool _cannotAffordBuyNow(P2pListing listing) {
    final buyNow = P2pAmount.tryParse(listing.buyNowPrice);
    final balance = _balance;
    return !_isBid && buyNow != null && balance != null && buyNow > balance;
  }

  Future<void> _submit(P2pListing listing) async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _tried = true;
      _error = null;
    });

    final P2pAmount? amount;
    if (_isBid) {
      amount = _typed(l10n, listing).amount;
    } else {
      amount = P2pAmount.tryParse(listing.buyNowPrice);
    }
    if (amount == null || _isSubmitting) {
      return;
    }

    setState(() => _isSubmitting = true);
    final detail = ref.read(p2pListingDetailProvider(widget.listingId).notifier);
    try {
      final result = await ref.read(p2pBidderProvider).place(
            listingId: widget.listingId,
            address: widget.address,
            amount: amount,
            isBuyNow: !_isBid,
            balance: _balance,
          );
      detail.replace(result.listing);
      if (mounted) {
        setState(() => _result = result);
      }
    } on P2pError catch (e) {
      _refused(e, detail);
    } on P2pSigningError catch (e) {
      _refused(e, detail);
    } on P2pSignInMismatch catch (e) {
      _refused(e, detail);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  /// Shows why the bid did not go through, and reads the listing again: a
  /// refusal usually means it changed (a higher bid, a sale).
  void _refused(Object error, P2pListingDetail detail) {
    detail.refresh();
    if (mounted) {
      setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final listing = ref.watch(p2pListingDetailProvider(widget.listingId)).valueOrNull;

    return AlertDialog(
      backgroundColor: const Color(0xFF191b1d),
      title: Text(_isBid ? l10n.p2pBidTitle : l10n.p2pBuyTitle),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: _result != null
              ? _placed(l10n, _result!)
              : listing == null
                  ? Text(l10n.p2pListingNotFound)
                  : _form(l10n, listing),
        ),
      ),
      actions: _result != null || listing == null
          ? [
              AppButton(
                key: const Key('p2p:bid_done'),
                label: l10n.actionDone,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ]
          : [
              AppButton(
                key: const Key('p2p:bid_cancel'),
                label: l10n.actionCancel,
                type: AppButtonType.Text,
                variant: AppColorVariant.Light,
                disabled: _isSubmitting,
                onPressed: () => Navigator.of(context).pop(),
              ),
              AppButton(
                key: const Key('p2p:bid_submit'),
                label: _isSubmitting
                    ? l10n.p2pBidSigning
                    : _isBid
                        ? l10n.p2pBidSubmit
                        : l10n.p2pBuySubmit,
                icon: Icons.draw_outlined,
                processing: _isSubmitting,
                disabled: _cannotAffordBuyNow(listing),
                onPressed: () => _submit(listing),
              ),
            ],
    );
  }

  Widget _form(AppLocalizations l10n, P2pListing listing) {
    final balance = ref.watch(p2pViewerBalanceProvider);
    final minimum = listing.nextMinBid ?? listing.floorPrice;
    final typed = _isBid ? _typed(l10n, listing) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(width: 52, height: 52, child: P2pListingThumb(listing: listing)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  Text(
                    "vfx://${listing.shopUrl}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: p2pBrand(), fontFamily: 'RobotoMono', fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isBid) ...[
          TextField(
            key: const Key('p2p:bid_amount'),
            controller: _amountController,
            autofocus: true,
            enabled: !_isSubmitting,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 20),
            onChanged: (_) => setState(() => _error = null),
            onSubmitted: (_) => _submit(listing),
            decoration: InputDecoration(
              labelText: l10n.p2pBidAmountLabel,
              helperText: minimum == null ? null : l10n.p2pBidMin(p2pVfxText(l10n, minimum)),
              errorText: _tried ? typed?.error : null,
              errorMaxLines: 2,
            ),
          ),
          if (listing.highBid != null) ...[
            const SizedBox(height: 10),
            _row(l10n.p2pPriceCurrentBid, p2pVfxText(l10n, listing.highBid!.amount)),
          ],
        ] else if (listing.buyNowPrice != null)
          P2pPrice(label: l10n.p2pPriceBuyNow, amount: listing.buyNowPrice!, large: true),
        if (balance != null) ...[
          const SizedBox(height: 8),
          _row(l10n.p2pBidAvailable, p2pVfxText(l10n, P2pAmount.fromDouble(balance < 0 ? 0 : balance).toDecimalString())),
        ],
        if (_cannotAffordBuyNow(listing)) ...[
          const SizedBox(height: 10),
          _notice(l10n.p2pBidErrorBalance, danger: true),
        ],
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: p2pSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: p2pBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.draw_outlined, size: 16, color: p2pBrand()),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isBid ? l10n.p2pBidSignNote : l10n.p2pBuySignNote,
                  key: const Key('p2p:bid_sign_note'),
                  style: const TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.35),
                ),
              ),
            ],
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          _notice(p2pErrorText(l10n, _error!), danger: true, key: const Key('p2p:bid_error')),
        ],
      ],
    );
  }

  Widget _placed(AppLocalizations l10n, P2pBidResult result) {
    final amount = p2pVfxText(l10n, result.bid.amount);
    final String body;
    if (!_isBid) {
      body = l10n.p2pBuyDoneBody;
    } else if (result.bid.status == P2pBidStatus.accepted) {
      body = l10n.p2pBidDoneReserve(amount);
    } else {
      body = l10n.p2pBidDoneBody(amount);
    }
    final success = AppColors.getSpringGreen(ColorShade.s50);
    return Column(
      key: const Key('p2p:bid_placed'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Icon(Icons.check_circle_outline, size: 44, color: success),
        const SizedBox(height: 10),
        Text(
          _isBid ? l10n.p2pBidDone : l10n.p2pBuyDone,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(body, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: p2pMuted, fontSize: 13)),
        Text(value, style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 13)),
      ],
    );
  }

  Widget _notice(String text, {bool danger = false, Key? key}) {
    final color = danger ? AppColors.getSanguine(ColorShade.s50) : Colors.white70;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(text, key: key, style: TextStyle(color: color, fontSize: 13, height: 1.35)),
    );
  }
}

class _TypedBid {
  final P2pAmount? amount;
  final String? error;

  const _TypedBid.amount(P2pAmount this.amount) : error = null;
  const _TypedBid.error(String this.error) : amount = null;
}
