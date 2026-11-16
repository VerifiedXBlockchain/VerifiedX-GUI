import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/components/buttons.dart';
import '../../../core/components/centered_loader.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/p2p_collection.dart';
import '../models/p2p_error.dart';
import '../models/p2p_shop.dart';
import '../providers/p2p_seller_providers.dart';
import '../services/p2p_session.dart';
import '../services/p2p_signer.dart';
import '../utils/p2p_error_text.dart';
import '../utils/p2p_rules.dart';
import 'p2p_parts.dart';

/// The owner's collections in My shop: add one, rename it, hide or show it,
/// delete it. Collections are records in the registry, not transactions.
/// Hiding one takes its listings out of the shop and stops bids on them.
class P2pCollectionsSection extends ConsumerStatefulWidget {
  final P2pShop shop;
  final String address;

  const P2pCollectionsSection({super.key, required this.shop, required this.address});

  @override
  ConsumerState<P2pCollectionsSection> createState() => _P2pCollectionsSectionState();
}

class _P2pCollectionsSectionState extends ConsumerState<P2pCollectionsSection> {
  /// Why the last change did not go through.
  Object? _error;

  /// The collection a change is being sent for.
  int? _busyId;

  Future<void> _open({P2pCollection? collection}) async {
    final saved = await showDialog<P2pCollection>(
      context: context,
      builder: (_) => _CollectionDialog(shop: widget.shop, address: widget.address, collection: collection),
    );
    if (saved != null && mounted) {
      setState(() => _error = null);
      refreshP2pSeller(ref, widget.address);
    }
  }

  /// Sends one change for [collection] and reads the shop again.
  Future<void> _change(P2pCollection collection, Future<void> Function() change) async {
    setState(() {
      _busyId = collection.id;
      _error = null;
    });
    try {
      await change();
      refreshP2pSeller(ref, widget.address);
    } on P2pError catch (e) {
      _refused(e);
    } on P2pSigningError catch (e) {
      _refused(e);
    } on P2pSignInMismatch catch (e) {
      _refused(e);
    } finally {
      if (mounted) {
        setState(() => _busyId = null);
      }
    }
  }

  void _refused(Object error) {
    if (mounted) {
      setState(() => _error = error);
    }
  }

  Future<void> _toggle(P2pCollection collection) {
    final seller = ref.read(p2pSellerProvider);
    return _change(collection, () => seller.updateCollection(widget.address, collection.id, isLive: !collection.isLive));
  }

  Future<void> _delete(AppLocalizations l10n, P2pCollection collection) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF191b1d),
        title: Text(l10n.p2pCollectionDelete),
        content: SizedBox(width: 400, child: Text(l10n.p2pCollectionDeleteBody(collection.name))),
        actions: [
          AppButton(
            key: const Key('p2p:collection_delete_cancel'),
            label: l10n.actionCancel,
            type: AppButtonType.Text,
            variant: AppColorVariant.Light,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          AppButton(
            key: const Key('p2p:collection_delete_confirm'),
            label: l10n.actionDelete,
            variant: AppColorVariant.Danger,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    final seller = ref.read(p2pSellerProvider);
    await _change(collection, () => seller.deleteCollection(widget.address, collection.id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = p2pOwnerCollectionsProvider(widget.address, widget.shop.url);
    final collections = ref.watch(provider);

    return Container(
      key: const Key('p2p:collections'),
      padding: const EdgeInsets.all(16),
      decoration: p2pCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(l10n.p2pCollectionsTitle, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
              AppButton(
                key: const Key('p2p:collection_new'),
                label: l10n.p2pCollectionNew,
                icon: Icons.add,
                type: AppButtonType.Outlined,
                variant: AppColorVariant.Light,
                size: AppSizeVariant.Sm,
                onPressed: () => _open(),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              p2pErrorText(l10n, _error!),
              key: const Key('p2p:collections_error'),
              style: TextStyle(color: Theme.of(context).colorScheme.danger, fontSize: 13),
            ),
          ],
          const SizedBox(height: 8),
          collections.when(
            loading: () => const Padding(padding: EdgeInsets.all(16), child: CenteredLoader()),
            error: (error, _) => P2pErrorView(error: error, onRetry: () => ref.invalidate(provider)),
            data: (collections) => Column(
              children: [
                for (final collection in collections)
                  _CollectionRow(
                    collection: collection,
                    busy: _busyId == collection.id,
                    onEdit: () => _open(collection: collection),
                    onToggle: () => _toggle(collection),
                    onDelete: () => _delete(l10n, collection),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionRow extends StatelessWidget {
  final P2pCollection collection;
  final bool busy;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _CollectionRow({
    required this.collection,
    required this.busy,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final id = collection.id;
    return Container(
      key: Key('p2p:collection_row:$id'),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: p2pBorder))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      collection.name,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5, color: collection.isLive ? Colors.white : p2pMuted),
                    ),
                    if (collection.isDefault) P2pTag(label: l10n.p2pCollectionDefault, color: p2pBrand()),
                    if (!collection.isLive) P2pTag(label: l10n.p2pCollectionHidden, color: Colors.white70, icon: Icons.visibility_off_outlined),
                    Text(l10n.p2pCollectionListings(collection.listingCount), style: const TextStyle(color: p2pMuted, fontSize: 12.5)),
                  ],
                ),
                if (collection.description.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      collection.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: p2pMuted, fontSize: 12.5),
                    ),
                  ),
              ],
            ),
          ),
          if (busy)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else ...[
            IconButton(
              key: Key('p2p:collection_edit:$id'),
              tooltip: l10n.p2pCollectionEdit,
              icon: const Icon(Icons.edit_outlined, size: 19),
              onPressed: onEdit,
            ),
            IconButton(
              key: Key('p2p:collection_toggle:$id'),
              tooltip: collection.isLive ? l10n.p2pCollectionHide : l10n.p2pCollectionShow,
              icon: Icon(collection.isLive ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 19),
              onPressed: onToggle,
            ),
            IconButton(
              key: Key('p2p:collection_delete:$id'),
              tooltip: collection.isDefault ? l10n.p2pCollectionDefaultStays : l10n.p2pCollectionDelete,
              icon: const Icon(Icons.delete_outline, size: 19),
              onPressed: collection.isDefault ? null : onDelete,
            ),
          ],
        ],
      ),
    );
  }
}

