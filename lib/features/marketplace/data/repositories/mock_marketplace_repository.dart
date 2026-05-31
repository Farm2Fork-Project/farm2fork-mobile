import 'package:Farm2Fork/features/marketplace/data/mock/mock_products.dart';
import 'package:Farm2Fork/features/marketplace/data/models/product.dart';
import 'package:Farm2Fork/features/marketplace/data/models/product_category.dart';
import 'marketplace_repository.dart';

/// Mock implementation of [MarketplaceRepository] using in-memory data.
/// Replace with a Dio-backed implementation when the API is ready.
class MockMarketplaceRepository implements MarketplaceRepository {
  @override
  Future<List<Product>> getProducts({ProductCategory? category}) async {
    // Simulate network latency
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (category == null) return List.unmodifiable(mockProducts);
    return mockProducts.where((p) => p.category == category).toList(growable: false);
  }

  @override
  Future<Product?> getProductById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    try {
      return mockProducts.firstWhere((p) => p.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return List.unmodifiable(mockProducts);
    return mockProducts
        .where((p) {
          return p.name.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q) ||
              p.farmer.farmName.toLowerCase().contains(q);
        })
        .toList(growable: false);
  }
}
