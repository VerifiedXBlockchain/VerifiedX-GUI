import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/core/base_screen.dart';
import 'package:rbx_wallet/core/providers/web_session_provider.dart';
import 'package:rbx_wallet/features/btc_web/providers/btc_web_vbtc_token_list_provider.dart';
import 'package:rbx_wallet/features/nft/models/web_nft.dart';
import 'package:rbx_wallet/features/nft/providers/nft_list_provider.dart';
import 'package:rbx_wallet/features/token/models/web_fungible_token.dart';
import 'package:rbx_wallet/features/token/providers/web_token_list_provider.dart';

import '../../../core/components/badges.dart';
import '../../../core/theme/components.dart';
import '../../../core/theme/pretty_icons.dart';
import '../../../core/web_router.gr.dart';
import '../../../generated/assets.gen.dart';
import '../../asset/polling_image_preview.dart';
import '../../btc_web/models/btc_web_vbtc_token.dart';
import '../../misc/providers/global_balances_expanded_provider.dart';
import '../../navigation/constants.dart';
import '../../nft/models/nft.dart';
import '../../nft/providers/web_nft_list_provider.dart';
import '../../nft/screens/nft_detail_screen.dart';
import '../../token/providers/web_token_detail_provider.dart';

class AllTokensScreen extends BaseScreen {
  const AllTokensScreen({super.key});

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final address = ref.watch(webSessionProvider.select((value) => value.keypair?.address));

    final vBtcTokens = ref.watch(btcWebVbtcTokenListProvider);
    final fungibleTokens = ref.watch(webTokenListProvider).where((element) => element.address == address);
    final nfts = address != null ? ref.watch(webNftListProvider(address)) : [];

    final tokens = [...vBtcTokens, ...fungibleTokens, ...nfts]..sort((a, b) {
        late int timestampA;
        late int timestampB;

        if (a is BtcWebVbtcToken) {
          timestampA = (a.createdAt.millisecondsSinceEpoch / 1000).round();
        }
        if (b is BtcWebVbtcToken) {
          timestampB = (b.createdAt.millisecondsSinceEpoch / 1000).round();
        }

        if (a is WebFungibleTokenBalance) {
          timestampA = (a.token.createdAt.millisecondsSinceEpoch / 1000).round();
        }

        if (b is WebFungibleTokenBalance) {
          timestampB = (b.token.createdAt.millisecondsSinceEpoch / 1000).round();
        }

        if (a is WebNft) {
          timestampA = (a.mintedAt.millisecondsSinceEpoch / 1000).round();
        }

        if (b is WebNft) {
          timestampB = (b.mintedAt.millisecondsSinceEpoch / 1000).round();
        }

        return timestampA > timestampB ? -1 : 1;
      });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.navigate_before),
              onPressed: () {
                ref.read(globalBalancesExpandedProvider.notifier).expand();
                AutoRouter.of(context).pop();
              },
            ),
            Text(
              "All My Tokens",
              style: TextStyle(
                fontSize: 20,
                letterSpacing: 1,
                fontWeight: FontWeight.w300,
              ),
            ),
            IgnorePointer(
              ignoring: true,
              child: Opacity(
                opacity: 0,
                child: IconButton(
                  icon: Icon(Icons.navigate_before),
                  onPressed: () {},
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Builder(builder: (context) {
            if (tokens.isEmpty) {
              return Center(
                child: Text(
                  "You have no vBTC Tokens, Fungible Tokens, or Non-Fungible Tokens",
                  textAlign: TextAlign.center,
                ),
              );
            }

            return ListView.builder(
              itemCount: tokens.length,
              itemBuilder: (context, index) {
                final token = tokens[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: AppCard(
                    padding: 0,
                    child: Builder(builder: (context) {
                      if (token is WebNft) {
                        final nft = token.smartContract;

                        return ListTile(
                          dense: true,
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => NftDetailScreen(id: nft.id)));
                          },
                          title: Text(token.name),
                          subtitle: Text("Non-Fungible Token"),
                          trailing: Icon(Icons.chevron_right),
                          leading: Builder(
                            builder: (context) {
                              if (nft.currentEvolveAssetWeb != null && nft.currentEvolveAssetWeb!.isImage) {
                                return Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                                  clipBehavior: Clip.antiAlias,
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: CachedNetworkImage(
                                      imageUrl: nft.currentEvolveAssetWeb!.location,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              }

                              if (nft.primaryAssetWeb != null) {
                                return Icon(Icons.file_present_outlined);
                              }

                              return SizedBox(
                                width: 32,
                                height: 32,
                              );
                            },
                          ),
                        );
                      }

                      if (token is WebFungibleTokenBalance) {
                        return ListTile(
                          dense: true,
                          onTap: () {
                            ref.invalidate(webTokenDetailProvider(token.token.smartContractId));
                            AutoRouter.of(context).push(WebTokenDetailScreenRoute(scId: token.token.smartContractId));
                          },
                          title: Text(token.token.name),
                          subtitle: Text("Fungible Token (${token.balance} ${token.token.ticker})"),
                          leading: token.token.imageUrl != null && token.token.imageUrl!.isNotEmpty
                              ? Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                                  clipBehavior: Clip.antiAlias,
                                  child: Image.network(token.token.imageUrl!, width: 32, height: 32, fit: BoxFit.cover))
                              : PrettyIcon(
                                  type: PrettyIconType.fungibleToken,
                                ),
                          trailing: Icon(Icons.chevron_right),
                        );
                      }

                      if (token is BtcWebVbtcToken) {
                        return ListTile(
                          dense: true,
                          onTap: () {
                            AutoRouter.of(context).push(WebTokenizedBtcDetailScreenRoute(scIdentifier: token.scIdentifier));
                          },
                          title: Text(token.name),
                          subtitle: Text("vBTC Token"),
                          trailing: Icon(Icons.chevron_right),
                          leading: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                            clipBehavior: Clip.antiAlias,
                            child: CachedNetworkImage(
                              imageUrl: token.imageUrl,
                              height: 32,
                              width: 32,
                              errorWidget: (context, _, __) {
                                return Image.asset(
                                  Assets.images.vbtcPng.path,
                                  width: 32,
                                  height: 32,
                                );
                              },
                            ),
                          ),
                        );
                      }

                      return SizedBox.shrink();
                    }),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
