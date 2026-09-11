import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/base_component.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../global_loader/global_loading_provider.dart';
import '../../nft/providers/nft_detail_watcher.dart';
import '../providers/pending_token_pause_provider.dart';
import '../services/token_service.dart';
import '../../../utils/toast.dart';

class PauseTokenButton extends BaseComponent {
  final String scId;
  final String fromAddress;
  final bool isOwnedByRa;
  final VoidCallback showRaErrorMessage;

  const PauseTokenButton({
    super.key,
    required this.scId,
    required this.fromAddress,
    required this.isOwnedByRa,
    required this.showRaErrorMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final data = ref.watch(nftDetailWatcher(scId));

    return data.when(
        loading: () => SizedBox(),
        error: (_, __) => SizedBox(),
        data: (nft) {
          if (nft == null) {
            return SizedBox();
          }

          final isPaused = nft.tokenStateDetails?.isPaused == true;

          if (ref.watch(pendingTokenPauseProvider).contains(nft.id)) {
            return AppButton(
              label: isPaused ? l10n.r3hPendingResume : l10n.r3hPendingPause,
              processing: true,
              variant: AppColorVariant.Light,
              onPressed: () {
                Toast.message(AppLocalizations.of(context).tokenStateChangePendingToast);
              },
            );
          }

          return AppButton(
            label: isPaused ? l10n.r3hResumeTxs : l10n.r3hPauseTxs,
            variant: isOwnedByRa ? AppColorVariant.Primary : AppColorVariant.Light,
            useDisabledColor: isOwnedByRa,
            onPressed: () async {
              if (isOwnedByRa) {
                showRaErrorMessage();
                return;
              }
              final confirmed = await ConfirmDialog.show(
                title: isPaused ? l10n.r3hResumeTokenTransactions : l10n.r3hPauseTokenTransactions,
                body: isPaused
                    ? l10n.r3hResumeTokenTxConfirmBody
                    : l10n.r3hPauseTokenTxConfirmBody,
                confirmText: isPaused ? l10n.r3hResume : l10n.r3hPause,
                cancelText: l10n.actionCancel,
              );

              if (confirmed != true) {
                return;
              }

              ref.read(globalLoadingProvider.notifier).start();
              final success = await TokenService().pause(
                scId: scId,
                fromAddress: fromAddress,
              );
              ref.read(globalLoadingProvider.notifier).complete();

              if (success) {
                ref.read(pendingTokenPauseProvider.notifier).addId(scId);

                Toast.message(isPaused ? l10n.r3hTokenResumeBroadcasted : l10n.r3hTokenPauseBroadcasted);
              }
            },
          );
        });
  }
}
