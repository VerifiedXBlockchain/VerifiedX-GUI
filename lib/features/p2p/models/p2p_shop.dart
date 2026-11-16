import 'package:freezed_annotation/freezed_annotation.dart';

import 'p2p_collection.dart';

part 'p2p_shop.freezed.dart';
part 'p2p_shop.g.dart';

/// Where a shop's registration stands: recorded by a dry-run DSTR, mirrored
/// from a DSTR on chain, or removed by `DecShopDelete()`.
enum P2pShopChainState {
  @JsonValue('dry_run')
  dryRun,
  @JsonValue('registered')
  registered,
  @JsonValue('deleted')
  deleted,
  unknown,
}

/// A shop in the P2P registry (`GET /p2p/shops/`, `GET /p2p/shops/{url}/`).
/// Addressed by [url] in every path, never by [id].
@freezed
class P2pShop with _$P2pShop {
  const P2pShop._();

  factory P2pShop({
    required int id,
    @JsonKey(name: 'unique_id') required String uniqueId,
    // Normalised: no `vfx://`, lower case.
    required String url,
    @JsonKey(name: 'display_url') required String displayUrl,
    required String name,
    @Default('') String description,
    @JsonKey(name: 'owner_address') required String ownerAddress,
    @JsonKey(name: 'chain_state', unknownEnumValue: P2pShopChainState.unknown) @Default(P2pShopChainState.unknown) P2pShopChainState chainState,
    @JsonKey(name: 'registered_at') DateTime? registeredAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'collection_count') @Default(0) int collectionCount,
    @JsonKey(name: 'live_listing_count') @Default(0) int liveListingCount,
    // On the shop's own page only (`GET /p2p/shops/{url}/`); null in a list.
    List<P2pCollection>? collections,
  }) = _P2pShop;

  factory P2pShop.fromJson(Map<String, dynamic> json) => _$P2pShopFromJson(json);

  bool get isDryRun => chainState == P2pShopChainState.dryRun;

  bool isOwnedBy(String? address) => address != null && address == ownerAddress;

  /// The collections a visitor sees.
  List<P2pCollection> get liveCollections => (collections ?? const []).where((c) => c.isLive).toList();
}

/// `GET /p2p/shops/available/?url=`.
@freezed
class P2pUrlAvailability with _$P2pUrlAvailability {
  factory P2pUrlAvailability({
    required String url,
    required String normalized,
    required bool available,
    // `taken`, `invalid` or null.
    String? reason,
  }) = _P2pUrlAvailability;

  factory P2pUrlAvailability.fromJson(Map<String, dynamic> json) => _$P2pUrlAvailabilityFromJson(json);
}
