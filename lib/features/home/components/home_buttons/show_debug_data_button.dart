import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/base_component.dart';
import '../../../../core/components/buttons.dart';
import '../../../../core/dialogs.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../utils/toast.dart';
import '../../../bridge/services/bridge_service.dart';

class ShowDebugDataButton extends BaseComponent {
  const ShowDebugDataButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final cliStarted = ref.watch(sessionProvider.select((v) => v.cliStarted));

    return AppButton(
      label: AppLocalizations.of(context).r3eShowDebugData,
      icon: Icons.analytics_outlined,
      onPressed: !cliStarted
          ? null
          : () async {
              final data = await BridgeService().getDebugInfo();
              InfoDialog.show(
                title: AppLocalizations.of(context).r3eDebugData,
                withBackArrow: true,
                content: Container(
                  color: Colors.black54,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppButton(
                            label: AppLocalizations.of(context).actionCopy,
                            icon: Icons.copy,
                            variant: AppColorVariant.Success,
                            onPressed: () async {
                              await Clipboard.setData(ClipboardData(text: data));
                              Toast.message(AppLocalizations.of(context)
                                  .r3eDebugDataCopied);
                            },
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          SelectableText(
                            data,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: "Courier",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
    );
  }
}
