// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'p2p_listed_nfts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$p2pListedNftsHash() => r'b7415732c6753b02aa67fc68a100e9ef5f3b9383';

/// The ids of this wallet's NFTs that are in an active listing of the P2P
/// registry, for the "Listed" badge. One read of Spyglass per local address
/// (`GET /nft/listed/{owner}/`), where the old shop's flag walks Core's
/// collections and listings.
///
/// A badge only: a listed NFT can still be moved, which ends its listing.
///
/// Copied from [P2pListedNfts].
@ProviderFor(P2pListedNfts)
final p2pListedNftsProvider =
    NotifierProvider<P2pListedNfts, Set<String>>.internal(
  P2pListedNfts.new,
  name: r'p2pListedNftsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$p2pListedNftsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$P2pListedNfts = Notifier<Set<String>>;
// ignore_for_file: unnecessary_raw_strings, subtype_of_sealed_class, invalid_use_of_internal_member, do_not_use_environment, prefer_const_constructors, public_member_api_docs, avoid_private_typedef_functions
