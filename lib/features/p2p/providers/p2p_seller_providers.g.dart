// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'p2p_seller_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$p2pNftSourceHash() => r'bcac9bff614ccb871c1381430e4e1827140a9f21';

/// The wallet's own NFTs and their media.
///
/// Copied from [p2pNftSource].
@ProviderFor(p2pNftSource)
final p2pNftSourceProvider = Provider<P2pNftSource>.internal(
  p2pNftSource,
  name: r'p2pNftSourceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$p2pNftSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef P2pNftSourceRef = ProviderRef<P2pNftSource>;
String _$p2pSellerHash() => r'fcedeae37b7aca759bf1bdd24b8b416c9a1ce235';

/// See also [p2pSeller].
@ProviderFor(p2pSeller)
final p2pSellerProvider = Provider<P2pSeller>.internal(
  p2pSeller,
  name: r'p2pSellerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$p2pSellerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef P2pSellerRef = ProviderRef<P2pSeller>;
String _$p2pOwnerCollectionsHash() =>
    r'32a72f5efa8d0bc3d31e4cbf7ed01a6ff868360f';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

typedef P2pOwnerCollectionsRef
    = AutoDisposeFutureProviderRef<List<P2pCollection>>;

/// [address]'s shop's collections, hidden ones included. Reading them signs
/// [address] in to the registry.
///
/// Copied from [p2pOwnerCollections].
@ProviderFor(p2pOwnerCollections)
const p2pOwnerCollectionsProvider = P2pOwnerCollectionsFamily();

/// [address]'s shop's collections, hidden ones included. Reading them signs
/// [address] in to the registry.
///
/// Copied from [p2pOwnerCollections].
class P2pOwnerCollectionsFamily
    extends Family<AsyncValue<List<P2pCollection>>> {
  /// [address]'s shop's collections, hidden ones included. Reading them signs
  /// [address] in to the registry.
  ///
  /// Copied from [p2pOwnerCollections].
  const P2pOwnerCollectionsFamily();

  /// [address]'s shop's collections, hidden ones included. Reading them signs
  /// [address] in to the registry.
  ///
  /// Copied from [p2pOwnerCollections].
  P2pOwnerCollectionsProvider call(
    String address,
    String shopUrl,
  ) {
    return P2pOwnerCollectionsProvider(
      address,
      shopUrl,
    );
  }

  @override
  P2pOwnerCollectionsProvider getProviderOverride(
    covariant P2pOwnerCollectionsProvider provider,
  ) {
    return call(
      provider.address,
      provider.shopUrl,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'p2pOwnerCollectionsProvider';
}

/// [address]'s shop's collections, hidden ones included. Reading them signs
/// [address] in to the registry.
///
/// Copied from [p2pOwnerCollections].
class P2pOwnerCollectionsProvider
    extends AutoDisposeFutureProvider<List<P2pCollection>> {
  /// [address]'s shop's collections, hidden ones included. Reading them signs
  /// [address] in to the registry.
  ///
  /// Copied from [p2pOwnerCollections].
  P2pOwnerCollectionsProvider(
    this.address,
    this.shopUrl,
  ) : super.internal(
          (ref) => p2pOwnerCollections(
            ref,
            address,
            shopUrl,
          ),
          from: p2pOwnerCollectionsProvider,
          name: r'p2pOwnerCollectionsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$p2pOwnerCollectionsHash,
          dependencies: P2pOwnerCollectionsFamily._dependencies,
          allTransitiveDependencies:
              P2pOwnerCollectionsFamily._allTransitiveDependencies,
        );

  final String address;
  final String shopUrl;

  @override
  bool operator ==(Object other) {
    return other is P2pOwnerCollectionsProvider &&
        other.address == address &&
        other.shopUrl == shopUrl;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, address.hashCode);
    hash = _SystemHash.combine(hash, shopUrl.hashCode);

    return _SystemHash.finish(hash);
  }
}

String _$p2pWalletNftsHash() => r'5f575b3e935aafdcbe2a257ffd159298210124bb';

/// Every NFT in this wallet, read from Core.
///
/// Copied from [p2pWalletNfts].
@ProviderFor(p2pWalletNfts)
final p2pWalletNftsProvider =
    AutoDisposeFutureProvider<List<P2pOwnedNft>>.internal(
  p2pWalletNfts,
  name: r'p2pWalletNftsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$p2pWalletNftsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef P2pWalletNftsRef = AutoDisposeFutureProviderRef<List<P2pOwnedNft>>;
// ignore_for_file: unnecessary_raw_strings, subtype_of_sealed_class, invalid_use_of_internal_member, do_not_use_environment, prefer_const_constructors, public_member_api_docs, avoid_private_typedef_functions
