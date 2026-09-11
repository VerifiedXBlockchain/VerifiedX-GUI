import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/base_component.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/adj_vote.dart';
import '../models/topic.dart';
import 'topic_vote_actions.dart';
import 'voting_category_badge.dart';
import 'voting_details.dart';

class TopicDetail extends BaseComponent {
  final Topic topic;
  const TopicDetail(this.topic, {Key? key}) : super(key: key);

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      topic.name,
                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    VotingCategoryBadge(topic: topic),
                    const SizedBox(height: 4),
                    SelectableText(
                      l10n.votingUid(topic.uid),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              DateCard(
                label: l10n.votingTopicCreatedLabel,
                value: topic.createdAtFormatted,
              ),
              DateCard(
                label: l10n.votingEndsLabel,
                value: topic.endsAtFormatted,
              )
            ],
          ),
          const Divider(),
          SelectableText(l10n.votingBlockHeightDetail(topic.blockHeight.toString())),
          SelectableText(l10n.votingTopicOwner(topic.ownerAddress)),
          const Divider(),
          const SizedBox(height: 6),
          topic.category == VoteTopicCategory.AdjVoteIn && topic.descriptionIsJson
              ? AdjudicatorInVoteDetails(
                  topic: topic,
                )
              : Text(
                  topic.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
          const Divider(),
          VotingDetails(topic),
          const Divider(),
          TopicVoteActions(topicUid: topic.uid),
          const Divider(),
        ],
      ),
    );
  }
}

class AdjudicatorInVoteDetails extends BaseComponent {
  const AdjudicatorInVoteDetails({Key? key, required this.topic}) : super(key: key);
  final Topic topic;
  @override
  Widget build(BuildContext context, ref) {
    final l10n = AppLocalizations.of(context);
    final data = jsonDecode(topic.description);
    final details = AdjVote.fromJson(data);
    return Column(
      children: [
        _AdjudicatorDetailValue(
          label: l10n.govAdjVfxAddressLabel,
          value: details.rbxAddress,
        ),
        _AdjudicatorDetailValue(
          label: l10n.govAdjIpAddressLabel,
          value: details.ipAddress,
        ),
        _AdjudicatorDetailValue(
          label: l10n.govAdjMachineProviderLabel,
          value: details.provider.name,
        ),
        _AdjudicatorDetailValue(
          label: l10n.govAdjOperatingSystemLabel,
          value: details.machineOs.name,
        ),
        _AdjudicatorDetailValue(
          label: l10n.govAdjMachineTypeLabel,
          value: details.machineType,
        ),
        Row(
          children: [
            _AdjudicatorDetailValue(
              label: l10n.govAdjCpuLabel,
              value: details.machineCPU,
            ),
            const SizedBox(
              width: 10,
            ),
            _AdjudicatorDetailValue(
              label: l10n.govAdjCpuCoresLabel,
              value: details.machineCPUCores.toString(),
            ),
            const SizedBox(
              width: 10,
            ),
            _AdjudicatorDetailValue(
              label: l10n.govAdjCpuThreadsLabel,
              value: details.machineCPUThreads.toString(),
            ),
          ],
        ),
        Row(
          children: [
            _AdjudicatorDetailValue(
              label: l10n.govAdjRamLabel,
              value: details.machineRam.toString(),
            ),
            const SizedBox(
              width: 10,
            ),
            _AdjudicatorDetailValue(
              label: l10n.govAdjHdSizeLabel,
              value: details.machineRam.toString() + details.machineHDDSpecifier.name.toUpperCase(),
            ),
          ],
        ),
        Row(
          children: [
            _AdjudicatorDetailValue(
              label: l10n.govAdjInternetDownLabel,
              value: details.internetSpeedDown.toString(),
            ),
            const SizedBox(
              width: 10,
            ),
            _AdjudicatorDetailValue(
              label: l10n.govAdjInternetUpLabel,
              value: details.internetSpeedUp.toString(),
            ),
            const SizedBox(
              width: 10,
            ),
            _AdjudicatorDetailValue(
              label: l10n.govAdjBandwidthLabel,
              value: details.bandwith != 0 ? details.bandwith.toString() : l10n.govAdjBandwidthUnlimited,
            ),
          ],
        ),
        _AdjudicatorDetailValue(
          label: l10n.govAdjTechnicalBackgroundLabel,
          value: details.technicalBackground,
          maxLines: 3,
        ),
        _AdjudicatorDetailValue(
          label: l10n.govAdjReasonLabel,
          value: details.reasonForAdjJoin,
          maxLines: 3,
        ),
        _AdjudicatorDetailValue(
          label: l10n.govAdjGithubLinkLabel,
          value: details.githubLink,
        ),
        _AdjudicatorDetailValue(
          label: l10n.govAdjAdditionalLinksLabel,
          value: details.supplementalURLs,
        ),
      ],
    );
  }
}

class _AdjudicatorDetailValue extends StatelessWidget {
  const _AdjudicatorDetailValue({Key? key, required this.label, required this.value, this.maxLines = 1}) : super(key: key);
  final int maxLines;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
            maxLines: maxLines,
          ),
        ],
      ),
    );
  }
}

class DateCard extends StatelessWidget {
  final String label;
  final String value;
  const DateCard({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
