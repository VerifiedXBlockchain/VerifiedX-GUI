import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/components/buttons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/p2p_error.dart';
import '../models/p2p_listing.dart';
import '../providers/p2p_listing_providers.dart';
import '../providers/p2p_seller_providers.dart';
import '../services/p2p_session.dart';
import '../services/p2p_signer.dart';
import '../utils/p2p_error_text.dart';
import 'p2p_listing_form.dart';

/// Shows everyone the listing as it stands after its seller changed it.
void _listingChanged(WidgetRef ref, String address, P2pListing listing) {
  refreshP2pSeller(ref, address);
  ref.invalidate(p2pListingDetailProvider(listing.id));
  ref.invalidate(p2pAllBidsProvider(listing.id));
}

/// Changes a listing's prices and dates, which the registry allows while it
/// is live with no bids. Sends the change itself and resolves the listing as
/// it now stands.
class P2pEditListingDialog extends ConsumerStatefulWidget {
  final P2pListing listing;
  final String address;

  const P2pEditListingDialog({super.key, required this.listing, required this.address});

  static Future<P2pListing?> show(BuildContext context, {required P2pListing listing, required String address}) {
    return showDialog<P2pListing>(
      context: context,
      barrierDismissible: false,
      builder: (_) => P2pEditListingDialog(listing: listing, address: address),
    );
  }

  @override
  ConsumerState<P2pEditListingDialog> createState() => _P2pEditListingDialogState();
}

class _P2pEditListingDialogState extends ConsumerState<P2pEditListingDialog> {
  bool _isSaving = false;
  Object? _error;

  Future<void> _save(P2pListingDraft draft) async {
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      final saved = await ref.read(p2pSellerProvider).updateListing(widget.address, widget.listing.id, draft.input);
      _listingChanged(ref, widget.address, saved);
      if (mounted) {
        Navigator.of(context).pop(saved);
      }
    } on P2pError catch (e) {
      _refused(e);
    } on P2pSigningError catch (e) {
      _refused(e);
    } on P2pSignInMismatch catch (e) {
      _refused(e);
    }
  }

  void _refused(Object error) {
    // A refusal usually means the listing changed: a bid came in, or it closed.
    _listingChanged(ref, widget.address, widget.listing);
    if (mounted) {
      setState(() {
        _error = error;
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final listing = widget.listing;
    return AlertDialog(
      backgroundColor: const Color(0xFF191b1d),
      title: Text(l10n.p2pListingEdit),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(listing.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 12),
            Flexible(
              child: P2pListingForm(
                smartContractUid: listing.smartContractUid,
                royalty: listing.nft?.royalty,
                editing: listing,
                submitLabel: l10n.p2pListingEditSave,
                busy: _isSaving,
                status: _error == null
                    ? null
                    : Text(
                        p2pErrorText(l10n, _error!),
                        key: const Key('p2p:list_error'),
                        style: TextStyle(color: Theme.of(context).colorScheme.danger, fontSize: 13),
                      ),
                onCancel: () => Navigator.of(context).pop(),
                onSubmit: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Asks before a listing is withdrawn, and withdraws it: no transaction,
/// since nothing of a listing is on chain before its sale starts. Resolves
/// the listing as it now stands (`cancelled`).
class P2pCancelListingDialog extends ConsumerStatefulWidget {
  final P2pListing listing;
  final String address;

  const P2pCancelListingDialog({super.key, required this.listing, required this.address});

  static Future<P2pListing?> show(BuildContext context, {required P2pListing listing, required String address}) {
    return showDialog<P2pListing>(
      context: context,
      barrierDismissible: false,
      builder: (_) => P2pCancelListingDialog(listing: listing, address: address),
    );
  }

  @override
  ConsumerState<P2pCancelListingDialog> createState() => _P2pCancelListingDialogState();
}

class _P2pCancelListingDialogState extends ConsumerState<P2pCancelListingDialog> {
  bool _isSending = false;
  Object? _error;

  Future<void> _cancel() async {
    setState(() {
      _isSending = true;
      _error = null;
    });
    try {
      final cancelled = await ref.read(p2pSellerProvider).cancelListing(widget.address, widget.listing.id);
      _listingChanged(ref, widget.address, cancelled);
      if (mounted) {
        Navigator.of(context).pop(cancelled);
      }
    } on P2pError catch (e) {
      _refused(e);
    } on P2pSigningError catch (e) {
      _refused(e);
    } on P2pSignInMismatch catch (e) {
      _refused(e);
    }
  }

  void _refused(Object error) {
    _listingChanged(ref, widget.address, widget.listing);
    if (mounted) {
      setState(() {
        _error = error;
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      backgroundColor: const Color(0xFF191b1d),
      title: Text(l10n.p2pListingCancel),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.p2pListingCancelBody(widget.listing.title)),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                p2pErrorText(l10n, _error!),
                key: const Key('p2p:listing_cancel_error'),
                style: TextStyle(color: Theme.of(context).colorScheme.danger, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
      actions: [
        AppButton(
          key: const Key('p2p:listing_cancel_keep'),
          label: l10n.actionBack,
          type: AppButtonType.Text,
          variant: AppColorVariant.Light,
          disabled: _isSending,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton(
          key: const Key('p2p:listing_cancel_confirm'),
          label: l10n.p2pListingCancel,
          variant: AppColorVariant.Danger,
          processing: _isSending,
          onPressed: _cancel,
        ),
      ],
    );
  }
}
