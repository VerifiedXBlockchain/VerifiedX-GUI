// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'p2p_browse_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$p2pViewerAddressHash() => r'4b5db3718872f0ffa55dff2e7d1f98bcca07b99a';

/// The VFX address the shop screens act for: the wallet's selected account,
/// or null when none is (or a Bitcoin account is selected).
///
/// Copied from [p2pViewerAddress].
@ProviderFor(p2pViewerAddress)
final p2pViewerAddressProvider = AutoDisposeProvider<String?>.internal(
  p2pViewerAddress,
  name: r'p2pViewerAddressProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$p2pViewerAddressHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef P2pViewerAddressRef = AutoDisposeProviderRef<String?>;
String _$p2pViewerBalanceHash() => r'b5635f76f0a4a62fec4e3a7b5f8065e72ee00cff';

/// What the selected account can spend, as Core reports it; null with no
/// account selected.
///
/// Copied from [p2pViewerBalance].
@ProviderFor(p2pViewerBalance)
final p2pViewerBalanceProvider = AutoDisposeProvider<double?>.internal(
  p2pViewerBalance,
  name: r'p2pViewerBalanceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$p2pViewerBalanceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef P2pViewerBalanceRef = AutoDisposeProviderRef<double?>;
String _$p2pMeHash() => r'82b00251d30c449cf808127909916b714ab72bf7';

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

typedef P2pMeRef = AutoDisposeFutureProviderRef<P2pMe>;

/// What [address] sells and has bid on (`GET /p2p/me/`). Reading it signs
/// [address] in to the registry: a message signed by Core, never a
/// transaction.
///
/// Copied from [p2pMe].
@ProviderFor(p2pMe)
const p2pMeProvider = P2pMeFamily();

/// What [address] sells and has bid on (`GET /p2p/me/`). Reading it signs
/// [address] in to the registry: a message signed by Core, never a
/// transaction.
///
/// Copied from [p2pMe].
class P2pMeFamily extends Family<AsyncValue<P2pMe>> {
  /// What [address] sells and has bid on (`GET /p2p/me/`). Reading it signs
  /// [address] in to the registry: a message signed by Core, never a
  /// transaction.
  ///
  /// Copied from [p2pMe].
  const P2pMeFamily();

  /// What [address] sells and has bid on (`GET /p2p/me/`). Reading it signs
  /// [address] in to the registry: a message signed by Core, never a
  /// transaction.
  ///
  /// Copied from [p2pMe].
  P2pMeProvider call(
    String address,
  ) {
    return P2pMeProvider(
      address,
    );
  }

  @override
  P2pMeProvider getProviderOverride(
    covariant P2pMeProvider provider,
  ) {
    return call(
      provider.address,
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
  String? get name => r'p2pMeProvider';
}

/// What [address] sells and has bid on (`GET /p2p/me/`). Reading it signs
/// [address] in to the registry: a message signed by Core, never a
/// transaction.
///
/// Copied from [p2pMe].
class P2pMeProvider extends AutoDisposeFutureProvider<P2pMe> {
  /// What [address] sells and has bid on (`GET /p2p/me/`). Reading it signs
  /// [address] in to the registry: a message signed by Core, never a
  /// transaction.
  ///
  /// Copied from [p2pMe].
  P2pMeProvider(
    this.address,
  ) : super.internal(
          (ref) => p2pMe(
            ref,
            address,
          ),
          from: p2pMeProvider,
          name: r'p2pMeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$p2pMeHash,
          dependencies: P2pMeFamily._dependencies,
          allTransitiveDependencies: P2pMeFamily._allTransitiveDependencies,
        );

  final String address;

  @override
  bool operator ==(Object other) {
    return other is P2pMeProvider && other.address == address;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, address.hashCode);

    return _SystemHash.finish(hash);
  }
}

String _$p2pOwnerShopHash() => r'fe75c49d311b894c455ede2459198f04fc66f8d5';
typedef P2pOwnerShopRef = AutoDisposeFutureProviderRef<P2pShop?>;

/// The shop [address] owns, or null when it has none.
///
/// Copied from [p2pOwnerShop].
@ProviderFor(p2pOwnerShop)
const p2pOwnerShopProvider = P2pOwnerShopFamily();

/// The shop [address] owns, or null when it has none.
///
/// Copied from [p2pOwnerShop].
class P2pOwnerShopFamily extends Family<AsyncValue<P2pShop?>> {
  /// The shop [address] owns, or null when it has none.
  ///
  /// Copied from [p2pOwnerShop].
  const P2pOwnerShopFamily();

  /// The shop [address] owns, or null when it has none.
  ///
  /// Copied from [p2pOwnerShop].
  P2pOwnerShopProvider call(
    String address,
  ) {
    return P2pOwnerShopProvider(
      address,
    );
  }

  @override
  P2pOwnerShopProvider getProviderOverride(
    covariant P2pOwnerShopProvider provider,
  ) {
    return call(
      provider.address,
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
  String? get name => r'p2pOwnerShopProvider';
}

/// The shop [address] owns, or null when it has none.
///
/// Copied from [p2pOwnerShop].
class P2pOwnerShopProvider extends AutoDisposeFutureProvider<P2pShop?> {
  /// The shop [address] owns, or null when it has none.
  ///
  /// Copied from [p2pOwnerShop].
  P2pOwnerShopProvider(
    this.address,
  ) : super.internal(
          (ref) => p2pOwnerShop(
            ref,
            address,
          ),
          from: p2pOwnerShopProvider,
          name: r'p2pOwnerShopProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$p2pOwnerShopHash,
          dependencies: P2pOwnerShopFamily._dependencies,
          allTransitiveDependencies:
              P2pOwnerShopFamily._allTransitiveDependencies,
        );

  final String address;

  @override
  bool operator ==(Object other) {
    return other is P2pOwnerShopProvider && other.address == address;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, address.hashCode);

    return _SystemHash.finish(hash);
  }
}

String _$p2pShopListHash() => r'65f3202fa200f14d1e62877b64cc39c55817c6ba';
typedef P2pShopListRef = AutoDisposeFutureProviderRef<P2pPage<P2pShop>>;

/// A page of the registry's shops, newest first.
///
/// Copied from [p2pShopList].
@ProviderFor(p2pShopList)
const p2pShopListProvider = P2pShopListFamily();

/// A page of the registry's shops, newest first.
///
/// Copied from [p2pShopList].
class P2pShopListFamily extends Family<AsyncValue<P2pPage<P2pShop>>> {
  /// A page of the registry's shops, newest first.
  ///
  /// Copied from [p2pShopList].
  const P2pShopListFamily();

  /// A page of the registry's shops, newest first.
  ///
  /// Copied from [p2pShopList].
  P2pShopListProvider call({
    String search = '',
    int page = 1,
  }) {
    return P2pShopListProvider(
      search: search,
      page: page,
    );
  }

  @override
  P2pShopListProvider getProviderOverride(
    covariant P2pShopListProvider provider,
  ) {
    return call(
      search: provider.search,
      page: provider.page,
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
  String? get name => r'p2pShopListProvider';
}

/// A page of the registry's shops, newest first.
///
/// Copied from [p2pShopList].
class P2pShopListProvider extends AutoDisposeFutureProvider<P2pPage<P2pShop>> {
  /// A page of the registry's shops, newest first.
  ///
  /// Copied from [p2pShopList].
  P2pShopListProvider({
    this.search = '',
    this.page = 1,
  }) : super.internal(
          (ref) => p2pShopList(
            ref,
            search: search,
            page: page,
          ),
          from: p2pShopListProvider,
          name: r'p2pShopListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$p2pShopListHash,
          dependencies: P2pShopListFamily._dependencies,
          allTransitiveDependencies:
              P2pShopListFamily._allTransitiveDependencies,
        );

  final String search;
  final int page;

  @override
  bool operator ==(Object other) {
    return other is P2pShopListProvider &&
        other.search == search &&
        other.page == page;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, search.hashCode);
    hash = _SystemHash.combine(hash, page.hashCode);

    return _SystemHash.finish(hash);
  }
}

String _$p2pShopHash() => r'24bb32d19e35ec226e75644101e789b6337ae82c';
typedef P2pShopRef = AutoDisposeFutureProviderRef<P2pShop?>;

/// A shop with its collections, or null when no shop has the URL.
///
/// Copied from [p2pShop].
@ProviderFor(p2pShop)
const p2pShopProvider = P2pShopFamily();

/// A shop with its collections, or null when no shop has the URL.
///
/// Copied from [p2pShop].
class P2pShopFamily extends Family<AsyncValue<P2pShop?>> {
  /// A shop with its collections, or null when no shop has the URL.
  ///
  /// Copied from [p2pShop].
  const P2pShopFamily();

  /// A shop with its collections, or null when no shop has the URL.
  ///
  /// Copied from [p2pShop].
  P2pShopProvider call(
    String url,
  ) {
    return P2pShopProvider(
      url,
    );
  }

  @override
  P2pShopProvider getProviderOverride(
    covariant P2pShopProvider provider,
  ) {
    return call(
      provider.url,
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
  String? get name => r'p2pShopProvider';
}

/// A shop with its collections, or null when no shop has the URL.
///
/// Copied from [p2pShop].
class P2pShopProvider extends AutoDisposeFutureProvider<P2pShop?> {
  /// A shop with its collections, or null when no shop has the URL.
  ///
  /// Copied from [p2pShop].
  P2pShopProvider(
    this.url,
  ) : super.internal(
          (ref) => p2pShop(
            ref,
            url,
          ),
          from: p2pShopProvider,
          name: r'p2pShopProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$p2pShopHash,
          dependencies: P2pShopFamily._dependencies,
          allTransitiveDependencies: P2pShopFamily._allTransitiveDependencies,
        );

  final String url;

  @override
  bool operator ==(Object other) {
    return other is P2pShopProvider && other.url == url;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, url.hashCode);

    return _SystemHash.finish(hash);
  }
}

String _$p2pShopListingsHash() => r'4e4df8728980ccfc4ae71fc4387de0dbfff09185';
typedef P2pShopListingsRef = AutoDisposeFutureProviderRef<P2pPage<P2pListing>>;

/// A page of a shop's public listings: the active ones and those sold in the
/// last 7 days.
///
/// Copied from [p2pShopListings].
@ProviderFor(p2pShopListings)
const p2pShopListingsProvider = P2pShopListingsFamily();

/// A page of a shop's public listings: the active ones and those sold in the
/// last 7 days.
///
/// Copied from [p2pShopListings].
class P2pShopListingsFamily extends Family<AsyncValue<P2pPage<P2pListing>>> {
  /// A page of a shop's public listings: the active ones and those sold in the
  /// last 7 days.
  ///
  /// Copied from [p2pShopListings].
  const P2pShopListingsFamily();

  /// A page of a shop's public listings: the active ones and those sold in the
  /// last 7 days.
  ///
  /// Copied from [p2pShopListings].
  P2pShopListingsProvider call(
    String url, {
    int? collectionId,
    int page = 1,
    int? limit,
  }) {
    return P2pShopListingsProvider(
      url,
      collectionId: collectionId,
      page: page,
      limit: limit,
    );
  }

  @override
  P2pShopListingsProvider getProviderOverride(
    covariant P2pShopListingsProvider provider,
  ) {
    return call(
      provider.url,
      collectionId: provider.collectionId,
      page: provider.page,
      limit: provider.limit,
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
  String? get name => r'p2pShopListingsProvider';
}

/// A page of a shop's public listings: the active ones and those sold in the
/// last 7 days.
///
/// Copied from [p2pShopListings].
class P2pShopListingsProvider
    extends AutoDisposeFutureProvider<P2pPage<P2pListing>> {
  /// A page of a shop's public listings: the active ones and those sold in the
  /// last 7 days.
  ///
  /// Copied from [p2pShopListings].
  P2pShopListingsProvider(
    this.url, {
    this.collectionId,
    this.page = 1,
    this.limit,
  }) : super.internal(
          (ref) => p2pShopListings(
            ref,
            url,
            collectionId: collectionId,
            page: page,
            limit: limit,
          ),
          from: p2pShopListingsProvider,
          name: r'p2pShopListingsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$p2pShopListingsHash,
          dependencies: P2pShopListingsFamily._dependencies,
          allTransitiveDependencies:
              P2pShopListingsFamily._allTransitiveDependencies,
        );

  final String url;
  final int? collectionId;
  final int page;
  final int? limit;

  @override
  bool operator ==(Object other) {
    return other is P2pShopListingsProvider &&
        other.url == url &&
        other.collectionId == collectionId &&
        other.page == page &&
        other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, url.hashCode);
    hash = _SystemHash.combine(hash, collectionId.hashCode);
    hash = _SystemHash.combine(hash, page.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}
// ignore_for_file: unnecessary_raw_strings, subtype_of_sealed_class, invalid_use_of_internal_member, do_not_use_environment, prefer_const_constructors, public_member_api_docs, avoid_private_typedef_functions
