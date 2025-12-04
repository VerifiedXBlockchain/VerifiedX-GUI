import 'package:flutter/material.dart';

import '../models/butterfly_link.dart';

class ButterflyStatusBadge extends StatelessWidget {
  final ButterflyLinkStatus status;

  const ButterflyStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getBackgroundColor()),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(),
            size: 14,
            color: _getBackgroundColor(),
          ),
          const SizedBox(width: 4),
          Text(
            _getLabel(),
            style: TextStyle(
              color: _getBackgroundColor(),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (status) {
      case ButterflyLinkStatus.pending:
        return Colors.orange;
      case ButterflyLinkStatus.readyForRedemption:
        return Colors.green;
      case ButterflyLinkStatus.claiming:
        return Colors.blue;
      case ButterflyLinkStatus.claimed:
        return Colors.grey;
    }
  }

  IconData _getIcon() {
    switch (status) {
      case ButterflyLinkStatus.pending:
        return Icons.hourglass_empty;
      case ButterflyLinkStatus.readyForRedemption:
        return Icons.check_circle_outline;
      case ButterflyLinkStatus.claiming:
        return Icons.sync;
      case ButterflyLinkStatus.claimed:
        return Icons.done_all;
    }
  }

  String _getLabel() {
    switch (status) {
      case ButterflyLinkStatus.pending:
        return 'Pending';
      case ButterflyLinkStatus.readyForRedemption:
        return 'Ready';
      case ButterflyLinkStatus.claiming:
        return 'Claiming';
      case ButterflyLinkStatus.claimed:
        return 'Claimed';
    }
  }
}
