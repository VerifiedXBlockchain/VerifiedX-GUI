import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils.dart';
import '../../../utils/toast.dart';
import '../../misc/providers/global_balances_expanded_provider.dart';
import '../../../core/models/web_session_model.dart';
import '../../web/components/web_wordmark.dart';
import '../../../core/services/password_prompt_service.dart';

import '../../../core/app_constants.dart';
import '../../../core/app_router.gr.dart';
import '../../../core/base_screen.dart';
import '../../../core/breakpoints.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/env.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../../core/singletons.dart';
import '../../../core/storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/web_router.gr.dart';
import '../../../generated/assets.gen.dart';
import '../auth_utils.dart';
import '../components/auth_type_modal.dart';

class WebAuthScreen extends BaseStatefulScreen {
  const WebAuthScreen({Key? key})
      : super(
          key: key,
          backgroundColor: Colors.black,
        );

  @override
  WebAuthScreenScreenState createState() => WebAuthScreenScreenState();
}

class WebAuthScreenScreenState extends BaseScreenState<WebAuthScreen> {
  @override
  void initState() {
    _handleSession(ref.read(webSessionProvider));
    super.initState();
  }

  Future<void> _showWelcomeMessage() async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Welcome to the VerifiedX Web Wallet!",
              style: TextStyle(
                  color: AppColors.getBlue(), fontWeight: FontWeight.w400),
            ),
            content: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "The network does NOT store your email/password or mnemonic. They are used as seeds to generate your accounts' keypairs."),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                      "This includes your VFX account, Vault account, and Bitcoin account."),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                      "We recommend backing up all private keys however, when generating with an email/password or mnemonic, your VFX private key will restore all three accounts."),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () async {
                    final success = await backupWebKeys(context, ref);
                  },
                  child: Text(
                    "Backup Keys",
                    style: TextStyle(color: Colors.white),
                  )),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Continue",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        });
  }

  void _handleSession(WebSessionModel session) {
    final currentPath = singleton<AppRouter>().current.path;

    if (session.isAuthenticated) {
      if (currentPath == '/') {
        AutoRouter.of(context).push(WebDashboardContainerRoute());
      }
    } else {
      // final path = Uri.base.toString().split("#").last;
      // final pathComponents = path.split("/");
      // print(pathComponents);
      // if (pathComponents[1] == "p2p" && pathComponents[2] == "shop") {
      //   final shopId = int.tryParse(pathComponents[3]);
      //   final collectionId = int.tryParse(pathComponents[5]);

      //   if (shopId == null || collectionId == null) {
      //     return;
      //   }

      //   if (pathComponents.length == 6) {
      //     if (pathComponents[4] == "collection") {
      //       AutoRouter.of(context)
      //           .pushAll([WebDashboardContainerRoute(), WebCollectionDetailScreenRoute(shopId: shopId, collectionId: collectionId)]);
      //     }
      //   }
      // }
    }
  }

  Future<void> redirectToDashboard(bool showWelcomeMessage) async {
    if (showWelcomeMessage) {
      await _showWelcomeMessage();
    }

    ref.read(globalBalancesExpandedProvider.notifier).expand();

    // Check for pending redirect URL
    final storage = singleton<Storage>();
    final pendingRedirect = storage.getString(Storage.PENDING_REDIRECT_URL);

    if (pendingRedirect != null && pendingRedirect.isNotEmpty) {
      // Clear the pending redirect
      storage.remove(Storage.PENDING_REDIRECT_URL);

      try {
        // Try using navigateNamed first (replaces current route in stack)
        await AutoRouter.of(context).navigateNamed(pendingRedirect);
      } catch (e) {
        try {
          // Fallback to pushNamed
          await AutoRouter.of(context).pushNamed(pendingRedirect);
        } catch (e) {
          // If both fail, go to dashboard
          AutoRouter.of(context).push(WebDashboardContainerRoute());
        }
      }
    } else {
      // Default navigation to dashboard
      AutoRouter.of(context).push(WebDashboardContainerRoute());
    }
  }

  @override
  Widget body(BuildContext context) {
    // ref.listen<WebSessionModel>(webSessionProvider, (prev, next) {
    //   _handleSession(next);
    // });

    final isMobile = BreakPoints.useMobileLayout(context);

    final keypair = ref.watch(webSessionProvider.select((v) => v.keypair));
    final session = ref.watch(webSessionProvider);

    // Check if we need password for encrypted keys
    final storage = singleton<Storage>();
    final needsPassword = storage.isEncryptionEnabled() &&
        storage.hasPasswordHash() &&
        !session.isAuthenticated;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          // Padding(
          //   padding: const EdgeInsets.all(12.0),
          //   child: Image.asset(
          //     Assets.images.rbxWallet.path,
          //     width: 120,
          //     height: 20,
          //     fit: BoxFit.contain,
          //   ),
          // ),
          SizedBox(
            height: 8,
          ),
          WebWalletWordWordmark(),

          const SizedBox(height: 16),
          if (needsPassword) ...[
            // Show the address they're unlocking
            Text(
              "Unlock wallet for:",
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
            Text(
              storage.getString(Storage.WEB_PRIMARY_ADDRESS) ??
                  "Unknown Address",
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontFamily: 'RobotoMono',
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: "Enter Password",
              icon: Icons.lock,
              onPressed: () async {
                final password =
                    await PasswordPromptService.promptAndVerifyPassword(
                  context,
                  title: "Enter Password",
                  customMessage:
                      "Enter your password to decrypt your stored keys.",
                );

                if (password != null) {
                  final success = await ref
                      .read(webSessionProvider.notifier)
                      .loginWithPassword(password);
                  if (success) {
                    redirectToDashboard(false);
                  } else {
                    Toast.error("Failed to decrypt keys");
                  }
                }
              },
              variant: AppColorVariant.Light,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: AppButton(
                label: "Logout",
                type: AppButtonType.Text,
                underlined: true,
                onPressed: () async {
                  ref.read(webSessionProvider.notifier).logout();
                },
                variant: AppColorVariant.Light,
              ),
            ),
          ] else
            AppButton(
              label: "Login / Create Account",
              icon: Icons.upload,
              onPressed: () {
                showWebLoginModal(context, ref,
                    allowPrivateKey: true,
                    allowBtcPrivateKey: true,
                    showRememberMe: true, onSuccess: () {
                  redirectToDashboard(true);
                });
              },
              variant: AppColorVariant.Light,
            ),
          if (keypair != null)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: AppButton(
                label: "Resume Session",
                variant: AppColorVariant.Light,
                type: AppButtonType.Text,
                underlined: true,
                onPressed: () {
                  redirectToDashboard(false);
                },
              ),
            ),

          if (Env.isTestNet)
            const Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Text(
                "TESTNET",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    letterSpacing: 2),
              ),
            ),
        ],
      ),
    );
  }
}

class WebWalletWordWordmark extends StatelessWidget {
  final bool withSubtitle;
  const WebWalletWordWordmark({
    super.key,
    this.withSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Verified",
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 26,
                fontWeight: FontWeight.w300,
                fontFamily: 'Mukta',
                letterSpacing: 0,
                height: 1,
              ),
            ),
            SizedBox(
              width: 1,
            ),
            Text(
              "X",
              style: TextStyle(
                color: AppColors.getBlue(ColorShade.s100),
                fontSize: 26,
                fontWeight: FontWeight.w700,
                fontFamily: 'Mukta',
                letterSpacing: 0,
                height: 1,
              ),
            ),
          ],
        ),
        if (withSubtitle) ...[
          SizedBox(
            height: 8,
          ),
          Text(
            "Web Wallet $APP_VERSION",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.7),
              letterSpacing: 2,
            ),
          ),
        ]
      ],
    );
  }
}
