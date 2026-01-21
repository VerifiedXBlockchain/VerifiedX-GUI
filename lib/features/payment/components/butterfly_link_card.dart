import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../utils/toast.dart';
import '../models/butterfly_link.dart';
import '../providers/butterfly_links_provider.dart';
import 'butterfly_status_badge.dart';

class ButterflyLinkCard extends ConsumerWidget {
  final ButterflyLink link;
  final VoidCallback? onTap;

  const ButterflyLinkCard({
    super.key,
    required this.link,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      link.iconData,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          link.displayAmount,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (link.message.isNotEmpty)
                          Text(
                            link.message,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  ButterflyStatusBadge(status: link.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    timeago.format(link.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const Spacer(),
                  if (link.status == ButterflyLinkStatus.pending ||
                      link.status == ButterflyLinkStatus.readyForRedemption)
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 18),
                      onPressed: () {
                        ref
                            .read(butterflyLinksProvider.notifier)
                            .refreshLinkStatus(link.linkId);
                        Toast.message('Refreshing status...');
                      },
                      tooltip: 'Refresh Status',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: link.fullUrl));
                      Toast.message('Link copied to clipboard');
                    },
                    tooltip: 'Copy Link',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
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
