import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sc_wizard_provider.dart';

import '../../../core/base_component.dart';
import '../../../generated/assets.gen.dart';
import '../providers/sc_wizard_minting_progress_provider.dart';
import '../../../l10n/generated/app_localizations.dart';

class ScWizardMintingProgressDialog extends BaseComponent {
  final BuildContext? contextOverride;
  const ScWizardMintingProgressDialog({Key? key, this.contextOverride}) : super(key: key);

  /// Close is enabled once the run is over: after a failure it only closes
  /// the dialog and keeps the wizard entries; after a full run it clears the
  /// wizard and leaves it.
  VoidCallback? _onClose(BuildContext context, WidgetRef ref, ScWizardMintingProgress model) {
    if (model.failed) {
      return () => Navigator.of(context).pop();
    }

    if (model.percent < 1) {
      return null;
    }

    return () {
      ref.read(scWizardProvider.notifier).clear();
      if (kIsWeb) {
        AutoRouter.of(context).pop();
      } else {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(scWizardMintingProgress);
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      backgroundColor: Colors.black,
      title: Text(
        l10n.r3aCompilingMinting,
        style: const TextStyle(color: Colors.white),
      ),
      content: Container(
        color: Colors.black,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              color: Colors.black,
              child: Center(
                child: Container(
                  color: Colors.black,
                  width: 100,
                  height: 100,
                  child: Image.asset(
                    Assets.images.animatedCube.path,
                    scale: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(model.label),
            if (model.error != null) ...[
              const SizedBox(height: 8),
              Text(
                model.error!,
                key: const Key('scWizardMinting:error'),
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: model.percent,
              color: Theme.of(context).colorScheme.secondary,
              backgroundColor: Colors.white24,
              minHeight: 16,
            ),
            const SizedBox(height: 4),
            Text(
              "${(model.percent * 100).round()}%",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            key: const Key('scWizardMinting:close'),
            onPressed: _onClose(context, ref, model),
            child: Text(
              l10n.actionClose,
              style: const TextStyle(color: Colors.white),
            ))
      ],
    );
  }
}
