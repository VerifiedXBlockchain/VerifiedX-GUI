import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../core/base_screen.dart';
import '../../../core/env.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/mother_child_list.dart';

class MotherDashboardScreen extends BaseScreen {
  const MotherDashboardScreen({Key? key}) : super(key: key);

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppBar(
      title: Text(l10n.motherDashboardTitle),
      backgroundColor: Colors.black12,
      shadowColor: Colors.transparent,
      actions: [
        TextButton(
            onPressed: () {
              final url = "${Env.apiBaseUrl}/mother".replaceAll("https://", "http://");
              launchUrlString(url);
            },
            child: Text(
              l10n.motherOpenInBrowser,
              style: const TextStyle(
                color: Colors.white,
              ),
            ))
      ],
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    return const MotherChildList();
  }
}
