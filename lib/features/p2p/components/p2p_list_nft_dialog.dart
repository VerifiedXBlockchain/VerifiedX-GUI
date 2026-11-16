import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/components/buttons.dart';
import '../../../core/components/centered_loader.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/p2p_collection.dart';
import '../models/p2p_error.dart';
import '../models/p2p_listing.dart';
import '../models/p2p_owned_nft.dart';
import '../models/p2p_shop.dart';
import '../providers/p2p_listed_nfts_provider.dart';
import '../providers/p2p_seller_providers.dart';
import '../services/p2p_nft_source.dart';
import '../services/p2p_session.dart';
import '../services/p2p_signer.dart';
import '../utils/p2p_error_text.dart';
import '../utils/p2p_view.dart';
import 'p2p_listing_form.dart';
import 'p2p_parts.dart';

enum _Stage { idle, checkingMedia, uploadingMedia, posting }

/// Lists one of the account's NFTs in its shop: choose the NFT, set its
/// prices and dates, and post the listing. Listing is a record in the
/// registry, not a transaction, and costs nothing.
///
/// A listing's picture is the NFT's media in Spyglass. An NFT minted in this
/// wallet has none there, so its media is uploaded first, as its owner.
class P2pListNftDialog extends ConsumerStatefulWidget {
  final P2pShop shop;
  final String address;

  /// The NFT to list, when it was chosen before the dialog opened (from the
  /// NFT's own page, or "List again").
  final String? nftId;

  const P2pListNftDialog({super.key, required this.shop, required this.address, this.nftId});

  /// Resolves the new listing, or null when none was made.
  static Future<P2pListing?> show(BuildContext context, {required P2pShop shop, required String address, String? nftId}) {
    return showDialog<P2pListing>(
      context: context,
      barrierDismissible: false,
      builder: (_) => P2pListNftDialog(shop: shop, address: address, nftId: nftId),
    );
  }

  @override
  ConsumerState<P2pListNftDialog> createState() => _P2pListNftDialogState();
}

class _P2pListNftDialogState extends ConsumerState<P2pListNftDialog> {
  /// The NFT chosen in the picker; before any choice, [widget.nftId].
  String? _pickedId;

  /// Whether the person went back to the picker from the NFT they came with.
  bool _choosing = false;

  _Stage _stage = _Stage.idle;
  Object? _error;

  /// Whether the last try stopped because the NFT's media could not be
  /// uploaded: the listing can then be posted without a picture.
  bool _mediaFailed = false;

  /// The form, to submit it from the "without a picture" button: what is
  /// posted is what its fields say then, not what they said at the try that
  /// failed. A new one for each NFT chosen.
  GlobalKey<P2pListingFormState> _formKey = GlobalKey<P2pListingFormState>();

  /// Set while the form is being submitted from "List without a picture".
  bool _withoutPicture = false;

  @override
  void initState() {
    super.initState();
    _pickedId = widget.nftId;
  }

