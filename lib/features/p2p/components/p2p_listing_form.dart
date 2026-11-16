import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/components/buttons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/p2p_collection.dart';
import '../models/p2p_listing.dart';
import '../utils/p2p_view.dart';
import 'p2p_parts.dart';

/// What the listing form resolves: the listing's prices and dates, and the
/// collection it goes in (null when an existing listing is changed, which
/// stays where it is).
class P2pListingDraft {
  final P2pListingInput input;
  final int? collectionId;

  const P2pListingDraft({required this.input, this.collectionId});
}

/// A listing's prices and dates: for a new listing of [smartContractUid], or
/// to change [editing]. Fixed price or auction; an auction has a starting
/// bid and may have a reserve and a buy-now price. It opens now or at a
/// chosen time and closes a number of days later, or at a chosen time.
///
/// The form only checks what the registry would refuse outright (the rules
/// in `P2pListingFormCheck`); posting is the caller's.
class P2pListingForm extends ConsumerStatefulWidget {
  /// The days a listing can be set to close after.
  static const List<int> dayChoices = [1, 3, 7, 14, 30];

  final String smartContractUid;
  final P2pRoyalty? royalty;

  /// The shop's collections to choose from; empty when [editing].
  final List<P2pCollection> collections;
  final P2pListing? editing;
  final String submitLabel;

  /// Whether the caller is at work on the last submit.
  final bool busy;

  /// The caller's progress or refusal, shown above the buttons.
  final Widget? status;
  final ValueChanged<P2pListingDraft> onSubmit;
  final VoidCallback onCancel;

  const P2pListingForm({
    super.key,
    required this.smartContractUid,
    required this.submitLabel,
    required this.onSubmit,
    required this.onCancel,
    this.royalty,
    this.collections = const [],
    this.editing,
    this.busy = false,
    this.status,
  });

  @override
  ConsumerState<P2pListingForm> createState() => _P2pListingFormState();
}

class _P2pListingFormState extends ConsumerState<P2pListingForm> {
  late bool _auction;
  late final TextEditingController _price;
  late final TextEditingController _floor;
  late final TextEditingController _reserve;
  late final TextEditingController _buyNow;

  /// Whether it opens at a chosen time, not now.
  bool _later = false;
  DateTime? _startsAt;

  /// The days it closes after; null when it closes at [_endsAt].
  int? _days = 7;
  DateTime? _endsAt;
  int? _collectionId;

  /// Errors show once a submit was tried.
  bool _tried = false;

  DateTime get _now => ref.read(p2pClockProvider)();

  /// Whether the listing being changed has opened already: its start stays.
  bool get _alreadyOpen {
    final starts = widget.editing?.startsAt;
    return starts != null && !starts.isAfter(_now);
  }

  @override
  void initState() {
    super.initState();
    final editing = widget.editing;
    _auction = editing?.isAuction ?? false;
    _price = TextEditingController(text: editing != null && !editing.isAuction ? editing.buyNowPrice ?? '' : '');
    _floor = TextEditingController(text: editing?.floorPrice ?? '');
    _reserve = TextEditingController(text: editing?.reservePrice ?? '');
    _buyNow = TextEditingController(text: editing != null && editing.isAuction ? editing.buyNowPrice ?? '' : '');
    if (editing != null) {
      _days = null;
      _endsAt = editing.endsAt;
      if (!_alreadyOpen) {
        _later = true;
        _startsAt = editing.startsAt;
      }
    }
    final collections = widget.collections;
    if (collections.isNotEmpty) {
      final main = collections.where((c) => c.isDefault);
      _collectionId = (main.isNotEmpty ? main.first : collections.first).id;
    }
  }

  @override
  void dispose() {
    _price.dispose();
    _floor.dispose();
    _reserve.dispose();
    _buyNow.dispose();
    super.dispose();
  }

  /// When the listing opens, as it would be posted at [now].
  DateTime _opens(DateTime now) {
    if (_later) {
      return _startsAt ?? now;
    }
    return _alreadyOpen ? widget.editing!.startsAt! : now;
  }

  /// When it closes: [_days] after it opens, or the chosen time.
  DateTime? _closes(DateTime now) {
    final days = _days;
    return days == null ? _endsAt : _opens(now).add(Duration(days: days));
  }

  P2pListingFormCheck _check(DateTime now) {
    return P2pListingFormCheck.of(
      buyNow: _auction ? _buyNow.text : _price.text,
      auction: _auction,
      floor: _floor.text,
      reserve: _reserve.text,
      startsAt: _later ? _startsAt : null,
      endsAt: _closes(now),
      now: now,
    );
  }

  void _submit() {
    final now = _now;
    final check = _check(now);
    final closes = _closes(now);
    final scheduled = !_later || _startsAt != null;
    if (!check.ok || closes == null || !scheduled) {
      setState(() => _tried = true);
      return;
    }
    widget.onSubmit(P2pListingDraft(
      input: P2pListingInput(
        smartContractUid: widget.smartContractUid,
        buyNowPrice: check.buyNowPrice,
        floorPrice: check.floorPrice,
        reservePrice: check.reservePrice,
        startsAt: _opens(now),
        endsAt: closes,
      ),
      collectionId: _collectionId,
    ));
  }

