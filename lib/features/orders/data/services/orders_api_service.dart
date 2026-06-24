import 'package:dio/dio.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';

/// Transport layer over the backend `/orders` endpoints. Returns raw decoded
/// JSON; the repository maps it into typed models. Throws [ApiException]
/// (already mapped by ErrorInterceptor) on failure.
class OrdersApiService {
  OrdersApiService(this._dio);

  final Dio _dio;

  /// POST /orders — places one order for a single farmer (§6.1). The backend
  /// resolves prices, the farmer, totals and the platform fee server-side; the
  /// client only sends product ids, quantities and the shipping address.
  Future<Map<String, dynamic>> createOrder({
    required List<({String productId, int quantity})> items,
    required Map<String, dynamic> shippingAddress,
  }) {
    return _unwrap(
      () => _dio.post<Map<String, dynamic>>(
        '/orders',
        data: {
          'items': items
              .map((i) => {'productId': i.productId, 'quantity': i.quantity})
              .toList(),
          'shippingAddress': shippingAddress,
        },
      ),
    );
  }

  /// GET /orders — caller's own orders (backend scopes by role).
  Future<Map<String, dynamic>> fetchOrders({
    String? status,
    int page = 1,
    int limit = 50,
  }) {
    return _unwrap(
      () => _dio.get<Map<String, dynamic>>(
        '/orders',
        queryParameters: {'status': ?status, 'page': page, 'limit': limit},
      ),
    );
  }

  /// PATCH /orders/:id/cancel
  Future<Map<String, dynamic>> cancelOrder(String id) {
    return _unwrap(
      () => _dio.patch<Map<String, dynamic>>('/orders/$id/cancel'),
    );
  }

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