  Future<void> _submit(P2pOwnedNft nft, P2pListingDraft draft, {bool skipMedia = false}) async {
    if (_stage != _Stage.idle) {
      return;
    }
    final collectionId = draft.collectionId;
    if (collectionId == null) {
      // A shop always has its default collection: the registry's answer was
      // not what it should be.
      setState(() => _error = const P2pError(status: null, code: P2pError.badResponse));
      return;
    }
    final seller = ref.read(p2pSellerProvider);
    setState(() {
      _stage = skipMedia ? _Stage.posting : _Stage.checkingMedia;
      _error = null;
      _mediaFailed = false;
    });
    try {
      if (!skipMedia && !await seller.hasMedia(nft.id)) {
        if (!mounted) {
          return;
        }
        setState(() => _stage = _Stage.uploadingMedia);
        try {
          await seller.uploadMedia(widget.address, nft.id);
        } on P2pMediaUploadError {
          if (mounted) {
            setState(() {
              _stage = _Stage.idle;
              _mediaFailed = true;
            });
          }
          return;
        }
      }
      if (!mounted) {
        return;
      }
      setState(() => _stage = _Stage.posting);
      final listing = await seller.list(widget.address, collectionId, draft.input);
      refreshP2pSeller(ref, widget.address);
      if (mounted) {
        Navigator.of(context).pop(listing);
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
    if (mounted) {
      setState(() {
        _stage = _Stage.idle;
        _error = error;
      });
    }
  }

  String _blockText(AppLocalizations l10n, P2pNftBlock block) {
    switch (block) {
      case P2pNftBlock.notYours:
        return l10n.p2pListCannotNotYours;
      case P2pNftBlock.unsellable:
        return l10n.p2pListCannotUnsellable;
      case P2pNftBlock.notMinted:
        return l10n.p2pListCannotNotMinted;
      case P2pNftBlock.listed:
        return l10n.p2pListCannotListed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final nfts = ref.watch(p2pWalletNftsProvider);
    final collections = ref.watch(p2pOwnerCollectionsProvider(widget.address, widget.shop.url));
    final listed = ref.watch(p2pListedNftsProvider);

    return AlertDialog(
      backgroundColor: const Color(0xFF191b1d),
      title: Text(l10n.p2pListOpen),
      content: SizedBox(
        width: 520,
        child: nfts.when(
          loading: () => const SizedBox(height: 160, child: CenteredLoader()),
          error: (error, _) => P2pErrorView(error: error, onRetry: () => ref.invalidate(p2pWalletNftsProvider)),
          data: (all) => collections.when(
            loading: () => const SizedBox(height: 160, child: CenteredLoader()),
            error: (error, _) => P2pErrorView(
              error: error,
              onRetry: () => ref.invalidate(p2pOwnerCollectionsProvider(widget.address, widget.shop.url)),
            ),
            data: (collections) => _content(l10n, all, collections, listed),
          ),
        ),
      ),
      // The form carries its own buttons; the picker has only a way out.
      actions: _showsForm(nfts.valueOrNull, listed) && collections.hasValue
          ? null
          : [
              AppButton(
                key: const Key('p2p:list_close'),
                label: l10n.actionClose,
                type: AppButtonType.Text,
                variant: AppColorVariant.Light,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
    );
  }

  /// The chosen NFT, when it is in the wallet and this account can list it.
  P2pOwnedNft? _chosen(List<P2pOwnedNft>? all, Set<String> listed) {
    if (all == null || _choosing || _pickedId == null) {
      return null;
    }
    final found = all.where((n) => n.id == _pickedId);
    if (found.isEmpty) {
      return null;
    }
    return p2pNftBlock(found.first, address: widget.address, listed: listed) == null ? found.first : null;
  }

  bool _showsForm(List<P2pOwnedNft>? all, Set<String> listed) => _chosen(all, listed) != null;

  Widget _content(AppLocalizations l10n, List<P2pOwnedNft> all, List<P2pCollection> collections, Set<String> listed) {
    final chosen = _chosen(all, listed);
    if (chosen != null) {
      return _form(l10n, chosen, collections);
    }

    // Why the NFT the person came with cannot be listed, above the picker.
    String? cannot;
    if (!_choosing && _pickedId != null) {
      final found = all.where((n) => n.id == _pickedId);
      cannot = found.isEmpty
          ? l10n.p2pListCannotNotFound
          : _blockText(l10n, p2pNftBlock(found.first, address: widget.address, listed: listed)!);
    }
    final mine = all.where((n) => n.owner == widget.address).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (cannot != null) ...[
          Text(cannot, key: const Key('p2p:list_cannot'), style: const TextStyle(color: Colors.white70, fontSize: 13.5)),
          const SizedBox(height: 10),
        ],
        if (mine.isEmpty)
          P2pEmptyState(icon: Icons.image_not_supported_outlined, title: l10n.p2pListNoNfts, body: l10n.p2pListNoNftsBody)
        else ...[
          Text(l10n.p2pListPick, style: const TextStyle(color: p2pMuted, fontSize: 13)),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 380),
            child: ListView.builder(
              key: const Key('p2p:list_picker'),
              shrinkWrap: true,
              itemCount: mine.length,
              itemBuilder: (context, index) {
                final nft = mine[index];
                final block = p2pNftBlock(nft, address: widget.address, listed: listed);
                return _NftRow(
                  nft: nft,
                  block: block,
                  onTap: block != null
                      ? null
                      : () => setState(() {
                            _pickedId = nft.id;
                            _choosing = false;
                            _error = null;
                            _mediaFailed = false;
                            _formKey = GlobalKey<P2pListingFormState>();
                          }),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _form(AppLocalizations l10n, P2pOwnedNft nft, List<P2pCollection> collections) {
    final busy = _stage != _Stage.idle;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(8), child: SizedBox(width: 52, height: 52, child: _NftThumb(nft: nft))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nft.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  Text(
                    shortP2pAddress(nft.id, 10, 8),
                    style: const TextStyle(color: p2pMuted, fontSize: 12, fontFamily: 'RobotoMono'),
                  ),
                ],
              ),
            ),
            AppButton(
              key: const Key('p2p:list_change'),
              label: l10n.p2pListChange,
              type: AppButtonType.Text,
              variant: AppColorVariant.Light,
              disabled: busy,
              onPressed: () => setState(() => _choosing = true),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Flexible(
          child: P2pListingForm(
            key: _formKey,
            smartContractUid: nft.id,
            royalty: nft.royalty,
            collections: collections,
            submitLabel: l10n.p2pListForSale,
            busy: busy,
            status: _status(l10n, nft),
            onCancel: () => Navigator.of(context).pop(),
            onSubmit: (draft) => _submit(nft, draft, skipMedia: _withoutPicture),
          ),
        ),
      ],
    );
  }

  /// Posts the listing without its picture: the form is submitted again, so
  /// its fields are checked and read as they are now.
  void _listWithoutPicture() {
    _withoutPicture = true;
    try {
      _formKey.currentState?.submit();
    } finally {
      _withoutPicture = false;
    }
  }

  /// What the last submit is doing, or why it stopped.
  Widget? _status(AppLocalizations l10n, P2pOwnedNft nft) {
    if (_mediaFailed) {
      return Column(
        key: const Key('p2p:list_media_failed'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.p2pListMediaFailed, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.35)),
          const SizedBox(height: 6),
          AppButton(
            key: const Key('p2p:list_skip_media'),
            label: l10n.p2pListMediaSkip,
            type: AppButtonType.Outlined,
            variant: AppColorVariant.Light,
            size: AppSizeVariant.Sm,
            onPressed: _listWithoutPicture,
          ),
        ],
      );
    }
    if (_error != null) {
      return Text(
        p2pErrorText(l10n, _error!),
        key: const Key('p2p:list_error'),
        style: TextStyle(color: Theme.of(context).colorScheme.danger, fontSize: 13),
      );
    }
    switch (_stage) {
      case _Stage.checkingMedia:
        return Text(l10n.p2pListMediaChecking, key: const Key('p2p:list_stage'), style: const TextStyle(color: p2pMuted, fontSize: 13));
      case _Stage.uploadingMedia:
        return Text(l10n.p2pListMediaUploading, key: const Key('p2p:list_stage'), style: const TextStyle(color: p2pMuted, fontSize: 13));
      case _Stage.posting:
      case _Stage.idle:
        return null;
    }
  }
}

/// An NFT's own picture from this disk, or a placeholder.
class _NftThumb extends StatelessWidget {
  final P2pOwnedNft nft;

  const _NftThumb({required this.nft});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: p2pSurfaceRaised,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: p2pMuted, size: 20),
    );
    final path = nft.imagePath;
    if (path == null) {
      return placeholder;
    }
    return Image.file(File(path), fit: BoxFit.cover, errorBuilder: (_, __, ___) => placeholder);
  }
}

