import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import '../providers/locale_provider.dart';
import 'buttons.dart';

/// "Language" action button matching the operations General section's
/// AppButton row. Opens a picker dialog (System default / English / Español);
/// selection applies immediately and persists via LocaleProvider.
class LanguageButton extends ConsumerWidget {
  const LanguageButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return AppButton(
      label: l10n.settingsLanguageSection,
      icon: Icons.language,
      onPressed: () {
        showDialog(
          context: context,
          builder: (dialogContext) {
            return Consumer(
              builder: (context, ref, _) {
                final current = ref.watch(localeProvider);
                final options = <Locale?, String>{
                  null: l10n.settingsLanguageSystemDefault,
                  const Locale('en'): l10n.settingsLanguageEnglish,
                  const Locale('es'): l10n.settingsLanguageSpanish,
                };

                return AlertDialog(
                  title: Text(l10n.settingsLanguageSection),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: options.entries.map((entry) {
                      final selected = current == entry.key;
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          size: 18,
                          color: selected
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.white54,
                        ),
                        title: Text(entry.value),
                        onTap: () {
                          ref.read(localeProvider.notifier).setLocale(entry.key);
                          Navigator.of(dialogContext).pop();
                        },
                      );
                    }).toList(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      child: Text(
                        l10n.actionClose,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
