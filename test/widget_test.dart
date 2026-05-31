import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/app/app.dart';
import 'package:farm2fork_mobile/features/cart/data/models/cart_pricing_config.dart';
import 'package:farm2fork_mobile/features/cart/presentation/providers/cart_controller.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/farmer_summary.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_category.dart';
import 'package:farm2fork_mobile/features/marketplace/data/repositories/marketplace_repository.dart';
import 'package:farm2fork_mobile/features/marketplace/presentation/providers/marketplace_providers.dart';

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
    price: price,
    quantity: 50,
    unit: ProductUnit.kg,
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
      final p1 = _makeProduct(
        id: 'p1',
        farmerId: 'f1',
        farmerName: 'Ali',
        price: 200,
      );
      final p2 = _makeProduct(
        id: 'p2',
        farmerId: 'f2',
        farmerName: 'Fatima',
        price: 100,
      );
      container.read(cartControllerProvider.notifier).addItem(p1, quantity: 2);
      container.read(cartControllerProvider.notifier).addItem(p2, quantity: 3);

      final groups = container.read(farmerCartGroupsProvider);
      expect(groups.length, 2);
    });

    test('products from same farmer are in one group', () {
      final p1 = _makeProduct(
        id: 'p1',
        farmerId: 'f1',
        farmerName: 'Ali',
        price: 100,
      );
      final p2 = _makeProduct(
        id: 'p2',
        farmerId: 'f1',
        farmerName: 'Ali',
        price: 200,
      );
      container.read(cartControllerProvider.notifier).addItem(p1, quantity: 1);
      container.read(cartControllerProvider.notifier).addItem(p2, quantity: 1);

      final groups = container.read(farmerCartGroupsProvider);
      expect(groups.length, 1);
      expect(groups.first.items.length, 2);
    });

    test(
      'FarmerCartGroup subtotal, platformFee, and grandTotal are correct',
      () {
        final p = _makeProduct(
          id: 'p1',
          farmerId: 'f1',
          farmerName: 'Ali',
          price: 100,
        );
        container.read(cartControllerProvider.notifier).addItem(p, quantity: 4);

        final group = container.read(farmerCartGroupsProvider).first;
        expect(group.itemsSubtotal, 400.0);
        expect(group.platformFee, closeTo(20.0, 0.001)); // 5% of 400
        expect(group.grandTotal, closeTo(420.0, 0.001));
      },
    );

    test('FarmerCartGroup uses typed platform fee percent from config', () {
      final p = _makeProduct(
        id: 'p1',
        farmerId: 'f1',
        farmerName: 'Ali',
        price: 200,
      );
      container.read(cartControllerProvider.notifier).addItem(p, quantity: 2);

      final group = container.read(farmerCartGroupsProvider).first;
      final pricedGroup = group.withPricing(
        const CartPricingConfig(platformFeePercent: 7.5),
      );

      expect(pricedGroup.itemsSubtotal, 400.0);
      expect(pricedGroup.platformFee, closeTo(30.0, 0.001));
      expect(pricedGroup.grandTotal, closeTo(430.0, 0.001));
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

  group('Product model schema alignment', () {
    test('parses backend product JSON using locked schema field names', () {
      final product = Product.fromJson({
        '_id': 'prod_001',
        'farmerId': 'farmer_001',
        'name': 'Tomatoes',
        'category': 'vegetables',
        'description': 'Fresh tomatoes',
        'price': 120,
        'quantity': 200,
        'unit': 'kg',
        'images': ['https://example.com/tomato.jpg'],
        'qualityGrade': 'A',
        'qrCode': 'https://farm2fork.test/qr/prod_001',
        'initialBlockchainRecordId': 'chain_001',
        'status': 'sold_out',
        'farmer': {
          'id': 'farmer_001',
          'name': 'Ali Hassan',
          'farmName': 'Hassan Organic Farm',
          'farmLocationAddress': 'Multan, Punjab',
          'rating': 4.8,
          'totalSales': 312,
        },
      });

      expect(product.id, 'prod_001');
      expect(product.price, 120);
      expect(product.quantity, 200);
      expect(product.images.single, 'https://example.com/tomato.jpg');
      expect(product.qualityGrade, QualityGrade.a);
      expect(product.status, ProductStatus.soldOut);
      expect(product.qrCode, 'https://farm2fork.test/qr/prod_001');
      expect(product.initialBlockchainRecordId, 'chain_001');
    });
  });
}
