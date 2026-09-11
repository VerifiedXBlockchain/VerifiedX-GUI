import 'dart:async';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/core/base_component.dart';
import 'package:rbx_wallet/core/breakpoints.dart';
import '../../../core/base_screen.dart';
import '../../../core/components/centered_loader.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../nft/providers/nft_detail_provider.dart';
import '../providers/btc_web_transaction_list_provider.dart';
import '../../transactions/providers/web_transaction_list_provider.dart';
import '../../../utils/toast.dart';

import '../../../core/theme/components.dart';
import '../../../generated/assets.gen.dart';
import '../../../core/dialogs.dart';
import '../../token/providers/web_token_actions_manager.dart';
import '../components/web_btc_tokenized_action_buttons.dart';
import '../components/web_btc_transaction_list_tile.dart';
import '../components/web_v2_withdrawal_dialog.dart';
import '../models/btc_web_vbtc_token.dart';
import '../providers/btc_web_vbtc_token_detail_provider.dart';
import '../services/pending_withdrawal_completion_service.dart';

class WebTokenizedBtcDetailScreen extends BaseScreen {
  final String scIdentifier;
  final String address;
  const WebTokenizedBtcDetailScreen({
    super.key,
    @PathParam("scId") required this.scIdentifier,
    @PathParam("address") required this.address,
  });

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    final family = "${scIdentifier}_$address";

    final data = ref.watch(btcWebVbtcTokenDetailProvider(family));

