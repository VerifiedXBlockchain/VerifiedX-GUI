import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:context_menus/context_menus.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/components/countdown.dart';
import '../../../utils/files.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/base_component.dart';
import '../../../core/breakpoints.dart';
import '../../../core/components/badges.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/env.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/web_router.gr.dart';
import '../../../utils/toast.dart';
import '../../nft/components/nft_qr_code.dart';
import '../../nft/models/nft.dart';
import '../../sc_property/models/sc_property.dart';
import '../../smart_contracts/components/sc_creator/common/modal_container.dart';
import '../models/web_auction.dart';
import '../models/web_bid.dart';
import '../models/web_listing.dart';
import '../providers/create_web_listing_provider.dart';
import '../providers/web_listing_full_list_provider.dart';
import '../providers/web_shop_bid_provider.dart';

class WebListingDetails extends BaseComponent {
  final WebListing listing;
  const WebListingDetails({super.key, required this.listing});

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final nft = listing.nft;

    return ContextMenuRegion(
      contextMenu: GenericContextMenu(
        buttonConfigs: [
          ContextMenuButtonConfig('Edit Listing', onPressed: () {
            print("edit listing ${listing.id}");
          })
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (nft == null) Text(listing.smartContractUid),
            if (nft != null) ...[
              _Details(listing: listing),
              SizedBox(
                height: 3,
              ),
              _Preview(listing: listing),

              _Features(nft: nft.smartContract),
              _Properties(nft: nft.smartContract),

              if (listing.canBuyNow) ...[
                _BuyNow(listing: listing),
                SizedBox(
                  height: 3,
                )
              ],
              if (listing.canBid) _Auction(listing: listing),
              SizedBox(
                height: 16,
              ),

              if (listing.canBid && !listing.isSaleComplete && !listing.isSalePending)
                _Countdown(
                  listing: listing,
                ),

              if (listing.isSaleComplete)
                Text(
                  "Sale has Completed",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),

              if (!listing.isSaleComplete && listing.isSalePending)
                Text(
                  "Sale is Pending",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),

              // _WebNftDetails(nft: nft.smartContract),
              Padding(
                padding: const EdgeInsets.only(left: 3),
                child: _WebNftData(nft: nft.smartContract),
              ),
              Center(
                child: _QRCode(
                  nft: nft.smartContract,
                  size: 150,
                ),
              ),
            ],

            // _Features(nft: nft),
          ],
        ),
      ),
    );
  }

  @override
  Widget desktopBody(BuildContext context, WidgetRef ref) {
    final nft = listing.nft;
    final myAddress = kIsWeb ? ref.read(webSessionProvider).keypair?.address : ref.read(sessionProvider).currentWallet?.address;

    return ContextMenuRegion(
      contextMenu: GenericContextMenu(
        buttonConfigs: [
          if (listing.ownerAddress == myAddress) ...[
            ContextMenuButtonConfig(
              'Edit Listing',
              onPressed: () async {
                ref.read(createWebListingProvider.notifier).load(listing, listing.collection.id, listing.collection.shop!.id);
                if (Env.isWeb) {
                  AutoRouter.of(context).push(CreateWebListingScreenRoute(shopId: listing.collection.shop!.id, collectionId: listing.collection.id));
                }
              },
              icon: Icon(Icons.edit),
            ),
            ContextMenuButtonConfig(
              'Delete Listing',
              onPressed: () async {
                final confirmed = await ConfirmDialog.show(
                  title: "Delete Listing",
                  body: "Are you sure you want to delete this listing?",
                  confirmText: "Delete",
                  cancelText: "Cancel",
                );
                if (confirmed == true) {
                  ref.read(createWebListingProvider.notifier).delete(context, listing.collection.shop!.id, listing);
                }
              },
              icon: Icon(Icons.delete),
            ),
          ],
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Preview(listing: listing),
                  if (nft != null) ...[
                    _Features(nft: nft.smartContract),
                    _Properties(nft: nft.smartContract),
                    _QRCode(
                      nft: nft.smartContract,
                      size: 150,
                    ),
                  ]
                ],
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (nft == null) Text(listing.smartContractUid),
                  if (nft != null) ...[
                    _Details(listing: listing),
                    const SizedBox(height: 8),
                    // _WebNftDetails(nft: nft.smartContract),
                    // const SizedBox(height: 16),
                    _WebNftData(nft: nft.smartContract),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      if (listing.canBuyNow) _BuyNow(listing: listing),
                      if (listing.canBuyNow && listing.canBid)
                        SizedBox(
                          width: 8,
                        ),
                      if (listing.canBid) _Auction(listing: listing),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  if (listing.canBid && !listing.isSaleComplete && !listing.isSalePending)
                    _Countdown(
                      listing: listing,
                    ),
                  if (listing.isSaleComplete)
                    Text(
                      "Sale has Completed",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                    ),
                  if (!listing.isSaleComplete && listing.isSalePending)
                    Text(
                      "Sale is Pending",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Preview extends StatefulWidget {
  const _Preview({
    required this.listing,
  });

  final WebListing listing;

  @override
  State<_Preview> createState() => _PreviewState();
}

class _PreviewState extends State<_Preview> {
  int selectedIndex = 0;
  bool rebuilding = false;

  late CarouselController controller;

  @override
  void initState() {
    super.initState();
    controller = CarouselController();
  }

  @override
  Widget build(BuildContext context) {
    if (rebuilding) {
      return SizedBox();
    }

    final isMobile = BreakPoints.useMobileLayout(context);

    final primaryFilename = widget.listing.nft!.smartContract.primaryAsset.fileName;
    final additionalFilenames = widget.listing.nft!.smartContract.additionalAssets.map((e) => e.fileName).toList();

    final assetFilenames = widget.listing.collection.shop!.isThirdParty
        ? [primaryFilename, ...additionalFilenames]
        : [primaryFilename, ...additionalFilenames]
            .map((a) => a
                .replaceAll(".png", ".jpg")
                .replaceAll(".gif", ".jpg")
                .replaceAll(".pdf", ".jpg")
                .replaceAll(".webp", ".jpg")
                .replaceAll(".jpeg", ".jpg"))
            .toList();

    final List<String> orderedThumbs = [];
    final List<IconData?> icons = [];

    final thumbnailPreviews = widget.listing.thumbnailPreviews;

    for (final a in assetFilenames) {
      final ext = a.split("/").last.split('.').last.toLowerCase();

      // if (["jpg", "jpeg", "gif", "png", "pdf", "webp"].contains(ext.toLowerCase())) {
      for (final t in widget.listing.thumbnails) {
        // final f = t.split("/").last.split('.').first;
        final fname = t.split("/").last;

        if (a == fname) {
          if (["jpg", "jpeg", "gif", "png", "webp"].contains(ext)) {
            orderedThumbs.add(t);
            icons.add(null);
          } else if (thumbnailPreviews != null && thumbnailPreviews.containsKey(fname)) {
            orderedThumbs.add(thumbnailPreviews[fname]);
            icons.add(iconFromPath(fname));
          } else {
            orderedThumbs.add("ICON||$a||$ext");
            icons.add(iconFromPath(fname));
          }
        }
      }
    }

    // else {
    //   orderedThumbs.add("ICON||$a||$ext");
    // }
    // }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            boxShadow: [
              BoxShadow(
                offset: Offset.zero,
                blurRadius: 5,
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                spreadRadius: 4,
              )
            ],
          ),
          child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: SizedBox(
                width: isMobile ? double.infinity : 320,
                child: CarouselSlider(
                  carouselController: controller,
                  options: CarouselOptions(
                    viewportFraction: 1,
                    autoPlay: false,
                    onPageChanged: (i, _) {
                      setState(() {
                        selectedIndex = i;
                      });
                    },
                  ),
                  items: orderedThumbs.asMap().entries.map((entry) {
                    final path = entry.value;
                    final i = entry.key;
                    final isIcon = path.contains("ICON||");

                    IconData? icon = isIcon ? iconFromPath(path.split("||").last) : null;

                    final IconData? extraIcon = icons[i];

                    String? filename = isIcon ? path.split("||")[1] : null;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: GestureDetector(
                          onTap: isIcon
                              ? null
                              : () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: CachedNetworkImage(
                                                imageUrl: path,
                                                width: isMobile ? 300 : 512,
                                                height: isMobile ? 300 : 512,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                },
                          child: isIcon
                              ? Center(
                                  child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(icon),
                                    if (filename != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6.0),
                                        child: Text(filename),
                                      )
                                  ],
                                ))
                              : Builder(builder: (context) {
                                  if (fileTypeFromPath(path) == "Image") {
                                    return Stack(
                                      children: [
                                        Center(
                                          child: CachedNetworkImage(
                                            imageUrl: path,
                                            errorWidget: (context, _, __) {
                                              // return Text(path);
                                              return Center(
                                                child: IconButton(
                                                  icon: Icon(Icons.refresh),
                                                  onPressed: () async {
                                                    setState(() {
                                                      rebuilding = true;
                                                    });
                                                    await FileImage(File(path)).evict();

                                                    Future.delayed(Duration(milliseconds: 300)).then((value) {
                                                      setState(() {
                                                        rebuilding = false;
                                                      });
                                                    });
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        if (extraIcon != null)
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Icon(extraIcon),
                                            ),
                                          )
                                      ],
                                    );
                                  }

                                  return Center(child: Icon(iconFromPath(path)));
                                })),
                    );
                  }).toList(),
                ),
              )),
        ),
        const SizedBox(
          height: 8,
        ),
        if (orderedThumbs.length > 1)
          SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: () {
                    controller.previousPage();
                  },
                ),
                DotsIndicator(
                  dotsCount: orderedThumbs.length,
                  position: selectedIndex.toDouble(),
                  decorator: const DotsDecorator(
                    activeColor: Colors.white,
                    color: Colors.white54,
                    size: Size.fromRadius(3),
                    activeSize: Size.fromRadius(4),
                  ),
                  onTap: (v) {
                    print(v);
                    controller.animateToPage(v.round());
                  },
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: () {
                    controller.nextPage();
                  },
                ),
              ],
            ),
          )
      ],
    );
  }
}

