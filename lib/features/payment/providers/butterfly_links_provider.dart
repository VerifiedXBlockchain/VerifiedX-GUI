import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/singletons.dart';
import '../../../core/storage.dart';
import '../models/butterfly_link.dart';
import '../services/butterfly_service.dart';

class ButterflyLinksModel {
  final List<ButterflyLink> links;
  final bool isLoading;

  const ButterflyLinksModel({
    this.links = const [],
    this.isLoading = false,
  });

  ButterflyLinksModel copyWith({
    List<ButterflyLink>? links,
    bool? isLoading,
  }) {
    return ButterflyLinksModel(
      links: links ?? this.links,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ButterflyLinksProvider extends StateNotifier<ButterflyLinksModel> {
  final Ref ref;

  ButterflyLinksProvider(this.ref) : super(const ButterflyLinksModel()) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final storage = singleton<Storage>();
    final linksJson = storage.getList(Storage.BUTTERFLY_LINKS);
    if (linksJson != null) {
      try {
        final links = linksJson
            .map((json) => ButterflyLink.fromJson(
                json is String ? jsonDecode(json) : json as Map<String, dynamic>))
            .toList();
        state = state.copyWith(links: links);
      } catch (e) {
        print('Error loading butterfly links: $e');
      }
    }
  }

  void _saveToStorage() {
    final storage = singleton<Storage>();
    final linksJson = state.links.map((link) => link.toJson()).toList();
    storage.setList(Storage.BUTTERFLY_LINKS, linksJson);
  }

  void addLink(ButterflyLink link) {
    state = state.copyWith(links: [link, ...state.links]);
    _saveToStorage();
  }

  void updateLink(ButterflyLink updatedLink) {
    final updatedLinks = state.links.map((link) {
      if (link.linkId == updatedLink.linkId) {
        return updatedLink;
      }
      return link;
    }).toList();
    state = state.copyWith(links: updatedLinks);
    _saveToStorage();
  }

  void updateLinkStatus(String linkId, ButterflyLinkStatus newStatus) {
    final updatedLinks = state.links.map((link) {
      if (link.linkId == linkId) {
        return link.copyWith(status: newStatus);
      }
      return link;
    }).toList();
    state = state.copyWith(links: updatedLinks);
    _saveToStorage();
  }

  void updateLinkTxHash(String linkId, String txHash) {
    final updatedLinks = state.links.map((link) {
      if (link.linkId == linkId) {
        return link.copyWith(txHash: txHash);
      }
      return link;
    }).toList();
    state = state.copyWith(links: updatedLinks);
    _saveToStorage();
  }

  Future<void> refreshLinkStatus(String linkId) async {
    final statusResponse = await ButterflyService().getButterflyStatus(linkId);
    if (statusResponse != null) {
      final newStatus = _parseStatus(statusResponse.status);
      updateLinkStatus(linkId, newStatus);
    }
  }

  Future<void> refreshAllPendingLinks() async {
    final pendingLinks = state.links
        .where((link) =>
            link.status == ButterflyLinkStatus.pending ||
            link.status == ButterflyLinkStatus.readyForRedemption)
        .toList();

    for (final link in pendingLinks) {
      await refreshLinkStatus(link.linkId);
    }
  }

  ButterflyLinkStatus _parseStatus(String status) {
    switch (status) {
      case 'pending':
        return ButterflyLinkStatus.pending;
      case 'ready_for_redemption':
        return ButterflyLinkStatus.readyForRedemption;
      case 'claiming':
        return ButterflyLinkStatus.claiming;
      case 'claimed':
        return ButterflyLinkStatus.claimed;
      default:
        return ButterflyLinkStatus.pending;
    }
  }

  void removeLink(String linkId) {
    state = state.copyWith(
      links: state.links.where((l) => l.linkId != linkId).toList(),
    );
    _saveToStorage();
  }

  void clearAll() {
    state = state.copyWith(links: []);
    _saveToStorage();
  }
}

final butterflyLinksProvider =
    StateNotifierProvider<ButterflyLinksProvider, ButterflyLinksModel>((ref) {
  return ButterflyLinksProvider(ref);
});
