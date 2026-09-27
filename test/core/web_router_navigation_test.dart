import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/web_route_information_parser.dart';
import 'package:rbx_wallet/core/web_router.gr.dart';
import 'package:rbx_wallet/features/root/web_dashboard_container.dart';

/// The web router's real route table with placeholder pages: nested routers
/// their nested router, the dashboard renders its tabs, and every leaf shows
/// its route name (plus path params) as text.
class _HarnessRouter extends WebRouter {
  @override
  Map<String, PageFactory> get pagesMap => {
        for (final name in super.pagesMap.keys) name: _page,
      };

  Page<dynamic> _page(RouteData data) {
    final Widget child;
    if (data.name == WebDashboardContainerRoute.name) {
      child = AutoTabsRouter(
        routes: WebDashboardContainer().routes,
        builder: (context, child, _) => child,
      );
    } else if (data.name.endsWith('Router')) {
      child = const AutoRouter();
    } else {
      final params = data.pathParams.rawMap.values.join(',');
      child = Text('${data.name}($params)', textDirection: TextDirection.ltr);
    }
    return MaterialPageX(routeData: data, child: child);
  }
}

Future<void> _pushRoute(WidgetTester tester, String location) async {
  const codec = JSONMethodCodec();
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    'flutter/navigation',
    codec.encodeMethodCall(MethodCall('pushRouteInformation', {'location': location, 'state': null})),
    (_) {},
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpApp(WidgetTester tester, String initialLocation) async {
  tester.binding.platformDispatcher.defaultRouteNameTestValue = initialLocation;
  addTearDown(tester.binding.platformDispatcher.clearDefaultRouteNameTestValue);
  final router = _HarnessRouter();
  await tester.pumpWidget(MaterialApp.router(
    routeInformationParser: WebRouteInformationParser(router),
    routerDelegate: AutoRouterDelegate(router),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a prefilled send link opens the prefilled send screen', (tester) async {
    await _pumpApp(tester, 'dashboard/send/vfx/xAbc/2.5');
    expect(find.text('WebPrefilledSendScreenRoute(vfx,xAbc,2.5)'), findsOneWidget);
  });

  testWidgets('an in-session URL change switches the dashboard tab', (tester) async {
    await _pumpApp(tester, 'dashboard/home');
    expect(find.text('WebHomeScreenRoute()'), findsOneWidget);

    await _pushRoute(tester, 'dashboard/transactions');
    expect(find.text('WebTransactionScreenRoute()'), findsOneWidget);
  });

  testWidgets('an in-session URL change to a send link opens the prefilled send screen', (tester) async {
    await _pumpApp(tester, 'dashboard/home');

    await _pushRoute(tester, 'dashboard/send/vfx/xAbc/2.5');
    expect(find.text('WebPrefilledSendScreenRoute(vfx,xAbc,2.5)'), findsOneWidget);

    await _pushRoute(tester, 'dashboard/send/vfx/xDef/7');
    expect(find.text('WebPrefilledSendScreenRoute(vfx,xDef,7)'), findsOneWidget);
  });

  testWidgets('the auth page still opens at the root URL', (tester) async {
    await _pumpApp(tester, '/');
    expect(find.text('WebAuthScreenRoute()'), findsOneWidget);
  });
}
