import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/features/cart/data/models/farmer_cart_group.dart';
import 'package:farm2fork_mobile/features/cart/presentation/providers/cart_controller.dart';
import 'package:farm2fork_mobile/features/orders/data/models/order.dart';
import 'package:farm2fork_mobile/features/orders/data/repositories/orders_repository.dart';
import 'package:farm2fork_mobile/features/orders/data/repositories/orders_repository_provider.dart';

/// Outcome of a checkout attempt across one or more farmer groups.
class CheckoutResult {
  const CheckoutResult({required this.placed, required this.failedFarmers});

  /// Orders successfully created (one per farmer group).
  final List<Order> placed;

  /// Names of farmer groups whose order failed; empty means full success.
  final List<String> failedFarmers;

  bool get isFullSuccess => failedFarmers.isEmpty && placed.isNotEmpty;
  bool get isPartial => placed.isNotEmpty && failedFarmers.isNotEmpty;
  int get placedCount => placed.length;
}

/// Drives checkout: creates one order per farmer group (One-Order-One-Farmer
/// §6.1), clearing each group from the cart as its order succeeds so a retry
/// only re-attempts the farmers that failed.
class CheckoutController extends AsyncNotifier<CheckoutResult?> {
  @override
  CheckoutResult? build() => null;

  /// Places orders for the cart's farmer groups. When [farmerId] is given, only
  /// that farmer's group is checked out (per-group checkout from the cart);
  /// otherwise every group is placed as a separate order (§6.1).
  Future<CheckoutResult> submit(
    OrderAddress shippingAddress, {
    String? farmerId,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final allGroups = ref.read(farmerCartGroupsProvider);
      final groups = farmerId == null
          ? allGroups
          : allGroups.where((g) => g.farmerId == farmerId).toList();
      final repo = ref.read(ordersRepositoryProvider);
      final cart = ref.read(cartControllerProvider.notifier);

      final placed = <Order>[];
      final failed = <String>[];

      for (final group in groups) {
        try {
          final order = await repo.createOrder(
            items: _linesFor(group),
            shippingAddress: shippingAddress,
          );
          placed.add(order);
          // Clear only this farmer's items so a retry targets the rest.
          cart.clearFarmerGroup(group.farmerId);
        } on Object {
          failed.add(group.farmerName);
        }
      }

      return CheckoutResult(placed: placed, failedFarmers: failed);
    });
    state = result;
    return result.asData?.value ??
        const CheckoutResult(placed: [], failedFarmers: []);
  }

  List<OrderLine> _linesFor(FarmerCartGroup group) => group.items
      .map((i) => (productId: i.product.id, quantity: i.quantity))
      .toList(growable: false);
}

final checkoutControllerProvider =
    AsyncNotifierProvider<CheckoutController, CheckoutResult?>(
      CheckoutController.new,
    );
