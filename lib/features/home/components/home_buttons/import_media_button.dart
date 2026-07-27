import 'package:flutter/material.dart';

import '../../../../core/base_component.dart';
import '../../../../core/components/buttons.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../core/utils.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../utils/toast.dart';

class ImportMediaButton extends BaseComponent {
  const ImportMediaButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final cliStarted = ref.watch(sessionProvider.select((v) => v.cliStarted));

    return AppButton(
      label: AppLocalizations.of(context).r3eImportMedia,
      icon: Icons.cloud_download_outlined,
      onPressed: !cliStarted
          ? null
          : () async {
              final success = await importMedia(context, ref);

              if (success == true) {
                Toast.message(AppLocalizations.of(context).r3eMediaImported);
              } else if (success == false) {
                Toast.error(
                    AppLocalizations.of(context).r3eCouldNotImportMedia);
              }
            },
    );
  }
}
