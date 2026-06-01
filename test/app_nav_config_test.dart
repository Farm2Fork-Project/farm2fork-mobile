import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';

void main() {
  group('AppNavConfig', () {
    test(
      'buyer navigation includes marketplace, QR trace, cart, orders, and profile',
      () {
        final tabs = AppNavConfig.forRole(AppUserRole.buyer);

        expect(tabs.map((tab) => tab.destination).toList(), [
          AppNavDestination.marketplace,
          AppNavDestination.trace,
          AppNavDestination.cart,
          AppNavDestination.orders,
          AppNavDestination.profile,
        ]);
      },
    );

    test('farmer navigation prioritizes listings and listing creation', () {
      final tabs = AppNavConfig.forRole(AppUserRole.farmer);

      expect(
        tabs.map((tab) => tab.destination),
        contains(AppNavDestination.listings),
      );
      expect(
        tabs.map((tab) => tab.destination),
        contains(AppNavDestination.createListing),
      );
      expect(
        tabs.map((tab) => tab.destination),
        isNot(contains(AppNavDestination.cart)),
      );
    });

    test('transporter navigation focuses on shipments and QR scan', () {
      final tabs = AppNavConfig.forRole(AppUserRole.transporter);

      expect(tabs.map((tab) => tab.destination).toList(), [
        AppNavDestination.shipments,
        AppNavDestination.trace,
        AppNavDestination.orders,
        AppNavDestination.profile,
      ]);
    });

    test('home routes are role-scoped for separate tab shells', () {
      expect(
        AppNavConfig.homeRouteForRole(AppUserRole.buyer),
        '/buyer/marketplace',
      );
      expect(
        AppNavConfig.homeRouteForRole(AppUserRole.farmer),
        '/farmer/listings',
      );
      expect(
        AppNavConfig.homeRouteForRole(AppUserRole.transporter),
        '/transporter/shipments',
      );
      expect(
        AppNavConfig.homeRouteForRole(AppUserRole.financialPartner),
        '/finance/loans',
      );
    });

    test('admin has no mobile navigation tabs', () {
      expect(AppNavConfig.forRole(AppUserRole.admin), isEmpty);
    });

    test('guest shell has 4 tabs: marketplace, trace, cart, profile', () {
      final tabs = AppNavConfig.forGuest();
      expect(tabs.map((t) => t.destination).toList(), [
        AppNavDestination.marketplace,
        AppNavDestination.trace,
        AppNavDestination.cart,
        AppNavDestination.profile,
      ]);
    });

    test('guest home route is /guest/marketplace', () {
      expect(AppNavConfig.guestHomeRoute, '/guest/marketplace');
    });

    test('guest and role route guards are centralized', () {
      expect(AppNavConfig.isPublicRoute('/auth/login'), isTrue);
      expect(AppNavConfig.isPublicRoute('/guest/trace'), isTrue);
      expect(AppNavConfig.isPublicRoute('/marketplace/products/abc'), isTrue);
      expect(AppNavConfig.isPublicRoute('/buyer/cart'), isFalse);

      expect(
        AppNavConfig.canAccessRouteForRole(
          role: AppUserRole.buyer,
          location: '/buyer/cart',
        ),
        isTrue,
      );
      expect(
        AppNavConfig.canAccessRouteForRole(
          role: AppUserRole.buyer,
          location: '/farmer/listings',
        ),
        isFalse,
      );
    });
  });
}
