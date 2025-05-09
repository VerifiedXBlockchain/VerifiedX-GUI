import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    Toast.message("$val copied to clipboard");
  }

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    final nft = ref.watch(nftDetailProvider(id));

    return AppBar(
      title: nft != null ? Text(nft.currentEvolveName) : const Text("NFT"),
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
                    label: nft.isPublished ? "Minted" : "Minting...",
                    variant: nft.isPublished ? AppColorVariant.Success : AppColorVariant.Warning,
                    progressAnimation: !nft.isPublished,
                  ),
                ),
                if (nft.isListed(ref))
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: AppBadge(
                      label: "Listed",
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
                            "NFT Locked",
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
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Tooltip(
                                    message: "Smart Contract ID",
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
                                      await Clipboard.setData(ClipboardData(text: nft.id));
                                      Toast.message("Smart Contract Identifier copied to clipboard");
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
                          "Minted By: ${nft.minterName}",
                          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                color: Colors.white,
                                height: 1,
                              ),
                        ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        nft.currentEvolveDescription.replaceAll("\\n", "\n"),
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                      ),
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
                                color: nft.currentOwner.startsWith("xRBX") ? Colors.deepPurple.shade200 : AppColors.getBlue(ColorShade.s50),
                              ),
                            ),
                            subtitle: const Text(
                              "Owner",
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
                              subtitle: const Text("Minter Address"),
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
                            style: TextStyle(fontSize: 13, color: nft.nextOwner!.startsWith("xRBX") ? Colors.deepPurple.shade200 : Colors.white)),
                        subtitle: const Text(
                          "Next Owner",
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
                                            ? WebAssetCard(nft, nft.currentEvolveAssetWeb)
                                            : buildAssetsNotAvailable(_provider)
                                        : AssetCard(
                                            nft.currentEvolveAsset,
                                            ownerAddress: nft.nextOwner ?? nft.currentOwner,
                                            nftId: nft.id,
                                            isPrimaryAsset: true,
                                          ),
                                    if (nft.additionalAssets.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Additional Assets:",
                                              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                                    color: Colors.white,
                                                  ),
                                            ),
                                            const SizedBox(
                                              height: 6,
                                            ),
                                            kIsWeb && nft.additionalAssetsWeb == null
                                                ? buildAssetsNotAvailable(_provider, false)
                                                : kIsWeb
                                                    ? Wrap(
                                                        children: (nft.additionalAssetsWeb ?? [])
                                                            .map(
                                                              (a) => Padding(
                                                                padding: const EdgeInsets.only(right: 6.0),
                                                                child: WebAssetThumbnail(
                                                                  a,
                                                                  nft: nft,
                                                                ),
                                                              ),
                                                            )
                                                            .toList(),
                                                      )
                                                    : Wrap(
                                                        children: nft.additionalLocalAssets
                                                            .map(
                                                              (a) => Padding(
                                                                padding: const EdgeInsets.only(right: 6.0),
                                                                child: AssetThumbnail(
                                                                  a,
                                                                  nftId: nft.id,
                                                                  ownerAddress: nft.nextOwner ?? nft.currentOwner,
                                                                  isPrimaryAsset: false,
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
                  Text("Properties:", style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white)),
                  SizedBox(
                    height: 8,
                  ),
                  NftPropertiesWrap(
                    properties: nft.currentEvolveProperties,
                  )
                ],
                const Divider(),
                Text("Features:",
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          color: Colors.white,
                        )),
                if (nft.features.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.cancel,
                          size: 16,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 4.0),
                          child: Text(
                            "No features",
                            style: TextStyle(fontSize: 16),
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
                                      label: "Reveal Evolve Stages",
                                      variant: AppColorVariant.Dark,
                                      onPressed: () {
                                        showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.black87,
                                            builder: (context) {
                                              final address = kIsWeb ? ref.watch(webSessionProvider.select((value) => value.keypair?.address)) : null;

                                              return ModalContainer(color: Colors.black26, children: [
                                                Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    EvolutionStateRow(
                                                      nft.baseEvolutionPhase,
                                                      nft: nft,
                                                      nftId: id,
                                                      canManageEvolve: nft.canManageEvolve(address),
                                                      index: 0,
                                                    ),
                                                    ...nft.updatedEvolutionPhases
                                                        .asMap()
                                                        .entries
                                                        .map(
                                                          (entry) => EvolutionStateRow(
                                                            entry.value,
                                                            nft: nft,
                                                            nftId: id,
                                                            canManageEvolve: nft.canManageEvolve(address),
                                                            index: entry.key + 1,
                                                            onAssociate: () {
                                                              Navigator.of(context).pop();
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
                      label: "Prove Ownership",
                      icon: Icons.security,
                      variant: AppColorVariant.Primary,
                      onPressed: () async {
                        String? str;

                        if (kIsWeb) {
                          final privateKey = nft.currentOwner.startsWith("xRBX")
                              ? ref.read(webSessionProvider).raKeypair?.private
                              : ref.read(webSessionProvider).keypair?.private;
                          final publicKey = nft.currentOwner.startsWith("xRBX")
                              ? ref.read(webSessionProvider).raKeypair?.public
                              : ref.read(webSessionProvider).keypair?.public;

                          final address = nft.currentOwner.startsWith("xRBX")
                              ? ref.read(webSessionProvider).raKeypair?.address
                              : ref.read(webSessionProvider).keypair?.address;
                          if (privateKey == null) {
                            Toast.error("Can't find private key");
                            return;
                          }
                          if (publicKey == null) {
                            Toast.error("Can't find public key");
                            return;
                          }

                          final randomKey = generateRandomString(8, 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz');
                          final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round();
                          final message = "$randomKey.$timestamp";

                          final sigScript = await RawTransaction.getSignature(message: message, privateKey: privateKey, publicKey: publicKey);

                          if (sigScript == null) {
                            Toast.error("Could not generate signature");
                            return;
                          }

                          str = "$address<>$message<>$sigScript<>${nft.id}";
                        } else {
                          str = await NftService().proveOwnership(id);
                        }

                        if (str == null) {
                          return;
                        }

                        InfoDialog.show(
                          title: "Ownership Verification Signature",
                          content: SizedBox(
                            width: 420,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Send this ownership validation signature to prove you are the owner.",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                TextFormField(
                                  initialValue: str,
                                  readOnly: true,
                                  minLines: 7,
                                  maxLines: 7,
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Center(
                                  child: AppButton(
                                    label: "Copy Signature",
                                    icon: Icons.copy,
                                    onPressed: () async {
                                      await Clipboard.setData(ClipboardData(text: str));
                                      Toast.message("Signature Verification copied to clipboard.");
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: AppButton(
                      label: "Transfer",
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
                      label: "Sell",
                      // helpType: HelpType.transfer,
                      icon: Icons.attach_money,
                      onPressed: () async {
                        if (kIsWeb) {
                          Toast.message("Activating soon!");
                          return;
                        }
                        if (!await passwordRequiredGuard(context, ref)) {
                          return;
                        }
                        Wallet? wallet = ref.read(walletListProvider).firstWhereOrNull((w) => w.address == nft.currentOwner);
                        if (wallet == null) {
                          Toast.error("No account selected");
                          return;
                        }

                        if (wallet.isReserved) {
                          Toast.error("Vault Accounts can not sell NFTs.");
                          return;
                        }

                        if (wallet.balance < MIN_RBX_FOR_SC_ACTION) {
                          Toast.error("Not enough balance for transaction");
                          return;
                        }

                        final _nft = await setAssetPath(nft);

                        final filesReady = await _nft.areFilesReady();

                        if (!filesReady) {
                          Toast.error("Media files not found on this machine.");
                          return;
                        }
                        String? address = await PromptModal.show(
                          contextOverride: context,
                          title: "Sell NFT",
                          validator: (value) => formValidatorRbxAddress(value, true),
                          labelText: "VFX Address",
                          confirmText: "Continue",
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9.]')),
                          ],
                          lines: 1,
                        );

                        if (address == null) {
                          return;
                        }

                        address = address.trim().replaceAll("\n", "");

                        final isValid = await BridgeService().validateSendToAddress(address);
                        if (!isValid) {
                          Toast.error("Invalid Address");
                          return;
                        }

                        final String? amountString = await PromptModal.show(
                          contextOverride: context,
                          title: "Sale Amount",
                          body: "How much are you selling this NFT for?",
                          labelText: "VFX Amount)",
                          confirmText: "Continue",
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9.]"))],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Amount required";
                            }

                            double parsed = 0;
                            try {
                              parsed = double.parse(value);
                            } catch (e) {
                              return "Not a valid amount";
                            }

                            if (parsed <= 0) {
                              return "The amount has to be a positive value";
                            }
                            return null;
                          },
                        );

                        if (amountString == null) {
                          return;
                        }

                        final amount = double.tryParse(amountString);

                        if (amount == null) {
                          Toast.error("Invalid Amount");
                          return;
                        }

                        final String? backupUrl = await PromptModal.show(
                          contextOverride: context,
                          title: "Backup URL (Optional)",
                          body: "Paste in a public URL to a hosted zipfile containing the assets.",
                          validator: (value) {
                            return null;
                          },
                          labelText: "URL (Optional)",
                          confirmText: "Continue",
                        );

                        final confirmed = await ConfirmDialog.show(
                          title: "Confirm Sale Start",
                          body: "Please confirm you want to sell the NFT to \"$address\" for $amount VFX.",
                          confirmText: "Start Sale",
                        );

                        if (confirmed == true) {
                          ref.read(globalLoadingProvider.notifier).start();
                          final success = await SmartContractService().transferSale(id, address, amount, backupUrl);
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
                    final address = kIsWeb ? ref.watch(webSessionProvider.select((value) => value.keypair?.address)) : null;
                    if (nft.manageable && nft.canManage(address)) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: AppButton(
                          label: "Manage",
                          icon: Icons.settings,
                          onPressed: () {
                            showModalBottomSheet(
                              isScrollControlled: true,
                              backgroundColor: Colors.black87,
                              context: context,
                              builder: (context) {
                                return ModalContainer(
                                  color: Colors.black26,
                                  children: [NftMangementModal(nft.id, nft, showViewNft: false)],
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
                        label: "View Code",
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

                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: AppButton(
                      label: "Burn",
                      icon: Icons.fire_hydrant,
                      // helpType: HelpType.burn,
                      variant: AppColorVariant.Danger,
                      onPressed: nft.isPublished
                          ? () async {
                              if (nft.isListed(ref)) {
                                Toast.error("This NFT is listed in your auction house. Please remove the listing before burning.");
                                return;
                              }

                              if (!await passwordRequiredGuard(context, ref)) return;

                              if (kIsWeb) {
                                if (nft.currentOwner.startsWith("xRBX")) {
                                  Toast.error("Vault Accounts cannot burn NFTs");
                                  return;
                                }
                              } else {
                                if (nft.currentOwner.startsWith("xRBX")) {
                                  Toast.error("Vault Accounts cannot burn NFTs");
                                  return;
                                }
                              }

                              final confirmed = await ConfirmDialog.show(
                                title: "Burn NFT?",
                                body: "Are you sure you want to burn ${nft.name}",
                                destructive: true,
                                confirmText: "Burn",
                                cancelText: "Cancel",
                              );

                              if (confirmed == true) {
                                ref.read(globalLoadingProvider.notifier).start();
                                final success = kIsWeb ? await _provider.burnWeb() : await _provider.burn();

                                if (success) {
                                  Toast.message("Burn transaction sent successfully!");
                                  ref.read(mySmartContractsProvider.notifier).load();
                                  Navigator.of(context).pop();
                                  ref.read(globalLoadingProvider.notifier).complete();
                                } else {
                                  ref.read(globalLoadingProvider.notifier).complete();

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

  Widget buildAssetsNotAvailable(NftDetailProvider _provider, [bool includeButton = true]) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          color: Colors.black12,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "NFT assets have not been transfered to the VFX Web Wallet.",
                  textAlign: TextAlign.center,
                ),
                if (includeButton)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: AppButton(
                      label: "Transfer Now",
                      onPressed: () async {
                        final success = await _provider.transferWebIn();

                        if (success == true) {
                          Toast.message("Transfer request has been broadcasted. Your assets should be available soon.");
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
                  final url = p.value.replaceAll("https//", "https://").replaceAll("http//", 'http://');
                  return Tooltip(
                    message: url,
                    child: InkWell(
                      onTap: () {
                        launchUrlString(url);
                      },
                      child: Text(
                        "Open",
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                  );
                }
                return Text(p.value);
              }),
              subtitle: Builder(builder: (context) {
                if (p.name == BACKUP_URL_PROPERTY_NAME) {
                  return Text("Media Backup URL");
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
