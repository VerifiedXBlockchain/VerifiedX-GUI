// ignore_for_file: library_private_types_in_public_api

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:rbx_wallet/features/voting/providers/vote_list_provider.dart';
import 'package:rbx_wallet/features/wallet/providers/wallet_list_provider.dart';

import '../../../core/base_component.dart';
import '../../../core/components/buttons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/topic.dart';
import '../services/topic_service.dart';
import 'vote_history_modal.dart';

class VotingDetails extends BaseStatefulComponent {
  final Topic topic;
  const VotingDetails(this.topic, {Key? key}) : super(key: key);

  @override
  _VotingDetailsState createState() => _VotingDetailsState();
}

class _VotingDetailsState extends BaseComponentState<VotingDetails> {
  late Topic topic;
  late Timer timer;
  @override
  void initState() {
    topic = widget.topic;
    poll();
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      poll();
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();

    super.dispose();
  }

  Future<void> poll() async {
    final t = await TopicService().retrieve(topic.uid);
    if (t != null) {
      setState(() {
        topic = t;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (topic.totalVotes < 1) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            l10n.votingNoVotesYet,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    final includeShowHistoryButton = ref.read(walletListProvider).where((w) => w.address == topic.ownerAddress).toList().isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Card(
          color: Colors.white.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.votingVoteCounts,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white),
                ),
                const SizedBox(
                  height: 4,
                ),
                Table(
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  children: [
                    buildDetailRow(
                      context,
                      l10n.votingVotesYes,
                      topic.yesVotes.toString(),
                      Theme.of(context).colorScheme.success,
                    ),
                    buildDetailRow(
                      context,
                      l10n.votingVotesNo,
                      topic.noVotes.toString(),
                      Theme.of(context).colorScheme.danger,
                    ),
                    buildDetailRow(
                      context,
                      l10n.votingTotalVotes,
                      topic.totalVotes.toString(),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Card(
          color: Colors.white.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.votingPercentages,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white),
                ),
                const SizedBox(
                  height: 4,
                ),
                Table(
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  children: [
                    buildDetailRow(
                      context,
                      l10n.votingVotesYes,
                      "${topic.yesPercent}%",
                      Theme.of(context).colorScheme.success,
                    ),
                    buildDetailRow(
                      context,
                      l10n.votingVotesNo,
                      "${topic.noPercent}%",
                      Theme.of(context).colorScheme.danger,
                    ),
                    if (topic.isActive) buildDetailRow(context, l10n.votingResult, l10n.votingInProgress),
                    if (!topic.isActive) buildDetailRow(context, l10n.votingResult, topic.percentInFavor > topic.percentAgainst ? l10n.votingPass : l10n.votingFail),
                  ],
                )
              ],
            ),
          ),
        ),
        const SizedBox(
          width: 16,
        ),
        PieChart(
          chartRadius: 100,
          chartType: ChartType.ring,
          chartValuesOptions: const ChartValuesOptions(
            decimalPlaces: 0,
            showChartValues: false,
          ),
          colorList: [
            Theme.of(context).colorScheme.success,
            Theme.of(context).colorScheme.danger,
          ],
          dataMap: {
            l10n.actionYes: topic.yesVotes.toDouble(),
            l10n.actionNo: topic.noVotes.toDouble(),
          },
        ),
        const SizedBox(width: 16),
        if (includeShowHistoryButton)
          AppButton(
            label: l10n.votingShowHistory,
            onPressed: () async {
              await ref.read(voteListProvider(topic.uid).notifier).load();
              showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: Colors.black87,
                context: context,
                builder: (context) {
                  return VoteListModal(topicUid: topic.uid);
                },
              );
            },
            type: AppButtonType.Elevated,
            variant: AppColorVariant.Light,
          )
      ],
    );
  }

  TableRow buildDetailRow(
    BuildContext context,
    String label,
    String value, [
    Color color = Colors.white,
  ]) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}
