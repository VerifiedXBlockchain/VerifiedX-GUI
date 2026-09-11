import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/base_component.dart';
import '../../../../core/components/buttons.dart';
import '../../../../core/dialogs.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../nft/services/nft_service.dart';
import '../../../../utils/toast.dart';
import '../../../../utils/validation.dart';

class VerifyNftOwnershipButton extends BaseComponent {
  const VerifyNftOwnershipButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cliStarted = kIsWeb ? null : ref.watch(sessionProvider.select((v) => v.cliStarted));

    final l10n = AppLocalizations.of(context);
    return AppButton(
      label: l10n.r3eVerifyNftOwnership,
      icon: Icons.security,
      onPressed: cliStarted == false
          ? null
          : () async {
              final sig = await PromptModal.show(
                title: l10n.homeValidateOwnership,
                body: l10n.r3ePasteSignature,
                validator: (val) =>
                    formValidatorNotEmpty(val, l10n.homeSignatureLabel),
                labelText: l10n.homeSignatureLabel,
              );

              if (sig != null && sig.isNotEmpty) {
                final components = sig.split("<>");
                if (components.length != 4) {
                  Toast.error(l10n.r3eInvalidOwnershipSig);
                  return;
                }

                final address = components.first;
                final scId = components.last;

                final verified = await NftService().verifyOwnership(sig);

                if (verified == null) {
                  return;
                }
                final color = verified ? Theme.of(context).colorScheme.success : Theme.of(context).colorScheme.danger;
                final iconData = verified ? Icons.check : Icons.close;
                final title = verified ? l10n.homeVerified : l10n.homeNotVerified;
                final subtitle = verified
                    ? l10n.homeOwnershipVerified
                    : l10n.r3eOwnershipNotVerified;
                final body = verified
                    ? l10n.r3eOwnsBody(address, scId)
                    : l10n.r3eDoesNotOwnBody(address, scId);

                InfoDialog.show(
                  title: title,
                  content: NftVerificationSuccessDialog(iconData: iconData, color: color, subtitle: subtitle, body: body),
                );
              }
            },
    );
  }
}

class NftVerificationSuccessDialog extends StatelessWidget {
  const NftVerificationSuccessDialog({
    super.key,
    required this.iconData,
    required this.color,
    required this.subtitle,
    required this.body,
  });

  final IconData iconData;
  final Color color;
  final String subtitle;
  final String body;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                iconData,
                color: color,
                size: 32,
              ),
              SizedBox(
                width: 12,
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 20,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 16,
          ),
          Text(
            body,
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
