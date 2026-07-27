import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../../core/app_constants.dart';
import '../../../core/components/buttons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../bridge/services/bridge_service.dart';
import '../../hd/components/restore_hd_wallet_button.dart';
import 'home_buttons/backup_button.dart';
import 'home_buttons/encrypt_wallet_button.dart';
import 'home_buttons/hd_wallet_button.dart';
import 'home_buttons/import_media_button.dart';
import 'home_buttons/import_snapshot_button.dart';
import 'home_buttons/mother_button.dart';
import 'home_buttons/open_db_button.dart';
import 'home_buttons/open_log_button.dart';
import 'home_buttons/print_addresses_button.dart';
import 'home_buttons/print_validators_button.dart';
import 'home_buttons/reserve_accounts_button.dart';
import 'home_buttons/restart_cli_button.dart';
import 'home_buttons/show_debug_data_button.dart';
import 'home_buttons/validating_check_button.dart';
import 'home_buttons/verify_nft_ownership_button.dart';
import '../../smart_contracts/components/sc_creator/common/modal_container.dart';

import '../../../core/theme/colors.dart';

enum HomeButtonSection {
  general,
  security,
  nft,
  validator,
  diagnose,
}

class HomeButtons extends StatefulWidget {
  final bool includeRestoreHd;
  const HomeButtons({super.key, required this.includeRestoreHd});

  @override
  State<HomeButtons> createState() => _HomeButtonsState();
}

class _HomeButtonsState extends State<HomeButtons> {
  Set<HomeButtonSection> selection = {HomeButtonSection.general};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tabsRouter = AutoTabsRouter.of(context);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      SegmentedButton<HomeButtonSection>(
        multiSelectionEnabled: false,
        selectedIcon: null,
        showSelectedIcon: false,
        style: ButtonStyle(
          side: MaterialStateProperty.all(
            BorderSide(
              width: 1,
              color: Colors.white10,
            ),
          ),
          splashFactory: NoSplash.splashFactory,
          backgroundColor: MaterialStateProperty.resolveWith(
            (states) {
              if (states.contains(MaterialState.selected)) {
                return AppColors.getBlue(ColorShade.s100);
              }
              if (states.contains(MaterialState.hovered)) {
                return AppColors.getBlue(ColorShade.s400);
              }
              if (states.contains(MaterialState.pressed)) {
                return AppColors.getBlue(ColorShade.s300);
              }
              return AppColors.getGray(ColorShade.s100);
            },
          ),
          foregroundColor: MaterialStateProperty.resolveWith(
            (states) {
              if (states.contains(MaterialState.selected)) {
                return Colors.black;
              }
              return AppColors.getWhite();
            },
          ),
        ),
        onSelectionChanged: (value) {
          if (value == selection) {
            return;
          }
          setState(() {
            selection = value;
          });
        },
        segments: [
          ButtonSegment(
            label: Text(l10n.votingCatGeneral),
            value: HomeButtonSection.general,
          ),
          ButtonSegment(
            label: Text(l10n.hnavSectionAccountSecurity),
            value: HomeButtonSection.security,
          ),
          ButtonSegment(
            label: Text(l10n.hnavSectionTokensNfts),
            value: HomeButtonSection.nft,
          ),
          if (VALIDATOR_NAV_ENABLED)
            ButtonSegment(
              label: Text(l10n.hnavSectionValidator),
              value: HomeButtonSection.validator,
            ),
          ButtonSegment(
            label: Text(l10n.hnavSectionDiagnose),
            value: HomeButtonSection.diagnose,
          ),
        ],
        selected: selection,
      ),
      SizedBox(
        height: 16,
      ),
      Builder(
        builder: (context) {
          if (selection.isEmpty) {
            return SizedBox();
          }

          switch (selection.first) {
            case HomeButtonSection.general:
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.start,
                children: [
                  RestartCliButton(),
                  PrintAdressesButton(),
                  const OpenDbFolderButton(),
                  ImportSnapshotButton(),
                  AppButton(
                    label: l10n.nodePoolTitle,
                    icon: Icons.wifi,
                    onPressed: () {
                      tabsRouter.setActiveIndex(6);
                    },
                  ),
                ],
              );
            case HomeButtonSection.security:
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.spaceEvenly,
                children: [
                  EncryptWalletButton(),
                  HdWalletButton(),
                  if (widget.includeRestoreHd) RestoreHdWalletButton(),
                  BackupButton(),
                  // ReserveAccountsButton(),
                ],
              );
            case HomeButtonSection.nft:
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.spaceEvenly,
                children: [
                  VerifyNftOwnershipButton(),
                  ImportMediaButton(),
                  // BackupButton(),
                  AppButton(
                    label: l10n.beaconTitle,
                    icon: Icons.satellite_alt,
                    onPressed: () {
                      tabsRouter.setActiveIndex(12);
                    },
                  ),
                  // AppButton(
                  //   label: "Fungible Tokens",
                  //   icon: Icons.toll,
                  //   onPressed: () {
                  //     tabsRouter.setActiveIndex(13);
                  //   },
                  // ),
                  // AppButton(
                  //   label: "Token Voting",
                  //   icon: Icons.gavel_outlined,
                  //   onPressed: () {
                  //     Toast.message("Coming Soon!");
                  //   },
                  // ),
                ],
              );

            case HomeButtonSection.validator:
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.spaceEvenly,
                children: [
                  // PrintValidatorsButton(),
                  ValidatingCheckButton(),
                  AppButton(
                    label: l10n.nodePoolTitle,
                    icon: Icons.wifi,
                    onPressed: () {
                      tabsRouter.setActiveIndex(6);
                    },
                  ),
                  AppButton(
                    label: l10n.hnavProposalsVoting,
                    icon: Icons.how_to_vote,
                    onPressed: () {
                      tabsRouter.setActiveIndex(11);
                    },
                  ),
                  MotherButton(),
                ],
              );
            case HomeButtonSection.diagnose:
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.spaceEvenly,
                children: [
                  RestartCliButton(),
                  const OpenDbFolderButton(),
                  OpenLogButton(),
                  ShowDebugDataButton(),
                  ValidatingCheckButton(),
                  AppButton(
                    label: l10n.hnavMempool,
                    icon: Icons.info,
                    onPressed: () async {
                      final data = await BridgeService().getMempool();
                      // if (data == null) {
                      //   Toast.message("Your Mempool is currently empty.");
                      //   return;
                      // }
                      showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return ModalContainer(
                              withDecor: false,
                              withClose: true,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    l10n.hnavMempool,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                                data == null
                                    ? Text(
                                        l10n.hnavMempoolEmpty,
                                        style: TextStyle(fontFamily: "RobotoMono"),
                                      )
                                    : TextFormField(
                                        minLines: 3,
                                        maxLines: 8,
                                        initialValue: data,
                                        readOnly: true,
                                        style: TextStyle(fontFamily: "RobotoMono"),
                                      ),
                              ],
                            );
                          });
                    },
                  ),
                ],
              );
          }
        },
      )
    ]);
  }
}
