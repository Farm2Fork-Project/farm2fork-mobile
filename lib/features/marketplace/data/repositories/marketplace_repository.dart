import 'package:Farm2Fork/features/marketplace/data/models/product.dart';
import 'package:Farm2Fork/features/marketplace/data/models/product_category.dart';

/// Abstract contract for marketplace data operations.
/// Mock and real (Dio) implementations both satisfy this interface.
abstract class MarketplaceRepository {
  /// Returns all available products, optionally filtered by [category].
  Future<List<Product>> getProducts({ProductCategory? category});

  /// Returns a single product by [id], or null if not found.
  Future<Product?> getProductById(String id);

  /// Returns products whose name or description contains [query] (case-insensitive).
  Future<List<Product>> searchProducts(String query);
}
