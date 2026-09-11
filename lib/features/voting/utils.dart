import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;

import '../../core/models/value_label.dart';
import '../../core/providers/session_provider.dart';
import '../../l10n/generated/app_localizations.dart';
import 'models/adj_vote.dart';
import 'models/new_topic.dart';
import 'models/topic.dart';

bool currentWalletIsValidating(WidgetRef ref) {
  return ref.read(sessionProvider).currentWallet?.isValidating == true;
}

String voteTopicCategoryToString(BuildContext context, VoteTopicCategory category) {
  final l10n = AppLocalizations.of(context);
  switch (category) {
    case VoteTopicCategory.General:
      return l10n.votingCatGeneral;
    case VoteTopicCategory.CodeChange:
      return l10n.votingCatCodeChange;
    case VoteTopicCategory.AddDeveloper:
      return l10n.votingCatAddDeveloper;
    case VoteTopicCategory.RemoveDeveloper:
      return l10n.votingCatRemoveDeveloper;
    case VoteTopicCategory.NetworkChange:
      return l10n.votingCatNetworkChange;
    case VoteTopicCategory.AdjVoteIn:
      return l10n.votingCatAdjVoteIn;
    case VoteTopicCategory.AdjVoteOut:
      return l10n.votingCatAdjVoteOut;
    case VoteTopicCategory.ValidatorChange:
      return l10n.votingCatValidatorChange;
    case VoteTopicCategory.BlockModify:
      return l10n.votingCatBlockModify;
    case VoteTopicCategory.TransactionModify:
      return l10n.votingCatTransactionModify;
    case VoteTopicCategory.BalanceCorrection:
      return l10n.votingCatBalanceCorrection;
    case VoteTopicCategory.HackOrExploitCorrection:
      return l10n.votingCatHackOrExploit;
    case VoteTopicCategory.Other:
      return l10n.votingCatOther;
  }
}

List<ValueLabel<VoteTopicCategory>> voteTopicCategoryValueLabels(BuildContext context) {
  return VoteTopicCategory.values.map((v) => ValueLabel<VoteTopicCategory>(v, voteTopicCategoryToString(context, v))).toList();
}

String votingDaysToString(BuildContext context, VotingDays value) {
  final l10n = AppLocalizations.of(context);
  switch (value) {
    case VotingDays.Thirty:
      return l10n.votingDays30;
    case VotingDays.Sixty:
      return l10n.votingDays60;
    case VotingDays.Ninety:
      return l10n.votingDays90;
    case VotingDays.OneHundredEighty:
      return l10n.votingDays180;
  }
}

List<ValueLabel<VotingDays>> votingDaysValueLabels(BuildContext context) {
  return VotingDays.values.map((v) => ValueLabel<VotingDays>(v, votingDaysToString(context, v))).toList();
}

String providerToString(BuildContext context, Provider provider) {
  final l10n = AppLocalizations.of(context);
  switch (provider) {
    case Provider.onlineCloudVPS:
      return l10n.votingProviderOnlineCloud;
    case Provider.onlineDedicated:
      return l10n.votingProviderOnlineDedicated;
    case Provider.localDedicated:
      return l10n.votingProviderLocalDedicated;
    case Provider.homeMachine:
      return l10n.votingProviderHomeMachine;
    case Provider.officeMachine:
      return l10n.votingProviderOfficeMachine;
  }
}

String osToString(BuildContext context, OS os) {
  switch (os) {
    case OS.linux:
      return "Linux";
    case OS.windows:
      return "Windows";
    case OS.mac:
      return "Mac";
  }
}

String hdSizeSpecifierToString(BuildContext context, HDSizeSpecifier size) {
  switch (size) {
    case HDSizeSpecifier.gb:
      return "GB";
    case HDSizeSpecifier.tb:
      return "TB";
    case HDSizeSpecifier.pb:
      return "PB";
  }
}

List<ValueLabel<Provider>> providerValueLabels(BuildContext context) {
  return Provider.values.map((v) => ValueLabel<Provider>(v, providerToString(context, v))).toList();
}

List<ValueLabel<OS>> osValueLabels(BuildContext context) {
  return OS.values.map((v) => ValueLabel<OS>(v, osToString(context, v))).toList();
}

List<ValueLabel<HDSizeSpecifier>> hdSizeSpecifierValueLabels(BuildContext context) {
  return HDSizeSpecifier.values.map((v) => ValueLabel<HDSizeSpecifier>(v, hdSizeSpecifierToString(context, v))).toList();
}