class _NftRow extends StatelessWidget {
  final P2pOwnedNft nft;
  final P2pNftBlock? block;
  final VoidCallback? onTap;

  const _NftRow({required this.nft, required this.block, required this.onTap});

  String? _tag(AppLocalizations l10n) {
    switch (block) {
      case P2pNftBlock.listed:
        return l10n.p2pListTagListed;
      case P2pNftBlock.unsellable:
        return l10n.p2pListTagUnsellable;
      case P2pNftBlock.notMinted:
        return l10n.p2pListTagNotMinted;
      case P2pNftBlock.notYours:
      case null:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tag = _tag(l10n);
    return Semantics(
      button: onTap != null,
      enabled: onTap != null,
      child: InkWell(
        key: Key('p2p:list_pick:${nft.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Opacity(
          opacity: onTap == null ? 0.55 : 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Row(
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(6), child: SizedBox(width: 44, height: 44, child: _NftThumb(nft: nft))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nft.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(
                        shortP2pAddress(nft.id, 10, 8),
                        style: const TextStyle(color: p2pMuted, fontSize: 11.5, fontFamily: 'RobotoMono'),
                      ),
                    ],
                  ),
                ),
                if (tag != null) P2pTag(label: tag, color: Colors.white70) else const Icon(Icons.chevron_right, color: p2pMuted, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
