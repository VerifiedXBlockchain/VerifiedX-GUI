import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pie_chart/pie_chart.dart';
import '../../../core/base_component.dart';
import '../../../core/base_screen.dart';
import '../../../core/components/badges.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/services/explorer_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../encrypt/utils.dart';
import '../../global_loader/global_loading_provider.dart';
import '../../nft/services/nft_service.dart';
import '../../smart_contracts/components/sc_creator/common/modal_container.dart';
import '../models/token_vote_topic.dart';
import '../services/token_service.dart';
import '../../voting/providers/pending_votes_provider.dart';
import '../../../utils/toast.dart';
import 'package:collection/collection.dart';

import '../../voting/components/topic_detail.dart';
import '../models/token_vote.dart';
import '../providers/web_token_actions_manager.dart';

class TokenTopicDetailScreen extends BaseScreen {
  final TokenVoteTopic topic;
  final String address;
  final double balance;
  final bool isOwner;
  const TokenTopicDetailScreen(this.topic, this.address, this.balance, this.isOwner, {super.key});

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: Colors.black,
      title: Text(topic.topicName),
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    return TokenTopicDetail(
      topic: topic,
      address: address,
      balance: balance,
      isOwner: isOwner,
    );
  }
}

class TokenTopicDetail extends BaseStatefulComponent {
  const TokenTopicDetail({
    super.key,
    required this.topic,
    required this.address,
    required this.balance,
    required this.isOwner,
  });

  final TokenVoteTopic topic;
  final String address;
  final double balance;
  final bool isOwner;

  @override
  _TokenTopicDetailState createState() => _TokenTopicDetailState();
}

class _TokenTopicDetailState extends BaseComponentState<TokenTopicDetail> {
  late TokenVoteTopic topic;
  late Timer timer;

  TokenVote? currentVote;

  @override
  void initState() {
    topic = widget.topic;
    poll();
    timer = Timer.periodic(const Duration(seconds: 20), (timer) {
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
    if (kIsWeb) {
      final t = await ExplorerService().retrieveTokenVotingTopic(widget.topic.topicUid);

      if (t != null) {
        setState(() {
          topic = t.toNative();
        });
      }

      return;
    }
    final nft = await NftService().getNftData(topic.smartContractUid);

    if (nft != null && nft.tokenStateDetails != null) {
      final t = nft.tokenStateDetails!.topicList.firstWhereOrNull((item) => item.topicUid == topic.topicUid);

      if (t != null) {
        setState(() {
          topic = t;
        });
      }
    }

    final votes = await TokenService().listAddressVotes(widget.address);

    setState(() {
      currentVote = votes.firstWhereOrNull((v) => v.topicUid == widget.topic.topicUid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
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
                    topic.topicName,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    l10n.tkbTopicUidLabel(topic.topicUid),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            DateCard(
              label: l10n.tokenTopicCreatedLabel,
              value: topic.createdAtFormatted,
            ),
            DateCard(
              label: l10n.tokenVotingEndsLabel,
              value: topic.endsAtFormatted,
            )
          ],
        ),
        const Divider(),
        Text(topic.topicDescription, style: TextStyle(fontSize: 18)),
        const SizedBox(height: 6),
        SelectableText(l10n.tkbSmartContractUidWithValue(topic.smartContractUid)),
        const SizedBox(height: 6),
        if (!kIsWeb) ...[
          Text(l10n.tkbBlockHeightValue(topic.blockHeight.toString())),
          const SizedBox(height: 6),
        ],
        Text(l10n.tkbMinimumTokensToVote(topic.minimumVoteRequirement.toString())),
        const SizedBox(height: 6),
        Text(l10n.tkbYourBalanceValue(widget.balance.toString())),

        // const SizedBox(height: 6),
        // Text("Token Holder Count: ${topic.tokenHolderCount}"),
        Divider(),
        _TopicVotingDetails(
          topic: topic,
          isOwner: widget.isOwner,
        ),
        const SizedBox(height: 12),
        _TopicVotingActions(
          topic: topic,
          address: widget.address,
          balance: widget.balance,
          currentVote: currentVote,
        )
      ],
    );
  }
}

class _TopicVotingActions extends BaseComponent {
  const _TopicVotingActions({
    required this.topic,
    required this.address,
    required this.balance,
    required this.currentVote,
  });

