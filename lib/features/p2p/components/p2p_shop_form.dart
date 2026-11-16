import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/components/buttons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../chain/p2p_tx_builders.dart';
import '../models/p2p_error.dart';
import '../models/p2p_shop.dart';
import '../providers/p2p_session_provider.dart';
import '../utils/p2p_rules.dart';
import '../utils/p2p_view.dart';
import 'p2p_parts.dart';

/// A shop's name, vfx:// address and description, checked against Core's
/// limits as they are typed, with the address's availability asked of the
/// registry once typing pauses. Used to open a shop and to change one.
class P2pShopForm extends ConsumerStatefulWidget {
  final P2pShopValues initial;

  /// The shop's own URL when editing: typing it back is "unchanged", not
  /// "taken".
  final String? currentUrl;

  /// With [currentUrl]: whether Review needs something to have changed.
  final Widget? note;
  final void Function(P2pShopValues values) onSubmit;
  final VoidCallback? onCancel;

  const P2pShopForm({
    super.key,
    required this.initial,
    required this.onSubmit,
    this.currentUrl,
    this.note,
    this.onCancel,
  });

  @override
  ConsumerState<P2pShopForm> createState() => _P2pShopFormState();
}

class _P2pShopFormState extends ConsumerState<P2pShopForm> {
  static const Duration _typingPause = Duration(milliseconds: 350);

  late final TextEditingController _name = TextEditingController(text: widget.initial.name);
  late final TextEditingController _url = TextEditingController(text: widget.initial.url);
  late final TextEditingController _description = TextEditingController(text: widget.initial.description);

