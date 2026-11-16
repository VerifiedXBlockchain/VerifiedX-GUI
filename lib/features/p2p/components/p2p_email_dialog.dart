import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../../../core/components/buttons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/p2p_error.dart';
import '../providers/p2p_session_provider.dart';
import '../services/p2p_session.dart';
import '../services/p2p_signer.dart';
import '../utils/p2p_error_text.dart';
import '../utils/p2p_rules.dart';

/// Asks, optionally, for an email for [address]: Spyglass writes to it when
/// one of the account's listings has a winner or a sale is started for it.
/// The address goes to Spyglass with the account's sign-in token; nothing is
/// kept in the wallet.
class P2pEmailDialog extends ConsumerStatefulWidget {
  final String address;

  const P2pEmailDialog({super.key, required this.address});

  static Future<void> show(String address) {
    return showDialog<void>(
      context: rootNavigatorKey.currentContext!,
      builder: (_) => P2pEmailDialog(address: address),
    );
  }

  @override
  ConsumerState<P2pEmailDialog> createState() => _P2pEmailDialogState();
}

class _P2pEmailDialogState extends ConsumerState<P2pEmailDialog> {
  late final TextEditingController _email = TextEditingController(text: ref.read(p2pSessionProvider).emailOf(widget.address) ?? '');
  bool _isSaving = false;
  bool _tried = false;
  Object? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final email = _email.text.trim();
    if (!isP2pEmail(email)) {
      setState(() => _tried = true);
      return;
    }
    setState(() {
      _isSaving = true;
      _error = null;
    });
    final session = ref.read(p2pSessionProvider);
    final service = ref.read(p2pServiceProvider);
    try {
      await session.withToken(widget.address, (token) => service.subscribeEmail(token: token, address: widget.address, email: email));
      session.noteEmail(widget.address, email);
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).p2pEmailSaved)));
        Navigator.of(context).pop();
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
    final error = _error;
    return AlertDialog(
      backgroundColor: const Color(0xFF191b1d),
      title: Text(l10n.p2pEmailTitle),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.p2pEmailBody, style: const TextStyle(color: Colors.white70, fontSize: 13.5, height: 1.4)),
            const SizedBox(height: 12),
            TextField(
              key: const Key('p2p:email_field'),
              controller: _email,
              autofocus: true,
              autocorrect: false,
              enabled: !_isSaving,
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _save(),
              decoration: InputDecoration(
                labelText: l10n.p2pEmailField,
                errorText: _tried && !isP2pEmail(_email.text.trim()) ? l10n.p2pEmailInvalid : null,
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 10),
              Text(
                // A refusal of the address itself is the registry's; a
                // sign-in that failed is worded as everywhere else.
                error is P2pError && !error.isUnauthorized && error.code != P2pError.unreachable ? l10n.p2pEmailFailed : p2pErrorText(l10n, error),
                key: const Key('p2p:email_error'),
                style: TextStyle(color: Theme.of(context).colorScheme.danger, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
      actions: [
        AppButton(
          key: const Key('p2p:email_skip'),
          label: l10n.p2pEmailSkip,
          type: AppButtonType.Text,
          variant: AppColorVariant.Light,
          disabled: _isSaving,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton(
          key: const Key('p2p:email_save'),
          label: l10n.p2pEmailSave,
          processing: _isSaving,
          onPressed: _save,
        ),
      ],
    );
  }
}