class _Details extends BaseComponent {
  final WebListing listing;
  const _Details({
    required this.listing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myAddress = kIsWeb ? ref.read(webSessionProvider).keypair?.address : ref.read(sessionProvider).currentWallet?.address;
    if (listing.nft == null) {
      return SizedBox();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "#${listing.listingId}",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize! + 4,
                          color: Colors.white.withAlpha(200),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    listing.nft!.name,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            // if (withShareButtons) buildShareButtons(context),
            AppButton(
              label: "Share Listing",
              icon: Icons.ios_share_rounded,
              variant: AppColorVariant.Light,
              type: AppButtonType.Text,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(
                    text:
                        "${Env.appBaseUrl}/#dashboard/p2p/shop/${listing.collection.shop!.id}/collection/${listing.collection.id}/listing/${listing.id}"));
                Toast.message("Share url copied to clipboard");
              },
            ),
            if (listing.ownerAddress == myAddress)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton(
                    label: "Edit",
                    icon: Icons.edit,
                    variant: AppColorVariant.Light,
                    type: AppButtonType.Text,
                    onPressed: () {
                      ref.read(createWebListingProvider.notifier).load(listing, listing.collection.id, listing.collection.shop!.id);
                      if (Env.isWeb) {
                        AutoRouter.of(context)
                            .push(CreateWebListingScreenRoute(shopId: listing.collection.shop!.id, collectionId: listing.collection.id));
                      }
                    },
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  AppButton(
                    label: "Delete",
                    icon: Icons.delete,
                    variant: AppColorVariant.Danger,
                    type: AppButtonType.Text,
                    onPressed: () async {
                      final confirmed = await ConfirmDialog.show(
                        title: "Delete Listing",
                        body: "Are you sure you want to delete this listing?",
                        confirmText: "Delete",
                        cancelText: "Cancel",
                      );
                      if (confirmed == true) {
                        ref.read(createWebListingProvider.notifier).delete(context, listing.collection.shop!.id, listing);
                      }
                    },
                  )
                ],
              )
          ],
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Text(listing.nft!.description.replaceAll("\\n", "\n")),
        ),
      ],
    );
  }
}

