import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/features/orders/data/models/order.dart';

abstract class OrdersRepository {
  Future<List<Order>> getOrdersByUser({
    required String userId,
    required AppUserRole role,
  });
  Future<Order> createOrder(Order order);
  Future<Order> updateOrderStatus(String orderId, OrderStatus status);
}
