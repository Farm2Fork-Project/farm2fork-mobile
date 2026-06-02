import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';

abstract class ListingsRepository {
  Future<List<Product>> getFarmerListings(String farmerId);
  Future<Product> createListing(Product product);
  Future<Product> updateListingStatus(String productId, ProductStatus status);
  Future<void> deleteListing(String productId);
}
