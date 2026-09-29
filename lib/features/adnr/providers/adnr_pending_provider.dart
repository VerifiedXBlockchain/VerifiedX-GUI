import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/singletons.dart';
import '../../../core/storage.dart';

/// [current] with `"$id.$type.$adnr"` as the only pending entry for address
/// [id]. An address holds one domain and has one domain action in flight, so
/// any older entry for it is stale; left in place it resurfaces once the
/// domain changes again. A web delete (type `delete`, where desktop uses
/// `burn`) used to leave the create's `.create.null` key behind, which
/// matched again as soon as the deleted domain was gone.
List<String> pendingAdnrKeysAfterAdd(List<String> current, String id, String type, String adnr) {
  final prefix = "$id.";
  return [
    ...current.where((element) => !element.startsWith(prefix)),
    "$id.$type.$adnr",
  ];
}

class AdnrPendingProvider extends StateNotifier<List<String>> {
  AdnrPendingProvider() : super([]) {
    // final items = singleton<Storage>().getStringList(Storage.PENDING_ADNRS) ?? [];
    state = [];
  }

  addId(String id, String type, String adnr) {
    final update = pendingAdnrKeysAfterAdd(state, id, type, adnr);

    singleton<Storage>().setStringList(Storage.PENDING_ADNRS, update);

    state = update;
  }
}

final adnrPendingProvider = StateNotifierProvider<AdnrPendingProvider, List<String>>(
  (_) => AdnrPendingProvider(),
);
