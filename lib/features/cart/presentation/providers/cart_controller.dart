import 'dart:convert';
import 'package:farm2fork_mobile/core/localization/locale_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/features/cart/data/models/cart_pricing_config.dart';
import 'package:farm2fork_mobile/features/cart/data/models/cart_item.dart';
import 'package:farm2fork_mobile/features/cart/data/models/farmer_cart_group.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';

// ─── Cart Controller ─────────────────────────────────────────────────────────

/// Manages a flat normalized list of [CartItem].
/// UI should consume [farmerCartGroupsProvider] for grouped display.
class CartController extends Notifier<List<CartItem>> {
  String? _storageKey;
  int _generation = 0;
  bool _disposed = false;
  Future<void> _writes = Future.value();

  @override
  List<CartItem> build() {
    ref.onDispose(() => _disposed = true);
    return const [];
  }

  /// Bound by the authenticated router, never shared across accounts.
  Future<void> bindUser(String? userId) async {
    final key = userId == null ? null : 'f2f.cart.v1.$userId';
    if (_storageKey == key) return;
    _storageKey = key;
    final generation = ++_generation;
    state = const [];
    if (key == null) return;
    try {
      await _writes;
      if (_disposed || generation != _generation) return;
      final encoded = await ref.read(secureStorageProvider).read(key: key);
      if (_disposed ||
          generation != _generation ||
          encoded == null ||
          state.isNotEmpty) {
        return;
      }
      final decoded = jsonDecode(encoded) as List;
      final items = decoded
          .map((raw) {
            final entry = raw as Map<String, dynamic>;
            return CartItem(
              product: Product.fromJson(
                entry['product'] as Map<String, dynamic>,
              ),
              quantity: entry['quantity'] as int,
            );
          })
          .where(
            (item) =>
                item.quantity > 0 &&
                item.product.status == ProductStatus.active &&
                item.product.quantity >= item.quantity,
          )
          .toList();
      state = items;
    } catch (_) {
      /* Storage is optional; malformed/old carts are ignored. */
    }
  }

  void _setCart(List<CartItem> items) {
    ++_generation;
    state = items;
    final key = _storageKey;
    if (key == null) return;
    final storage = ref.read(secureStorageProvider);
    final encoded = jsonEncode([
      for (final item in items)
        {'product': item.product.toJson(), 'quantity': item.quantity},
    ]);
    _writes = _writes
        .then((_) => storage.write(key: key, value: encoded))
        .catchError((Object _) {});
  }

  /// Adds [product] to the cart.
  /// If the product already exists, increments its quantity by [quantity].
  void addItem(Product product, {int quantity = 1}) {
    if (quantity < 1 ||
        product.status != ProductStatus.active ||
        product.quantity < 1) {
      return;
    }
    final maximum = product.quantity.floor();
    final idx = state.indexWhere((i) => i.product.id == product.id);
    if (idx == -1) {
      _setCart([
        ...state,
        CartItem(product: product, quantity: quantity.clamp(1, maximum)),
      ]);
    } else {
      _setCart([
        for (var i = 0; i < state.length; i++)
          if (i == idx)
            state[i].copyWith(
              product: product,
              quantity: (state[i].quantity + quantity).clamp(1, maximum),
            )
          else
            state[i],
      ]);
    }
  }

  /// Removes the item for [productId] entirely.
  void removeItem(String productId) {
    _setCart(state.where((i) => i.product.id != productId).toList());
  }

  /// Sets the quantity for [productId]. If [quantity] <= 0, removes the item.
  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    _setCart([
      for (final item in state)
        if (item.product.id == productId)
          item.copyWith(
            quantity: quantity.clamp(
              1,
              item.product.quantity.floor().clamp(1, 1 << 31),
            ),
          )
        else
          item,
    ]);
  }

  /// Removes all items belonging to a specific farmer (post-checkout).
  void clearFarmerGroup(String farmerId) {
    _setCart(state.where((i) => i.farmerId != farmerId).toList());
  }

  /// Clears the entire cart.
  void clear() => _setCart(const []);
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
