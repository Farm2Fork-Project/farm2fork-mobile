import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Farm2Fork/app/app.dart';
import 'package:Farm2Fork/features/cart/presentation/providers/cart_controller.dart';
import 'package:Farm2Fork/features/marketplace/data/models/farmer_summary.dart';
import 'package:Farm2Fork/features/marketplace/data/models/product.dart';
import 'package:Farm2Fork/features/marketplace/data/models/product_category.dart';
import 'package:Farm2Fork/features/marketplace/data/repositories/marketplace_repository.dart';
import 'package:Farm2Fork/features/marketplace/presentation/providers/marketplace_providers.dart';

// ─── Zero-delay repository stub ───────────────────────────────────────────────

class _InstantRepository implements MarketplaceRepository {
  @override
  Future<List<Product>> getProducts({ProductCategory? category}) async => [];

  @override
  Future<Product?> getProductById(String id) async => null;

  @override
  Future<List<Product>> searchProducts(String query) async => [];
}

// ─── Test helper ──────────────────────────────────────────────────────────────

Product _makeProduct({
  required String id,
  required String farmerId,
  required String farmerName,
  double price = 100,
}) {
  return Product(
    id: id,
    farmerId: farmerId,
    name: 'Product $id',
    category: ProductCategory.vegetables,
    description: 'Test description',
    pricePerUnit: price,
    availableQuantity: 50,
    unit: 'kg',
    farmer: FarmerSummary(
      id: farmerId,
      name: farmerName,
      farmName: '$farmerName Farm',
      farmLocationAddress: 'Punjab',
    ),
  );
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  // ── Widget smoke test ──────────────────────────────────────────────────────
  testWidgets('App loads successfully smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          marketplaceRepositoryProvider.overrideWithValue(_InstantRepository()),
        ],
        child: const Farm2ForkApp(),
      ),
    );

    // Settle all frames including the empty product list render
    await tester.pumpAndSettle();

    expect(find.byType(Farm2ForkApp), findsOneWidget);
  });

  // ── CartController unit tests ─────────────────────────────────────────────
  group('CartController', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('cart starts empty', () {
      expect(container.read(cartControllerProvider), isEmpty);
    });

    test('addItem adds a product', () {
      final p = _makeProduct(id: 'p1', farmerId: 'f1', farmerName: 'Ali');
      container.read(cartControllerProvider.notifier).addItem(p);
      final items = container.read(cartControllerProvider);
      expect(items.length, 1);
      expect(items.first.product.id, 'p1');
      expect(items.first.quantity, 1);
    });

    test('addItem increments quantity for existing product', () {
      final p = _makeProduct(id: 'p1', farmerId: 'f1', farmerName: 'Ali');
      container.read(cartControllerProvider.notifier).addItem(p);
      container.read(cartControllerProvider.notifier).addItem(p, quantity: 2);
      final items = container.read(cartControllerProvider);
      expect(items.length, 1);
      expect(items.first.quantity, 3);
    });

    test('removeItem removes the correct product', () {
      final p1 = _makeProduct(id: 'p1', farmerId: 'f1', farmerName: 'Ali');
      final p2 = _makeProduct(id: 'p2', farmerId: 'f1', farmerName: 'Ali');
      container.read(cartControllerProvider.notifier).addItem(p1);
      container.read(cartControllerProvider.notifier).addItem(p2);
      container.read(cartControllerProvider.notifier).removeItem('p1');
      final items = container.read(cartControllerProvider);
      expect(items.length, 1);
      expect(items.first.product.id, 'p2');
    });

    test('updateQuantity updates correctly', () {
      final p = _makeProduct(id: 'p1', farmerId: 'f1', farmerName: 'Ali');
      container.read(cartControllerProvider.notifier).addItem(p);
      container.read(cartControllerProvider.notifier).updateQuantity('p1', 5);
      expect(container.read(cartControllerProvider).first.quantity, 5);
    });

    test('updateQuantity with 0 removes item', () {
      final p = _makeProduct(id: 'p1', farmerId: 'f1', farmerName: 'Ali');
      container.read(cartControllerProvider.notifier).addItem(p);
      container.read(cartControllerProvider.notifier).updateQuantity('p1', 0);
      expect(container.read(cartControllerProvider), isEmpty);
    });

    test('clear empties the cart', () {
      final p = _makeProduct(id: 'p1', farmerId: 'f1', farmerName: 'Ali');
      container.read(cartControllerProvider.notifier).addItem(p);
      container.read(cartControllerProvider.notifier).clear();
      expect(container.read(cartControllerProvider), isEmpty);
    });

    test('products from two different farmers create two groups', () {
      final p1 = _makeProduct(id: 'p1', farmerId: 'f1', farmerName: 'Ali', price: 200);
      final p2 = _makeProduct(id: 'p2', farmerId: 'f2', farmerName: 'Fatima', price: 100);
      container.read(cartControllerProvider.notifier).addItem(p1, quantity: 2);
      container.read(cartControllerProvider.notifier).addItem(p2, quantity: 3);

      final groups = container.read(farmerCartGroupsProvider);
      expect(groups.length, 2);
    });

    test('products from same farmer are in one group', () {
      final p1 = _makeProduct(id: 'p1', farmerId: 'f1', farmerName: 'Ali', price: 100);
      final p2 = _makeProduct(id: 'p2', farmerId: 'f1', farmerName: 'Ali', price: 200);
      container.read(cartControllerProvider.notifier).addItem(p1, quantity: 1);
      container.read(cartControllerProvider.notifier).addItem(p2, quantity: 1);

      final groups = container.read(farmerCartGroupsProvider);
      expect(groups.length, 1);
      expect(groups.first.items.length, 2);
    });

    test('FarmerCartGroup subtotal, platformFee, and grandTotal are correct', () {
      final p = _makeProduct(id: 'p1', farmerId: 'f1', farmerName: 'Ali', price: 100);
      container.read(cartControllerProvider.notifier).addItem(p, quantity: 4);

      final group = container.read(farmerCartGroupsProvider).first;
      expect(group.itemsSubtotal, 400.0);
      expect(group.platformFee, closeTo(20.0, 0.001)); // 5% of 400
      expect(group.grandTotal, closeTo(420.0, 0.001));
    });

    test('clearFarmerGroup removes only that farmer items', () {
      final p1 = _makeProduct(id: 'p1', farmerId: 'f1', farmerName: 'Ali');
      final p2 = _makeProduct(id: 'p2', farmerId: 'f2', farmerName: 'Fatima');
      container.read(cartControllerProvider.notifier).addItem(p1);
      container.read(cartControllerProvider.notifier).addItem(p2);
      container.read(cartControllerProvider.notifier).clearFarmerGroup('f1');

      final items = container.read(cartControllerProvider);
      expect(items.length, 1);
      expect(items.first.product.farmerId, 'f2');
    });
  });
}
