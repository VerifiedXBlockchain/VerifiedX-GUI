import 'dart:io';

import 'package:flutter/material.dart';
import '../../../../utils/toast.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/base_component.dart';
import '../../../../core/components/buttons.dart';
import '../../../../core/data_home.dart';
import '../../../../core/env.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../utils/files.dart';

class OpenLogButton extends BaseComponent {
  const OpenLogButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    return AppButton(
      label: AppLocalizations.of(context).r3eOpenLog,
      icon: Icons.open_in_new,
      onPressed: () async {
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String appDocPath = appDocDir.path;

        String logPath;
        if (Platform.isMacOS) {
          appDocPath = DataHome.fromDocuments(
              appDocPath, Env.isTestNet ? "/rbxtest" : "/vfx");
          logPath =
              "$appDocPath/Databases${Env.isTestNet ? 'TestNet' : ''}/rbxlog.txt";
        } else {
          appDocDir = await getApplicationSupportDirectory();

          appDocPath = appDocDir.path;

          appDocPath = appDocPath.replaceAll(
              "\\Roaming\\com.example\\rbx_wallet_gui",
              "\\Local\\VFX${Env.isTestNet ? 'Test' : ''}");
          logPath =
              "$appDocPath\\Databases${Env.isTestNet ? 'TestNet' : ''}\\rbxlog.txt";
        }

        // Opened through a file URI (as Open DB Folder does) rather than a
        // shell command, so a path containing spaces is not split apart.
        final logFile = File(logPath);
        if (!await logFile.exists() || !await openFile(logFile)) {
          Toast.error(AppLocalizations.of(context).r3eLogFileNotFound(logPath));
        }
      },
    );
  }
}
