import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/token/models/token_vote_topic.dart';
import 'package:rbx_wallet/features/token/providers/web_token_topic_list_provider.dart';
import 'package:rbx_wallet/features/web/models/paginated_response.dart';

const scId = 'sc-1';

void main() {
  test('reopening the voting sheet fetches the topics again', () async {
    var fetches = 0;
    final container = ProviderContainer(overrides: [
      webTokenTopicListProvider(scId).overrideWith((ref) => WebTokenTopicListProvider(ref, scId, fetchTopics: (_) async {
            fetches++;
            return PaginatedResponse.empty();
          })),
    ]);
    addTearDown(container.dispose);

    final firstOpen = container.listen(webTokenTopicListProvider(scId), (_, __) {});
    expect(fetches, 1);

    firstOpen.close();
    await container.pump();

    container.listen(webTokenTopicListProvider(scId), (_, __) {});
    expect(fetches, 2);
  });

  test('an answer that arrives after the sheet closed is dropped without an error', () async {
    final pending = Completer<PaginatedResponse<WebTokenVoteTopic>>();
    final container = ProviderContainer(overrides: [
      webTokenTopicListProvider(scId).overrideWith((ref) => WebTokenTopicListProvider(ref, scId, fetchTopics: (_) => pending.future)),
    ]);
    addTearDown(container.dispose);

    final open = container.listen(webTokenTopicListProvider(scId), (_, __) {});
    final notifier = container.read(webTokenTopicListProvider(scId).notifier);
    open.close();
    await container.pump();
    expect(notifier.mounted, isFalse);

    // Without the guard, writing the state of the disposed notifier throws.
    pending.complete(PaginatedResponse.empty());
    await pumpEventQueue();
  });
}
