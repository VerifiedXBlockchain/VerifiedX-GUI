import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/core/base_screen.dart';
import 'package:rbx_wallet/core/providers/session_provider.dart';
import 'package:rbx_wallet/core/providers/web_session_provider.dart';
import 'package:rbx_wallet/features/btc/providers/tokenized_bitcoin_list_provider.dart';
import 'package:rbx_wallet/features/btc_web/providers/btc_web_vbtc_token_list_provider.dart';
import 'package:rbx_wallet/features/nft/models/web_nft.dart';
import 'package:rbx_wallet/features/nft/providers/nft_list_provider.dart';
import 'package:rbx_wallet/features/token/models/web_fungible_token.dart';
import 'package:rbx_wallet/features/token/providers/token_list_provider.dart';
import 'package:rbx_wallet/features/token/providers/web_token_list_provider.dart';

import '../../../core/theme/components.dart';
import '../../../core/theme/pretty_icons.dart';
import '../../../core/web_router.gr.dart';
import '../../../generated/assets.gen.dart';
import '../../asset/polling_image_preview.dart';
import '../../btc/models/tokenized_bitcoin.dart';
import '../../btc/screens/tokenized_btc_list_screen.dart';
import '../../btc_web/models/btc_web_vbtc_token.dart';
import '../../misc/providers/global_balances_expanded_provider.dart';
import '../../nft/models/nft.dart';
import '../../nft/providers/web_nft_list_provider.dart';
import '../../nft/screens/nft_detail_screen.dart';
import '../../nft/services/nft_service.dart';
import '../../token/models/token_account.dart';
import '../../token/models/token_sc_feature.dart';
import '../../token/providers/web_token_detail_provider.dart';
import '../../token/screens/token_management_screen.dart';

class AllTokensScreen extends BaseScreen {
  const AllTokensScreen({super.key});

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final address = kIsWeb
        ? ref.watch(webSessionProvider.select((value) => value.keypair?.address))
        : ref.watch(sessionProvider.select((value) => value.currentWallet?.address));
    final raAddress = ref.watch(webSessionProvider.select((value) => value.raKeypair?.address));
    final allAddresses = kIsWeb ? [address, raAddress] : [address];

    final vBtcTokens = kIsWeb ? ref.watch(btcWebVbtcTokenListProvider) : ref.watch(tokenizedBitcoinListProvider);
    final fungibleTokens = kIsWeb
        ? ref.watch(webTokenListProvider).where((element) => allAddresses.contains(element.address)).toList()
        : ref.watch(tokenListProvider).data.results;

    final nfts = kIsWeb
        ? address != null
            ? ref.watch(webNftListProvider(address))
            : []
        : ref.watch(nftListProvider).data.results;

    final tokens = [...vBtcTokens, ...fungibleTokens, ...nfts]..sort((a, b) {
        late int timestampA;
        late int timestampB;
        //A
        if (a is BtcWebVbtcToken) {
          timestampA = (a.createdAt.millisecondsSinceEpoch / 1000).round();
        } else if (b is BtcWebVbtcToken) {
          timestampB = (b.createdAt.millisecondsSinceEpoch / 1000).round();
        } else if (a is WebFungibleTokenBalance) {
          timestampA = (a.token.createdAt.millisecondsSinceEpoch / 1000).round();
        } else if (a is TokenizedBitcoin) {
          timestampA = a.timestamp;
        } else if (a is Nft) {
          timestampA = a.timestamp;
        } else {
          timestampA = 0;
        }

        //B

        if (b is WebFungibleTokenBalance) {
          timestampB = (b.token.createdAt.millisecondsSinceEpoch / 1000).round();
        } else if (a is WebNft) {
          timestampB = (a.mintedAt.millisecondsSinceEpoch / 1000).round();
        } else if (b is WebNft) {
          timestampB = (b.mintedAt.millisecondsSinceEpoch / 1000).round();
        } else if (b is TokenizedBitcoin) {
          timestampB = b.timestamp;
        } else if (b is Nft) {
          timestampB = b.timestamp;
        } else {
          timestampB = 0;
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
                      if (token is WebNft || token is Nft) {
                        final nft = token is WebNft ? token.smartContract : token;
                        final subtitle = token is Nft
                            ? token.isToken
                                ? "Fungible Token"
                                : "Non-Fungible Token"
                            : "Non-Fungible Token";

                        return ListTile(
                          dense: true,
                          onTap: () async {
                            if (token is WebNft) {
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => NftDetailScreen(id: token.smartContract.id)));
                            } else if (token is Nft) {
                              if (token.isToken) {
                                final n = await NftService().getNftData(nft.id);

                                if (n != null && n.isToken) {
                                  final tokenAccount = TokenAccount.fromNft(n, ref);
                                  final tokenFeature = TokenScFeature.fromNft(n);
                                  if (tokenAccount != null && tokenFeature != null) {
                                    Navigator.of(context).push(MaterialPageRoute(
                                        builder: (_) => TokenManagementScreenContainer(
                                              address: n.currentOwner,
                                              nftId: n.id,
                                              tokenAccount: tokenAccount,
                                              tokenFeature: tokenFeature,
                                              ref: ref,
                                              nft: n,
                                            )));
                                  }
                                }
                              } else {
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => NftDetailScreen(id: token.id)));
                              }
                            }
                          },
                          title: Text(token.name),
                          subtitle: Text(subtitle),
                          trailing: Icon(Icons.chevron_right),
                          leading: Builder(
                            builder: (context) {
                              if (kIsWeb) {
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
                              }

                              if (nft.currentEvolveAsset.isImage) {
                                if (nft.currentEvolveAsset.localPath == null) {
                                  return const SizedBox(
                                    width: 32,
                                    height: 32,
                                  );
                                }

                                return SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: PollingImagePreview(
                                    localPath: nft.currentEvolveAsset.localPath!,
                                    expectedSize: nft.currentEvolveAsset.fileSize,
                                    withProgress: false,
                                  ),
                                );
                              }
                              return const Icon(Icons.file_present_outlined);
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
                            AutoRouter.of(context).push(WebTokenizedBtcDetailScreenRoute(scIdentifier: token.scIdentifier, address: token.address));
                          },
                          title: Text(token.name),
                          subtitle: Text("vBTC Token (${token.balanceForAddress(address)} vBTC)"),
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

                      if (token is TokenizedBitcoin) {
                        return TokenizedBtcListTile(token: token);
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
