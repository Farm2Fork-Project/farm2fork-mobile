import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/features/orders/data/models/order.dart';

/// A single product line a buyer wants to order (one farmer per order, §6.1).
typedef OrderLine = ({String productId, int quantity});

abstract class OrdersRepository {
  Future<List<Order>> getOrdersByUser({
    required String userId,
    required AppUserRole role,
  });

  /// Places one order for a single farmer. The backend resolves prices, the
  /// farmer, totals and platform fee; callers send only product lines and the
  /// shipping address. Returns the created [Order].
  Future<Order> createOrder({
    required List<OrderLine> items,
    required OrderAddress shippingAddress,
  });

  Future<Order> updateOrderStatus(String orderId, OrderStatus status);
}
