import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/features/marketplace/data/mock/mock_products.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'listings_repository.dart';

final listingsRepositoryProvider = Provider<ListingsRepository>((ref) {
  return MockListingsRepository();
});

class MockListingsRepository implements ListingsRepository {
  @override
  Future<List<Product>> getFarmerListings(String farmerId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    // Support matching both 'farmer_001' style mock IDs and 'mock_farmer_001' auth session IDs
    final normalizedFarmerId = farmerId.replaceAll('mock_', '');
    return mockProducts
        .where(
          (p) => p.farmerId == normalizedFarmerId || p.farmerId == farmerId,
        )
        .toList();
  }

  @override
  Future<Product> createListing(Product product) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    mockProducts.insert(0, product);
    return product;
  }

  @override
  Future<Product> updateListingStatus(
    String productId,
    ProductStatus status,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final index = mockProducts.indexWhere((p) => p.id == productId);
    if (index == -1) throw Exception('Product not found');
    final updated = mockProducts[index].copyWith(status: status);
    mockProducts[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteListing(String productId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    mockProducts.removeWhere((p) => p.id == productId);
  }
}
