import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../core/base_component.dart';
import '../../../core/env.dart';
import '../../../core/theme/colors.dart';
import '../models/shielded_balance.dart';
import '../models/shielded_commitment.dart';

class CommitmentList extends BaseComponent {
  final ShieldedBalance balance;

  const CommitmentList({
    super.key,
    required this.balance,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commitments = balance.commitments;
    if (commitments == null || commitments.isEmpty) {
      return const SizedBox.shrink();
    }

    final unspent = commitments.where((c) => !c.isSpent).toList();

    return Card(
      color: AppColors.getGray(ColorShade.s200),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Row(
            children: [
              Text(
                "Commitments (${unspent.length} note${unspent.length == 1 ? '' : 's'})",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 6),
              Tooltip(
                message:
                    "Notes represent individual shielded outputs that make up your\n"
                    "private balance. Each note is a separate commitment on-chain.\n"
                    "When you send a private transaction, notes are consumed and\n"
                    "new ones are created as change. Use consolidation to merge\n"
                    "many small notes into fewer larger ones.",
                child: Icon(Icons.info_outline, size: 15, color: Colors.white30),
              ),
            ],
          ),
          iconColor: Colors.white54,
          collapsedIconColor: Colors.white38,
          children: [
            const Divider(height: 1, color: Colors.white12),
            ...unspent.map((c) => _CommitmentRow(commitment: c)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _CommitmentRow extends StatelessWidget {
  final ShieldedCommitment commitment;

  const _CommitmentRow({required this.commitment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: commitment.isSpent ? Colors.red : AppColors.getSpringGreen(),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${commitment.amount} ${commitment.assetType}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      "Tree pos: ${commitment.treePosition}  |  ",
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        launchUrlString("${Env.baseExplorerUrl}block/${commitment.blockHeight}");
                      },
                      child: Text(
                        "Block: ${commitment.blockHeight}",
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
