// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'side_nav_expanded_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sideNavExpandedHash() => r'11ee652b419bd8eb77b99dfc6a6b3a720814b6e5';

/// Whether the web dashboard's side nav is expanded. Kept in a provider so a
/// collapsed nav stays collapsed when the dashboard rebuilds on navigation.
///
/// Copied from [SideNavExpanded].
@ProviderFor(SideNavExpanded)
final sideNavExpandedProvider =
    NotifierProvider<SideNavExpanded, bool>.internal(
  SideNavExpanded.new,
  name: r'sideNavExpandedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sideNavExpandedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SideNavExpanded = Notifier<bool>;
// ignore_for_file: unnecessary_raw_strings, subtype_of_sealed_class, invalid_use_of_internal_member, do_not_use_environment, prefer_const_constructors, public_member_api_docs, avoid_private_typedef_functions
