import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/explorer_service.dart';
import '../../web/models/paginated_response.dart';
import '../models/token_vote_topic.dart';

class WebTokenTopicListModel {
  final List<WebTokenVoteTopic> topics;
  final bool isLoading;
  final bool canLoadMore;
  final int page;

  const WebTokenTopicListModel({
    this.topics = const [],
    this.isLoading = false,
    this.canLoadMore = true,
    this.page = 1,
  });

  WebTokenTopicListModel copyWith({
    List<WebTokenVoteTopic>? topics,
    bool? isLoading,
    bool? canLoadMore,
    int? page,
  }) {
    return WebTokenTopicListModel(
      topics: topics ?? this.topics,
      isLoading: isLoading ?? this.isLoading,
      canLoadMore: canLoadMore ?? this.canLoadMore,
      page: page ?? this.page,
    );
  }
}

class WebTokenTopicListProvider extends StateNotifier<WebTokenTopicListModel> {
  final Ref ref;
  final String scId;

  /// [fetchTopics] is for tests; the app reads the topics from Spyglass.
  final Future<PaginatedResponse<WebTokenVoteTopic>> Function(String scId) fetchTopics;

  WebTokenTopicListProvider(this.ref, this.scId, {Future<PaginatedResponse<WebTokenVoteTopic>> Function(String scId)? fetchTopics})
      : fetchTopics = fetchTopics ?? ExplorerService().listTokenVotingTopics,
        super(const WebTokenTopicListModel()) {
    load(1);
  }

  load(int page) async {
    state = state.copyWith(isLoading: true);
    final data = await fetchTopics(scId);
    if (!mounted) {
      return;
    }

    state = state.copyWith(
      topics: [...state.topics, ...data.results],
      isLoading: false,
      canLoadMore: data.num_pages > data.page,
      page: page,
    );
  }
}

// autoDispose so the list is fetched again each time the voting sheet opens;
// a topic created or confirmed since the last open would otherwise never show
// until a page reload.
final webTokenTopicListProvider = StateNotifierProvider.autoDispose.family<WebTokenTopicListProvider, WebTokenTopicListModel, String>((ref, scId) {
  return WebTokenTopicListProvider(ref, scId);
});
