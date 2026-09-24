import 'package:farm2fork_mobile/features/listings/data/models/new_listing.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';

abstract class ListingsRepository {
  /// The signed-in farmer's listings. [farmerId] scopes the mock; the real
  /// API derives the farmer from the session.
  Future<List<Product>> getFarmerListings(String farmerId);
  Future<Product> createListing(String farmerId, NewListing listing);
  Future<Product> updateListingStatus(String productId, ProductStatus status);
  Future<void> deleteListing(String productId);
}
