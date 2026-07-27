import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_constants.dart';

import '../../../core/base_component.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/toast.dart';
import '../../encrypt/utils.dart';
import '../models/new_topic.dart';
import '../models/topic.dart';
import '../providers/topic_form_provider.dart';
import 'adj_vote_form.dart';

class TopicForm extends BaseComponent {
  const TopicForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.read(topicFormProvider.notifier);
    final model = ref.watch(topicFormProvider);
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      child: Form(
        key: provider.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.votingCategoryLabel,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                      DropdownButton<VoteTopicCategory>(
                        value: model.category,
                        focusColor: Colors.transparent,
                        items: provider.categoryOptions(context).map((item) {
                          return DropdownMenuItem<VoteTopicCategory>(
                            value: item.value,
                            child: Text(item.label),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val == null) {
                            return;
                          }
                          provider.setCategory(val);
                        },
                        isExpanded: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.votingEndsLabel,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                      DropdownButton<VotingDays>(
                        focusColor: Colors.transparent,
                        value: model.votingEndDays,
                        items: provider.votingDaysOptions(context).map((item) {
                          return DropdownMenuItem<VotingDays>(
                            value: item.value,
                            child: Text(item.label),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val == null) {
                            return;
                          }
                          provider.setVotingEndDays(val);
                        },
                        isExpanded: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            TextFormField(
                controller: provider.nameController,
                validator: provider.nameValidator,
                decoration: InputDecoration(
                  label: Text(l10n.votingTopicNameLabel),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(
                      r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'))
                ],
                maxLength: 128,
                buildCounter: (context,
                    {int? currentLength, int? maxLength, bool? isFocused}) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.votingCharLimit128,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        "$currentLength/$maxLength",
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    ],
                  );
                }),
            const SizedBox(
              height: 16,
            ),
            if (model.category == VoteTopicCategory.AdjVoteIn)
              const AdjVoteForm(),
            if (model.category != VoteTopicCategory.AdjVoteIn)
              TextFormField(
                  controller: provider.descriptionController,
                  validator: provider.descriptionValidator,
                  decoration: InputDecoration(
                    label: Text(l10n.votingTopicDescriptionLabel),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(
                        r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'))
                  ],
                  minLines: 3,
                  maxLines: 6,

                  // maxLength: 1600,
                  buildCounter: (context,
                      {int? currentLength, int? maxLength, bool? isFocused}) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.votingCharLimit1600,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          "$currentLength/1600",
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      ],
                    );
                  }),
            const SizedBox(
              height: 32,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppButton(
                  label: l10n.actionCancel,
                  type: AppButtonType.Text,
                  variant: AppColorVariant.Light,
                  onPressed: () async {
                    final confirmed = await ConfirmDialog.show(
                        title: l10n.votingDiscardTitle,
                        body: l10n.votingDiscardBody);

                    if (confirmed == true) {
                      provider.clear();
                      AutoRouter.of(context).pop();
                    }
                  },
                ),
                AppButton(
                  label: l10n.votingCreateTopic,
                  onPressed: () async {
                    if (!await passwordRequiredGuard(context, ref)) return;
                    final confirmed = await ConfirmDialog.show(
                      title: l10n.votingCreateTopic,
                      body: l10n
                          .votingCreateTopicConfirmBody(VOTE_TOPIC_COST.toString()),
                      confirmText: l10n.votingCreateAction,
                      cancelText: l10n.actionCancel,
                    );

                    if (confirmed != true) {
                      return;
                    }
                    final success = await provider.submit();
                    if (success == null) return;

                    if (success == true) {
                      Toast.message(l10n.votingTopicCreatedToast);
                      AutoRouter.of(context).pop();
                    } else {
                      Toast.error();
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
