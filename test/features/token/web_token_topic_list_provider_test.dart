import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/token/providers/web_token_topic_list_provider.dart';

const scId = 'sc-1';

class _CountingTopicList extends WebTokenTopicListProvider {
  _CountingTopicList(Ref ref, this.onLoad) : super(ref, scId);

  final void Function() onLoad;

  @override
  load(int page) async {
    onLoad();
  }
}

void main() {
  test('reopening the voting sheet fetches the topics again', () async {
    var loads = 0;
    final container = ProviderContainer(overrides: [
      webTokenTopicListProvider(scId).overrideWith((ref) => _CountingTopicList(ref, () => loads++)),
    ]);
    addTearDown(container.dispose);

    final firstOpen = container.listen(webTokenTopicListProvider(scId), (_, __) {});
    expect(loads, 1);

    firstOpen.close();
    await container.pump();

    container.listen(webTokenTopicListProvider(scId), (_, __) {});
    expect(loads, 2);
  });
}