  Future<DateTime?> _pickDateTime(DateTime initial) async {
    final now = _now;
    final first = DateTime(now.year, now.month, now.day);
    final start = initial.isBefore(first) ? first : initial;
    final date = await showDatePicker(
      context: context,
      initialDate: start,
      firstDate: first,
      lastDate: first.add(const Duration(days: 365 * 2)),
    );
    if (date == null || !mounted) {
      return null;
    }
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(start));
    if (time == null) {
      return null;
    }
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String? _errorText(AppLocalizations l10n, P2pListingFieldError? error) {
    if (error == null || !_tried) {
      return null;
    }
    switch (error) {
      case P2pListingFieldError.required:
        return l10n.p2pListErrorRequired;
      case P2pListingFieldError.format:
        return l10n.p2pListErrorFormat;
      case P2pListingFieldError.decimals:
        return l10n.p2pListErrorDecimals;
      case P2pListingFieldError.belowFloor:
        return l10n.p2pListErrorBelowFloor;
      case P2pListingFieldError.belowReserve:
        return l10n.p2pListErrorBelowReserve;
      case P2pListingFieldError.belowStart:
        return l10n.p2pListErrorBelowStart;
      case P2pListingFieldError.past:
        return l10n.p2pListErrorPast;
      case P2pListingFieldError.beforeStart:
        return l10n.p2pListErrorBeforeStart;
    }
  }

  Widget _amountField({
    required String key,
    required TextEditingController controller,
    required String label,
    String? helper,
    String? error,
  }) {
    return TextField(
      key: Key(key),
      controller: controller,
      enabled: !widget.busy,
      autocorrect: false,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => setState(() {}),
      style: const TextStyle(fontFamily: 'RobotoMono'),
      decoration: InputDecoration(labelText: label, helperText: helper, helperMaxLines: 2, errorText: error, errorMaxLines: 2),
    );
  }

