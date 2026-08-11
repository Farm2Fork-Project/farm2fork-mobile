import 'package:dio/dio.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';

class PaymentsApiService {
  PaymentsApiService(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> initiatePayment({
    required String orderId,
    required String gateway,
  }) => _unwrap(() => _dio.post<Map<String, dynamic>>(
        '/payments',
        data: {'orderId': orderId, 'gateway': gateway},
      ));

  Future<Map<String, dynamic>> simulatePayment({
    required String paymentId,
    required String status,
  }) => _unwrap(() => _dio.post<Map<String, dynamic>>(
        '/payments/$paymentId/simulate',
        data: {'status': status},
      ));

  Future<Map<String, dynamic>> _unwrap(
    Future<Response<Map<String, dynamic>>> Function() request,
  ) async {
    final data = (await request()).data;
    if (data == null) throw const ApiException(ApiErrorKind.unknown);
    return data;
  }
}
