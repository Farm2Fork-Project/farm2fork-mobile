import 'package:dio/dio.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';

/// Raw transport for the farmer AI endpoints (`/ai/*` on the Nest backend,
/// which proxies the farm2fork-ai FastAPI service).
class AiApiService {
  AiApiService(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> status() =>
      _unwrap(() => _dio.get<Map<String, dynamic>>('/ai/status'));

  Future<Map<String, dynamic>> suggestPrice(Map<String, dynamic> body) =>
      _unwrap(() => _dio.post<Map<String, dynamic>>('/ai/price', data: body));

  Future<Map<String, dynamic>> checkQuality({
    required List<int> bytes,
    required String filename,
    required String mimeType,
    required String crop,
  }) => _unwrap(
    () => _dio.post<Map<String, dynamic>>(
      '/ai/quality',
      data: FormData.fromMap({
        'crop': crop,
        'image': MultipartFile.fromBytes(
          bytes,
          filename: filename,
          contentType: DioMediaType.parse(mimeType),
        ),
      }),
    ),
  );

  Future<Map<String, dynamic>> _unwrap(
    Future<Response<Map<String, dynamic>>> Function() request,
  ) async {
    final data = (await request()).data;
    if (data == null) throw const ApiException(ApiErrorKind.unknown);
    return data;
  }
}
