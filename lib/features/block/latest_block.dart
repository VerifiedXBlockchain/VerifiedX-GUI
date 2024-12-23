import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/base_component.dart';
import '../../utils/formatting.dart';
import '../bridge/providers/wallet_info_provider.dart';
import 'block.dart';
import 'block_transaction_list_bottom_sheet.dart';

class LatestBlock extends BaseComponent {
  final Block? blockOverride;
  final Color? backgroundColor;
  const LatestBlock({
    Key? key,
    this.blockOverride,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestBlock = blockOverride ?? ref.watch(walletInfoProvider)?.lastestBlock;

    if (latestBlock == null) {
      return const SizedBox();
    }
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFF050505),
        boxShadow: glowingBox,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Block ${latestBlock.height}",
                  style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.white),
                ),
                Text(
                  timeago.format(
                    DateTime.fromMillisecondsSinceEpoch(
                      latestBlock.timestamp * 1000,
                    ),
                  ),
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            _DetailItem(
              label: "Hash",
              value: latestBlock.hash,
            ),
            Row(
              children: [
                Expanded(
                  child: _DetailItem(
                    label: "Craft Time",
                    value: "${(latestBlock.craftTime / 1000)} seconds",
                  ),
                ),
                Expanded(
                  child: _DetailItem(
                    label: "Size",
                    value: formatIntWithCommas(latestBlock.size),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _DetailItem(
                    label: "# of Txs",
                    value: "${latestBlock.numberOfTransactions}",
                  ),
                ),
                if (latestBlock.transactions.isNotEmpty)
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return BlockTransactionListBottomSheet(transactions: latestBlock.transactions);
                            });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          "View Txs",
                          style: Theme.of(context)
                              .textTheme
                              .caption!
                              .copyWith(fontSize: 10, color: Theme.of(context).colorScheme.secondary, decoration: TextDecoration.underline),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _DetailItem(
                    label: "Total Amount",
                    value: "${latestBlock.totalAmount} RBX",
                  ),
                ),
                Expanded(
                  child: _DetailItem(
                    label: "Total Reward",
                    value: "${latestBlock.totalReward} RBX",
                  ),
                ),
              ],
            ),
            _DetailItem(
              label: "Validated By",
              value: latestBlock.validator,
              mono: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final bool mono;
  const _DetailItem({
    Key? key,
    required this.label,
    required this.value,
    this.mono = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.caption!.copyWith(decoration: TextDecoration.underline),
        ),
        const SizedBox(
          height: 2,
        ),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .caption!
              .copyWith(fontSize: mono ? 10 : null, fontFamily: mono ? "RobotoMono" : null, color: Colors.white38),
        ),
        const SizedBox(
          height: 8,
        ),
      ],
    );
  }
}
