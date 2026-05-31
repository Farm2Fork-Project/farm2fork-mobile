import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/features/cart/data/models/cart_pricing_config.dart';
import 'package:farm2fork_mobile/features/cart/data/models/cart_item.dart';
import 'package:farm2fork_mobile/features/cart/data/models/farmer_cart_group.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';

// ─── Cart Controller ─────────────────────────────────────────────────────────

/// Manages a flat normalized list of [CartItem].
/// UI should consume [farmerCartGroupsProvider] for grouped display.
class CartController extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => const [];

  /// Adds [product] to the cart.
  /// If the product already exists, increments its quantity by [quantity].
  void addItem(Product product, {int quantity = 1}) {
    assert(quantity > 0, 'Quantity must be positive');
    final idx = state.indexWhere((i) => i.product.id == product.id);
    if (idx == -1) {
      state = [...state, CartItem(product: product, quantity: quantity)];
    } else {
      state = [
        for (var i = 0; i < state.length; i++)
          if (i == idx)
            state[i].copyWith(quantity: state[i].quantity + quantity)
          else
            state[i],
      ];
    }
  }

  /// Removes the item for [productId] entirely.
  void removeItem(String productId) {
    state = state.where((i) => i.product.id != productId).toList();
  }

  /// Sets the quantity for [productId]. If [quantity] <= 0, removes the item.
  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    state = [
      for (final item in state)
        if (item.product.id == productId)
          item.copyWith(quantity: quantity)
        else
          item,
    ];
  }

  /// Removes all items belonging to a specific farmer (post-checkout).
  void clearFarmerGroup(String farmerId) {
    state = state.where((i) => i.farmerId != farmerId).toList();
  }

  /// Clears the entire cart.
  void clear() => state = const [];
}

// ─── Provider ────────────────────────────────────────────────────────────────

final cartControllerProvider = NotifierProvider<CartController, List<CartItem>>(
  CartController.new,
);

// ─── Derived: Total item count badge ─────────────────────────────────────────

final cartItemCountProvider = Provider<int>((ref) {
  return ref
      .watch(cartControllerProvider)
      .fold(0, (sum, item) => sum + item.quantity);
});

final cartPricingConfigProvider = Provider<CartPricingConfig>((ref) {
  return CartPricingConfig.fallback;
});

// ─── Derived: Grouped by Farmer ──────────────────────────────────────────────

/// Groups flat cart items into [FarmerCartGroup] list sorted by farmer name.
final farmerCartGroupsProvider = Provider<List<FarmerCartGroup>>((ref) {
  final items = ref.watch(cartControllerProvider);
  final pricingConfig = ref.watch(cartPricingConfigProvider);
  final Map<String, List<CartItem>> grouped = {};

  for (final item in items) {
    grouped.putIfAbsent(item.farmerId, () => []).add(item);
  }

  final groups = grouped.entries.map((entry) {
    final first = entry.value.first;
    return FarmerCartGroup(
      farmerId: entry.key,
      farmerName: first.farmerName,
      farmName: first.farmName,
      items: entry.value,
      pricingConfig: pricingConfig,
    );
  }).toList()..sort((a, b) => a.farmerName.compareTo(b.farmerName));

  return groups;
});

// ─── Derived: Cart total ──────────────────────────────────────────────────────

final cartGrandTotalProvider = Provider<double>((ref) {
  return ref
      .watch(farmerCartGroupsProvider)
      .fold(0.0, (sum, g) => sum + g.grandTotal);
});
