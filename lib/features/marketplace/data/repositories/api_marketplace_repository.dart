import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_dto_mapper.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_category.dart';
import 'package:farm2fork_mobile/features/marketplace/data/services/marketplace_api_service.dart';
import 'marketplace_repository.dart';

/// Real [MarketplaceRepository] backed by the backend `/products` API.
///
/// The backend [ProductResponseDto] differs from the mobile [Product] model in
/// two ways this adapter reconciles:
///  * `category` is a free-form string on the backend but a 4-value enum on the
///    client. Unknown categories fall back to [ProductCategory.vegetables] (the
///    UI groups under "All" regardless, so this never hides a product).
///  * the listing endpoint returns only `farmerId`, not embedded farmer detail.
///    A minimal [FarmerSummary] is synthesised from the id; rich farmer info
///    awaits a profiles endpoint (tracked separately).
class ApiMarketplaceRepository implements MarketplaceRepository {
  ApiMarketplaceRepository(this._api);

  final MarketplaceApiService _api;

  @override
  Future<List<Product>> getProducts({ProductCategory? category}) async {
    final body = await _api.fetchProducts(category: category?.name);
    return _parseList(body);
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final body = await _api.fetchProducts(search: query);
    return _parseList(body);
  }

  @override
  Future<Product?> getProductById(String id) async {
    try {
      final json = await _api.fetchProductById(id);
      return const ProductDtoMapper().fromDto(json);
    } on ApiException catch (e) {
      if (e.kind == ApiErrorKind.notFound) return null;
      rethrow;
    }
  }

  List<Product> _parseList(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(const ProductDtoMapper().fromDto)
        .toList(growable: false);
  }
}
