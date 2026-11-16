// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'p2p_sale_notices_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$p2pSaleNoticeSinkHash() => r'ad688be6af7d4d650108cd6ece49c1927d928285';

/// How a new sale to start is announced: the app's notification, which
/// stays up longer than a transaction's.
///
/// Copied from [p2pSaleNoticeSink].
@ProviderFor(p2pSaleNoticeSink)
final p2pSaleNoticeSinkProvider = Provider<void Function(P2pListing)>.internal(
  p2pSaleNoticeSink,
  name: r'p2pSaleNoticeSinkProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$p2pSaleNoticeSinkHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef P2pSaleNoticeSinkRef = ProviderRef<void Function(P2pListing)>;
String _$p2pSaleNoticesHash() => r'31c9635338fe1cccd7e8a1fa43452531acbe19dc';

/// The listings of this wallet's shops that have a winner and wait for
/// their seller to start the sale, for the badge on the shop's entry.
///
/// Found by polling the public `GET /p2p/shops/{url}/listings/
/// ?state=awaiting_sale_start` for each shop an account of this wallet owns.
/// Public reads need no sign-in, so the poll never asks for the wallet's
/// password. A listing is announced once, when it first shows up.
///
/// Copied from [P2pSaleNotices].
@ProviderFor(P2pSaleNotices)
final p2pSaleNoticesProvider =
    NotifierProvider<P2pSaleNotices, List<P2pListing>>.internal(
  P2pSaleNotices.new,
  name: r'p2pSaleNoticesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$p2pSaleNoticesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$P2pSaleNotices = Notifier<List<P2pListing>>;
// ignore_for_file: unnecessary_raw_strings, subtype_of_sealed_class, invalid_use_of_internal_member, do_not_use_environment, prefer_const_constructors, public_member_api_docs, avoid_private_typedef_functions
