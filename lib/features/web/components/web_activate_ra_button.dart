import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/base_component.dart';
import '../../../core/components/badges.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../../core/components/buttons.dart';
import 'package:flutter/material.dart';
import '../../../core/app_constants.dart';
import '../../../core/dialogs.dart';
import '../../../core/theme/app_theme.dart';
import '../../global_loader/global_loading_provider.dart';
import '../../raw/raw_service.dart';
import '../../reserve/vault_web_utils.dart';
import '../providers/web_ra_pending_activation_provider.dart';
import '../utils/raw_transaction.dart';
import '../../../utils/toast.dart';

class WebActivateRaButton extends BaseComponent {
  const WebActivateRaButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keypair = ref.watch(webSessionProvider.select((v) => v.raKeypair));

    final hasActivated = ref.watch(webRaPendingActivationProvider).contains(keypair?.address);

    if (keypair == null) {
      return SizedBox();
    }

    if (hasActivated) {
      return AppBadge(
        label: "Pending Activation",
        variant: AppColorVariant.Warning,
      );
    }

    return AppButton(
      label: "Activate Now",
      variant: AppColorVariant.Light,
      onPressed: () async {
        activateVaultAccountWeb(
          keypair: keypair,
          loadingProvider: ref.read(globalLoadingProvider.notifier),
          widgetRef: ref,
        );
      },
    );
  }
}