// class _Features extends StatelessWidget {
//   final WebNft nft;
//   const _Features({super.key, required this.nft});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text("NFT Features:", style: Theme.of(context).textTheme.headline5),
//           Builder(
//             builder: (context) {
//               if (nft.features.isEmpty) {
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 8.0),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: const [
//                       Icon(
//                         Icons.cancel,
//                         size: 16,
//                         color: Colors.white54,
//                       ),
//                       Padding(
//                         padding: EdgeInsets.only(left: 4.0),
//                         child: Text(
//                           "No Smart Contract Features",
//                           style: TextStyle(fontSize: 14, color: Colors.white54),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }

//               return Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: nft.featureList
//                     .map(
//                       (f) => ConstrainedBox(
//                         constraints: const BoxConstraints(maxWidth: 300),
//                         child: ListTile(
//                           dense: true,
//                           visualDensity: VisualDensity.compact,
//                           contentPadding: EdgeInsets.zero,
//                           leading: Icon(f.icon),
//                           title: Text(f.nameLabel),
//                           subtitle: Text(f.description),
//                         ),
//                       ),
//                     )
//                     .toList(),
//               );
//             },
//           )
//         ],
//       ),
//     );
//   }
// }

class _QRCode extends StatelessWidget {
  final double size;
  final Nft nft;
  const _QRCode({
    required this.nft,
    this.size = 260,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: size),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NftQrCode(
            data: nft.explorerUrl,
            size: size,
            bgColor: Colors.transparent,
            cardPadding: 0,
            withOpen: true,
            iconButtons: true,
          ),
        ],
      ),
    );
  }
}

