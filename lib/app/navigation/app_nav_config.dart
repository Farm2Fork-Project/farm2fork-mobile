import 'package:flutter/material.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';

enum AppUserRole { farmer, buyer, transporter, financialPartner, admin }

enum AppNavDestination {
  marketplace,
  listings,
  createListing,
  trace,
  cart,
  orders,
  deliveries,
  shipments,
  loans,
  feed,
  profile,
}

class AppNavItem {
  const AppNavItem({
    required this.destination,
    required this.route,
    required this.icon,
    required this.labelBuilder,
  });

  final AppNavDestination destination;
  final String route;
  final IconData icon;
  final String Function(BuildContext context) labelBuilder;
}

abstract final class AppNavConfig {
  static const String guestHomeRoute = '/guest/marketplace';

  static List<AppNavItem> forGuest() => [
    AppNavItem(
      destination: AppNavDestination.marketplace,
      route: '/guest/marketplace',
      icon: Icons.storefront_rounded,
      labelBuilder: _marketplaceLabel,
    ),
    AppNavItem(
      destination: AppNavDestination.trace,
      route: '/guest/trace',
      icon: Icons.qr_code_scanner_rounded,
      labelBuilder: _traceLabel,
    ),
    AppNavItem(
      destination: AppNavDestination.cart,
      route: '/guest/cart',
      icon: Icons.shopping_basket_rounded,
      labelBuilder: _cartLabel,
    ),
    AppNavItem(
      destination: AppNavDestination.profile,
      route: '/guest/profile',
      icon: Icons.person_rounded,
      labelBuilder: _profileLabel,
    ),
  ];

  static List<AppNavItem> forRole(AppUserRole role) {
    return switch (role) {
      AppUserRole.buyer => [
        _item(role, AppNavDestination.marketplace),
        _item(role, AppNavDestination.trace),
        _item(role, AppNavDestination.cart),
        _item(role, AppNavDestination.orders),
        _item(role, AppNavDestination.profile),
      ],
      AppUserRole.farmer => [
        _item(role, AppNavDestination.listings),
        _item(role, AppNavDestination.createListing),
        _item(role, AppNavDestination.orders),
        _item(role, AppNavDestination.feed),
        _item(role, AppNavDestination.profile),
      ],
      // Transporters are mobile-only: nearby offers first, then their
      // delivery history.
      AppUserRole.transporter => [
        _item(role, AppNavDestination.deliveries),
        _item(role, AppNavDestination.shipments),
        _item(role, AppNavDestination.trace),
        _item(role, AppNavDestination.profile),
      ],
      AppUserRole.financialPartner => [
        _item(role, AppNavDestination.loans),
        _item(role, AppNavDestination.feed),
        _item(role, AppNavDestination.profile),
      ],
      AppUserRole.admin => const <AppNavItem>[],
    };
  }

  static String homeRouteForRole(AppUserRole role) => forRole(role).first.route;

  /// Farmer microfinance (not a tab: reached from Profile and notifications).
  static const String farmerLoansRoute = '/farmer/loans';

  /// Community feed for buyers (farmers and partners have it as a tab).
  static const String buyerCommunityRoute = '/buyer/community';

  static const String notificationsRoute = '/notifications';
  static const String newPostRoute = '/community/new';
  static String postRoute(String postId) => '/community/posts/$postId';

  /// Public provenance journey for one product (also the mobile target for a
  /// scanned QR trace link).
  static String traceRouteForProduct(String productId) =>
      '/trace/products/$productId';

  static String roleRoutePrefix(AppUserRole role) {
    return switch (role) {
      AppUserRole.farmer => '/farmer',
      AppUserRole.buyer => '/buyer',
      AppUserRole.transporter => '/transporter',
      AppUserRole.financialPartner => '/finance',
      AppUserRole.admin => '/admin',
    };
  }

  static bool isPublicRoute(String location) {
    return location.startsWith('/auth') ||
        location.startsWith('/guest') ||
        location.startsWith('/marketplace/products/') ||
        location.startsWith('/trace/products/') ||
        location.startsWith('/settings/') ||
        // Farmer onboarding pins the farm before the backend session exists.
        location == '/pick-location';
  }