/// A collection's name and description: a new one, or one to change. Sends
/// the change itself and resolves the collection as the registry now has it.
class _CollectionDialog extends ConsumerStatefulWidget {
  final P2pShop shop;
  final String address;

  /// The collection to change, or null for a new one.
  final P2pCollection? collection;

  const _CollectionDialog({required this.shop, required this.address, this.collection});

  @override
  ConsumerState<_CollectionDialog> createState() => _CollectionDialogState();
}

class _CollectionDialogState extends ConsumerState<_CollectionDialog> {
  late final TextEditingController _name = TextEditingController(text: widget.collection?.name ?? '');
  late final TextEditingController _description = TextEditingController(text: widget.collection?.description ?? '');
  bool _isSaving = false;
  Object? _error;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  bool get _canSave => _name.text.trim().isNotEmpty && !_isSaving;

  Future<void> _save() async {
    if (!_canSave) {
      return;
    }
    setState(() {
      _isSaving = true;
      _error = null;
    });
    final seller = ref.read(p2pSellerProvider);
    final existing = widget.collection;
    final name = _name.text.trim();
    final description = _description.text.trim();
    try {
      final saved = existing == null
          ? await seller.createCollection(widget.address, widget.shop.url, name: name, description: description)
          : await seller.updateCollection(widget.address, existing.id, name: name, description: description);
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
    final isNew = widget.collection == null;
    return AlertDialog(
      backgroundColor: const Color(0xFF191b1d),
      title: Text(isNew ? l10n.p2pCollectionNew : l10n.p2pCollectionEdit),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const Key('p2p:collection_name'),
              controller: _name,
              autofocus: true,
              maxLength: p2pShopNameMax,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _save(),
              decoration: InputDecoration(labelText: l10n.p2pCollectionName, counterText: ''),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('p2p:collection_description'),
              controller: _description,
              minLines: 2,
              maxLines: 4,
              maxLength: p2pShopDescriptionMaxChars,
              decoration: InputDecoration(labelText: l10n.p2pCollectionDescription, alignLabelWithHint: true, counterText: ''),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                p2pErrorText(l10n, _error!),
                key: const Key('p2p:collection_error'),
                style: TextStyle(color: Theme.of(context).colorScheme.danger, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
      actions: [
        AppButton(
          key: const Key('p2p:collection_cancel'),
          label: l10n.actionCancel,
          type: AppButtonType.Text,
          variant: AppColorVariant.Light,
          disabled: _isSaving,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton(
          key: const Key('p2p:collection_save'),
          label: isNew ? l10n.p2pCollectionCreate : l10n.p2pCollectionSave,
          processing: _isSaving,
          disabled: !_canSave,
          onPressed: _save,
        ),
      ],
    );
  }
}