class _Properties extends StatelessWidget {
  final Nft nft;
  const _Properties({
    required this.nft,
  });

  @override
  Widget build(BuildContext context) {
    if (nft.properties.isEmpty) {
      return SizedBox.shrink();
    }
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 260),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Properties:",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: nft.properties
                .map((p) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Builder(builder: (context) {
                              switch (p.type) {
                                case ScPropertyType.color:
                                  return Icon(
                                    Icons.color_lens,
                                    color: colorFromHex(p.value),
                                    size: 14,
                                  );
                                case ScPropertyType.number:
                                  return Icon(Icons.numbers, size: 14);
                                default:
                                  return Icon(Icons.text_fields, size: 14);
                              }
                            }),
                          ),
                          Expanded(child: Text(" ${p.name}: ${p.value}")),
                        ],
                      ),
                    ))
                .toList(),
          ),
          SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }
}

class _Features extends StatelessWidget {
  final Nft nft;
  const _Features({required this.nft});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("NFT Features:", style: Theme.of(context).textTheme.headlineSmall),
          Builder(
            builder: (context) {
              if (nft.features.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.cancel,
                        size: 16,
                        color: Colors.white54,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 4.0),
                        child: Text(
                          "Baseline Asset",
                          style: TextStyle(fontSize: 14, color: Colors.white54),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: nft.featureList
                    .map(
                      (f) => ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: ListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(f.icon),
                          title: Text(f.nameLabel),
                          subtitle: Text(f.description),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WebNftDetails extends StatelessWidget {
  final Nft nft;
  const _WebNftDetails({required this.nft});

  @override
  Widget build(BuildContext context) {
    final headingStyle = TextStyle(
      fontWeight: FontWeight.w600,
      letterSpacing: 1,
      color: Theme.of(context).colorScheme.secondary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              height: 1.4,
            ),
            children: [
              TextSpan(text: "NFT Name: ", style: headingStyle),
              TextSpan(text: nft.name),
              const TextSpan(text: "\n"),
              TextSpan(text: "NFT Description: ", style: headingStyle),
              TextSpan(text: nft.description.replaceAll("\\n", "\n")),
            ],
          ),
        ),
        const SizedBox(
          height: 8,
        ),
      ],
    );
  }
}

class _WebNftData extends StatelessWidget {
  final Nft nft;

  const _WebNftData({
    required this.nft,
  });

  TableRow buildDetailRow(BuildContext context, String label, String value, [bool copyValue = false]) {
    final isMobile = BreakPoints.useMobileLayout(context);

    if (isMobile) {
      return TableRow(children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "$label: ",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Text(value),
                if (copyValue)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: InkWell(
                        onTap: () async {
                          await Clipboard.setData(ClipboardData(text: value));

                          Toast.message("$label copied to clipboard");
                        },
                        child: const Icon(Icons.copy, size: 12)),
                  ),
              ],
            ),
            const SizedBox(
              height: 6,
            ),
          ],
        ),
      ]);
    }
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value),
              const SizedBox(width: 8),
              if (copyValue)
                InkWell(
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: value));

                      Toast.message("$label copied to clipboard");
                    },
                    child: const Icon(Icons.copy, size: 12)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Details",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            children: [
              buildDetailRow(context, "Identifier", nft.id, true),
              buildDetailRow(context, "Minted By", nft.minterName),
              buildDetailRow(context, "Minter Address", nft.minterAddress, true),
              buildDetailRow(context, "Owned by", nft.currentOwner, true),
              buildDetailRow(context, "Chain", "VFX"),
              //TODO: Auction stuff
            ],
          ),
        ],
      ),
    );
  }
}