  Widget _choice({required String key, required String label, required bool selected, required VoidCallback onSelected}) {
    final color = selected ? p2pBrand() : Colors.white70;
    return ChoiceChip(
      key: Key(key),
      label: Text(label),
      labelStyle: TextStyle(color: color, fontSize: 13, fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
      selected: selected,
      selectedColor: p2pBrand().withOpacity(0.16),
      backgroundColor: p2pSurfaceRaised,
      side: BorderSide(color: selected ? p2pBrand() : p2pBorder),
      onSelected: widget.busy ? null : (_) => onSelected(),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(color: p2pMuted, fontSize: 12.5, fontWeight: FontWeight.w600)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = _now;
    final check = _check(now);
    final errors = check.errors;
    final closes = _closes(now);
    final royalty = widget.royalty;
    final percent = royalty == null ? null : p2pRoyaltyPercent(royalty);
    final danger = Theme.of(context).colorScheme.danger;

    final fields = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _label(l10n.p2pListKind),
        Wrap(
          spacing: 8,
          children: [
            _choice(
              key: 'p2p:list_kind_fixed',
              label: l10n.p2pListingFixedPrice,
              selected: !_auction,
              onSelected: () => setState(() => _auction = false),
            ),
            _choice(
              key: 'p2p:list_kind_auction',
              label: l10n.p2pListingAuction,
              selected: _auction,
              onSelected: () => setState(() => _auction = true),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (!_auction)
          _amountField(
            key: 'p2p:list_price',
            controller: _price,
            label: l10n.p2pListBuyNow,
            error: _errorText(l10n, errors['buyNow'] ?? (check.noPrice ? P2pListingFieldError.required : null)),
          )
        else ...[
          _amountField(key: 'p2p:list_floor', controller: _floor, label: l10n.p2pListFloor, error: _errorText(l10n, errors['floor'])),
          const SizedBox(height: 10),
          _amountField(
            key: 'p2p:list_reserve',
            controller: _reserve,
            label: l10n.p2pListReserve,
            helper: l10n.p2pListReserveHint,
            error: _errorText(l10n, errors['reserve']),
          ),
          const SizedBox(height: 10),
          _amountField(
            key: 'p2p:list_buy_now',
            controller: _buyNow,
            label: l10n.p2pListBuyNowOptional,
            error: _errorText(l10n, errors['buyNow']),
          ),
        ],
        if (!_alreadyOpen) ...[
          const SizedBox(height: 16),
          _label(l10n.p2pListOpens),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _choice(key: 'p2p:list_opens_now', label: l10n.p2pListNow, selected: !_later, onSelected: () => setState(() => _later = false)),
              _choice(key: 'p2p:list_opens_later', label: l10n.p2pListLater, selected: _later, onSelected: () => setState(() => _later = true)),
              if (_later)
                _DateTimeButton(
                  buttonKey: 'p2p:list_opens_at',
                  label: l10n.p2pListOpensAt,
                  at: _startsAt,
                  pickLabel: l10n.p2pListPickDateTime,
                  missing: _tried && _startsAt == null,
                  onPressed: widget.busy
                      ? null
                      : () async {
                          final picked = await _pickDateTime(_startsAt ?? now.add(const Duration(hours: 1)));
                          if (picked != null && mounted) {
                            setState(() => _startsAt = picked);
                          }
                        },
                ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        _label(l10n.p2pListCloses),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final days in P2pListingForm.dayChoices)
              _choice(
                key: 'p2p:list_days:$days',
                label: days == 1 ? l10n.p2pListDayOne : l10n.p2pListDays(days),
                selected: _days == days,
                onSelected: () => setState(() => _days = days),
              ),
            _choice(
              key: 'p2p:list_days:custom',
              label: l10n.p2pListCustom,
              selected: _days == null,
              onSelected: () => setState(() => _days = null),
            ),
            if (_days == null)
              _DateTimeButton(
                buttonKey: 'p2p:list_closes_at',
                label: l10n.p2pListClosesAt,
                at: _endsAt,
                pickLabel: l10n.p2pListPickDateTime,
                missing: _tried && _endsAt == null,
                onPressed: widget.busy
                    ? null
                    : () async {
                        final picked = await _pickDateTime(_endsAt ?? _opens(now).add(const Duration(days: 7)));
                        if (picked != null && mounted) {
                          setState(() => _endsAt = picked);
                        }
                      },
              ),
          ],
        ),
        const SizedBox(height: 6),
        if (_errorText(l10n, errors['endsAt']) != null && closes != null)
          Text(_errorText(l10n, errors['endsAt'])!, key: const Key('p2p:list_closes_error'), style: TextStyle(color: danger, fontSize: 12.5))
        else if (closes != null)
          Text(
            l10n.p2pListClosesOn(p2pDateTimeText(context, closes)),
            key: const Key('p2p:list_closes_on'),
            style: const TextStyle(color: p2pMuted, fontSize: 12.5),
          ),
        if (widget.collections.length > 1) ...[
          const SizedBox(height: 14),
          DropdownButtonFormField<int>(
            key: const Key('p2p:list_collection'),
            // A collection deleted since the form opened is no longer a choice.
            value: widget.collections.any((c) => c.id == _collectionId) ? _collectionId : null,
            decoration: InputDecoration(labelText: l10n.p2pListCollection),
            dropdownColor: const Color(0xFF191b1d),
            items: [
              for (final collection in widget.collections)
                DropdownMenuItem(
                  value: collection.id,
                  child: Text(collection.isLive ? collection.name : "${collection.name} (${l10n.p2pCollectionHidden})"),
                ),
            ],
            onChanged: widget.busy ? null : (id) => setState(() => _collectionId = id),
          ),
        ],
        if (royalty != null) ...[
          const SizedBox(height: 14),
          Text(
            percent == null ? l10n.p2pListRoyaltyUnpayable : l10n.p2pListRoyalty(percent, shortP2pAddress(royalty.payTo)),
            key: const Key('p2p:list_royalty'),
            style: TextStyle(color: percent == null ? danger : Colors.white70, fontSize: 13, height: 1.35),
          ),
        ],
        const SizedBox(height: 12),
        Text(l10n.p2pListNote, style: const TextStyle(color: p2pMuted, fontSize: 12.5, height: 1.35)),
      ],
    );

    // The fields scroll; what the last submit did and the buttons stay in
    // view under them.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: SingleChildScrollView(child: fields)),
        if (widget.status != null) ...[
          const SizedBox(height: 12),
          widget.status!,
        ],
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AppButton(
              key: const Key('p2p:list_cancel'),
              label: l10n.actionCancel,
              type: AppButtonType.Text,
              variant: AppColorVariant.Light,
              disabled: widget.busy,
              onPressed: widget.onCancel,
            ),
            const SizedBox(width: 8),
            AppButton(
              key: const Key('p2p:list_submit'),
              label: widget.submitLabel,
              processing: widget.busy,
              onPressed: _submit,
            ),
          ],
        ),
      ],
    );
  }
}

/// A chosen date and time, or the button that picks one.
class _DateTimeButton extends StatelessWidget {
  final String buttonKey;
  final String label;
  final DateTime? at;
  final String pickLabel;

  /// Whether a time is needed and none was chosen.
  final bool missing;
  final VoidCallback? onPressed;

  const _DateTimeButton({
    required this.buttonKey,
    required this.label,
    required this.at,
    required this.pickLabel,
    required this.missing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final at = this.at;
    final color = missing ? Theme.of(context).colorScheme.danger : Colors.white;
    return Semantics(
      label: label,
      button: true,
      child: OutlinedButton.icon(
        key: Key(buttonKey),
        onPressed: onPressed,
        icon: Icon(Icons.event, size: 16, color: color),
        label: Text(at == null ? pickLabel : p2pDateTimeText(context, at), style: TextStyle(color: color, fontSize: 13)),
        style: OutlinedButton.styleFrom(side: BorderSide(color: missing ? color : p2pBorder)),
      ),
    );
  }
}