    return data.when(
      loading: () => AppBar(
        title: Text(AppLocalizations.of(context).bw2Loading),
        shadowColor: Colors.transparent,
        backgroundColor: Colors.black,
      ),
      data: (token) {
        if (token == null) {
          return AppBar(
            backgroundColor: Colors.black,
            shadowColor: Colors.transparent,
          );
        }
        return AppBar(
          backgroundColor: Colors.black,
          shadowColor: Colors.transparent,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/connector1.png',
                width: 155 / 4,
                height: 118 / 4,
                isAntiAlias: true,
              ),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  token.name,
                  style: TextStyle(fontSize: 28),
                ),
              ),
              Image.asset(
                'assets/images/connector2.png',
                width: 155 / 4,
                height: 118 / 4,
                isAntiAlias: true,
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 22.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Builder(builder: (context) {
                  final balance = token.balanceForAddress(address);
                  // final raBalance = token.balanceForAddress(myVaultAddress);

                  // final balance = vfxBalance + raBalance;

                  return Text(
                    AppLocalizations.of(context).bw2MyBalanceVbtc(balance.toString()),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
      error: (_, __) => AppBar(
        title: Text(AppLocalizations.of(context).btcWebError),
        shadowColor: Colors.transparent,
        backgroundColor: Colors.black,
      ),
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final family = "${scIdentifier}_$address";
    final data = ref.watch(btcWebVbtcTokenDetailProvider(family));

    return data.when(
        data: (token) {
          if (token == null) {
            return Center(
              child: Text(AppLocalizations.of(context).btcTokenNotFoundLabel),
            );
          }

          final isOwner = address == token.ownerAddress;

          final btcTxs = ref.watch(btcWebTransactionListProvider(token.depositAddress));

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                WebVBTCDetailsCard(
                  token: token,
                  address: address,
                  isOwner: isOwner,
                ),
                SizedBox(
                  height: 16,
                ),
                SizedBox(
                  height: 8,
                ),
                _VbtcActionButtonsContainer(token: token, isOwner: isOwner),
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: Text(
                //     "Ownership:",
                //     style: TextStyle(
                //       decoration: TextDecoration.underline,
                //       fontSize: 18,
                //     ),
                //   ),
                // ),
                // ListView.builder(
                //     itemCount: token.addresses.entries.length,
                //     shrinkWrap: true,
                //     itemBuilder: (context, index) {
                //       final entry = token.addresses.entries.toList()[index];
                //       final address = entry.key;
                //       final balance = entry.value;

                //       final percent = token.globalBalance > 0 ? balance / token.globalBalance : null;

                //       return Padding(
                //         padding: const EdgeInsets.only(bottom: 16.0),
                //         child: AppCard(
                //           padding: 0,
                //           child: ListTile(
                //             title: Text("$balance VBTC"),
                //             subtitle: Text(address),
                //             trailing: percent != null ? Text("${percent * 100}%") : null,
                //           ),
                //         ),
                //       );
                //     }),
                Builder(builder: (context) {
                  final myAddr = ref.read(webSessionProvider).keypair?.address;
                  final withdrawals = (token.withdrawalRequests ?? [])
                      .where((wr) => wr['requestor_address'] == myAddr)
                      .toList();
                  if (withdrawals.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      AppLocalizations.of(context).bw2WithdrawalHistory,
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  ListView.builder(
                    itemCount: withdrawals.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final wr = withdrawals[index];
                      final status = wr['status'] ?? 'unknown';
                      final amount = wr['amount'];
                      final btcAddr = wr['btc_address'] ?? '';
                      // Resumable AND ours. The list shows every holder's
                      // withdrawals because the contract is shared, but only
                      // the wallet that made a request can finish it: the node
                      // takes the FROST coordinator from the stored
                      // RequestorAddress while the signature comes from the
                      // active wallet, so acting on someone else's request
                      // makes validators reject a ceremony that then hangs.
                      final isMine = wr['requestor_address'] == address;
                      final isRequested = withdrawalIsResumable(wr) && isMine;
                      final unrecorded = PendingWithdrawalCompletionService().get(
                        wr['request_transaction_hash'] ?? '',
                      );
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: AppCard(
                          padding: 8,
                          child: ListTile(
                            title: Text(AppLocalizations.of(context).bw2WithdrawalToLine(amount.toString(), btcAddr.toString())),
                            subtitle: Text(
                              unrecorded != null
                                  ? AppLocalizations.of(context).bw2BtcSentTapToSettle
                                  : isRequested
                                      ? AppLocalizations.of(context).bw2PendingTapResume
                                      : AppLocalizations.of(context).bw2StatusWithValue(status.toString()),
                              style: unrecorded != null
                                  ? const TextStyle(color: Color(0xFFE0A32E))
                                  : null,
                            ),
                            onTap: isRequested || unrecorded != null
                                ? () {
                                    final requestHash = wr['request_transaction_hash'] as String?;
                                    if (requestHash != null) {
                                      WebV2WithdrawalDialog.show(
                                        scIdentifier: token.scIdentifier,
                                        requestorAddress: address,
                                        btcAddress: btcAddr,
                                        amount: (amount is num) ? amount.toDouble() : (double.tryParse(amount.toString()) ?? 0),
                                        feeRate: 0,
                                        ownerAddress: token.ownerAddress,
                                        existingRequestHash: requestHash,
                                      );
                                    }
                                  }
                                : null,
                            // Cancelling is only meaningful before the BTC goes
                            // out; once it has, the request must be settled.
                            trailing: unrecorded != null
                                ? const Icon(Icons.warning_amber_rounded, color: Color(0xFFE0A32E))
                                : isRequested
                                    ? IconButton(
                                        icon: const Icon(Icons.cancel, color: Colors.redAccent, size: 20),
                                        tooltip: AppLocalizations.of(context).bw2CancelWithdrawalTooltip,
                                        onPressed: () async {
                                          final confirmed = await ConfirmDialog.show(
                                            title: AppLocalizations.of(context).bw2CancelWithdrawalQuestion,
                                            body: AppLocalizations.of(context).bw2CancelWithdrawalBody,
                                          );
                                          if (confirmed == true) {
                                            final manager = ref.read(webTokenActionsManager);
                                            await manager.cancelV2Withdrawal(
                                              scIdentifier: token.scIdentifier,
                                              requestorAddress: wr['requestor_address'] ?? '',
                                              requestHash: wr['request_transaction_hash'] ?? '',
                                            );
                                          }
                                        },
                                      )
                                    : status == 'completed'
                                        ? const Icon(Icons.check_circle, color: Colors.green)
                                        : const Icon(Icons.pending, color: Colors.orange),
                          ),
                        ),
                      );
                    },
                  ),
                    ],
                  );
                }),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    AppLocalizations.of(context).bw2TransactionsColon,
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 18,
                    ),
                  ),
                ),
                if (btcTxs.isEmpty) Text(AppLocalizations.of(context).btcNoTransactions),
                ListView.builder(
                  itemCount: btcTxs.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final tx = btcTxs[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: WebBtcTransactionListTile(
                        transaction: tx,
                      ),
                    );
                  },
                )
              ],
            ),
          );
        },
        error: (_, __) => Text(AppLocalizations.of(context).btcWebError),
        loading: () => const CenteredLoader());
  }
}

