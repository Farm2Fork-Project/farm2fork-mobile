import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/features/orders/data/models/order.dart';
import 'orders_repository.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return MockOrdersRepository();
});

class MockOrdersRepository implements OrdersRepository {
  final List<Order> _orders = [
    Order(
      id: 'ord_1001',
      buyerId: 'mock_buyer_001',
      farmerId: 'farmer_001',
      items: const [
        OrderItem(
          productId: 'prod_001',
          farmerId: 'farmer_001',
          productName: 'Organic Tomatoes',
          quantity: 10,
          unit: 'kg',
          unitPrice: 120,
          subtotal: 1200,
        ),
        OrderItem(
          productId: 'prod_002',
          farmerId: 'farmer_001',
          productName: 'Fresh Spinach',
          quantity: 5,
          unit: 'kg',
          unitPrice: 80,
          subtotal: 400,
        ),
      ],
      totalAmount: 1600,
      platformFeePercent: 5.0,
      platformFeeAmount: 80,
      grandTotal: 1680,
      shippingAddress: const OrderAddress(
        street: 'Building 14B, Gulberg III',
        city: 'Lahore',
        province: 'Punjab',
        zip: '54000',
      ),
      status: OrderStatus.processing,
      paymentId: 'pay_2001',
      shipmentId: 'ship_3001',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Order(
      id: 'ord_1002',
      buyerId: 'mock_buyer_001',
      farmerId: 'farmer_002',
      items: const [
        OrderItem(
          productId: 'prod_004',
          farmerId: 'farmer_002',
          productName: 'Sindhri Mangoes',
          quantity: 2,
          unit: 'dozen',
          unitPrice: 350,
          subtotal: 700,
        ),
      ],
      totalAmount: 700,
      platformFeePercent: 5.0,
      platformFeeAmount: 35,
      grandTotal: 735,
      shippingAddress: const OrderAddress(
        street: 'Building 14B, Gulberg III',
        city: 'Lahore',
        province: 'Punjab',
        zip: '54000',
      ),
      status: OrderStatus.delivered,
      paymentId: 'pay_2002',
      shipmentId: 'ship_3002',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  @override
  Future<List<Order>> getOrdersByUser({
    required String userId,
    required AppUserRole role,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final normalizedUserId = userId.replaceAll('mock_', '');

    return switch (role) {
      AppUserRole.buyer =>
        _orders
            .where((o) => o.buyerId == userId || o.buyerId == normalizedUserId)
            .toList(),
      AppUserRole.farmer =>
        _orders
            .where(
              (o) => o.farmerId == userId || o.farmerId == normalizedUserId,
            )
            .toList(),
      AppUserRole.transporter =>
        _orders, // Transporters can view shipments/assigned deliveries
      _ => [],
    };
  }

  @override
  Future<Order> createOrder(Order order) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _orders.insert(0, order);
    return order;
  }

  @override
  Future<Order> updateOrderStatus(String orderId, OrderStatus status) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) throw Exception('Order not found');
    final updated = _orders[index].copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );
    _orders[index] = updated;
    return updated;
  }
}
