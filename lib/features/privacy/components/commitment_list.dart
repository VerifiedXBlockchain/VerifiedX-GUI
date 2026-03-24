import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/base_component.dart';
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
          title: Text(
            "Commitments (${unspent.length} note${unspent.length == 1 ? '' : 's'})",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          iconColor: Colors.white54,
          collapsedIconColor: Colors.white38,
          children: [
            const Divider(height: 1, color: Colors.white12),
            ...unspent.map((c) => _CommitmentRow(commitment: c)),
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
                Text(
                  "Tree pos: ${commitment.treePosition}  |  Block: ${commitment.blockHeight}",
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