class WebVBTCDetailsCard extends BaseComponent {
  final BtcWebVbtcToken token;
  final String address;
  final bool isOwner;

  const WebVBTCDetailsCard({
    super.key,
    required this.token,
    required this.address,
    required this.isOwner,
  });

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    return AppCard(
      padding: 8,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 450),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _VBTCImage(token: token, isSmall: true),
              SizedBox(
                height: 6,
              ),
              _VBTCDetails(token: token, address: address, isOwner: isOwner),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget desktopBody(BuildContext context, WidgetRef ref) {
    return AppCard(
      padding: 8,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _VBTCImage(token: token),
          SizedBox(
            width: 16,
          ),
          _VBTCDetails(token: token, address: address, isOwner: isOwner),
        ],
      ),
    );
  }
}

class _VBTCDetails extends StatelessWidget {
  const _VBTCDetails({
    required this.token,
    required this.address,
    required this.isOwner,
  });

  final BtcWebVbtcToken token;
  final String address;
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final balance = token.balanceForAddress(address);

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _TokenDetailRefresher(
            scId: token.scIdentifier,
            address: address,
          ),
          _DetailRow(
            label: l10n.btcDetailNameLabel,
            value: token.name,
          ),
          _DetailRow(
            label: l10n.btcDetailOwnerLabel,
            value: token.ownerAddress,
            isReserve: token.ownerAddress.startsWith("xRBX"),
            withCopy: true,
          ),
          _DetailRow(
            label: l10n.btcDetailMyBalanceLabel,
            value: l10n.bw2VbtcAmount(balance.toString()),
          ),
          _DetailRow(
            label: l10n.btcDetailDescriptionLabel,
            value: token.description,
            inExpanded: true,
            withMaxLines: BreakPoints.useMobileLayout(context),
          ),
          _DetailRow(
            label: l10n.btcDetailScIdLabel,
            value: token.scIdentifier,
            inExpanded: true,
            withCopy: true,
          ),
          _DetailRow(
            label: l10n.btcDetailScOwnerAddressLabel,
            value: token.ownerAddress,
            isReserve: token.ownerAddress.startsWith("xRBX"),
            withCopy: true,
          ),
          if (isOwner)
            _DetailRow(
              label: l10n.btcDetailDepositAddressLabel,
              value: token.depositAddress,
              inExpanded: true,
              withCopy: true,
            ),
          if (isOwner)
            _DetailRow(
              label: l10n.btcDetailTotalBalanceLabel,
              value: l10n.bw2VbtcAmount(token.globalBalance.toString()),
            ),
          if (token.frostGroupPublicKey != null)
              _DetailRow(
                label: l10n.bw2FrostGroupKey,
                value: token.frostGroupPublicKey!,
                inExpanded: true,
                withCopy: true,
              ),
            if (token.requiredThreshold != null)
              _DetailRow(
                label: l10n.bw2SigningThreshold,
                value: "${token.requiredThreshold}",
              ),
          if (token.isPendingWithdrawal)
            _DetailRow(
              label: l10n.btcStatusLabel,
              value: l10n.bw2PendingWithdrawal,
            ),
        ],
      ),
    );
  }
}