  Timer? _debounce;
  late String _settledUrl = widget.initial.url;
  P2pUrlAvailability? _answer;
  bool _checkFailed = false;
  bool _tried = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _name.dispose();
    _url.dispose();
    _description.dispose();
    super.dispose();
  }

  P2pShopValues get _values => P2pShopValues(name: _name.text, url: _url.text, description: _description.text);

  P2pShopUrlStatus get _status => p2pShopUrlStatus(_url.text, _settledUrl, _answer, widget.currentUrl);

  bool get _changed {
    final current = widget.currentUrl;
    if (current == null) {
      return true;
    }
    return _name.text.trim() != widget.initial.name ||
        normalizeP2pShopUrl(_url.text) != normalizeP2pShopUrl(current) ||
        _description.text.trim() != widget.initial.description;
  }

  void _onUrlTyped(String value) {
    setState(() => _checkFailed = false);
    _debounce?.cancel();
    _debounce = Timer(_typingPause, () => _checkUrl(value));
  }

  Future<void> _checkUrl(String typed) async {
    if (!mounted) {
      return;
    }
    setState(() => _settledUrl = typed);
    final current = widget.currentUrl;
    final url = normalizeP2pShopUrl(typed);
    if (!isValidP2pShopUrl(typed) || (current != null && url == normalizeP2pShopUrl(current))) {
      return;
    }
    try {
      final answer = await ref.read(p2pServiceProvider).urlAvailability(url);
      if (mounted && normalizeP2pShopUrl(_url.text) == url) {
        setState(() => _answer = answer);
      }
    } on P2pError {
      // An address the registry could not be asked about still goes to
      // review: recording the step refuses a taken one.
      if (mounted) {
        setState(() => _checkFailed = true);
      }
    }
  }

  void _submit() {
    setState(() => _tried = true);
    final values = _values;
    final errors = checkP2pShopFields(name: values.name, url: values.url, description: values.description);
    final status = _status;
    final ready = errors.isEmpty &&
        (status == P2pShopUrlStatus.free || status == P2pShopUrlStatus.unchanged || (status == P2pShopUrlStatus.checking && _checkFailed));
    if (!ready || !_changed) {
      return;
    }
    widget.onSubmit(values);
  }

  String? _fieldError(AppLocalizations l10n, P2pShopFieldError? error) {
    if (!_tried || error == null) {
      return null;
    }
    switch (error) {
      case P2pShopFieldError.required:
        return l10n.p2pShopErrorRequired;
      case P2pShopFieldError.tooLong:
        return l10n.p2pShopErrorTooLong;
      case P2pShopFieldError.tooManyWords:
        return l10n.p2pShopErrorTooManyWords(p2pShopDescriptionMaxWords);
      case P2pShopFieldError.invalid:
        return l10n.p2pShopErrorUrlInvalid;
    }
  }

  String? _urlError(AppLocalizations l10n, P2pShopUrlStatus status) {
    switch (status) {
      case P2pShopUrlStatus.taken:
        return l10n.p2pShopUrlTaken;
      case P2pShopUrlStatus.invalid:
        return l10n.p2pShopErrorUrlInvalid;
      case P2pShopUrlStatus.empty:
        return _tried ? l10n.p2pShopErrorRequired : null;
      case P2pShopUrlStatus.checking:
        return _tried && !_checkFailed ? l10n.p2pShopUrlStillChecking : null;
      case P2pShopUrlStatus.free:
      case P2pShopUrlStatus.unchanged:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final values = _values;
    final errors = checkP2pShopFields(name: values.name, url: values.url, description: values.description);
    final status = _status;
    final success = AppColors.getSpringGreen(ColorShade.s50);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          key: const Key('p2p:shop_name'),
          controller: _name,
          maxLength: p2pShopNameMax,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: l10n.p2pShopFieldName,
            errorText: _fieldError(l10n, errors['name']),
            counterText: '',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('p2p:shop_url'),
          controller: _url,
          autocorrect: false,
          onChanged: _onUrlTyped,
          style: const TextStyle(fontFamily: 'RobotoMono'),
          decoration: InputDecoration(
            labelText: l10n.p2pShopFieldUrl,
            hintText: l10n.p2pShopFieldUrlPlaceholder,
            prefixText: 'vfx://',
            helperText: l10n.p2pShopFieldUrlHint,
            helperMaxLines: 2,
            errorText: _urlError(l10n, status),
            errorMaxLines: 2,
          ),
        ),
        SizedBox(
          height: 22,
          child: Align(
            alignment: Alignment.centerLeft,
            child: _statusLine(l10n, status, success),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          key: const Key('p2p:shop_description'),
          controller: _description,
          minLines: 3,
          maxLines: 6,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: l10n.p2pShopFieldDescription,
            alignLabelWithHint: true,
            helperText: l10n.p2pShopFieldWords(countP2pWords(values.description), p2pShopDescriptionMaxWords),
            errorText: _fieldError(l10n, errors['description']),
          ),
        ),
        if (widget.note != null) ...[
          const SizedBox(height: 12),
          widget.note!,
        ],
        if (_tried && !_changed) ...[
          const SizedBox(height: 10),
          Text(l10n.p2pShopEditUnchanged, key: const Key('p2p:shop_unchanged'), style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (widget.onCancel != null) ...[
              AppButton(
                key: const Key('p2p:shop_cancel'),
                label: l10n.actionCancel,
                type: AppButtonType.Text,
                variant: AppColorVariant.Light,
                onPressed: widget.onCancel,
              ),
              const SizedBox(width: 8),
            ],
            AppButton(
              key: const Key('p2p:shop_review'),
              label: l10n.p2pShopReview,
              onPressed: _submit,
            ),
          ],
        ),
      ],
    );
  }

  Widget _statusLine(AppLocalizations l10n, P2pShopUrlStatus status, Color success) {
    if (status == P2pShopUrlStatus.free) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, size: 14, color: success),
          const SizedBox(width: 5),
          Text(
            l10n.p2pShopUrlFree(normalizeP2pShopUrl(_url.text)),
            key: const Key('p2p:shop_url_free'),
            style: TextStyle(color: success, fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
        ],
      );
    }
    if (status == P2pShopUrlStatus.checking) {
      return Text(
        _checkFailed ? l10n.p2pShopUrlCheckFailed : l10n.p2pShopUrlChecking,
        key: const Key('p2p:shop_url_checking'),
        style: const TextStyle(color: p2pMuted, fontSize: 12.5),
      );
    }
    return const SizedBox.shrink();
  }
}
