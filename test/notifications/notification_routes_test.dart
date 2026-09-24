import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/features/notifications/presentation/notification_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String? route(AppUserRole role, String type, [String? model, String? id]) =>
      routeForNotification(
        role: role,
        type: type,
        relatedEntityModel: model,
        relatedEntityId: id,
      );

  test('delivery offers open the transporter Deliveries tab', () {
    expect(
      route(AppUserRole.transporter, 'delivery_offer', 'Order', 'o1'),
      '/transporter/deliveries',
    );
    expect(route(AppUserRole.buyer, 'delivery_offer', 'Order', 'o1'), isNull);
  });

  test('shipment updates open the tracking screen', () {
    expect(
      route(AppUserRole.buyer, 'delivery_update', 'Shipment', 's1'),
      '/shipments/s1',
    );
  });

  test('order notifications open the Orders tab of roles that have one', () {
    expect(
      route(AppUserRole.buyer, 'order_placed', 'Order', 'o1'),
      '/buyer/orders',
    );
    expect(
      route(AppUserRole.farmer, 'payment_confirmed', 'Order', 'o1'),
      '/farmer/orders',
    );
  });

  test('loan updates open the farmer loans screen', () {
    expect(
      route(AppUserRole.farmer, 'loan_update', 'LoanApplication', 'l1'),
      AppNavConfig.farmerLoansRoute,
    );
  });
}