class _VBTCImage extends StatelessWidget {
  const _VBTCImage({
    this.isSmall = false,
    required this.token,
  });
  final bool isSmall;
  final BtcWebVbtcToken token;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
      ),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: token.imageUrl,
        height: isSmall ? 120 : 200,
        width: isSmall ? 120 : 200,
        errorWidget: (context, _, __) {
          return Image.asset(
            Assets.images.vbtcPng.path,
            height: isSmall ? 120 : 200,
            width: isSmall ? 120 : 200,
          );
        },
      ),
    );
  }
}

class _VbtcActionButtonsContainer extends StatefulWidget {
  const _VbtcActionButtonsContainer({
    required this.token,
    required this.isOwner,
  });

  final BtcWebVbtcToken token;
  final bool isOwner;

  @override
  State<_VbtcActionButtonsContainer> createState() => _VbtcActionButtonsContainerState();
}

class _VbtcActionButtonsContainerState extends State<_VbtcActionButtonsContainer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
      value: 0,
    )..repeat(reverse: true); // Looping the animation

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              // color: Theme.of(context).colorScheme.btcOrange.withOpacity(1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.getBlue(ColorShade.s100),
                width: 1,
              ),
              gradient: LinearGradient(
                end: Alignment.topCenter,
                begin: Alignment.bottomCenter,
                stops: [0, _animation.value, 1],
                colors: [
                  AppColors.getBlue(ColorShade.s100),
                  AppColors.getBlue(ColorShade.s200),
                  AppColors.getBtc(),
                ],
              ),
            ),
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: WebTokenizedBtcActionButtons(token: widget.token, isOwner: widget.isOwner),
            ),
          );
        });
  }
}

class _TokenDetailRefresher extends ConsumerStatefulWidget {
  final String scId;
  final String address;

  const _TokenDetailRefresher({super.key, required this.scId, required this.address});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => __TokenDetailRefresherState();
}

class __TokenDetailRefresherState extends ConsumerState<_TokenDetailRefresher> {
  late final Timer timer;

  @override
  void initState() {
    timer = Timer.periodic(Duration(seconds: 10), (timer) {
      final family = "${widget.scId}_${widget.address}";
      ref.invalidate(btcWebVbtcTokenDetailProvider(family));
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool withCopy;
  final bool inExpanded;
  final bool withMaxLines;
  final bool isReserve;
  const _DetailRow({
    required this.label,
    required this.value,
    this.withCopy = false,
    this.inExpanded = false,
    this.withMaxLines = false,
    this.isReserve = false,
  });

  @override
  Widget build(BuildContext context) {
    final useExpanded = inExpanded || withCopy;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label:",
            style: TextStyle(
              color: Theme.of(context).colorScheme.btcOrange,
            ),
          ),
          SizedBox(
            width: 6,
          ),
          useExpanded
              ? Flexible(
                  child: Text(
                  value,
                  maxLines: withMaxLines ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: isReserve ? AppColors.getReserve() : null),
                ))
              : Text(
                  value,
                  style: TextStyle(color: isReserve ? AppColors.getReserve() : null),
                ),
          SizedBox(
            width: 6,
          ),
          if (withCopy)
            Transform.translate(
              offset: Offset(0, 2),
              child: InkWell(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: value));
                  Toast.message(AppLocalizations.of(context).btcLabelCopiedToast(label));
                },
                child: Icon(
                  Icons.copy,
                  size: 12,
                  color: isReserve ? AppColors.getReserve() : null,
                ),
              ),
            )
        ],
      ),
    );
  }
}
