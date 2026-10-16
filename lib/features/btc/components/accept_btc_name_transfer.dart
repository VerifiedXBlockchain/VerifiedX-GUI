import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_constants.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/toast.dart';
import '../../../utils/validation.dart';
import '../utils/btc_name_acceptance.dart';

/// Signs the acceptance of [name] being transferred to [btcAddress] with
/// [newOwner] as its VFX owner, returning the acceptance code or null after
/// showing why it could not be signed.
typedef BtcNameAcceptanceSigner = Future<String?> Function(String name, String newOwner);

/// Asks the receiver of a BTC domain for the domain and its new VFX owner,
/// signs the acceptance with [sign] and shows the resulting code to copy.
Future<void> acceptBtcNameTransfer({
  required BuildContext context,
  required String btcAddress,
  required BtcNameAcceptanceSigner sign,
  String initialOwner = "",
  Widget Function(TextEditingController controller)? ownerPicker,
}) async {
  final l10n = AppLocalizations.of(context);

  final name = await PromptModal.show(
    contextOverride: context,
    title: l10n.btcAcceptTransferTitle,
    body: l10n.btcAcceptTransferNameBody(btcAddress),
    labelText: l10n.btcAcceptTransferNameLabel,
    validator: (value) => _nameValidator(l10n, value),
  );
  if (name == null) return;

  final ownerController = TextEditingController(text: initialOwner);
  final owner = await PromptModal.show(
    contextOverride: context,
    title: l10n.btcAcceptTransferTitle,
    body: l10n.btcAcceptTransferOwnerBody,
    labelText: l10n.btcAcceptTransferOwnerLabel,
    controller: ownerController,
    sufixIcon: ownerPicker?.call(ownerController),
    validator: (value) => formValidatorRbxAddress(value?.trim(), false),
  );
  if (owner == null) return;

  final domain = BtcNameAcceptance.normalizeName(name);
  final code = await sign(domain, owner.trim());
  if (code == null) return;

  await InfoDialog.show(
    contextOverride: context,
    title: l10n.btcAcceptanceCodeTitle,
    content: _AcceptanceCodeContent(
      code: code,
      name: domain,
      owner: owner.trim(),
    ),
  );
}

String? _nameValidator(AppLocalizations l10n, String? value) {
  final name = (value ?? "").trim().replaceAll(RegExp(r'\.btc$', caseSensitive: false), "");
  if (name.isEmpty) {
    return l10n.bw2DomainNameRequired;
  }
  if (name.length > BTC_ADNR_MAX_LENGTH) {
    return l10n.bw2DomainTooLong((BTC_ADNR_MAX_LENGTH + 1).toString());
  }
  if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(name)) {
    return l10n.bw2InvalidDomainLetters;
  }
  return null;
}

class _AcceptanceCodeContent extends StatelessWidget {
  const _AcceptanceCodeContent({
    required this.code,
    required this.name,
    required this.owner,
  });

  final String code;
  final String name;
  final String owner;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.btcAcceptanceCodeBody(name, owner),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: code,
            readOnly: true,
            minLines: 4,
            maxLines: 4,
          ),
          const SizedBox(height: 8),
          Center(
            child: AppButton(
              label: l10n.btcCopyAcceptanceCode,
              icon: Icons.copy,
              variant: AppColorVariant.Btc,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: code));
                Toast.message(l10n.btcAcceptanceCodeCopied);
              },
            ),
          ),
        ],
      ),
    );
  }
}
