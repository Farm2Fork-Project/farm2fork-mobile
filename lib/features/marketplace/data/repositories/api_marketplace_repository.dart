import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/features/marketplace/data/mappers/product_dto_mapper.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_category.dart';
import 'package:farm2fork_mobile/features/marketplace/data/services/marketplace_api_service.dart';
import 'marketplace_repository.dart';

/// Real [MarketplaceRepository] backed by the backend `/products` API.
/// DTO mapping lives in [ProductDtoMapper].
class ApiMarketplaceRepository implements MarketplaceRepository {
  ApiMarketplaceRepository(this._api);

  final MarketplaceApiService _api;

  @override
  Future<List<Product>> getProducts({ProductCategory? category}) async {
    return _allProducts(category: category?.name);
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    return _allProducts(search: query);
  }

  Future<List<Product>> _allProducts({String? search, String? category}) async {
    final products = <Product>[];
    var page = 1;
    var totalPages = 1;
    do {
      final body = await _api.fetchProducts(
        search: search,
        category: category,
        page: page,
      );
      products.addAll(_parseList(body));
      totalPages = (body['totalPages'] as num?)?.toInt() ?? 1;
      page++;
    } while (page <= totalPages);
    return products;
  }

  @override
  Future<Product?> getProductById(String id) async {
    try {
      final json = await _api.fetchProductById(id);
      return ProductDtoMapper.fromDto(json);
    } on ApiException catch (e) {
      if (e.kind == ApiErrorKind.notFound) return null;
      rethrow;
    }
  }

  List<Product> _parseList(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is! List) throw const FormatException('Invalid products response');
    return data
        .whereType<Map<String, dynamic>>()
        .map(ProductDtoMapper.fromDto)
        .toList(growable: false);
  }
}
