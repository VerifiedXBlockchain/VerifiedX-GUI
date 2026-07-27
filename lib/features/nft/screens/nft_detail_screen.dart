import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/core/services/explorer_service.dart';
import 'package:rbx_wallet/core/utils.dart';
import 'package:rbx_wallet/features/raw/raw_service.dart';
import 'package:rbx_wallet/features/web/utils/raw_transaction.dart';
import '../../../core/theme/colors.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../../core/theme/components.dart';
import '../providers/sale_provider.dart';
import '../services/nft_service.dart';
import '../../smart_contracts/services/smart_contract_service.dart';
import '../../global_loader/global_loading_provider.dart';
import '../../sc_property/models/sc_property.dart';

import '../../../core/app_constants.dart';
import '../../../core/base_screen.dart';
import '../../../core/components/badges.dart';
import '../../../core/components/buttons.dart';
import '../../../core/components/centered_loader.dart';
import '../../../core/dialogs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/l10n_helper.dart';
import '../../../utils/toast.dart';
import '../../../utils/validation.dart';
import '../../asset/asset_card.dart';
import '../../asset/asset_thumbnail.dart';
import '../../bridge/services/bridge_service.dart';
import '../../encrypt/utils.dart';
import '../../smart_contracts/components/sc_creator/common/help_button.dart';
import '../../smart_contracts/components/sc_creator/common/modal_container.dart';
import '../../smart_contracts/components/sc_creator/modals/code_modal.dart';
import '../../smart_contracts/models/feature.dart';
import '../../smart_contracts/providers/my_smart_contracts_provider.dart';
import '../../wallet/models/wallet.dart';
import '../../wallet/providers/wallet_list_provider.dart';
import '../components/media_backup.dart';
import '../components/nft_qr_code.dart';
import '../components/web_asset_card.dart';
import '../components/web_asset_thumbnail.dart';
import '../modals/nft_management_modal.dart';
import '../models/nft.dart';
import '../providers/nft_detail_provider.dart';
import '../utils.dart';

class NftDetailScreen extends BaseScreen {
  final String id;
  final bool fromCreator;

  const NftDetailScreen({
    @PathParam('id') required this.id,
    Key? key,
    this.fromCreator = false,
  }) : super(key: key);

  void copyToClipboard(String val) async {
    await Clipboard.setData(
      ClipboardData(text: val),
    );
    Toast.message(globalL10n.r3gValueCopiedToClipboard(val));
  }

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    final nft = ref.watch(nftDetailProvider(id));

