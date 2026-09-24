import 'package:dio/dio.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';

/// Raw transport for the public, unauthenticated trace endpoint.
class TraceabilityApiService {
  TraceabilityApiService(this._dio);

  final Dio _dio;

  /// GET /trace/products/:id
  Future<Map<String, dynamic>> fetchProductTrace(String productId) async {
    final data = (await _dio.get<Map<String, dynamic>>(
      '/trace/products/${Uri.encodeComponent(productId)}',
    )).data;
    if (data == null) throw const ApiException(ApiErrorKind.unknown);
    return data;
  }
}
