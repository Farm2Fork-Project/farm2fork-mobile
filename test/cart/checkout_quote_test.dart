import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/features/cart/presentation/providers/cart_controller.dart';
import 'package:farm2fork_mobile/features/cart/presentation/screens/checkout_screen.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/farmer_summary.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_category.dart';
import 'package:farm2fork_mobile/features/orders/data/models/order.dart';
import 'package:farm2fork_mobile/features/orders/data/repositories/orders_repository.dart';
import 'package:farm2fork_mobile/features/orders/data/repositories/orders_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

class _Orders implements OrdersRepository {
  OrderAddress? quotedFor;

  @override
  Future<OrderQuote> quoteOrder({
    required List<OrderLine> items,
    required OrderAddress shippingAddress,
  }) async {
    quotedFor = shippingAddress;
    return const OrderQuote(
      totalAmount: 600,
      platformFeePercent: 5,
      platformFeeAmount: 30,
      deliveryFee: 1150,
      deliveryDistanceKm: 39.7,
      grandTotal: 1780,
    );
  }

  @override
  Future<Order> createOrder({
    required List<OrderLine> items,
    required OrderAddress shippingAddress,
  }) => throw UnimplementedError();

  @override
  Future<List<Order>> getOrdersByUser({
    required String userId,
    required AppUserRole role,
  }) async => const [];

  @override
  Future<Order> updateOrderStatus(String orderId, OrderStatus status) =>
      throw UnimplementedError();
}

void main() {
  testWidgets('pinning the drop-off shows the server-quoted delivery fee', (
    tester,
  ) async {
    final orders = _Orders();
    await pumpScreen(
      tester,
      const CheckoutScreen(),
      overrides: [ordersRepositoryProvider.overrideWithValue(orders)],
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(CheckoutScreen)),
    );
    container
        .read(cartControllerProvider.notifier)
        .addItem(
          const Product(
            id: 'p1',
            farmerId: 'f1',
            name: 'Mangoes',
            category: ProductCategory.fruits,
            description: '',
            price: 300,
            quantity: 50,
            unit: ProductUnit.kg,
            farmer: FarmerSummary(
              id: 'f1',
              name: 'Smoke Farm',
              farmName: 'Smoke Farm',
              farmLocationAddress: 'Sheikhupura',
            ),
          ),
          quantity: 2,
        );
    await tester.pumpAndSettle();

    expect(
      find.text('Pin the drop-off to see the delivery fee.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Pin drop-off on map'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm this spot'));
    await tester.pumpAndSettle();

    expect(orders.quotedFor?.lat, testGps.lat);
    expect(orders.quotedFor?.lng, testGps.lng);
    expect(find.text('Delivery (39.7 km)'), findsOneWidget);
    expect(find.text('Rs 1,150'), findsOneWidget);
    // Grand total is the server's, including delivery.
    expect(find.text('Rs 1,780'), findsOneWidget);
  });
}
