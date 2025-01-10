import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/core/base_component.dart';
import 'package:rbx_wallet/features/btc/components/btc_transaction_list_tile.dart';
import 'package:rbx_wallet/features/transactions/components/transaction_list_tile.dart';
import '../../../core/breakpoints.dart';
import '../../../core/models/web_session_model.dart';
import '../../../core/providers/currency_segmented_button_provider.dart';
import '../../../core/theme/colors.dart';
import '../../btc_web/components/web_btc_transaction_list_tile.dart';
import '../../btc_web/models/btc_web_transaction.dart';
import '../../btc_web/providers/btc_web_transaction_list_provider.dart';
import '../../web/components/web_mobile_drawer_button.dart';
import '../../web/components/web_wallet_type_switcher.dart';
import '../../../core/components/centered_loader.dart';

import '../../../core/base_screen.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../btc_web/components/web_btc_transaction_list.dart';
import '../../web/components/web_no_wallet.dart';
import '../components/vfx_transaction_filter_button.dart';
import '../components/web_transaction_card.dart';
import '../models/web_transaction.dart';
import '../providers/vfx_transaction_filter_provider.dart';
import '../providers/web_transaction_list_provider.dart';

class WebTransactionScreen extends BaseScreen {
  const WebTransactionScreen({Key? key})
      : super(
          key: key,
          includeWebDrawer: true,
          backgroundColor: Colors.black87,
          horizontalPadding: 0,
          verticalPadding: 0,
        );

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    final session = ref.watch(webSessionProvider);

    final isMobile = BreakPoints.useMobileLayout(context);

    return AppBar(
      title: const Text("Transactions"),
      backgroundColor: Colors.black,
      shadowColor: Colors.transparent,
      leading: isMobile ? WebMobileDrawerButton() : null,
      actions: [
        // if (session.selectedWalletType == WalletType.rbx) VfxTransactionFilterButton(),
        // WebWalletTypeSwitcher(),
        // Padding(
        //   padding: const EdgeInsets.only(right: 6.0),
        //   child: IconButton(
        //       onPressed: () {
        //         if (ref.read(webSessionProvider).selectedWalletType == WalletType.btc) {
        //           final address = ref.read(webSessionProvider).btcKeypair?.address;
        //           if (address != null) {
        //             ref.read(btcWebTransactionListProvider(address).notifier).reload();
        //           }
        //           return;
        //         }

        //         final address = ref.read(webSessionProvider).currentWallet?.address;
        //         if (address != null) {
        //           ref.read(webTransactionListProvider(address).notifier).refresh();
        //         }
        //       },
        //       icon: const Icon(
        //         Icons.refresh,
        //         size: 16,
        //       )),
        // )
      ],
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final session = ref.watch(webSessionProvider);

    final filters = ref.watch(vfxTransactionFilterProvider);

    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            indicatorColor: AppColors.getBlue(),
            tabs: [
              Tab(
                child: Text("All"),
              ),
              Tab(
                child: Text("VFX"),
              ),
              Tab(
                child: Text("Vault"),
              ),
              Tab(
                child: Text("BTC"),
              ),
            ],
          ),
          SizedBox(
            height: 16,
          ),
          Expanded(
            child: TabBarView(
              children: [
                WebTransactionsCombinedList(),
                WebTransactionsVfxList(address: session.keypair?.address),
                WebTransactionsVfxList(address: session.raKeypair?.address),
                WebBtcTransactionList(address: session.btcKeypair?.address),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class WebTransactionsVfxList extends BaseComponent {
  final String? address;
  const WebTransactionsVfxList({
    super.key,
    required this.address,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (address == null) {
      return const WebNotWallet();
    }

    final model = ref.watch(webTransactionListProvider(address!));
    if (model.transactions.isEmpty) {
      return Center(
        child: Text("No Transactions found for $address."),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        itemCount: model.transactions.length,
        itemBuilder: (context, index) {
          final tx = model.transactions[index];
          final isLast = index + 1 == model.transactions.length;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                WebTransactionCard(tx),
                if (isLast)
                  _NextPageRequester(
                    isLoading: model.isLoading,
                    pageRequestFunction: () {
                      ref.read(webTransactionListProvider(address!).notifier).fetchNextPage();
                    },
                  )
              ],
            ),
          );
        },
      ),
    );
  }
}

class WebTransactionsCombinedList extends BaseComponent {
  const WebTransactionsCombinedList({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(webSessionProvider);

    final combinedIdentifier = "${session.keypair?.address}:${session.raKeypair?.address}";

    final data = ref.watch(combinedWebTransactionListProvider(combinedIdentifier));

    return data.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      loading: () => CenteredLoader(),
      error: (e, _) => Text("Error"),
      data: (transactions) {
        return ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final tx = transactions[index];
            if (tx is WebTransaction) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 42,
                      decoration: BoxDecoration(
                        color: tx.toAddress.startsWith("xRBX") || tx.fromAddress.startsWith("xRBX") ? AppColors.getReserve() : AppColors.getBlue(),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ),
                    Expanded(child: WebTransactionCard(tx)),
                  ],
                ),
              );
            }

            if (tx is BtcWebTransaction) {
              if (session.btcKeypair == null) {
                return SizedBox();
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 16),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.getBtc(),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ),
                    Expanded(
                      child: WebBtcTransactionListTile(
                        transaction: tx,
                        compact: true,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Text("TODO");
          },
        );
      },
    );
  }
}

class _NextPageRequester extends StatefulWidget {
  final Function pageRequestFunction;
  final bool isLoading;
  const _NextPageRequester({
    required this.pageRequestFunction,
    required this.isLoading,
  });

  @override
  State<_NextPageRequester> createState() => __NextPageRequesterState();
}

class __NextPageRequesterState extends State<_NextPageRequester> {
  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 300)).then((_) {
      widget.pageRequestFunction();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 100,
      child: widget.isLoading ? CenteredLoader() : SizedBox(),
    );
  }
}
