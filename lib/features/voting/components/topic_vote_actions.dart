import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/base_component.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../encrypt/utils.dart';
import '../providers/my_vote_list_provider.dart';
import '../providers/pending_votes_provider.dart';
import '../providers/voting_provider.dart';

class TopicVoteActions extends BaseComponent {
  const TopicVoteActions({
    Key? key,
    required this.topicUid,
  }) : super(key: key);

  final String topicUid;

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final topic = ref.watch(votingProvider(topicUid));
    final provider = ref.read(votingProvider(topicUid).notifier);

    final myVotes = ref.watch(myVoteListProvider);

    if (topic == null) {
      return const SizedBox.shrink();
    }

    if (!topic.isActive) {
      return _ErrorMessage(l10n.r3hVotingEndedOn(topic.endsAtFormatted));
    }

    final myAddress = ref.watch(sessionProvider.select((v) => v.currentWallet?.address));

    if (myAddress == null) {
      return _ErrorMessage(l10n.r3hMustSelectAccountToVote);
    }

    final isValidating = ref.watch(sessionProvider.select((v) => v.currentWallet?.isValidating)) == true;
    if (!isValidating) {
      return _ErrorMessage(l10n.votingMustBeValidatorToVote);
    }

    final existingVote = myVotes.firstWhereOrNull((a) => a.address == myAddress && a.topicUid == topic.uid);

    if (existingVote != null) {
      if (existingVote.blockHeight == 0) {
        return _ErrorMessage(l10n.r3hYouVotedPending(existingVote.voteTypeLabel));
      }
      return _ErrorMessage(l10n.r3hYouVotedOnBlock(existingVote.voteTypeLabel, existingVote.blockHeight.toString()));
    }

    if (ref.read(pendingVotesProvider).contains(topic.uid)) {
      return _ErrorMessage(l10n.votingPendingTx);
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
                  title: l10n.r3hConfirmVoteYesTitle,
                  body: l10n.r3hConfirmVoteYesBody,
                  confirmText: l10n.r3hVoteYesUpper,
                  cancelText: l10n.actionCancel,
                );
                if (confirmed == true) {
                  provider.voteYes();
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
                  title: l10n.r3hConfirmVoteNoTitle,
                  body: l10n.r3hConfirmVoteNoBody,
                  confirmText: l10n.r3hVoteNoUpper,
                  cancelText: l10n.actionCancel,
                );
                if (confirmed == true) {
                  provider.voteNo();
                }
              },
              variant: AppColorVariant.Danger,
              size: AppSizeVariant.Lg,
            )
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.r3hVotingEndsOn(topic.endsAtFormatted),
          style: Theme.of(context).textTheme.bodySmall,
        )
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
