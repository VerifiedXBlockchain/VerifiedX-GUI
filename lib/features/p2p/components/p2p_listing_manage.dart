import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_router.gr.dart';
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
import '../utils/p2p_view.dart';
import 'p2p_chain_step_dialog.dart';
import 'p2p_listing_form.dart';
import 'p2p_parts.dart';

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

/// Opens the confirmation for the seller's `Sale_Start()` on [listing],
/// whose winner is chosen, and carries it out on Confirm. It hands the NFT's
/// contract to the winner at the winning bid; the buyer then pays with
/// `Sale_Complete()`. While chain steps are dry runs it is recorded with the
/// registry; nothing is signed or sent.
Future<void> startP2pSale(WidgetRef ref, AppLocalizations l10n, P2pListing listing) async {
  final steps = ref.read(p2pChainStepsProvider);
  final buyer = listing.winnerAddress;
  final price = listing.highBid?.amount;
  await P2pChainStepDialog.show(
    title: l10n.p2pSaleStart,
    rows: [
      P2pStepRow(l10n.p2pChainRowNft, listing.title),
      if (buyer != null) P2pStepRow(l10n.p2pChainRowBuyer, shortP2pAddress(buyer), mono: true),
      if (price != null) P2pStepRow(l10n.p2pChainRowPrice, p2pVfxText(l10n, price), mono: true),
    ],
    describe: () => steps.describeStartSale(listing),
    carryOut: (tx) async => _listingChanged(ref, listing.sellerAddress, await steps.startSale(listing, tx)),
    doneBody: listing.title,
  );
}

/// Opens the confirmation for the seller's `Sale_Cancel()` of [listing]'s
/// started sale, and carries it out on Confirm. A started sale has no time
/// limit: if the buyer never completes it, only this frees the NFT.
Future<void> cancelP2pSale(WidgetRef ref, AppLocalizations l10n, P2pListing listing) async {
  final steps = ref.read(p2pChainStepsProvider);
  final buyer = listing.winnerAddress;
  await P2pChainStepDialog.show(
    title: l10n.p2pSaleCancel,
    rows: [
      P2pStepRow(l10n.p2pChainRowNft, listing.title),
      if (buyer != null) P2pStepRow(l10n.p2pChainRowBuyer, shortP2pAddress(buyer), mono: true),
    ],
    warning: l10n.p2pSaleCancelWarning,
    describe: () => steps.describeSaleCancellation(listing),
    carryOut: (tx) async => _listingChanged(ref, listing.sellerAddress, await steps.cancelSale(listing, tx)),
    doneBody: listing.title,
  );
}

/// What a seller can do with a listing of theirs, as buttons: in a row of My
/// shop ([compact]) and on the listing's own page.
class P2pSellerButtons extends ConsumerWidget {
  final P2pListing listing;

  /// The seller: the account the buttons act for.
  final String address;

  /// Opens "List an NFT" for an NFT, where the shop is on screen. Elsewhere
  /// "List again" leaves the request for My shop and goes there.
  final void Function(String nftId)? onListAgain;
  final bool compact;

  const P2pSellerButtons({
    super.key,
    required this.listing,
    required this.address,
    this.onListAgain,
    this.compact = false,
  });

  void _listAgain(BuildContext context, WidgetRef ref) {
    final again = onListAgain;
    if (again != null) {
      again(listing.smartContractUid);
      return;
    }
    ref.read(p2pListRequestProvider.notifier).state = listing.smartContractUid;
    AutoRouter.of(context).push(const P2pMyShopScreenRoute());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final actions = P2pSellerActions.of(listing);
    final size = compact ? AppSizeVariant.Sm : AppSizeVariant.Md;
    final id = listing.id;

    AppButton quiet(String key, String label, IconData icon, VoidCallback onPressed) {
      return AppButton(
        key: Key(key),
        label: label,
        icon: icon,
        type: AppButtonType.Outlined,
        variant: AppColorVariant.Light,
        size: size,
        onPressed: onPressed,
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      alignment: compact ? WrapAlignment.end : WrapAlignment.start,
      children: [
        if (actions.startSale)
          AppButton(
            key: Key('p2p:sale_start:$id'),
            label: l10n.p2pSaleStart,
            icon: Icons.play_arrow,
            size: size,
            onPressed: () => startP2pSale(ref, l10n, listing),
          ),
        if (actions.editListing)
          quiet('p2p:listing_edit:$id', l10n.p2pListingEdit, Icons.edit_outlined, () => P2pEditListingDialog.show(context, listing: listing, address: address)),
        if (actions.cancelListing)
          quiet('p2p:listing_cancel:$id', l10n.p2pListingCancel, Icons.close, () => P2pCancelListingDialog.show(context, listing: listing, address: address)),
        if (actions.cancelSale) quiet('p2p:sale_cancel:$id', l10n.p2pSaleCancel, Icons.undo, () => cancelP2pSale(ref, l10n, listing)),
        if (actions.listAgain) quiet('p2p:listing_again:$id', l10n.p2pListingListAgain, Icons.replay, () => _listAgain(context, ref)),
      ],
    );
  }
}
