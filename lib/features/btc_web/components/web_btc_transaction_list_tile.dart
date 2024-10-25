import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/app_constants.dart';
import '../../../core/base_component.dart';
import '../../../core/theme/components.dart';
import '../../../core/components/badges.dart';
import '../../../core/components/buttons.dart';
import '../../../core/env.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../generated/assets.gen.dart';
import '../../web/providers/all_btc_addresses_provider.dart';
import '../models/btc_web_transaction.dart';
import '../../../utils/toast.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../providers/btc_web_vbtc_token_list_provider.dart';

class WebBtcTransactionListTile extends BaseComponent {
  final BtcWebTransaction transaction;
  // final String address;
  final bool compact;

  const WebBtcTransactionListTile({
    super.key,
    required this.transaction,
    // required this.address,
    this.compact = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tx = transaction;

    final myAddresses = ref.watch(allBtcAddressesProvider);
    final vbtcTokenAddresses = ref.watch(btcWebVbtcTokenListProvider).map((v) => v.depositAddress).toList();

    final amount = tx.amountBtc(myAddresses);

    final toAddress = tx.toAddress(myAddresses);
    final fromAddress = tx.fromAddress();

    final isVbtc = vbtcTokenAddresses.contains(toAddress) || vbtcTokenAddresses.contains(fromAddress);

    return _WebBtcTransactionListTileContent(amount: amount, tx: tx, compact: compact, isVbtc: isVbtc);
  }
}

class _WebBtcTransactionListTileContent extends StatefulWidget {
  const _WebBtcTransactionListTileContent({
    super.key,
    required this.amount,
    required this.tx,
    required this.compact,
    this.isVbtc = false,
  });

  final double amount;
  final BtcWebTransaction tx;
  final bool compact;
  final bool isVbtc;

  @override
  State<_WebBtcTransactionListTileContent> createState() => _WebBtcTransactionListTileContentState();
}

class _WebBtcTransactionListTileContentState extends State<_WebBtcTransactionListTileContent> {
  late bool expanded;

  @override
  void initState() {
    expanded = !widget.compact;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: 12,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.isVbtc)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Image.asset(
                          Assets.images.vbtcSmall.path,
                          width: 16,
                          height: 16,
                        ),
                      ),
                    Text(
                      "${widget.amount} ${widget.isVbtc ? 'v' : ''}BTC",
                      style: TextStyle(
                        color: widget.amount >= 0 ? Theme.of(context).colorScheme.success : Colors.red.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    if (Env.isTestNet) {
                      launchUrlString("https://mempool.space/testnet4/tx/${widget.tx.txid}");
                    } else {
                      launchUrlString("https://mempool.space/tx/${widget.tx.txid}");
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "TX ID: ",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.tx.txid,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Icon(
                        Icons.open_in_new,
                        size: 12,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Row(
            children: [
              Expanded(
                child: AppCard(
                  padding: 0,
                  color: AppColors.getGray(ColorShade.s100),
                  glowOpacity: 0,
                  child: ListTile(
                    title: widget.tx.status.confirmed
                        ? Text(
                            "Confirmed",
                            style: TextStyle(color: Theme.of(context).colorScheme.success, fontWeight: FontWeight.bold),
                          )
                        : Text(
                            "Pending",
                            style: TextStyle(color: Theme.of(context).colorScheme.warning, fontWeight: FontWeight.bold),
                          ),
                    subtitle: Text("Status"),
                  ),
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: AppCard(
                  padding: 0,
                  color: AppColors.getGray(ColorShade.s100),
                  glowOpacity: 0,
                  child: ListTile(
                    title: Text("${widget.tx.fee} SATS | ${widget.tx.feeBtc} BTC"),
                    subtitle: Text("Fee"),
                  ),
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: AppCard(
                  padding: 0,
                  color: AppColors.getGray(ColorShade.s100),
                  glowOpacity: 0,
                  child: ListTile(
                    title: Text(widget.tx.blockTimeLabel),
                    subtitle: Text("Block Time"),
                  ),
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: AppCard(
                  padding: 0,
                  color: AppColors.getGray(ColorShade.s100),
                  glowOpacity: 0,
                  child: ListTile(
                    title: Text(widget.tx.blockHeightLabel),
                    subtitle: Text("Block Height"),
                  ),
                ),
              ),
              SizedBox(
                width: 8,
              ),
              InkWell(
                  onTap: () {
                    setState(() {
                      expanded = !expanded;
                    });
                  },
                  child: Icon(expanded ? Icons.arrow_drop_up : Icons.arrow_drop_down))
            ],
          ),
          if (expanded) ...[
            SizedBox(
              height: 4,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Inputs:",
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...widget.tx.vin.map((input) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              border: Border.all(color: Colors.white10, width: 1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: ListTile(
                              dense: true,
                              title: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(input.prevout.scriptpubkeyAddress),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4.0),
                                    child: InkWell(
                                      onTap: () async {
                                        await Clipboard.setData(ClipboardData(text: input.prevout.scriptpubkeyAddress));
                                        Toast.message("Address copied to clipboard");
                                      },
                                      child: Icon(
                                        Icons.copy,
                                        size: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Text("${input.prevout.value * BTC_SATOSHI_MULTIPLIER} BTC"),
                            ),
                          ),
                        );
                      })
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Outputs:",
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...widget.tx.vout.map((output) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              border: Border.all(color: Colors.white10, width: 1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: ListTile(
                              dense: true,
                              title: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(output.scriptpubkeyAddress),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4.0),
                                    child: InkWell(
                                      onTap: () async {
                                        await Clipboard.setData(ClipboardData(text: output.scriptpubkeyAddress));
                                        Toast.message("Address copied to clipboard");
                                      },
                                      child: Icon(
                                        Icons.copy,
                                        size: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Text(
                                "${output.value * BTC_SATOSHI_MULTIPLIER} BTC",
                                style: TextStyle(
                                  // color: isToMe ? Theme.of(context).colorScheme.success : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      })
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
