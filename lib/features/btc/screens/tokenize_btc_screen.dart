import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_constants.dart';
import '../../../core/base_component.dart';
import '../../../core/base_screen.dart';
import '../../../core/dialogs.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/components.dart';
import '../../btc_web/components/web_mpc_ceremony_dialog.dart';
import '../../wallet/providers/wallet_list_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/toast.dart';

import '../components/mpc_ceremony_progress_modal.dart';
import '../providers/mpc_ceremony_provider.dart';
import '../providers/tokenize_btc_form_provider.dart';

class TokenizeBtcScreen extends BaseScreen {
  const TokenizeBtcScreen({super.key});

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: Colors.black,
      title: Text(AppLocalizations.of(context).btcTokenizeTitle),
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: TokenizeBtcForm(
        onSuccess: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class TokenizeBtcForm extends BaseComponent {
  final VoidCallback onSuccess;
  const TokenizeBtcForm({super.key, required this.onSuccess});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(tokenizeBtcFormProvider);
    final formProvider = ref.read(tokenizeBtcFormProvider.notifier);
    final ceremonyState = ref.watch(mpcCeremonyProvider);

    // Watch for ceremony completion to trigger contract creation
    ref.listen<MpcCeremonyState>(mpcCeremonyProvider, (previous, next) {
      if (previous?.phase != MpcCeremonyPhase.ceremonyCompleted &&
          next.phase == MpcCeremonyPhase.ceremonyCompleted) {
        // Ceremony just completed — create the contract
        formProvider.createContractFromCeremony();
      }
      if (next.isContractCreated) {
        onSuccess();
      }
    });

    return AppCard(
      padding: 16,
      child: Form(
        key: formProvider.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 6,
            ),
            TextFormField(
              controller: formProvider.tokenNameController,
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.getWhite()),
                ),
                label: Text(
                  AppLocalizations.of(context).bw2TokenNameOptional,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                hintText: AppLocalizations.of(context).btcVbtcTokenHint,
              ),
            ),
            TextFormField(
              controller: formProvider.tokenDescriptionController,
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.getWhite()),
                ),
                label: Text(
                  AppLocalizations.of(context).bw2TokenDescriptionOptional,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                hintText: AppLocalizations.of(context).btcVbtcTokenHint,
              ),
              minLines: 3,
              maxLines: 3,
            ),
            TextFormField(
              controller: formProvider.tokenTickerController,
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.getWhite()),
                ),
                label: Text(
                  AppLocalizations.of(context).bw2TokenTickerOptional,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                hintText: AppLocalizations.of(context).btcVbtcHint,
              ),
            ),
            SizedBox(
              height: 22,
            ),
            Center(
              child: _buildSubmitButton(context, ref, formState, formProvider, ceremonyState),
            ),
            SizedBox(
              height: 8,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    WidgetRef ref,
    TokenizeBtcFormState formState,
    TokenizeBtcFormProvider formProvider,
    MpcCeremonyState ceremonyState,
  ) {
    // If a ceremony is in progress, show "View Progress" button
    if (!ceremonyState.isIdle && !ceremonyState.isFailed && !ceremonyState.isContractCreated) {
      return VBtcButton(
        label: AppLocalizations.of(context).btcViewProgress,
        icon: Icons.visibility,
        onPressed: () {
          MpcCeremonyProgressModal.show(context);
        },
      );
    }

    // Web flow — V2 MPC ceremony
    if (kIsWeb) {
      return VBtcButton(
        label: AppLocalizations.of(context).tkbCreateVbtcToken,
        onPressed: () async {
          if (formState.isProcessing) return;

          final keypair = ref.read(webSessionProvider).keypair;
          if (keypair == null) {
            Toast.error(AppLocalizations.of(context).bw2VfxAccountRequired);
            return;
          }

          final balance = ref.read(webSessionProvider).balance;
          if (balance == null || balance < MIN_RBX_FOR_SC_ACTION) {
            Toast.error(AppLocalizations.of(context).bw2VfxAccountBalanceRequiredShort);
            return;
          }

          final formProvider = ref.read(tokenizeBtcFormProvider.notifier);
          final success = await WebMpcCeremonyDialog.show(
            ownerAddress: keypair.address,
            name: formProvider.tokenNameController.text.trim(),
            description: formProvider.tokenDescriptionController.text.trim(),
            ticker: formProvider.tokenTickerController.text.trim(),
          );

          if (success == true) {
            formProvider.clear();
            if (context.mounted) Navigator.of(context).pop();
          }
        },
      );
    }

    // Desktop V2 flow
    return VBtcButton(
      label: AppLocalizations.of(context).btcMintAndDeploy,
      onPressed: () async {
        if (formState.isProcessing) return;

        if (formState.vfxAddress == null) {
          Toast.error(AppLocalizations.of(context).btcVfxAddressRequired);
          return;
        }

        final confirmed = await ConfirmDialog.show(
          title: AppLocalizations.of(context).btcCreateVbtcTitle,
          cancelText: AppLocalizations.of(context).actionCancel,
          confirmText: AppLocalizations.of(context).btcMintAndDeploy,
          content: Consumer(builder: (context, ref, child) {
            final formState = ref.watch(tokenizeBtcFormProvider);
            final formProvider = ref.read(tokenizeBtcFormProvider.notifier);

            final wallets = ref.watch(walletListProvider).where((a) => a.balance > MIN_RBX_FOR_SC_ACTION && !a.isReserved);

            return ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context).btcMpcStartBody),
                  Text(AppLocalizations.of(context).btcNetworkFeeBody),
                  if (wallets.length == 1) Text(AppLocalizations.of(context).btcVfxAccountLabel(formState.vfxAddress ?? '')),
                  if (wallets.length > 1)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12),
                        Text(AppLocalizations.of(context).btcChangeAccountLabel),
                        Row(
                          children: [
                            PopupMenuButton<String>(
                              onSelected: (address) {
                                formProvider.setAddress(address);
                              },
                              color: Color(0xFF080808),
                              constraints: const BoxConstraints(
                                minWidth: 2.0 * 56.0,
                                maxWidth: 8.0 * 56.0,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(AppLocalizations.of(context).btcVfxAddressLabel),
                                  SizedBox(width: 4),
                                  Text(
                                    formState.vfxAddress ?? "None",
                                    style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                                  ),
                                  Transform.translate(
                                    offset: Offset(0, 2),
                                    child: Icon(
                                      Icons.arrow_drop_down,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              itemBuilder: (context) {
                                return wallets.map(
                                  (w) {
                                    return PopupMenuItem(
                                      value: w.address,
                                      child: Text(
                                        "${w.labelWithoutTruncation} (${w.balance} VFX)",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: w.address == formState.vfxAddress ? Theme.of(context).colorScheme.secondary : Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                ).toList();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  SizedBox(height: 12),
                  Text(AppLocalizations.of(context).btcContinueQuestion),
                ],
              ),
            );
          }),
        );

        if (confirmed != true) return;

        final success = await formProvider.submit();

        if (success == true) {
          final created = await MpcCeremonyProgressModal.show(context);

          if (created == true) {
            formProvider.clear();
            if (context.mounted) Navigator.of(context).pop();
          }
        }
      },
    );
  }
}
