import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/new_token_topic.dart';

import '../../../core/base_component.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/toast.dart';
import '../../encrypt/utils.dart';
import '../providers/token_topic_form_provider.dart';

class TokenTopicForm extends BaseComponent {
  final String scId;
  final String address;
  const TokenTopicForm({
    Key? key,
    required this.scId,
    required this.address,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final family = "$scId||$address";
    final provider = ref.read(tokenTopicFormProvider(family).notifier);
    final model = ref.watch(tokenTopicFormProvider(family));
    return SingleChildScrollView(
      child: Form(
        key: provider.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: TextFormField(
                        controller: provider.nameController,
                        validator: provider.nameValidator,
                        decoration: InputDecoration(
                          label: Text(l10n.votingTopicNameLabel),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(
                            RegExp(r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'),
                          )
                        ],
                        maxLength: 128,
                        buildCounter: (context, {int? currentLength, int? maxLength, bool? isFocused}) {
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
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.votingEndsLabel,
                        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                      ),
                      DropdownButton<TokenVotingDays>(
                        focusColor: Colors.transparent,
                        value: model.votingEndDays,
                        items: provider.votingDaysOptions(context).map((item) {
                          return DropdownMenuItem<TokenVotingDays>(
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
            const SizedBox(
              height: 16,
            ),
            TextFormField(
              controller: provider.descriptionController,
              validator: provider.descriptionValidator,
              decoration: InputDecoration(
                label: Text(l10n.votingTopicDescriptionLabel),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.deny(
                    RegExp(r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'))
              ],
              minLines: 3,
              maxLines: 6,

              // maxLength: 1600,
              buildCounter: (context, {int? currentLength, int? maxLength, bool? isFocused}) {
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
              },
            ),
            TextFormField(
              controller: provider.miniumVotesController,
              validator: provider.minimumVotesValidator,
              decoration: InputDecoration(
                label: Text(l10n.tkbMinimumTokenRequirement),
                helperText: l10n.tkbMinimumTokenRequirementHelper,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
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
                    final confirmed = await ConfirmDialog.show(title: l10n.votingDiscardTitle, body: l10n.votingDiscardBody);

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
                      body: l10n.tkbCreateTokenTopicBody,
                      confirmText: l10n.votingCreateAction,
                      cancelText: l10n.actionCancel,
                    );

                    if (confirmed != true) {
                      return;
                    }
                    final success = await provider.submit();
                    if (success == null) return;

                    if (success == true) {
                      Toast.message(l10n.tkbTokenTopicCreated);
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
