import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/base_screen.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../components/token_form.dart';

class WebTokenCreateScreen extends BaseScreen {
  const WebTokenCreateScreen({super.key});

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: Colors.black54,
      title: Text(AppLocalizations.of(context).tokenCreateTitle),
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final keypair = ref.watch(webSessionProvider.select((value) => value.keypair));
    if (keypair == null) {
      return Center(
        child: Text(AppLocalizations.of(context).btcVfxAddressRequired),
      );
    }

    return SingleChildScrollView(
      child: TokenForm(),
    );
  }
}
