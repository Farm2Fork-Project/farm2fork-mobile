import 'package:dio/dio.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/features/ai/data/models/ai_models.dart';
import 'package:farm2fork_mobile/features/ai/data/repositories/api_ai_repository.dart';
import 'package:farm2fork_mobile/features/ai/data/services/ai_api_service.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_category.dart';
import 'package:flutter_test/flutter_test.dart';

class _Api implements AiApiService {
  _Api({this.response, this.error});

  final Map<String, dynamic>? response;
  final Object? error;
  Map<String, dynamic>? priceBody;
  String? uploadedCrop;

  @override
  Future<Map<String, dynamic>> status() async =>
      response ?? {'available': true, 'qualityModel': 'untrained'};

  @override
  Future<Map<String, dynamic>> suggestPrice(Map<String, dynamic> body) async {
    priceBody = body;
    if (error != null) throw error!;
    return response!;
  }

  @override
  Future<Map<String, dynamic>> checkQuality({
    required List<int> bytes,
    required String filename,
    required String mimeType,
    required String crop,
  }) async {
    uploadedCrop = crop;
    if (error != null) throw error!;
    return response!;
  }
}

DioException _dio(int status) => DioException(
  requestOptions: RequestOptions(),
  error: ApiException(ApiErrorKind.server, statusCode: status),
);

Future<Object?> _priceError(Object error) async {
  try {
    await ApiAiRepository(_Api(error: error)).suggestPrice(
      productName: 'Eggs',
      category: ProductCategory.dairy,
      unit: ProductUnit.dozen,
      grade: QualityGrade.a,
    );
  } catch (e) {
    return e;
  }
  return null;
}

void main() {
  test(
    'sends the backend price contract and reads a rule-based range',
    () async {
      final api = _Api(
        response: {
          'predictedMinPrice': 154,
          'predictedMaxPrice': 352,
          'confidenceScore': 0.45,
          'method': 'rule_based',
        },
      );
      final price = await ApiAiRepository(api).suggestPrice(
        productName: ' Chaunsa Mangoes ',
        category: ProductCategory.fruits,
        unit: ProductUnit.kg,
        grade: QualityGrade.b,
      );

      expect(api.priceBody, {
        'productName': 'Chaunsa Mangoes',
        'category': 'fruits',
        'unit': 'kg',
        'qualityGrade': 'B',
      });
      expect(price.minPrice, 154);
      expect(price.midpoint, 253);
      expect(price.ruleBased, isTrue);
    },
  );

  test(
    'maps a D grade to no listing grade and keeps the model status',
    () async {
      final api = _Api(
        response: {
          'modelGrade': 'D',
          'suggestedListingGrade': null,
          'confidenceScore': 0.7,
          'cropSupported': true,
          'lowConfidence': false,
          'modelStatus': 'trained',
        },
      );
      final result = await ApiAiRepository(api).checkQuality(
        bytes: const [1, 2, 3],
        filename: 'rice.jpg',
        mimeType: 'image/jpeg',
        crop: GradableCrop.rice,
      );

      expect(api.uploadedCrop, 'rice');
      expect(result.modelGrade, 'D');
      expect(result.suggestedListingGrade, isNull);
      expect(result.modelStatus, AiModelStatus.trained);
    },
  );

  test('turns transport errors into actionable kinds', () async {
    expect(
      ((await _priceError(_dio(503))) as AiException).kind,
      AiErrorKind.unavailable,
    );
    expect(
      ((await _priceError(_dio(429))) as AiException).kind,
      AiErrorKind.tooManyRequests,
    );
    expect(
      ((await _priceError(_dio(422))) as AiException).kind,
      AiErrorKind.noPriceRule,
    );
    expect(
      ((await _priceError(const ApiException(ApiErrorKind.network)))
              as AiException)
          .kind,
      AiErrorKind.unavailable,
    );
  });

  test('reports the service as unavailable instead of throwing', () async {
    final status = await ApiAiRepository(_ThrowingStatusApi()).status();
    expect(status.available, isFalse);
  });
}

class _ThrowingStatusApi extends _Api {
  @override
  Future<Map<String, dynamic>> status() async =>
      throw const ApiException(ApiErrorKind.network);
}
