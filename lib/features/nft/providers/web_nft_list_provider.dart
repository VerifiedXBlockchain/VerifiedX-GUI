import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/explorer_service.dart';
import '../models/nft.dart';
import '../models/web_nft.dart';

class WebNftListProvider extends StateNotifier<List<WebNft>> {
  final Ref ref;
  final String address;

  WebNftListProvider(this.ref, this.address) : super([]) {
    load(1);
  }

  Future<void> load(int page) async {
    final data = await ExplorerService().listNftsAsWebNfts(address);

    if (page == 1) {
      state = [...data.results];
    } else {
      state = [...state, ...data.results];
    }

    if (data.num_pages > data.page) {
      load(data.page + 1);
    }
  }
}

final webNftListProvider = StateNotifierProvider.family<WebNftListProvider, List<WebNft>, String>(
  (ref, address) => WebNftListProvider(ref, address),
);
