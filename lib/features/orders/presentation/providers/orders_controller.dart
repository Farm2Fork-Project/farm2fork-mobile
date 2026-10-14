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

  bool _mutating = false;
  Future<bool> updateStatus(String orderId, OrderStatus status) async {
    if (_mutating) return false;
    final authState = ref.read(authControllerProvider).asData?.value;
    if (authState?.user == null) return false;
    _mutating = true;
    final previous = state;
    try {
      final updated = await ref
          .read(ordersRepositoryProvider)
          .updateOrderStatus(orderId, status);
      state = AsyncData([
        for (final order in previous.asData?.value ?? <Order>[])
          if (order.id == orderId) updated else order,
      ]);
      return true;
    } catch (_) {
      state = previous;
      return false;
    } finally {
      _mutating = false;
    }
  }
}