    return AppBar(
      title: nft != null ? Text(nft.currentEvolveName) : Text(AppLocalizations.of(context).nftDetailFallback),
      backgroundColor: Colors.black12,
      shadowColor: Colors.transparent,
      // leading: AutoRouter.of(context).canPopSelfOrChildren
      //     ? IconButton(
      //         onPressed: () {
      //           AutoRouter.of(context).pop();
      //         },
      //         icon: Icon(
      //           Icons.navigate_before,
      //           size: 32,
      //         ))
      //     : GestureDetector(
      //         onTap: () {
      //           AutoRouter.of(context).push(WebDashboardContainerRoute());
      //         },
      //         child: SizedBox(
      //           width: 24,
      //           height: 24,
      //           child: Image.asset(
      //             Assets.images.animatedCube.path,
      //             scale: 1,
      //           ),
      //         ),
      //       ),
      actions: [
        if (nft != null && !nft.isToken)
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!nft.isPublished) const HelpButton(HelpType.minting),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: AppBadge(
                    label: nft.isPublished ? AppLocalizations.of(context).r3gMinted : AppLocalizations.of(context).r3gMinting,
                    variant: nft.isPublished
                        ? AppColorVariant.Success
                        : AppColorVariant.Warning,
                    progressAnimation: !nft.isPublished,
                  ),
                ),
                if (nft.isListed(ref))
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: AppBadge(
                      label: AppLocalizations.of(context).nftBadgeListed,
                    ),
                  ),
                SizedBox(
                  width: 8,
                ),
              ],
            ),
          )
      ],
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final _provider = ref.read(nftDetailProvider(id).notifier);
    final nft = ref.watch(nftDetailProvider(id));

    if (nft == null) {
      return const CenteredLoader();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (nft.isLocked)
                  Container(
                    decoration: BoxDecoration(color: Colors.red.shade800),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Center(
                          child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock,
                            size: 16,
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            AppLocalizations.of(context).nftLockedBadge,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )),
                    ),
                  ),
                AppCard(
                  padding: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              nft.currentEvolveName,
                              style: TextStyle(
                                fontSize: 40,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                height: 1,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.getBlue(ColorShade.s300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Tooltip(
                                    message: AppLocalizations.of(context).btcDetailScIdLabel,
                                    child: Text(
                                      nft.id,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 6,
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      await Clipboard.setData(
                                          ClipboardData(text: nft.id));
                                      Toast.message(
                                          AppLocalizations.of(context).r3gSmartContractIdCopied);
                                    },
                                    child: Icon(
                                      Icons.copy,
                                      size: 14,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      if (nft.minterName.isNotEmpty)
                        Text(
                          AppLocalizations.of(context).r3gMintedByName(nft.minterName),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                color: Colors.white,
                                height: 1,
                              ),
                        ),
                      const SizedBox(
                        height: 4,
                      ),
                      _buildDescriptionWithDecrypt(context, ref, nft),
                    ],
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    if (nft.currentOwner.isNotEmpty)
                      Expanded(
                        child: AppCard(
                          padding: 0,
                          child: ListTile(
                            title: Text(
                              nft.currentOwner,
                              style: TextStyle(
                                fontSize: 13,
                                color: nft.currentOwner.startsWith("xRBX")
                                    ? Colors.deepPurple.shade200
                                    : AppColors.getBlue(ColorShade.s50),
                              ),
                            ),
                            subtitle: Text(
                              AppLocalizations.of(context).btcDetailOwnerLabel,
                            ),
                            trailing: IconButton(
                              iconSize: 16,
                              icon: const Icon(Icons.copy),
                              onPressed: () {
                                copyToClipboard(nft.currentOwner);
                              },
                            ),
                          ),
                        ),
                      ),
                    if (nft.minterAddress.isNotEmpty)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: AppCard(
                            padding: 0,
                            child: ListTile(
                              title: Text(
                                nft.minterAddress,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.getBlue(ColorShade.s50),
                                ),
                              ),
                              subtitle: Text(AppLocalizations.of(context).nftMinterAddressLabel),
                              trailing: IconButton(
                                icon: const Icon(Icons.copy),
                                iconSize: 16,
                                onPressed: () {
                                  copyToClipboard(nft.minterAddress);
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                if (nft.nextOwner != null && nft.nextOwner!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: AppCard(
                      padding: 0,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(nft.nextOwner!,
                            style: TextStyle(
                                fontSize: 13,
                                color: nft.nextOwner!.startsWith("xRBX")
                                    ? Colors.deepPurple.shade200
                                    : Colors.white)),
                        subtitle: Text(
                          AppLocalizations.of(context).r3gNextOwner,
                        ),
                        leading: IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            copyToClipboard(nft.nextOwner!);
                          },
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Wrap(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppCard(
                            padding: 8,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 512),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    kIsWeb
                                        ? nft.currentEvolveAssetWeb != null
                                            ? WebAssetCard(
                                                nft, nft.currentEvolveAssetWeb)
                                            : buildAssetsNotAvailable(_provider)
                                        : AssetCard(
                                            nft.currentEvolveAsset,
                                            ownerAddress: nft.nextOwner ??
                                                nft.currentOwner,
                                            nftId: nft.id,
                                            isPrimaryAsset: true,
                                          ),
                                    if (nft.additionalAssets.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context).r3gAdditionalAssetsColon,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall!
                                                  .copyWith(
                                                    color: Colors.white,
                                                  ),
                                            ),
                                            const SizedBox(
                                              height: 6,
                                            ),
                                            kIsWeb &&
                                                    nft.additionalAssetsWeb ==
                                                        null
                                                ? buildAssetsNotAvailable(
                                                    _provider, false)
                                                : kIsWeb
                                                    ? Wrap(
                                                        children:
                                                            (nft.additionalAssetsWeb ??
                                                                    [])
                                                                .map(
                                                                  (a) =>
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            6.0),
                                                                    child:
                                                                        WebAssetThumbnail(
                                                                      a,
                                                                      nft: nft,
                                                                    ),
                                                                  ),
                                                                )
                                                                .toList(),
                                                      )
                                                    : Wrap(
                                                        children: nft
                                                            .additionalLocalAssets
                                                            .map(
                                                              (a) => Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            6.0),
                                                                child:
                                                                    AssetThumbnail(
                                                                  a,
                                                                  nftId: nft.id,
                                                                  ownerAddress:
                                                                      nft.nextOwner ??
                                                                          nft.currentOwner,
                                                                  isPrimaryAsset:
                                                                      false,
                                                                ),
                                                              ),
                                                            )
                                                            .toList(),
                                                      ),
                                          ],
                                        ),
                                      )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 316),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppCard(
                                padding: 8,
                                child: NftQrCode(
                                  data: nft.explorerUrl,
                                  size: 300,
                                  withOpen: true,
                                ),
                              ),
                              MediaBackup(nft),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                if (nft.currentEvolveProperties.isNotEmpty) ...[
                  const Divider(),
                  Text(AppLocalizations.of(context).nftPropertiesHeading,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(color: Colors.white)),
                  SizedBox(
                    height: 8,
                  ),
                  NftPropertiesWrap(
                    properties: nft.currentEvolveProperties,
                  )
                ],
                const Divider(),
                Text(AppLocalizations.of(context).nftFeaturesHeading,
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          color: Colors.white,
                        )),
                if (nft.features.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.cancel,
                          size: 16,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Text(
                            AppLocalizations.of(context).r3gNoFeatures,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: nft.featureList
                      .map(
                        (f) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: AppCard(
                            padding: 0,
                            child: ListTile(
                              leading: Icon(f.icon),
                              title: Text(f.nameLabel),
                              subtitle: Text(f.description),
                              trailing: f.type == FeatureType.evolution
                                  ? AppButton(
                                      label: AppLocalizations.of(context).nftRevealEvolveStages,
                                      variant: AppColorVariant.Dark,
                                      onPressed: () {
                                        showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.black87,
                                            builder: (context) {
                                              final address = kIsWeb
                                                  ? ref.watch(webSessionProvider
                                                      .select((value) => value
                                                          .keypair?.address))
                                                  : null;

                                              return ModalContainer(
                                                  color: Colors.black26,
                                                  children: [
                                                    Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        EvolutionStateRow(
                                                          nft.baseEvolutionPhase,
                                                          nft: nft,
                                                          nftId: id,
                                                          canManageEvolve: nft
                                                              .canManageEvolve(
                                                                  address),
                                                          index: 0,
                                                        ),
                                                        ...nft
                                                            .updatedEvolutionPhases
                                                            .asMap()
                                                            .entries
                                                            .map(
                                                              (entry) =>
                                                                  EvolutionStateRow(
                                                                entry.value,
                                                                nft: nft,
                                                                nftId: id,
                                                                canManageEvolve:
                                                                    nft.canManageEvolve(
                                                                        address),
                                                                index:
                                                                    entry.key +
                                                                        1,
                                                                onAssociate:
                                                                    () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                              ),
                                                            )
                                                            .toList(),
                                                      ],
                                                    )
                                                  ]);
                                            });
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        if (!nft.isLocked)
          Padding(
            padding: const EdgeInsets.all(4.0).copyWith(bottom: 24, top: 8),
            child: Center(
              child: Wrap(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,

                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: AppButton(
                      label: AppLocalizations.of(context).nftProveOwnership,
                      icon: Icons.security,
                      variant: AppColorVariant.Primary,
                      onPressed: () {
                        proveSmartContractOwnership(
                            context, ref, nft.currentOwner, nft.id);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: AppButton(
                      label: AppLocalizations.of(context).nftTransfer,
                      // helpType: HelpType.transfer,
                      icon: Icons.send,
                      onPressed: nft.isPublished
                          ? () async {
                              initTransferNftProcess(context, ref, nft);
                            }
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: AppButton(
                      label: AppLocalizations.of(context).nftSell,
                      // helpType: HelpType.transfer,
                      icon: Icons.attach_money,
                      onPressed: () async {
                        final l10n = AppLocalizations.of(context);
                        if (kIsWeb) {
                          Toast.message(l10n.nftActivatingSoonToast);
                          return;
                        }
                        if (!await passwordRequiredGuard(context, ref)) {
                          return;
                        }
                        Wallet? wallet = ref
                            .read(walletListProvider)
                            .firstWhereOrNull(
                                (w) => w.address == nft.currentOwner);
                        if (wallet == null) {
                          Toast.error(l10n.nftNoAccountSelectedToast);
                          return;
                        }

                        if (wallet.isReserved) {
                          Toast.error(l10n.nftVaultCannotSellToast);
                          return;
                        }

                        if (wallet.balance < MIN_RBX_FOR_SC_ACTION) {
                          Toast.error(l10n.nftNotEnoughBalanceToast);
                          return;
                        }

                        final _nft = await setAssetPath(nft);

                        final filesReady = await _nft.areFilesReady();

                        if (!filesReady) {
                          Toast.error(l10n.nftMediaNotFoundToast);
                          return;
                        }
                        String? address = await PromptModal.show(
                          contextOverride: context,
                          title: l10n.nftSellTitle,
                          validator: (value) =>
                              formValidatorRbxAddress(value, true),
                          labelText: l10n.nftSellAddressLabel,
                          confirmText: l10n.actionContinue,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp('[a-zA-Z0-9.]')),
                          ],
                          lines: 1,
                        );

                        if (address == null) {
                          return;
                        }

                        address = address.trim().replaceAll("\n", "");

                        final isValid = await BridgeService()
                            .validateSendToAddress(address);
                        if (!isValid) {
                          Toast.error(l10n.nftInvalidAddressToast);
                          return;
                        }

                        final String? amountString = await PromptModal.show(
                          contextOverride: context,
                          title: l10n.nftSellAmountTitle,
                          body: l10n.r3gSellNftPrompt,
                          labelText: l10n.nftSellAmountLabel,
                          confirmText: l10n.actionContinue,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp("[0-9.]"))
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.svcAmountRequired;
                            }

                            double parsed = 0;
                            try {
                              parsed = double.parse(value);
                            } catch (e) {
                              return l10n.svcNotValidAmount;
                            }

                            if (parsed <= 0) {
                              return l10n.svcAmountPositive;
                            }
                            return null;
                          },
                        );

                        if (amountString == null) {
                          return;
                        }

                        final amount = double.tryParse(amountString);

                        if (amount == null) {
                          Toast.error(l10n.nftSellInvalidAmountToast);
                          return;
                        }

                        final String? backupUrl = await PromptModal.show(
                          contextOverride: context,
                          title: l10n.nftBackupUrlTitle,
                          body: l10n.r3gPasteZipfileUrl,
                          validator: (value) {
                            return null;
                          },
                          labelText: l10n.nftBackupUrlLabel,
                          confirmText: l10n.actionContinue,
                        );

                        final confirmed = await ConfirmDialog.show(
                          title: l10n.nftConfirmSaleStartTitle,
                          body: l10n.r3gConfirmSellNftBody(address, amount.toString()),
                          confirmText: l10n.r3gStartSale,
                        );

                        if (confirmed == true) {
                          ref.read(globalLoadingProvider.notifier).start();
                          final success = await SmartContractService()
                              .transferSale(id, address, amount, backupUrl);
                          ref.read(globalLoadingProvider.notifier).complete();
                          if (success) {
                            // Toast.message("Sale Start transaction broadcasted");
                            ref.read(saleProvider.notifier).addId(id);
                            Navigator.of(context).pop();
                          }
                        }
                      },
                    ),
                  ),

                  Builder(builder: (context) {
                    final address = kIsWeb
                        ? ref.watch(webSessionProvider
                            .select((value) => value.keypair?.address))
                        : null;
                    if (nft.manageable && nft.canManage(address)) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: AppButton(
                          label: AppLocalizations.of(context).nftManage,
                          icon: Icons.settings,
                          onPressed: () {
                            showModalBottomSheet(
                              isScrollControlled: true,
                              backgroundColor: Colors.black87,
                              context: context,
                              builder: (context) {
                                return ModalContainer(
                                  color: Colors.black26,
                                  children: [
                                    NftMangementModal(nft.id, nft,
                                        showViewNft: false)
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  }),
                  // if (!kIsWeb)
                  //   Padding(
                  //     padding: const EdgeInsets.all(4.0),
                  //     child: AppButton(
                  //       label: nft.isPublic ? "Make Private" : "Make Public",
                  //       icon: nft.isPublic ? Icons.visibility_off : Icons.visibility,
                  //       onPressed: () {
                  //         _provider.togglePrivate();
                  //       },
                  //     ),
                  //   ),
                  if (nft.code != null)
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: AppButton(
                        label: AppLocalizations.of(context).nftViewCode,
                        icon: Icons.code,
                        variant: AppColorVariant.Primary,
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return CodeModal(nft.code!);
                            },
                          );
                        },
                      ),
                    ),

                  if (!kIsWeb)
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: AppButton(
                        label: AppLocalizations.of(context).nftSyncMedia,
                        icon: Icons.sync,
                        variant: AppColorVariant.Primary,
                        onPressed: () async {
                          final assets = [
                            nft.primaryAsset,
                            ...nft.additionalAssets
                          ];
                          Map<String, String> mediaMap = {};
                          for (final a in assets) {
                            final bytes = await a.file.readAsBytes();
                            final url = await ExplorerService()
                                .uploadAsset(bytes, a.fileName, a.extension);

                            mediaMap[a.fileName] = url ?? 'ERROR';
                          }

                          await ExplorerService()
                              .associateMedia(nft.id, mediaMap);
                        },
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: AppButton(
                      label: AppLocalizations.of(context).nftBurn,
                      icon: Icons.fire_hydrant,
                      // helpType: HelpType.burn,
                      variant: AppColorVariant.Danger,
                      onPressed: nft.isPublished
                          ? () async {
                              if (nft.isListed(ref)) {
                                Toast.error(
                                    AppLocalizations.of(context).r3gNftListedBeforeBurning);
                                return;
                              }

                              if (!await passwordRequiredGuard(context, ref))
                                return;

                              if (kIsWeb) {
                                if (nft.currentOwner.startsWith("xRBX")) {
                                  Toast.error(
                                      AppLocalizations.of(context).r3gVaultCannotBurnNfts);
                                  return;
                                }
                              } else {
                                if (nft.currentOwner.startsWith("xRBX")) {
                                  Toast.error(
                                      AppLocalizations.of(context).r3gVaultCannotBurnNfts);
                                  return;
                                }
                              }

                              final confirmed = await ConfirmDialog.show(
                                title: AppLocalizations.of(context).nftBurnTitle,
                                body:
                                    AppLocalizations.of(context).r3gConfirmBurnName(nft.name),
                                destructive: true,
                                confirmText: AppLocalizations.of(context).nftBurn,
                                cancelText: AppLocalizations.of(context).actionCancel,
                              );

                              if (confirmed == true) {
                                ref
                                    .read(globalLoadingProvider.notifier)
                                    .start();
                                final success = kIsWeb
                                    ? await _provider.burnWeb()
                                    : await _provider.burn();

                                if (success) {
                                  Toast.message(
                                      AppLocalizations.of(context).r3gBurnSentSuccess);
                                  ref
                                      .read(mySmartContractsProvider.notifier)
                                      .load();
                                  Navigator.of(context).pop();
                                  ref
                                      .read(globalLoadingProvider.notifier)
                                      .complete();
                                } else {
                                  ref
                                      .read(globalLoadingProvider.notifier)
                                      .complete();

                                  Toast.error();
                                }
                              }
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          )
      ],
    );
  }

  Widget buildAssetsNotAvailable(NftDetailProvider _provider,
      [bool includeButton = true]) {
    return Builder(builder: (context) => Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          color: Colors.black12,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context).r3gNftAssetsNotTransferred,
                  textAlign: TextAlign.center,
                ),
                if (includeButton)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: AppButton(
                      label: AppLocalizations.of(context).nftTransferNow,
                      onPressed: () async {
                        final success = await _provider.transferWebIn();

                        if (success == true) {
                          Toast.message(AppLocalizations.of(context).btcTransferNowToast);
                        }
                      },
                      variant: AppColorVariant.Success,
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildDescriptionWithDecrypt(
    BuildContext context,
    WidgetRef ref,
    Nft nft,
  ) {
    // Get user's addresses for checking ownership
    final List<String> userAddresses = [];

    if (kIsWeb) {
      final keypair = ref.watch(webSessionProvider.select((value) => value.keypair));
      if (keypair?.address != null) {
        userAddresses.add(keypair!.address);
      }
    } else {
      final wallets = ref.watch(walletListProvider);
      userAddresses.addAll(wallets.map((w) => w.address));
    }

    final canDecrypt = nft.canDecryptMessage(userAddresses);
    final hasEncrypted = nft.hasEncryptedMessage;
    final provider = ref.read(nftDetailProvider(nft.id).notifier);
    final decryptedMessage = provider.decryptedMessage;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          nft.currentEvolveDescription.replaceAll("\\n", "\n"),
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
        ),
        if (hasEncrypted && canDecrypt && decryptedMessage == null) ...[
          const SizedBox(height: 8),
          Center(
            child: AppButton(
              label: AppLocalizations.of(context).nftDecrypt,
              icon: Icons.lock_open,
              variant: AppColorVariant.Success,
              onPressed: () async {
                final success = await provider.decryptMessage();
                if (!success) {
                  // Error toast already shown in provider
                }
              },
            ),
          ),
        ],
        if (decryptedMessage != null) ...[
          const SizedBox(height: 8),
          AppBadge(
            label: AppLocalizations.of(context).nftDecrypted,
            variant: AppColorVariant.Success,
          ),
        ],
      ],
    );
  }
}

class NftPropertiesWrap extends StatelessWidget {
  final Color? cardColor;
  final List<ScProperty> properties;

  const NftPropertiesWrap({
    Key? key,
    required this.properties,
    this.cardColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      // mainAxisSize: MainAxisSize.min,
      spacing: 12,
      runSpacing: 12,
      children: properties.map((p) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 250),
          child: AppCard(
            padding: 8,
            child: ListTile(
              // dense: true,
              visualDensity: VisualDensity.compact,
              leading: Builder(builder: (context) {
                switch (p.type) {
                  case ScPropertyType.color:
                    return Icon(
                      Icons.color_lens,
                      color: colorFromHex(p.value),
                    );
                  case ScPropertyType.number:
                    return Icon(Icons.numbers);
                  case ScPropertyType.url:
                    return Icon(Icons.link);
                  default:
                    return Icon(Icons.text_fields);
                }
              }),
              title: Builder(builder: (context) {
                if (p.name == BACKUP_URL_PROPERTY_NAME) {
                  final url = p.value
                      .replaceAll("https//", "https://")
                      .replaceAll("http//", 'http://');
                  return Tooltip(
                    message: url,
                    child: InkWell(
                      onTap: () {
                        launchUrlString(url);
                      },
                      child: Text(
                        AppLocalizations.of(context).nftQrOpen,
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                  );
                }
                return Text(p.value);
              }),
              subtitle: Builder(builder: (context) {
                if (p.name == BACKUP_URL_PROPERTY_NAME) {
                  return Text(AppLocalizations.of(context).nftMediaBackupUrl);
                }
                return Text(p.name);
              }),
            ),
          ),
        );
      }).toList(),
    );
  }
}
