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
  static List<AppNavItem> forRole(AppUserRole role) {
    return switch (role) {
      AppUserRole.buyer => [_marketplace, _trace, _cart, _orders, _profile],
      AppUserRole.farmer => [
        _listings,
        _createListing,
        _orders,
        _feed,
        _profile,
      ],
      AppUserRole.transporter => [_shipments, _trace, _orders, _profile],
      AppUserRole.financialPartner => [_loans, _feed, _profile],
      AppUserRole.admin => [_marketplace, _orders, _loans, _feed, _profile],
    };
  }

  static const _marketplace = AppNavItem(
    destination: AppNavDestination.marketplace,
    route: '/marketplace',
    icon: Icons.storefront_rounded,
    labelBuilder: _marketplaceLabel,
  );

  static const _listings = AppNavItem(
    destination: AppNavDestination.listings,
    route: '/marketplace',
    icon: Icons.inventory_2_rounded,
    labelBuilder: _listingsLabel,
  );

  static const _createListing = AppNavItem(
    destination: AppNavDestination.createListing,
    route: '/create-listing',
    icon: Icons.add_business_rounded,
    labelBuilder: _createListingLabel,
  );

  static const _trace = AppNavItem(
    destination: AppNavDestination.trace,
    route: '/trace',
    icon: Icons.qr_code_scanner_rounded,
    labelBuilder: _traceLabel,
  );

  static const _cart = AppNavItem(
    destination: AppNavDestination.cart,
    route: '/cart',
    icon: Icons.shopping_basket_rounded,
    labelBuilder: _cartLabel,
  );

  static const _orders = AppNavItem(
    destination: AppNavDestination.orders,
    route: '/orders',
    icon: Icons.receipt_long_rounded,
    labelBuilder: _ordersLabel,
  );

  static const _shipments = AppNavItem(
    destination: AppNavDestination.shipments,
    route: '/shipments',
    icon: Icons.local_shipping_rounded,
    labelBuilder: _shipmentsLabel,
  );

  static const _loans = AppNavItem(
    destination: AppNavDestination.loans,
    route: '/loans',
    icon: Icons.account_balance_rounded,
    labelBuilder: _loansLabel,
  );

  static const _feed = AppNavItem(
    destination: AppNavDestination.feed,
    route: '/feed',
    icon: Icons.forum_rounded,
    labelBuilder: _feedLabel,
  );

  static const _profile = AppNavItem(
    destination: AppNavDestination.profile,
    route: '/profile',
    icon: Icons.person_rounded,
    labelBuilder: _profileLabel,
  );
}

String _marketplaceLabel(BuildContext context) => context.l10n.navHome;
String _listingsLabel(BuildContext context) => context.l10n.navListings;
String _createListingLabel(BuildContext context) =>
    context.l10n.navCreateListing;
String _traceLabel(BuildContext context) => context.l10n.navTrace;
String _cartLabel(BuildContext context) => context.l10n.navCart;
String _ordersLabel(BuildContext context) => context.l10n.navOrders;
String _shipmentsLabel(BuildContext context) => context.l10n.navShipments;
String _loansLabel(BuildContext context) => context.l10n.navLoans;
String _feedLabel(BuildContext context) => context.l10n.navFeed;
String _profileLabel(BuildContext context) => context.l10n.navProfile;