  final String address;
  final TokenVoteTopic topic;
  final double balance;
  final TokenVote? currentVote;

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (currentVote != null) {
      return _ErrorMessage(l10n.tkbVotedOnBlock(currentVote!.voteTypeLabel, currentVote!.blockHeight.toString()));
    }

    final pendingVoteKey = "$address|${topic.topicUid}";

    if (!kIsWeb && ref.watch(pendingVotesProvider).contains(pendingVoteKey)) {
      return _ErrorMessage(l10n.votingPendingTx);
    }

    if (kIsWeb && ref.watch(pendingVotesProvider).contains(pendingVoteKey)) {
      return _ErrorMessage(l10n.tkbYouHaveVoted);
    }

    if (!topic.isActive) {
      return _ErrorMessage(l10n.votingEndedOn(topic.endsAtFormatted));
    }

    if (balance < topic.minimumVoteRequirement) {
      return _ErrorMessage(l10n.tkbNeedTokensToVote(topic.minimumVoteRequirement.toString()));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.votingCastYourVote,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppButton(
              label: l10n.tokenVoteYes,
              onPressed: () async {
                if (!await passwordRequiredGuard(context, ref)) return;
                final confirmed = await ConfirmDialog.show(
                  title: l10n.tokenConfirmVoteYes,
                  body: l10n.tkbConfirmVoteYesBody,
                  confirmText: l10n.votingConfirmYesAction,
                  cancelText: l10n.actionCancel,
                );
                if (confirmed == true) {
                  // provider.voteYes();
                  ref.read(globalLoadingProvider.notifier).start();

                  bool? success;

                  if (kIsWeb) {
                    final token = await ExplorerService().retrieveToken(topic.smartContractUid);
                    if (token == null) {
                      Toast.error(l10n.tokenNoOwnerToast);
                      success = false;
                    } else {
                      success = await ref
                          .read(webTokenActionsManager)
                          .voteOnTopic(topic.smartContractUid, token.token.ownerAddress, address, topic.topicUid, true);
                    }
                  } else {
                    success = await TokenService().castVote(
                      scId: topic.smartContractUid,
                      fromAddress: address,
                      topicUid: topic.topicUid,
                      yes: true,
                    );
                  }

                  if (success == true) {
                    ref.read(pendingVotesProvider.notifier).addId(pendingVoteKey);
                    Toast.message(l10n.tokenVoteCastedToast);
                  }

                  ref.read(globalLoadingProvider.notifier).complete();
                }
              },
              variant: AppColorVariant.Success,
              size: AppSizeVariant.Lg,
            ),
            const SizedBox(
              width: 16,
            ),
            AppButton(
              label: l10n.tokenVoteNo,
              onPressed: () async {
                if (!await passwordRequiredGuard(context, ref)) return;

                final confirmed = await ConfirmDialog.show(
                  title: l10n.tokenConfirmVoteNo,
                  body: l10n.tkbConfirmVoteNoBody,
                  confirmText: l10n.votingConfirmNoAction,
                  cancelText: l10n.actionCancel,
                );
                if (confirmed == true) {
                  // provider.voteNo();
                  ref.read(globalLoadingProvider.notifier).start();

                  bool? success;

                  if (kIsWeb) {
                    final token = await ExplorerService().retrieveToken(topic.smartContractUid);
                    if (token == null) {
                      Toast.error(l10n.tokenNoOwnerToast);
                      success = false;
                    } else {
                      success = await ref
                          .read(webTokenActionsManager)
                          .voteOnTopic(topic.smartContractUid, token.token.ownerAddress, address, topic.topicUid, false);
                    }
                  } else {
                    success = await TokenService().castVote(
                      scId: topic.smartContractUid,
                      fromAddress: address,
                      topicUid: topic.topicUid,
                      yes: false,
                    );
                  }

                  if (success == true) {
                    ref.read(pendingVotesProvider.notifier).addId(pendingVoteKey);
                    Toast.message(l10n.tokenVoteCastedToast);
                  }
                  ref.read(globalLoadingProvider.notifier).complete();
                }
              },
              variant: AppColorVariant.Danger,
              size: AppSizeVariant.Lg,
            )
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.votingEndsAt(topic.endsAtFormatted),
          style: Theme.of(context).textTheme.bodySmall,
        )
      ],
    );
  }
}

