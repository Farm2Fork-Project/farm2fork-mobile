import 'package:dio/dio.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';

class ListingsApiService {
  ListingsApiService(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> fetchMine(int page) => _request(
    () => _dio.get<Map<String, dynamic>>(
      '/products/mine',
      queryParameters: {'page': page, 'limit': 100},
    ),
  );

  Future<Map<String, dynamic>> create(Map<String, dynamic> fields) => _request(
    () => _dio.post<Map<String, dynamic>>('/products', data: fields),
  );

  Future<Map<String, dynamic>> updateStatus(String id, String status) =>
      _request(
        () => _dio.patch<Map<String, dynamic>>(
          '/products/$id',
          data: {'status': status},
        ),
      );

  Future<void> delete(String id) async {
    await _request(() => _dio.delete<Map<String, dynamic>>('/products/$id'));
  }

  Future<Map<String, dynamic>> _request(
    Future<Response<Map<String, dynamic>>> Function() request,
  ) async {
    try {
      final response = await request();
      return response.data ?? (throw const ApiException(ApiErrorKind.unknown));
    } on DioException catch (error) {
      if (error.error is ApiException) throw error.error!;
      rethrow;
    }
  }
}
