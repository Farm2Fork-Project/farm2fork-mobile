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
  });
}