class _BuyNow extends BaseComponent {
  final WebListing listing;
  const _BuyNow({required this.listing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (listing.buyNowPrice == null) {
      return SizedBox.shrink();
    }

    final isMobile = BreakPoints.useMobileLayout(context);
    return SizedBox(
      width: isMobile ? double.infinity : null,
      child: Card(
        color: Colors.transparent,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: isMobile ? 0 : 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Buy Now",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              _Price(
                label: "Price",
                amount: listing.buyNowPrice!,
              ),
              const SizedBox(height: 16),
              AppButton(
                label: "Buy Now",
                icon: Icons.money,
                size: AppSizeVariant.Lg,
                onPressed: () async {
                  if (listing.collection.shop!.isOwner(ref)) {
                    Toast.error("You are the owner of this shop.");
                    return;
                  }

                  final success = await ref.read(webBidListProvider(listing.id).notifier).buyNow(context, listing);
                  if (success == true) {
                    ref.read(webListingFullListProvider("${listing.collection.shop!.id},${listing.collection.id}").notifier).fetch();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Price extends StatelessWidget {
  final String label;
  final double amount;
  const _Price({
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "$label: ",
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        Text(
          "$amount VFX",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        )
      ],
    );
  }
}

class _Auction extends BaseComponent {
  final WebListing listing;
  const _Auction({
    required this.listing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (listing.floorPrice == null) {
      return SizedBox.shrink();
    }

    final isMobile = BreakPoints.useMobileLayout(context);
    return SizedBox(
      width: isMobile ? double.infinity : null,
      child: Card(
        color: Colors.transparent,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: isMobile ? 0 : 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Auction",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              if (listing.auction != null && listing.floorPrice != null) ...[
                listing.floorPrice == listing.auction!.currentBidPrice
                    ? _Price(label: "Floor Price", amount: listing.floorPrice!)
                    : _Price(
                        label: "Highest Bid",
                        amount: listing.auction!.currentBidPrice!,
                      )
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: isMobile ? MainAxisAlignment.start : MainAxisAlignment.center,
                children: [
                  AppButton(
                      label: "Bid Now",
                      icon: Icons.gavel,
                      size: AppSizeVariant.Lg,
                      onPressed: () {
                        if (listing.collection.shop!.isOwner(ref)) {
                          Toast.error("You are the owner of this shop.");
                          return;
                        }
                        ref.read(webBidListProvider(listing.id).notifier).sendBid(context, listing);
                        ref.read(webListingFullListProvider("${listing.collection.shop!.id},${listing.collection.id}").notifier).fetch(1);
                      }),
                  const SizedBox(
                    width: 6,
                  ),
                  _BidHistoryButton(listing: listing),
                  const SizedBox(width: 8),
                  if (listing.auction != null)
                    AppButton(
                      label: "Details",
                      icon: Icons.info,
                      size: AppSizeVariant.Lg,
                      onPressed: () async {
                        final auction = listing.auction!;

                        InfoDialog.show(
                          title: "Auction Details",
                          content: _AuctionInfoDialogContent(
                            auction: auction,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Countdown extends StatelessWidget {
  final WebListing listing;
  const _Countdown({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: BreakPoints.useMobileLayout(context) ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (listing.isActive)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 3),
            child: AppCountdown(
              dueDate: listing.endDate,
              prefix: listing.floorPrice != null ? "Auction Ends" : "Ends in",
            ),
          ),
        // if (!listing.hasStarted)
        //   Padding(
        //     padding: const EdgeInsets.symmetric(vertical: 16.0),
        //     child: AppCountdown(
        //       dueDate: listing.startDate,
        //       prefix: "Auction Starts",
        //     ),
        //   ),
      ],
    );
  }
}

class _AuctionInfoDialogContent extends StatelessWidget {
  const _AuctionInfoDialogContent({
    required this.auction,
  });

  final WebAuction auction;

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(fontWeight: FontWeight.w600);
    final valueStyle = TextStyle();

    return SizedBox(
      width: 300,
      child: Table(
        columnWidths: {
          0: IntrinsicColumnWidth(),
          1: IntrinsicColumnWidth(),
        },
        children: [
          TableRow(
            children: [
              Text(
                "Current Bid Price:",
                style: labelStyle,
              ),
              Text(
                "${auction.currentBidPrice} VFX",
                style: valueStyle,
              )
            ],
          ),
          TableRow(
            children: [
              Text(
                "Increment Amount:",
                style: labelStyle,
              ),
              Text(
                "${auction.incrementAmount} VFX",
                style: valueStyle,
              )
            ],
          ),
          TableRow(
            children: [
              Text(
                "Reserve Met:",
                style: labelStyle,
              ),
              Text(
                auction.isReserveMet ? "Yes" : "No",
                style: valueStyle,
              )
            ],
          ),
          TableRow(
            children: [
              Text(
                "Active:",
                style: labelStyle,
              ),
              Text(
                auction.isAuctionOver ? "Completed" : "Yes",
                style: valueStyle,
              )
            ],
          ),
        ],
      ),
    );
  }
}

class _BidHistoryButton extends BaseComponent {
  const _BidHistoryButton({
    required this.listing,
  });

  final WebListing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final provider = ref.read(bidListProvider(listing.familyIdentifier).notifier);

    return AppButton(
      label: "Bid History",
      icon: Icons.punch_clock,
      size: AppSizeVariant.Lg,
      onPressed: () async {
        List<WebBid> bids = [...listing.bids];
        bids.sort((a, b) => a.amount > b.amount ? -1 : 1);

        if (bids.isEmpty) {
          Toast.message("No bids.");
          return;
        }

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return _BidHistoryModal(
              bids: bids,
            );
          },
        );
      },
    );
  }
}

class _BidHistoryModal extends BaseComponent {
  final List<WebBid> bids;
  const _BidHistoryModal({
    required this.bids,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = BreakPoints.useMobileLayout(context);
    return ModalContainer(
      withClose: true,
      withDecor: false,
      children: [
        const Text(
          "Current Bids",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(
          height: 12,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: bids.map(
            (bid) {
              return ListTile(
                leading: _BidStatusIndicator(bid),
                title: Text("${bid.amount} VFX"),
                subtitle: SelectableText(isMobile ? "${bid.address} \n${timeago.format(bid.sendDateTime)}" : bid.address),
                trailing: Builder(builder: (context) {
                  final currentAddress = kIsWeb
                      ? ref.watch(webSessionProvider.select((v) => v.keypair?.address))
                      : ref.watch(sessionProvider.select((v) => v.currentWallet?.address));
                  final isBidder = currentAddress == bid.address;

                  // if (isBidder && bid.bidStatus == BidStatus.Sent) {
                  //   return AppButton(
                  //     label: "Resend Bid",
                  //     onPressed: () async {
                  //       //TODO: resend bid
                  //     },
                  //   );
                  // }

                  return Text(isMobile ? '' : bid.sendTimeLabel);
                }),
              );
            },
          ).toList(),
        )
      ],
    );
  }
}

class _BidStatusIndicator extends StatelessWidget {
  final WebBid bid;
  const _BidStatusIndicator(this.bid);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (bid.bidStatus == WebBidStatus.Sent) {
          return AppBadge(
            label: "Sent",
            variant: AppColorVariant.Primary,
          );
        }

        if (bid.bidStatus == WebBidStatus.Received) {
          return AppBadge(
            label: "Received",
            variant: AppColorVariant.Primary,
          );
        }

        if (bid.bidStatus == WebBidStatus.Accepted) {
          if (bid.isBuyNow) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBadge(
                  label: "Purchased",
                  variant: AppColorVariant.Success,
                ),
                SizedBox(height: 4),
                Text("[Buy Now]")
              ],
            );
          }

          return AppBadge(
            label: "Accepted",
            variant: AppColorVariant.Success,
          );
        }

        if (bid.bidStatus == WebBidStatus.Rejected) {
          return AppBadge(
            label: "Rejected",
            variant: AppColorVariant.Danger,
          );
        }

        return SizedBox();
      },
    );
  }
}
