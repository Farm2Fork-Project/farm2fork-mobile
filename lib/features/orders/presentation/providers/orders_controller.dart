import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/orders/data/models/order.dart';
import 'package:farm2fork_mobile/features/orders/data/repositories/orders_repository_provider.dart';

final ordersControllerProvider =
    AsyncNotifierProvider<OrdersController, List<Order>>(OrdersController.new);

class OrdersController extends AsyncNotifier<List<Order>> {
  @override
  Future<List<Order>> build() async {
    final authState = ref.watch(authControllerProvider).asData?.value;
    if (authState == null || authState.user == null) {
      return [];
    }
    final repository = ref.watch(ordersRepositoryProvider);
    return repository.getOrdersByUser(
      userId: authState.user!.id,
      role: authState.user!.role,
    );
  }

  Future<void> fetchOrders() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authState = ref.read(authControllerProvider).asData?.value;
      if (authState == null || authState.user == null) return [];
      return ref
          .read(ordersRepositoryProvider)
          .getOrdersByUser(
            userId: authState.user!.id,
            role: authState.user!.role,
          );
    });
  }

  Future<void> updateStatus(String orderId, OrderStatus status) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authState = ref.read(authControllerProvider).asData?.value;
      if (authState == null || authState.user == null) {
        throw Exception('Unauthorized');
      }
      final repository = ref.read(ordersRepositoryProvider);
      await repository.updateOrderStatus(orderId, status);
      return repository.getOrdersByUser(
        userId: authState.user!.id,
        role: authState.user!.role,
      );
    });
  }
}
