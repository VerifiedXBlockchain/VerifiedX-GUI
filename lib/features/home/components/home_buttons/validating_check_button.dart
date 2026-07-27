import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/base_component.dart';
import '../../../../core/components/buttons.dart';
import '../../../../core/dialogs.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../bridge/services/bridge_service.dart';
import '../../../../utils/toast.dart';

class ValidatingCheckButton extends BaseComponent {
  const ValidatingCheckButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppButton(
      label: l10n.r3eValidatorCheck,
      icon: Icons.medical_services,
      onPressed: ref.watch(sessionProvider.select((v) => v.cliStarted))
          ? () async {
              final isValidating = await BridgeService().isValidating();

              if (isValidating == null) {
                Toast.error(l10n.r3eValidatingCheckProblem);
                return;
              }

              if (isValidating) {
                InfoDialog.show(
                  headerColor: Colors.white,
                  title: l10n.r3eValidatingTitle,
                  content: Text(
                    l10n.r3eYesValidating,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                InfoDialog.show(
                  title: l10n.r3eNotValidatingTitle,
                  headerColor: Colors.white,
                  content: Text(
                    l10n.r3eNoNotValidating,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }
            }
          : null,
    );
  }
}
