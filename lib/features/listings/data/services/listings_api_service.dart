import 'package:dio/dio.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';

/// Raw transport over the farmer-only `/products` write endpoints and
/// `/products/mine`. Typed mapping lives in the repository.
class ListingsApiService {
  ListingsApiService(this._dio);

  final Dio _dio;

  /// Backend pagination caps `limit` at 100.
  static const int pageSize = 100;

  /// GET /products/mine - the signed-in farmer's listings, all statuses.
  Future<Map<String, dynamic>> fetchMine() => _unwrap(
    () => _dio.get<Map<String, dynamic>>(
      '/products/mine',
      queryParameters: {'limit': pageSize},
    ),
  );

  /// POST /products - also records the listing's first ledger event.
  Future<Map<String, dynamic>> create(Map<String, dynamic> body) =>
      _unwrap(() => _dio.post<Map<String, dynamic>>('/products', data: body));

  /// PATCH /products/:id
  Future<Map<String, dynamic>> update(
    String productId,
    Map<String, dynamic> body,
  ) => _unwrap(
    () => _dio.patch<Map<String, dynamic>>('/products/$productId', data: body),
  );

  /// DELETE /products/:id - a soft delete (the listing becomes inactive).
  Future<void> delete(String productId) async {
    await _dio.delete<Map<String, dynamic>>('/products/$productId');
  }

  Future<Map<String, dynamic>> _unwrap(
    Future<Response<Map<String, dynamic>>> Function() request,
  ) async {
    final data = (await request()).data;
    if (data == null) throw const ApiException(ApiErrorKind.unknown);
    return data;
  }
}
