import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../models/topic.dart';
import '../services/topic_service.dart';

enum TopicListType {
  All,
  Active,
  Inactive,
  VotedOn,
  NotVotedOn,
  Mine,
}

class TopicListProvider extends StateNotifier<List<Topic>> {
  final Ref ref;
  final TopicListType listType;

  TopicListProvider(this.ref, this.listType, [List<Topic> topics = const []]) : super(topics) {
    load();
  }

  Future<void> load() async {
    late final List<Topic> data;

    switch (listType) {
      case TopicListType.All:
        data = await TopicService().all();
        break;
      case TopicListType.Active:
        data = await TopicService().active();
        break;
      case TopicListType.Inactive:
        data = await TopicService().inactive();
        break;
      case TopicListType.VotedOn:
        data = await TopicService().hasVoted();
        break;
      case TopicListType.NotVotedOn:
        data = await TopicService().notVoted();
        break;
      case TopicListType.Mine:
        data = await TopicService().mine();
        break;
    }

    state = data;
  }

  void refresh() {
    load();
  }

  String emptyMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (listType) {
      case TopicListType.All:
        return l10n.tokenNoTopicsTitle;
      case TopicListType.Active:
        return l10n.r3hNoActiveTopics;
      case TopicListType.Inactive:
        return l10n.r3hNoInactiveTopics;
      case TopicListType.VotedOn:
        return l10n.r3hNotVotedAnyTopics;
      case TopicListType.NotVotedOn:
        return l10n.r3hVotedAllTopics;
      case TopicListType.Mine:
        return l10n.r3hNoCreatedTopics;
    }
  }
}

final topicListProvider = StateNotifierProvider.family<TopicListProvider, List<Topic>, TopicListType>(
  (ref, listType) => TopicListProvider(ref, listType),
);
