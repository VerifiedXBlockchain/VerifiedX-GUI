// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'p2p_session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$p2pServiceHash() => r'b8bd3f351e20fc728b5bb585097039e5daaee8f6';

/// See also [p2pService].
@ProviderFor(p2pService)
final p2pServiceProvider = Provider<P2pService>.internal(
  p2pService,
  name: r'p2pServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$p2pServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef P2pServiceRef = ProviderRef<P2pService>;
String _$p2pSignerHash() => r'5376f74369e5a4bd9f6e2703fb7f57190d390262';

/// Signs the shop's messages (sign-in, bids) through Core.
///
/// Copied from [p2pSigner].
@ProviderFor(p2pSigner)
final p2pSignerProvider = Provider<P2pMessageSigner>.internal(
  p2pSigner,
  name: r'p2pSignerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$p2pSignerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef P2pSignerRef = ProviderRef<P2pMessageSigner>;
String _$p2pSessionHash() => r'35ffe832929f16f478490460c9de7fcb72b5a1cc';

/// The wallet's sign-in tokens for the P2P registry, one per address, dropped
/// when the wallet locks.
///
/// Copied from [p2pSession].
@ProviderFor(p2pSession)
final p2pSessionProvider = Provider<P2pSession>.internal(
  p2pSession,
  name: r'p2pSessionProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$p2pSessionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef P2pSessionRef = ProviderRef<P2pSession>;
// ignore_for_file: unnecessary_raw_strings, subtype_of_sealed_class, invalid_use_of_internal_member, do_not_use_environment, prefer_const_constructors, public_member_api_docs, avoid_private_typedef_functions
