import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/breakpoints.dart';
import '../../../core/app_constants.dart';
import '../../../core/dialogs.dart';
import '../../../core/env.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/providers/web_session_provider.dart';
import '../components/sc_wizard_list.dart';
import '../models/bulk_smart_contract_entry.dart';
import 'sc_wizard_edit_item_screen.dart';
import '../../wallet/components/wallet_selector.dart';
import 'package:collection/collection.dart';
import '../../../utils/toast.dart';

import '../../../core/base_screen.dart';
import '../../../core/components/buttons.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/sc_wizard_provider.dart';
import '../../../l10n/generated/app_localizations.dart';

class SmartContractWizardScreen extends BaseScreen {
  const SmartContractWizardScreen({Key? key})
      : super(
          key: key,
          verticalPadding: 0,
          horizontalPadding: 0,
        );

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppBar(
      title: Text(l10n.r3aNftCollectionWizard),
      backgroundColor: Colors.black12,
      shadowColor: Colors.transparent,
      actions: [
        !Env.isWeb ? WalletSelector() : SizedBox.shrink(),
      ],
      leading: IconButton(
          onPressed: () async {
            final confirmed = await ConfirmDialog.show(
              title: l10n.r3aCloseNftWizardConfirm,
              body: l10n.configCloseDialogBody,
              cancelText: l10n.actionCancel,
              confirmText: l10n.actionContinue,
            );
            if (confirmed == true) {
              ref.read(scWizardProvider.notifier).clear();
              Navigator.of(context).pop();
            }
          },
          icon: Icon(Icons.chevron_left)),
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final provider = ref.read(scWizardProvider.notifier);
    final items = ref.watch(scWizardProvider);
    final isMobile = BreakPoints.useMobileLayout(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        const Expanded(child: ScWizardList()),
        if (items.isNotEmpty)
          Container(
            color: Colors.black87,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AppButton(
                    label: l10n.actionClear,
                    onPressed: () async {
                      if (items.isEmpty) {
                        provider.clear();
                        Navigator.of(context).pop();
                        return;
                      }

                      final confirmed = await ConfirmDialog.show(
                        title: l10n.r3aClearNftWizardTitle,
                        body: l10n.r3aRemoveEverythingConfirm,
                        cancelText: l10n.actionCancel,
                        confirmText: l10n.actionClear,
                        destructive: true,
                      );

                      if (confirmed == true) {
                        provider.clear();
                        Navigator.of(context).pop();
                      }
                    },
                    variant: AppColorVariant.Danger,
                  ),
                  AppButton(
                    label: isMobile ? l10n.r3aNewInstance : l10n.r3aCreateNewInstance,
                    onPressed: () {
                      provider.insert(
                        entry: BulkSmartContractEntry.empty(),
                        index: items.length,
                        y: 0,
                        x: 0,
                      );

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ScWizardEditItemScreen(
                            title: l10n.r3aCreateInstance,
                            index: items.length,
                          ),
                        ),
                      );
                    },
                    variant: AppColorVariant.Primary,
                  ),
                  AppButton(
                    label: isMobile ? l10n.r3aMint : l10n.btcCompileMint,
                    onPressed: () async {
                      final wallet = kIsWeb ? ref.read(webSessionProvider).currentWallet : ref.read(sessionProvider).currentWallet;
                      if (wallet == null) {
                        Toast.error(l10n.svcNoAccountSelectedPeriod);

                        return;
                      }

                      final amount = items.map((e) => e.entry.quantity).toList().sum;
                      if (amount < 1) {
                        return;
                      }

                      if (!kIsWeb) {
                        if (wallet.balance < MIN_RBX_FOR_SC_ACTION) {
                          Toast.error(l10n.r3aNotEnoughVfxToMint);
                          return;
                        }
                      }

                      final confirmed = await ConfirmDialog.show(
                        title: l10n.r3aCompileMintScConfirm,
                        body: l10n.r3aConfirmMintBody(amount.toString()),
                        confirmText: l10n.actionContinue,
                        cancelText: l10n.actionCancel,
                      );

                      if (confirmed == true) {
                        final extraConfirm = await ConfirmDialog.show(
                          title: l10n.tokenFormConfirmAddressTitle,
                          body: l10n.r3aWillBeMintedBy(wallet.labelWithoutTruncation),
                          confirmText: l10n.btcCompileMint,
                          cancelText: l10n.actionCancel,
                        );

                        if (extraConfirm == true) {
                          ref.read(scWizardProvider.notifier).mint(context);
                        }
                      }
                    },
                    variant: AppColorVariant.Success,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