  static bool canAccessRouteForRole({
    required AppUserRole role,
    required String location,
  }) {
    if (role == AppUserRole.admin) return false;
    if (location.startsWith('/marketplace/products/')) return true;
    // A product's provenance is public; any signed-in role may open it.
    if (location.startsWith('/trace/products/')) return true;
    if (location == '/pick-location') return true;
    if (location == notificationsRoute) return true;
    if (location.startsWith('/community/')) {
      return role == AppUserRole.farmer ||
          role == AppUserRole.buyer ||
          role == AppUserRole.financialPartner;
    }
    if (role == AppUserRole.buyer &&
        (location == '/checkout' || location == '/payments')) {
      return true;
    }
    if ((role == AppUserRole.buyer ||
            role == AppUserRole.farmer ||
            role == AppUserRole.transporter) &&
        location.startsWith('/shipments/')) {
      return true;
    }
    final prefix = roleRoutePrefix(role);
    return location == prefix || location.startsWith('$prefix/');
  }

  static AppNavItem _item(AppUserRole role, AppNavDestination destination) {
    return AppNavItem(
      destination: destination,
      route: routeFor(role, destination),
      icon: _iconFor(destination),
      labelBuilder: _labelFor(destination),
    );
  }

  static String routeFor(AppUserRole role, AppNavDestination destination) {
    final rolePath = switch (role) {
      AppUserRole.farmer => 'farmer',
      AppUserRole.buyer => 'buyer',
      AppUserRole.transporter => 'transporter',
      AppUserRole.financialPartner => 'finance',
      AppUserRole.admin => 'admin',
    };
    final destinationPath = switch (destination) {
      AppNavDestination.marketplace => 'marketplace',
      AppNavDestination.listings => 'listings',
      AppNavDestination.createListing => 'create-listing',
      AppNavDestination.trace => 'trace',
      AppNavDestination.cart => 'cart',
      AppNavDestination.orders => 'orders',
      AppNavDestination.deliveries => 'deliveries',
      AppNavDestination.shipments => 'shipments',
      AppNavDestination.loans => 'loans',
      AppNavDestination.feed => 'feed',
      AppNavDestination.profile => 'profile',
    };
    return '/$rolePath/$destinationPath';
  }

  static IconData _iconFor(AppNavDestination destination) {
    return switch (destination) {
      AppNavDestination.marketplace => Icons.storefront_rounded,
      AppNavDestination.listings => Icons.inventory_2_rounded,
      AppNavDestination.createListing => Icons.add_business_rounded,
      AppNavDestination.trace => Icons.qr_code_scanner_rounded,
      AppNavDestination.cart => Icons.shopping_basket_rounded,
      AppNavDestination.orders => Icons.receipt_long_rounded,
      AppNavDestination.deliveries => Icons.delivery_dining_rounded,
      AppNavDestination.shipments => Icons.history_rounded,
      AppNavDestination.loans => Icons.account_balance_rounded,
      AppNavDestination.feed => Icons.forum_rounded,
      AppNavDestination.profile => Icons.person_rounded,
    };
  }

  static String Function(BuildContext context) _labelFor(
    AppNavDestination destination,
  ) {
    return switch (destination) {
      AppNavDestination.marketplace => _marketplaceLabel,
      AppNavDestination.listings => _listingsLabel,
      AppNavDestination.createListing => _createListingLabel,
      AppNavDestination.trace => _traceLabel,
      AppNavDestination.cart => _cartLabel,
      AppNavDestination.orders => _ordersLabel,
      AppNavDestination.deliveries => _deliveriesLabel,
      AppNavDestination.shipments => _shipmentsLabel,
      AppNavDestination.loans => _loansLabel,
      AppNavDestination.feed => _feedLabel,
      AppNavDestination.profile => _profileLabel,
    };
  }
}

String _marketplaceLabel(BuildContext context) => context.l10n.navHome;
String _listingsLabel(BuildContext context) => context.l10n.navListings;
String _createListingLabel(BuildContext context) =>
    context.l10n.navCreateListing;
String _traceLabel(BuildContext context) => context.l10n.navTrace;
String _cartLabel(BuildContext context) => context.l10n.navCart;
String _ordersLabel(BuildContext context) => context.l10n.navOrders;
String _shipmentsLabel(BuildContext context) => context.l10n.navShipments;
String _deliveriesLabel(BuildContext context) => context.l10n.navDeliveries;
String _loansLabel(BuildContext context) => context.l10n.navLoans;
String _feedLabel(BuildContext context) => context.l10n.navFeed;
String _profileLabel(BuildContext context) => context.l10n.navProfile;
