import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../smart_contracts/components/sc_creator/common/modal_container.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/base_component.dart';
import '../../../core/components/badges.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../utils/files.dart';
import '../../../utils/toast.dart';
import '../../asset/asset_thumbnail.dart';
import '../../asset/polling_image_preview.dart';
import '../../smart_contracts/features/evolve/evolve_phase.dart';
import '../../smart_contracts/services/smart_contract_service.dart';
import '../../wallet/providers/wallet_list_provider.dart';
import '../models/nft.dart';
import '../providers/nft_detail_provider.dart';
import '../providers/nft_list_provider.dart';
import '../screens/nft_detail_screen.dart';

class NftMangementModal extends BaseComponent {
  final String id;
  final Nft nft;
  final bool showViewNft;
  const NftMangementModal(this.id, this.nft, {Key? key, this.showViewNft = true}) : super(key: key);

  void evolve(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      title: "Evolve?",
      body: "Are you sure you want to evolve this NFT one stage?",
      confirmText: "Evolve",
      cancelText: "Cancel",
    );
    if (confirmed == true) {
      final _provider = ref.read(nftDetailProvider(id).notifier);
      final success = await _provider.evolve();
      if (success) {
        Toast.message("Evolve transaction sent successfully!");
        showEvolveMessage();
      } else {
        Toast.error();
      }
    }
  }

  void devolve(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      title: "Devolve?",
      body: "Are you sure you want to devolve this NFT one stage?",
      confirmText: "Devolve",
      cancelText: "Cancel",
    );
    if (confirmed == true) {
      final _provider = ref.read(nftDetailProvider(id).notifier);
      final success = await _provider.devolve();
      if (success) {
        Toast.message("Devolve transaction sent successfully!");
        showEvolveMessage();
      } else {
        Toast.error();
      }
    }
  }

  void setEvolve(
    BuildContext context,
    WidgetRef ref,
    int stage,
  ) async {
    final _provider = ref.read(nftDetailProvider(id).notifier);
    final _model = ref.read(nftDetailProvider(id));
    final success = await _provider.setEvolve(stage, _model!.currentOwner);
    if (success) {
      Toast.message("Evolve transaction sent successfully!");
      await showEvolveMessage();
      Navigator.of(context).pop();
    } else {
      Toast.error();
    }
  }

  Future<void> showEvolveMessage() async {
    await InfoDialog.show(
      title: "Evolve transaction sent successfully",
      body: "This screen will reflect the change once the block is crafted and block height has synced with this transaction.",
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // if (nft.isProcessing)
          //   Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       SizedBox(
          //         width: 16,
          //         height: 16,
          //         child: CircularProgressIndicator(
          //           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          //         ),
          //       ),
          //       SizedBox(
          //         width: 8,
          //       ),
          //       Text("Evolve Transaction Processing..."),
          //     ],
          //   ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppButton(
                label: "Close",
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              if (showViewNft)
                AppButton(
                  label: "View NFT",
                  onPressed: () {
                    Navigator.of(context).pop();
                    // AutoRouter.of(context).push(NftDetailScreenRoute(id: nft.id));
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => NftDetailScreen(id: nft.id)));
                  },
                ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Managing ${nft.name}",
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white),
              ),
              Builder(builder: (context) {
                final nftIds = ref.watch(nftListProvider).data.results.map((n) => n.id).toList();

                if (nftIds.contains(nft.id)) {
                  return const AppBadge(
                    label: "Owned by Me",
                    variant: AppColorVariant.Success,
                  );
                }

                return const AppBadge(
                  label: "Transferred",
                  variant: AppColorVariant.Danger,
                );
              })
            ],
          ),
          // Text("Owner: ${nft.currentOwner} "),
          // Text("Minter: ${nft.minterAddress}"),
          const SizedBox(
            height: 6,
          ),
          Text(
            "Current Stage: ${nft.currentEvolvePhase.name}",
            style: const TextStyle(fontSize: 18),
          ),
          // if (nft.canEvolve)
          //   Column(
          //     mainAxisSize: MainAxisSize.min,
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Text(
          //         "Evolution History",
          //         style: Theme.of(context).textTheme.headline5,
          //       ),
          //       ListTile(
          //         leading: Icon(Icons.star),
          //         title: Text("Stage 0 (Base)"),
          //         subtitle: Text("05/15/2022 4:03 PM"),
          //       ),
          //     ],
          //   ),

          Builder(builder: (context) {
            final address = kIsWeb ? ref.watch(webSessionProvider.select((value) => value.keypair?.address)) : null;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                Text(
                  nft.evolveIsDynamic ? "Evolution" : "Manage Evolution",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
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
            );
          }),
        ],
      ),
    );
  }
}

class EvolutionStateRow extends BaseComponent {
  final String nftId;
  final Nft nft;
  final EvolvePhase phase;
  final int index;
  final bool canManageEvolve;
  final Function()? onAssociate;
  const EvolutionStateRow(
    this.phase, {
    Key? key,
    required this.nftId,
    required this.nft,
    required this.canManageEvolve,
    required this.index,
    this.onAssociate,
  }) : super(key: key);

