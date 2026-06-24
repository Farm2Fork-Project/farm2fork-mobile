import 'package:dio/dio.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';

/// Thin transport layer over the backend `/products` endpoints. Returns raw
/// decoded JSON; mapping into typed models happens in the repository. Throws
/// [ApiException] (already mapped by ErrorInterceptor) on failure.
class MarketplaceApiService {
  MarketplaceApiService(this._dio);

  final Dio _dio;

  /// GET /products — supports search and category filters plus pagination.
  /// Returns the paginated envelope `{ data, total, page, limit, totalPages }`.
  Future<Map<String, dynamic>> fetchProducts({
    String? search,
    String? category,
    int page = 1,
    int limit = 50,
  }) async {
    final trimmedSearch = (search != null && search.isNotEmpty) ? search : null;
    final response = await _unwrap(
      () => _dio.get<Map<String, dynamic>>(
        '/products',
        queryParameters: {
          'search': ?trimmedSearch,
          'category': ?category,
          'page': page,
          'limit': limit,
        },
      ),
    );
    return response;
  }

  /// GET /products/:id — single product.
  Future<Map<String, dynamic>> fetchProductById(String id) {
    return _unwrap(() => _dio.get<Map<String, dynamic>>('/products/$id'));
  }

  /// Centralises null-body handling so callers always get a non-null map.
  Future<Map<String, dynamic>> _unwrap(
    Future<Response<Map<String, dynamic>>> Function() request,
  ) async {
    final response = await request();
    final data = response.data;
    if (data == null) {
      throw const ApiException(ApiErrorKind.unknown);
    }
    return data;
  }
}
