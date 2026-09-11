import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/base_screen.dart';
import '../../../l10n/generated/app_localizations.dart';

import '../../navigation/root_container.dart';

class AccountsScreen extends BaseScreen {
  const AccountsScreen({super.key});

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: Text(AppLocalizations.of(context).walletAccountsTitle),
      shadowColor: Colors.transparent,
      backgroundColor: Colors.black,
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    return AccountManagementContainer();
  }
}
