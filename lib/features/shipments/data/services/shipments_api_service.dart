import 'package:dio/dio.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';

/// Raw authenticated shipment API transport. Typed mapping belongs in the
/// repository so API response validation is independent from Dio.
class ShipmentsApiService {
  ShipmentsApiService(this._dio);

  final Dio _dio;

  Future<List<Map<String, dynamic>>> getAvailableDeliveries() =>
      _unwrapList(() => _dio.get<List<dynamic>>('/shipments/available'));

  Future<Map<String, dynamic>> getStatus() => _unwrap(
    () => _dio.get<Map<String, dynamic>>('/shipments/transporter/status'),
  );

  Future<Map<String, dynamic>> setAvailability(Map<String, dynamic> body) =>
      _unwrap(
        () => _dio.put<Map<String, dynamic>>(
          '/shipments/transporter/availability',
          data: body,
        ),
      );

  Future<void> reportLocation(Map<String, double> location) =>
      _dio.put<void>('/shipments/transporter/location', data: location);

  Future<void> decline(String orderId) =>
      _dio.post<void>('/shipments/offers/$orderId/decline');

  Future<List<Map<String, dynamic>>> getMyShipments() =>
      _unwrapList(() => _dio.get<List<dynamic>>('/shipments'));

  Future<Map<String, dynamic>> getShipment(String shipmentId) =>
      _unwrap(() => _dio.get<Map<String, dynamic>>('/shipments/$shipmentId'));

  Future<Map<String, dynamic>> claimShipment(String orderId) => _unwrap(
    () => _dio.post<Map<String, dynamic>>(
      '/shipments/claims',
      data: {'orderId': orderId},
    ),
  );

  Future<Map<String, dynamic>> updateShipmentStatus({
    required String shipmentId,
    required String status,
    required String note,
  }) => _unwrap(
    () => _dio.patch<Map<String, dynamic>>(
      '/shipments/$shipmentId/status',
      data: {'status': status, 'note': note},
    ),
  );

  Future<Map<String, dynamic>> _unwrap(
    Future<Response<Map<String, dynamic>>> Function() request,
  ) async {
    final data = (await request()).data;
    if (data == null) throw const ApiException(ApiErrorKind.unknown);
    return data;
  }

  Future<List<Map<String, dynamic>>> _unwrapList(
    Future<Response<List<dynamic>>> Function() request,
  ) async {
    final data = (await request()).data;
    if (data == null) throw const ApiException(ApiErrorKind.unknown);
    return data
        .map((item) {
          if (item is! Map) throw const ApiException(ApiErrorKind.unknown);
          return Map<String, dynamic>.from(item);
        })
        .toList(growable: false);
  }
}
