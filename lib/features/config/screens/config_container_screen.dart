import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api_token_manager.dart';
import '../../../core/singletons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../core/base_screen.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../core/env.dart';
import '../../../core/theme/app_theme.dart';
import '../../../utils/files.dart';
import '../../../utils/toast.dart';
import '../../easter/secret_button.dart';
import '../components/configuration_form_group.dart';
import '../providers/config_form_provider.dart';

class ConfigContainerScreen extends BaseScreen {
  const ConfigContainerScreen({Key? key}) : super(key: key, verticalPadding: 0, horizontalPadding: 0);

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    final provider = ref.read(configFormProvider.notifier);
    return AppBar(
      title: Text(AppLocalizations.of(context).configAppBarTitle),
      leading: IconButton(
        onPressed: () async {
          final confirmed = await ConfirmDialog.show(
            title: AppLocalizations.of(context).configCloseDialogTitle,
            body: AppLocalizations.of(context).configCloseDialogBody,
            cancelText: AppLocalizations.of(context).actionCancel,
            confirmText: AppLocalizations.of(context).actionContinue,
          );

          if (confirmed == true) {
            AutoRouter.of(context).pop();
            provider.clear();
            ref.refresh(configFormProvider);
          }
        },
        icon: const Icon(Icons.close),
      ),
      actions: [
        AppButton(
          onPressed: () async {
            final p = await configPath();
            openFile(File(p));
          },
          label: AppLocalizations.of(context).configButtonOpenConfig,
          type: AppButtonType.Text,
          variant: AppColorVariant.Light,
          icon: Icons.launch,
        ),
        AppButton(
          onPressed: () {
            launchUrl(Uri.parse('https://github.com/ReserveBlockIO/ReserveBlock-Core/blob/main/ConfigSetup.md'));
          },
          label: AppLocalizations.of(context).configButtonViewDocs,
          type: AppButtonType.Text,
          variant: AppColorVariant.Light,
          icon: Icons.launch,
        )
      ],
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final provider = ref.read(configFormProvider.notifier);
    return Column(
      children: [
        const SizedBox(
          height: 16,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning,
              color: Theme.of(context).colorScheme.warning,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(AppLocalizations.of(context).configWarningAdvanced,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
        if (kDebugMode)
          Builder(builder: (context) {
            final token = singleton<ApiTokenManager>().get();
            return SelectableText(token);
          }),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _LanguageSection(),
                const ConfigurationFormGroup(),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: SecretButton(
            onPressed: () {
              launchUrlString("${Env.apiBaseUrl}/snake");
            },
          ),
        ),
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF040f26),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton(
                  label: AppLocalizations.of(context).actionSave,
                  variant: AppColorVariant.Success,
                  onPressed: () async {
                    final shouldRestart = await provider.submit();
                    if (!shouldRestart) {
                      Toast.message(AppLocalizations.of(context).configRestartRequiredToast);
                    }
                    AutoRouter.of(context).pop();
                  },
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LanguageSection extends ConsumerWidget {
  const _LanguageSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = ref.watch(localeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.language, size: 20),
          const SizedBox(width: 8),
          Text(
            l10n.settingsLanguageSection,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 16),
          DropdownButton<Locale?>(
            value: current,
            onChanged: (locale) {
              ref.read(localeProvider.notifier).setLocale(locale);
            },
            items: [
              DropdownMenuItem<Locale?>(
                value: null,
                child: Text(l10n.settingsLanguageSystemDefault),
              ),
              DropdownMenuItem<Locale?>(
                value: const Locale('en'),
                child: Text(l10n.settingsLanguageEnglish),
              ),
              DropdownMenuItem<Locale?>(
                value: const Locale('es'),
                child: Text(l10n.settingsLanguageSpanish),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