  Future<void> showEvolveMessage() async {
    InfoDialog.show(
      title: "Evolve transaction sent successfully",
      body: "This screen will reflect the change once the block is crafted and block height has synced with this transaction.",
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String descriptionText = phase.description;

    if (phase.dateTime != null) {
      descriptionText =
          "Evolve Date: ${phase.dateLabelLocalized} ${phase.timeLabelLocalized} ${DateTime.now().timeZoneName.toString()} \n${phase.description}";
    } else if (phase.blockHeight != null) {
      descriptionText = "Evolve Block Height: ${phase.blockHeight}\n${phase.description}";
    }

    // final isCurrent = nft.currentEvolvePhase.evolutionState + 1 == index;
    // final isCurrent = nft.currentEvolveAsset.localPath == phase.asset!.localPath;
    // const isCurrent = false; // TEMP
    final isCurrent = phase.isCurrentState;

    final isMinter = kIsWeb
        ? ref.watch(webSessionProvider.select((v) => v.keypair?.address)) == nft.minterAddress
        : ref.watch(walletListProvider).firstWhereOrNull((w) => w.address == nft.minterAddress) != null;

    final showMedia = isMinter || index <= nft.currentEvolvePhaseIndex + 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Container(
        color: isCurrent ? Theme.of(context).colorScheme.success : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Container(
            color: Colors.black,
            child: Card(
              color: Colors.white10,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 50,
                      child: Center(
                        child: Text(
                          "${phase.evolutionState}.",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                    ),
                    if (!showMedia)
                      const SizedBox(
                        width: 100,
                        height: 100,
                        // ignore: unnecessary_const
                        child: const Center(
                          child: Text(
                            "?",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white38,
                            ),
                          ),
                        ),
                      ),
                    if (showMedia)
                      InkWell(
                        onTap: kIsWeb
                            ? null
                            : () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AssetThumbnailDialog(
                                      asset: phase.asset!,
                                      nftId: nftId,
                                      ownerAddress: nft.currentOwner,
                                      isPrimaryAsset: index == 0,
                                      onAssociate: () {
                                        if (onAssociate != null) {
                                          onAssociate!();
                                        }
                                      },
                                    );
                                  },
                                );
                              },
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              if (kIsWeb)
                                phase.webAsset != null
                                    ? SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: CachedNetworkImage(
                                          imageUrl: phase.webAsset!.location,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Text(""),
                              if (!kIsWeb && phase.asset != null && phase.asset!.isImage)
                                phase.asset!.localPath != null
                                    ? SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: PollingImagePreview(
                                          localPath: phase.asset!.localPath!,
                                          expectedSize: phase.asset!.fileSize,
                                          withProgress: false,
                                        ),
                                      )
                                    : const Text(""),
                              if (phase.asset == null)
                                const SizedBox(
                                  width: 100,
                                  height: 100,
                                ),
                              Container(
                                color: Colors.black38,
                              ),
                              if (phase.asset != null && phase.asset!.localPath == null && !kIsWeb)
                                AppButton(
                                  label: "Associate",
                                  type: AppButtonType.Text,
                                  variant: AppColorVariant.Light,
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AssetThumbnailDialog(
                                          asset: phase.asset!,
                                          nftId: nftId,
                                          isPrimaryAsset: index == 0,
                                          ownerAddress: nft.currentOwner,
                                          onAssociate: () {
                                            if (onAssociate != null) {
                                              onAssociate!();
                                            }
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                              if (phase.asset?.localPath != null)
                                AppButton(
                                  label: "Open File",
                                  type: AppButtonType.Text,
                                  variant: AppColorVariant.Light,
                                  onPressed: () async {
                                    final path = await SmartContractService().getAssetPath(nftId, phase.asset!.name!);
                                    if (path != null) {
                                      openFile(File(path));
                                    }
                                  },
                                )
                            ],
                          ),
                        ),
                      ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Name: ${phase.name}", style: Theme.of(context).textTheme.headlineMedium),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(
                                descriptionText,
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (phase.properties.isNotEmpty)
                              InkWell(
                                onTap: showMedia
                                    ? () {
                                        showModalBottomSheet(
                                            context: context,
                                            builder: (context) {
                                              return ModalContainer(
                                                withDecor: false,
                                                withClose: true,
                                                children: [
                                                  NftPropertiesWrap(
                                                    properties: phase.properties,
                                                  )
                                                ],
                                              );
                                            });
                                      }
                                    : null,
                                child: Text(
                                  "${phase.properties.length} ${phase.properties.length == 1 ? 'Property' : 'Properties'}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    decoration: showMedia ? TextDecoration.underline : TextDecoration.none,
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                    ),
                    if (canManageEvolve)
                      SizedBox(
                        width: 100,
                        child: AppButton(
                          label: "Evolve",
                          onPressed: isCurrent
                              ? null
                              : () async {
                                  final confirmed = await ConfirmDialog.show(
                                    title: "Evolve?",
                                    body: "Are you sure you want to evolve to stage $index?",
                                    confirmText: "Evolve",
                                    cancelText: "Cancel",
                                  );
                                  if (confirmed == true) {
                                    final _provider = ref.read(nftDetailProvider(nftId).notifier);
                                    final _model = ref.read(nftDetailProvider(nftId));

                                    final success = await _provider.setEvolve(index, _model!.currentOwner);

                                    if (success) {
                                      Toast.message("Evolve transaction sent successfully!");
                                      await showEvolveMessage();
                                      Navigator.of(context).pop();
                                    } else {
                                      Toast.error();
                                    }
                                  }
                                },
                        ),
                      )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
