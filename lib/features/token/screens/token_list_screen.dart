import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_router.gr.dart';
import '../../../core/base_screen.dart';
import '../../../core/breakpoints.dart';
import '../../../core/components/buttons.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/web_router.gr.dart';
import '../../web/components/web_mobile_drawer_button.dart';
import '../components/token_list.dart';

import '../components/web_token_list.dart';
import '../providers/web_token_list_provider.dart';

class TokenListScreen extends BaseScreen {
  const TokenListScreen({super.key})
      : super(
          backgroundColor: Colors.black87,
          horizontalPadding: 0,
          verticalPadding: 0,
        );

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    final isMobile = BreakPoints.useMobileLayout(context);
    final hasAccounts = kIsWeb
        ? ref.watch(webTokenListProvider).isNotEmpty
        : ref.watch(sessionProvider.select((v) => v.balances)).where((b) => b.tokens.isNotEmpty).toList().isNotEmpty;

    return AppBar(
      leading: isMobile ? WebMobileDrawerButton() : null,
      backgroundColor: Colors.black54,
      centerTitle: !isMobile,
      title: Text("Fungible Tokens"),
      actions: [
        if (hasAccounts)
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: AppButton(
              label: "Create New Token",
              variant: AppColorVariant.Success,
              onPressed: () {
                if (kIsWeb) {
                  AutoRouter.of(context).push(WebTokenCreateScreenRoute());
                } else {
                  AutoRouter.of(context).push(TokenCreateScreenRoute());
                }
              },
            ),
          )
      ],
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    return kIsWeb ? WebTokenList() : TokenList();
  }
}
