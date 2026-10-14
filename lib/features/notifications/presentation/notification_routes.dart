import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';

/// Where tapping a notification (in the inbox or a push) should go.
String? routeForNotification({
  required AppUserRole role,
  required String type,
  String? relatedEntityId,
  String? relatedEntityModel,
}) {
  if (type == 'delivery_offer') {
    return role == AppUserRole.transporter
        ? AppNavConfig.routeFor(role, AppNavDestination.deliveries)
        : null;
  }
  switch (relatedEntityModel) {
    case 'Shipment':
      return relatedEntityId == null ? null : '/shipments/$relatedEntityId';
    case 'LoanApplication':
      return role == AppUserRole.farmer ? AppNavConfig.farmerLoansRoute : null;
    case 'Order':
      final hasOrders = AppNavConfig.forRole(
        role,
      ).any((item) => item.destination == AppNavDestination.orders);
      return hasOrders
          ? AppNavConfig.routeFor(role, AppNavDestination.orders)
          : null;
  }
  return null;
}
