import 'package:dio/dio.dart';
import 'package:farm2fork_mobile/features/ai/data/models/ai_models.dart';
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
  }) {
    if (!GradableCrop.values.any(
      (value) => value.supportsGrading && value.name == crop,
    )) {
      throw const AiException(AiErrorKind.unsupportedCrop);
    }
    return _unwrap(
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
  }

  Future<Map<String, dynamic>> _unwrap(
    Future<Response<Map<String, dynamic>>> Function() request,
  ) async {
    final data = (await request()).data;
    if (data == null) throw const ApiException(ApiErrorKind.unknown);
    return data;
  }
}