class _TopicVotingDetails extends BaseComponent {
  const _TopicVotingDetails({
    required this.topic,
    required this.isOwner,
  });

  final TokenVoteTopic topic;
  final bool isOwner;

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Builder(
      builder: (context) {
        if (topic.totalVotes < 1) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                l10n.tkbNoVotesYet,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }
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
                      l10n.tkbVoteCounts,
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
                          l10n.tkbVotesYes,
                          topic.voteYes.toString(),
                          Theme.of(context).colorScheme.success,
                        ),
                        buildDetailRow(
                          context,
                          l10n.tkbVotesNo,
                          topic.voteNo.toString(),
                          Theme.of(context).colorScheme.danger,
                        ),
                        buildDetailRow(
                          context,
                          l10n.tkbTotalVotes,
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
                      l10n.tkbPercentages,
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
                          l10n.tkbVotesYes,
                          "${topic.percentVotesYes}%",
                          Theme.of(context).colorScheme.success,
                        ),
                        buildDetailRow(
                          context,
                          l10n.tkbVotesNo,
                          "${topic.percentVotesNo}%",
                          Theme.of(context).colorScheme.danger,
                        ),
                        if (topic.isActive) buildDetailRow(context, l10n.tkbResult, l10n.tkbInProgress),
                        if (!topic.isActive) buildDetailRow(context, l10n.tkbResult, topic.percentInFavor > topic.percentAgainst ? l10n.tkbResultPass : l10n.tkbResultFail),
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
                l10n.actionYes: topic.voteYes.toDouble(),
                l10n.actionNo: topic.voteNo.toDouble(),
              },
            ),
            const SizedBox(width: 16),
            if (isOwner)
              AppButton(
                label: l10n.tokenVoteHistory,
                onPressed: () async {
                  // await ref.read(voteListProvider(topic.uid).notifier).load();

                  if (kIsWeb) {
                    final votes = topic.webVoteList;
                    if (votes == null || votes.isEmpty) {
                      Toast.message(l10n.tokenNoVotesToast);
                      return;
                    }

                    showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: Colors.black87,
                      context: context,
                      builder: (context) {
                        return ModalContainer(
                            padding: 8,
                            withClose: true,
                            withDecor: false,
                            children: votes
                                .map(
                                  (vote) => ListTile(
                                    title: SelectableText(vote.address),
                                    subtitle: Text(vote.createdAtFormatted),
                                    trailing: AppBadge(
                                      label: vote.value ? l10n.tkbYesUpper : l10n.tkbNoUpper,
                                      variant: vote.value ? AppColorVariant.Success : AppColorVariant.Danger,
                                    ),
                                  ),
                                )
                                .toList());
                      },
                    );

                    return;
                  }

                  final votes = await TokenService().listVotes(topic.topicUid);
                  showModalBottomSheet(
                    isScrollControlled: true,
                    backgroundColor: Colors.black87,
                    context: context,
                    builder: (context) {
                      return ModalContainer(
                          padding: 8,
                          withClose: true,
                          withDecor: false,
                          children: votes
                              .map(
                                (vote) => ListTile(
                                  title: SelectableText(vote.address),
                                  subtitle: Text(l10n.tokenVoteBlockSubtitle(vote.blockHeight.toString())),
                                  trailing: AppBadge(
                                    label: vote.voteTypeLabel,
                                    variant: vote.voteType == TokenVoteType.Yes ? AppColorVariant.Success : AppColorVariant.Danger,
                                  ),
                                ),
                              )
                              .toList());
                    },
                  );
                },
                type: AppButtonType.Elevated,
                variant: AppColorVariant.Light,
              )
          ],
        );
      },
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

class _ErrorMessage extends StatelessWidget {
  final String message;
  const _ErrorMessage(
    this.message, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ));
  }
}
