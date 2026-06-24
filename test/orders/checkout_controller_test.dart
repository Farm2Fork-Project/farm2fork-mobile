import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/features/cart/data/models/cart_item.dart';
import 'package:farm2fork_mobile/features/cart/presentation/providers/cart_controller.dart';
import 'package:farm2fork_mobile/features/cart/presentation/providers/checkout_controller.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/farmer_summary.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_category.dart';
import 'package:farm2fork_mobile/features/orders/data/models/order.dart';
import 'package:farm2fork_mobile/features/orders/data/repositories/orders_repository.dart';
import 'package:farm2fork_mobile/features/orders/data/repositories/orders_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Product _product(String id, String farmerId, String farmerName) => Product(
  id: id,
  farmerId: farmerId,
  name: 'Product $id',
  category: ProductCategory.vegetables,
  description: '',
  price: 100,
  quantity: 50,
  unit: ProductUnit.kg,
  farmer: FarmerSummary(
    id: farmerId,
    name: farmerName,
    farmName: '$farmerName Farm',
    farmLocationAddress: '',
  ),
);

const _address = OrderAddress(
  street: '12 Mall Road',
  city: 'Lahore',
  province: 'Punjab',
);

/// Records createOrder calls and can fail for specific farmers.
class _RecordingOrdersRepo implements OrdersRepository {
  final List<List<OrderLine>> createdLines = [];

  @override
  Future<Order> createOrder({
    required List<OrderLine> items,
    required OrderAddress shippingAddress,
  }) async {
    createdLines.add(items);
    final now = DateTime(2026, 6, 15);
    // The first line's product id encodes the farmer in these tests via lookup
    // in the controller; here we just succeed/fail deterministically.
    return Order(
      id: 'ord_${createdLines.length}',
      buyerId: 'buyer',
      farmerId: 'farmer',
      items: const [],
      totalAmount: 0,
      platformFeePercent: 5,
      platformFeeAmount: 0,
      grandTotal: 0,
      shippingAddress: shippingAddress,
      status: OrderStatus.pending,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<List<Order>> getOrdersByUser({
    required String userId,
    required AppUserRole role,
  }) async => const [];

  @override
  Future<Order> updateOrderStatus(String orderId, OrderStatus status) async =>
      throw UnimplementedError();
}

/// Fails createOrder for one specific farmer (matched by farmer name embedded
/// in the product), to exercise partial-success handling.
class _PartialFailRepo implements OrdersRepository {
  int created = 0;

  @override
  Future<Order> createOrder({
    required List<OrderLine> items,
    required OrderAddress shippingAddress,
  }) async {
    // The controller passes product ids; we can't see farmer name here, so the
    // test wires distinct product ids and we fail on a known id prefix.
    if (items.first.productId.startsWith('B')) {
      throw Exception('gateway down');
    }
    created++;
    final now = DateTime(2026, 6, 15);
    return Order(
      id: 'ord_$created',
      buyerId: 'buyer',
      farmerId: 'farmer',
      items: const [],
      totalAmount: 0,
      platformFeePercent: 5,
      platformFeeAmount: 0,
      grandTotal: 0,
      shippingAddress: shippingAddress,
      status: OrderStatus.pending,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<List<Order>> getOrdersByUser({
    required String userId,
    required AppUserRole role,
  }) async => const [];

  @override
  Future<Order> updateOrderStatus(String orderId, OrderStatus status) async =>
      throw UnimplementedError();
}

ProviderContainer _containerWith(OrdersRepository repo, List<CartItem> items) {
  final container = ProviderContainer(
    overrides: [ordersRepositoryProvider.overrideWithValue(repo)],
  );
  for (final item in items) {
    container
        .read(cartControllerProvider.notifier)
        .addItem(item.product, quantity: item.quantity);
  }
  return container;
}

void main() {
  group('CheckoutController', () {
    test(
      'creates one order per farmer group and clears the whole cart',
      () async {
        final repo = _RecordingOrdersRepo();
        final container = _containerWith(repo, [
          CartItem(product: _product('A1', 'farmerA', 'Ali'), quantity: 2),
          CartItem(product: _product('A2', 'farmerA', 'Ali'), quantity: 1),
          CartItem(product: _product('C1', 'farmerC', 'Chaudhry'), quantity: 3),
        ]);
        addTearDown(container.dispose);

        final result = await container
            .read(checkoutControllerProvider.notifier)
            .submit(_address);

        expect(result.isFullSuccess, isTrue);
        expect(result.placedCount, 2); // two farmers -> two orders
        expect(repo.createdLines, hasLength(2));
        // farmerA's order carries both of its lines.
        final twoLineOrder = repo.createdLines.firstWhere(
          (lines) => lines.length == 2,
        );
        expect(twoLineOrder.map((l) => l.productId), containsAll(['A1', 'A2']));
        // Cart is emptied after full success.
        expect(container.read(cartControllerProvider), isEmpty);
      },
    );

    test('scopes to a single farmer when farmerId is given', () async {
      final repo = _RecordingOrdersRepo();
      final container = _containerWith(repo, [
        CartItem(product: _product('A1', 'farmerA', 'Ali'), quantity: 1),
        CartItem(product: _product('C1', 'farmerC', 'Chaudhry'), quantity: 1),
      ]);
      addTearDown(container.dispose);

      final result = await container
          .read(checkoutControllerProvider.notifier)
          .submit(_address, farmerId: 'farmerA');

      expect(result.placedCount, 1);
      expect(repo.createdLines.single.single.productId, 'A1');
      // Only farmerA cleared; farmerC remains in the cart.
      final remaining = container.read(cartControllerProvider);
      expect(remaining.map((i) => i.farmerId), ['farmerC']);
    });

    test('partial success keeps the failed farmer in the cart', () async {
      final repo = _PartialFailRepo();
      final container = _containerWith(repo, [
        CartItem(product: _product('A1', 'farmerA', 'Ali'), quantity: 1),
        CartItem(product: _product('B1', 'farmerB', 'Bashir'), quantity: 1),
      ]);
      addTearDown(container.dispose);

      final result = await container
          .read(checkoutControllerProvider.notifier)
          .submit(_address);

      expect(result.isPartial, isTrue);
      expect(result.placedCount, 1);
      expect(result.failedFarmers, ['Bashir']);
      // farmerA cleared (succeeded); farmerB retained for retry.
      expect(container.read(cartControllerProvider).map((i) => i.farmerId), [
        'farmerB',
      ]);
    });
  });
}
