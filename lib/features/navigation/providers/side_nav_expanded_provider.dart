import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'side_nav_expanded_provider.g.dart';

/// Whether the web dashboard's side nav is expanded. Kept in a provider so a
/// collapsed nav stays collapsed when the dashboard rebuilds on navigation.
@Riverpod(keepAlive: true)
class SideNavExpanded extends _$SideNavExpanded {
  @override
  bool build() {
    return true;
  }

  void toggle() {
    state = !state;
  }
}
