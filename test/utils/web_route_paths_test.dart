import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/utils/web_route_paths.dart';

void main() {
  group('normalizeWebRoutePath', () {
    test('strips leading slashes', () {
      expect(normalizeWebRoutePath('/dashboard/send'), 'dashboard/send');
      expect(normalizeWebRoutePath('//dashboard'), 'dashboard');
    });

    test('keeps paths without a leading slash and the bare root', () {
      expect(normalizeWebRoutePath('dashboard/home'), 'dashboard/home');
      expect(normalizeWebRoutePath('/'), '/');
      expect(normalizeWebRoutePath(''), '');
    });
  });

  group('dashboardRedirectPath', () {
    test('accepts the in-app hash form', () {
      expect(
        dashboardRedirectPath('http://127.0.0.1:42069/?automation=1#dashboard/transactions'),
        'dashboard/transactions',
      );
    });

    test('accepts the leading-slash hash form', () {
      expect(
        dashboardRedirectPath('https://wallet.example/#/dashboard/send/vfx/xAbc/2.5'),
        'dashboard/send/vfx/xAbc/2.5',
      );
    });

    test('ignores non-dashboard and rewritten hashes', () {
      expect(dashboardRedirectPath('https://wallet.example/#./'), isNull);
      expect(dashboardRedirectPath('https://wallet.example/'), isNull);
      expect(dashboardRedirectPath('https://wallet.example/#dashboards'), isNull);
      expect(dashboardRedirectPath('https://wallet.example/dashboard/#./'), isNull);
    });
  });

  group('isDashboardHomePath', () {
    test('accepts Home and the bare dashboard route', () {
      expect(isDashboardHomePath('dashboard/home'), isTrue);
      expect(isDashboardHomePath('/dashboard/home/'), isTrue);
      expect(isDashboardHomePath('dashboard'), isTrue);
    });

    test('rejects other dashboard pages and Home sub-pages', () {
      expect(isDashboardHomePath('dashboard/send/vfx/xAbc/2.5'), isFalse);
      expect(isDashboardHomePath('dashboard/transactions'), isFalse);
      expect(isDashboardHomePath('dashboard/home/all-tokens'), isFalse);
      expect(isDashboardHomePath('dashboard/homes'), isFalse);
    });
  });

  group('InitialWebUrl', () {
    tearDown(() => InitialWebUrl.set(null));

    test('returns the dashboard route once', () {
      InitialWebUrl.set('https://wallet.example/#dashboard/send/vfx/xAbc/5');
      expect(InitialWebUrl.takeDashboardRedirect(), 'dashboard/send/vfx/xAbc/5');
      expect(InitialWebUrl.takeDashboardRedirect(), isNull);
    });

    test('returns null when the app opened on the auth page', () {
      InitialWebUrl.set('https://wallet.example/');
      expect(InitialWebUrl.takeDashboardRedirect(), isNull);
    });
  });
}
