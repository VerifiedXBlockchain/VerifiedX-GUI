// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'p2p_listing_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$p2pAllBidsHash() => r'2e9a84ab58b5e2ac534c5b026f1aa388e62b5240';

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

typedef P2pAllBidsRef = AutoDisposeFutureProviderRef<List<P2pBidSummary>>;

/// Every bid on a listing, newest first: the listing itself carries only its
/// newest 100.
///
/// Copied from [p2pAllBids].
@ProviderFor(p2pAllBids)
const p2pAllBidsProvider = P2pAllBidsFamily();

/// Every bid on a listing, newest first: the listing itself carries only its
/// newest 100.
///
/// Copied from [p2pAllBids].
class P2pAllBidsFamily extends Family<AsyncValue<List<P2pBidSummary>>> {
  /// Every bid on a listing, newest first: the listing itself carries only its
  /// newest 100.
  ///
  /// Copied from [p2pAllBids].
  const P2pAllBidsFamily();

  /// Every bid on a listing, newest first: the listing itself carries only its
  /// newest 100.
  ///
  /// Copied from [p2pAllBids].
  P2pAllBidsProvider call(
    int listingId,
  ) {
    return P2pAllBidsProvider(
      listingId,
    );
  }

  @override
  P2pAllBidsProvider getProviderOverride(
    covariant P2pAllBidsProvider provider,
  ) {
    return call(
      provider.listingId,
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
  String? get name => r'p2pAllBidsProvider';
}

/// Every bid on a listing, newest first: the listing itself carries only its
/// newest 100.
///
/// Copied from [p2pAllBids].
class P2pAllBidsProvider
    extends AutoDisposeFutureProvider<List<P2pBidSummary>> {
  /// Every bid on a listing, newest first: the listing itself carries only its
  /// newest 100.
  ///
  /// Copied from [p2pAllBids].
  P2pAllBidsProvider(
    this.listingId,
  ) : super.internal(
          (ref) => p2pAllBids(
            ref,
            listingId,
          ),
          from: p2pAllBidsProvider,
          name: r'p2pAllBidsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$p2pAllBidsHash,
          dependencies: P2pAllBidsFamily._dependencies,
          allTransitiveDependencies:
              P2pAllBidsFamily._allTransitiveDependencies,
        );

  final int listingId;

  @override
  bool operator ==(Object other) {
    return other is P2pAllBidsProvider && other.listingId == listingId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, listingId.hashCode);

    return _SystemHash.finish(hash);
  }
}

String _$p2pFeeQuoterHash() => r'93d2b8815c3d1665fdad8eb229a46023178f7a58';

/// Quotes a chain step's fee through Core.
///
/// Copied from [p2pFeeQuoter].
@ProviderFor(p2pFeeQuoter)
final p2pFeeQuoterProvider = Provider<P2pFeeQuoter>.internal(
  p2pFeeQuoter,
  name: r'p2pFeeQuoterProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$p2pFeeQuoterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef P2pFeeQuoterRef = ProviderRef<P2pFeeQuoter>;
String _$p2pChainStepsHash() => r'd3eb8ef15b99b92bb3f8301c0a3ea87077dac177';

/// The shop's chain steps. Dry runs while `Env.p2pBroadcast` is off, which
/// it is in every build: there is no path that sends a transaction yet.
///
/// Copied from [p2pChainSteps].
@ProviderFor(p2pChainSteps)
final p2pChainStepsProvider = Provider<P2pChainSteps>.internal(
  p2pChainSteps,
  name: r'p2pChainStepsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$p2pChainStepsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef P2pChainStepsRef = ProviderRef<P2pChainSteps>;
String _$p2pBidderHash() => r'60eb7b9c0cf980a53c358584981ae2cd01d87aaf';

/// See also [p2pBidder].
@ProviderFor(p2pBidder)
final p2pBidderProvider = Provider<P2pBidder>.internal(
  p2pBidder,
  name: r'p2pBidderProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$p2pBidderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef P2pBidderRef = ProviderRef<P2pBidder>;
String _$p2pListingDetailHash() => r'93a3ec684583948be2ed1f8cc21530290add7a96';

abstract class _$P2pListingDetail
    extends BuildlessAutoDisposeAsyncNotifier<P2pListing?> {
  late final int id;

  Future<P2pListing?> build(
    int id,
  );
}

/// A listing with its newest bids, or null when there is no such listing.
///
/// Copied from [P2pListingDetail].
@ProviderFor(P2pListingDetail)
const p2pListingDetailProvider = P2pListingDetailFamily();

/// A listing with its newest bids, or null when there is no such listing.
///
/// Copied from [P2pListingDetail].
class P2pListingDetailFamily extends Family<AsyncValue<P2pListing?>> {
  /// A listing with its newest bids, or null when there is no such listing.
  ///
  /// Copied from [P2pListingDetail].
  const P2pListingDetailFamily();

  /// A listing with its newest bids, or null when there is no such listing.
  ///
  /// Copied from [P2pListingDetail].
  P2pListingDetailProvider call(
    int id,
  ) {
    return P2pListingDetailProvider(
      id,
    );
  }

  @override
  P2pListingDetailProvider getProviderOverride(
    covariant P2pListingDetailProvider provider,
  ) {
    return call(
      provider.id,
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
  String? get name => r'p2pListingDetailProvider';
}

/// A listing with its newest bids, or null when there is no such listing.
///
/// Copied from [P2pListingDetail].
class P2pListingDetailProvider extends AutoDisposeAsyncNotifierProviderImpl<
    P2pListingDetail, P2pListing?> {
  /// A listing with its newest bids, or null when there is no such listing.
  ///
  /// Copied from [P2pListingDetail].
  P2pListingDetailProvider(
    this.id,
  ) : super.internal(
          () => P2pListingDetail()..id = id,
          from: p2pListingDetailProvider,
          name: r'p2pListingDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$p2pListingDetailHash,
          dependencies: P2pListingDetailFamily._dependencies,
          allTransitiveDependencies:
              P2pListingDetailFamily._allTransitiveDependencies,
        );

  final int id;

  @override
  bool operator ==(Object other) {
    return other is P2pListingDetailProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }

  @override
  Future<P2pListing?> runNotifierBuild(
    covariant P2pListingDetail notifier,
  ) {
    return notifier.build(
      id,
    );
  }
}
// ignore_for_file: unnecessary_raw_strings, subtype_of_sealed_class, invalid_use_of_internal_member, do_not_use_environment, prefer_const_constructors, public_member_api_docs, avoid_private_typedef_functions
