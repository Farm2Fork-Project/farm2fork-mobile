import 'package:dio/dio.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/features/ai/data/models/ai_models.dart';
import 'package:farm2fork_mobile/features/ai/data/repositories/api_ai_repository.dart';
import 'package:farm2fork_mobile/features/ai/data/repositories/mock_ai_repository.dart';
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
  test('missing review flag cannot recommend a listing grade', () async {
    final result =
        await ApiAiRepository(
          _Api(
            response: {
              'modelGrade': 'A',
              'suggestedListingGrade': 'A',
              'confidenceScore': 0.99,
              'cropSupported': true,
              'lowConfidence': false,
              'modelStatus': 'trained',
            },
          ),
        ).checkQuality(
          bytes: [1],
          filename: 'rice.jpg',
          mimeType: 'image/jpeg',
          crop: GradableCrop.rice,
        );
    expect(result.suggestedListingGrade, isNull);
  });

  test('quality safety gates override an optimistic listing grade', () async {
    final safe = <String, dynamic>{
      'modelGrade': 'A',
      'suggestedListingGrade': 'A',
      'confidenceScore': .9,
      'cropSupported': true,
      'lowConfidence': false,
      'modelStatus': 'trained',
      'needsReview': false,
      'reviewReason': null,
      'photoSimilarity': .9,
      'crop': 'rice',
    };
    for (final patch in <Map<String, dynamic>>[
      {'needsReview': true},
      {'crop': 'mango'},
      {'crop': null},
      {'confidenceScore': double.infinity},
      {'confidenceScore': 1.01},
      {'suggestedListingGrade': 'B'},
      {'confidenceScore': .69},
      {'modelStatus': 'untrained'},
      {'cropSupported': false},
      {'lowConfidence': true},
      {'modelGrade': 'D'},
      {'photoSimilarity': null},
      {'photoSimilarity': double.nan},
      {'reviewReason': 'unfamiliar_photo'},
    ]) {
      final result = await ApiAiRepository(_Api(response: {...safe, ...patch}))
          .checkQuality(
            bytes: [1],
            filename: 'rice.jpg',
            mimeType: 'image/jpeg',
            crop: GradableCrop.rice,
          );
      expect(result.canApply, isFalse, reason: '$patch');
      expect(result.suggestedListingGrade, isNull, reason: '$patch');
    }
    final result = await ApiAiRepository(_Api(response: safe)).checkQuality(
      bytes: [1],
      filename: 'rice.jpg',
      mimeType: 'image/jpeg',
      crop: GradableCrop.rice,
    );
    expect(result.canApply, isTrue);
  });

  test(
    'direct quality models reject invalid confidence and mismatching grade',
    () {
      for (final confidence in [double.infinity, double.nan, 1.01]) {
        expect(
          QualityCheck(
            modelGrade: 'A',
            suggestedListingGrade: QualityGrade.a,
            confidence: confidence,
            cropSupported: true,
            lowConfidence: false,
            modelStatus: AiModelStatus.trained,
            needsReview: false,
            photoSimilarity: .9,
          ).canApply,
          isFalse,
        );
      }
      expect(
        const QualityCheck(
          modelGrade: 'A',
          suggestedListingGrade: QualityGrade.b,
          confidence: .9,
          cropSupported: true,
          lowConfidence: false,
          modelStatus: AiModelStatus.trained,
          needsReview: false,
          photoSimilarity: .9,
        ).canApply,
        isFalse,
      );
    },
  );
  test('future official price observations are rejected', () async {
    await expectLater(
      ApiAiRepository(
        _Api(
          response: {
            'predictedMinPrice': 10,
            'predictedMaxPrice': 20,
            'method': 'official_wholesale',
            'currency': 'PKR',
            'unit': 'kg',
            'modelVersion': 'official-v1',
            'commodity': 'Mango',
            'observedOn': '2999-01-01',
            'marketScope': 'Punjab',
            'marketCount': 1,
            'source': 'AMIS',
            'sourceUrl': 'http://www.amis.pk',
            'predictionId': 'test-id',
          },
        ),
      ).suggestPrice(
        productName: 'Mango',
        category: ProductCategory.fruits,
        unit: ProductUnit.kg,
        grade: QualityGrade.a,
      ),
      throwsA(isA<AiException>()),
    );
  });

  test('legacy price ranges without provenance are rejected', () async {
    await expectLater(
      ApiAiRepository(
        _Api(
          response: {
            'predictedMinPrice': 10,
            'predictedMaxPrice': 20,
            'method': 'rule_based',
          },
        ),
      ).suggestPrice(
        productName: 'Mango',
        category: ProductCategory.fruits,
        unit: ProductUnit.kg,
        grade: QualityGrade.a,
      ),
      throwsA(isA<AiException>()),
    );
  });

  test(
    'sends the backend price contract and reads a provenanced wholesale range',
    () async {
      final api = _Api(
        response: {
          'predictedMinPrice': 154,
          'predictedMaxPrice': 352,
          'method': 'official_wholesale',
          'currency': 'PKR',
          'unit': 'kg',
          'modelVersion': 'official-v1',
          'commodity': 'Mango',
          'observedOn': '2026-10-01',
          'marketScope': 'Punjab',
          'marketCount': 2,
          'source': 'AMIS',
          'sourceUrl': 'http://www.amis.pk',
          'predictionId': 'test-id',
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
      expect(price.observedOn, '2026-10-01');
      expect(price.source, 'AMIS');
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

  test('Other rejects grading without calling the API', () async {
    final api = _Api();
    await expectLater(
      ApiAiRepository(api).checkQuality(
        bytes: [1],
        filename: 'other.jpg',
        mimeType: 'image/jpeg',
        crop: GradableCrop.other,
      ),
      throwsA(
        isA<AiException>().having(
          (e) => e.kind,
          'kind',
          AiErrorKind.unsupportedCrop,
        ),
      ),
    );
    expect(api.uploadedCrop, isNull);
  });

  test('mock repository also rejects Other', () async {
    await expectLater(
      MockAiRepository().checkQuality(
        bytes: [1],
        filename: 'other.jpg',
        mimeType: 'image/jpeg',
        crop: GradableCrop.other,
      ),
      throwsA(
        isA<AiException>().having(
          (e) => e.kind,
          'kind',
          AiErrorKind.unsupportedCrop,
        ),
      ),
    );
  });

  test('transport rejects unsupported crops before a request', () {
    final dio = Dio();
    var requests = 0;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests++;
          handler.reject(DioException(requestOptions: options));
        },
      ),
    );
    for (final crop in ['other', 'cotton', 'sugarcane', 'banana', '']) {
      expect(
        () => AiApiService(dio).checkQuality(
          bytes: [1],
          filename: 'crop.jpg',
          mimeType: 'image/jpeg',
          crop: crop,
        ),
        throwsA(
          isA<AiException>().having(
            (e) => e.kind,
            'kind',
            AiErrorKind.unsupportedCrop,
          ),
        ),
      );
    }
    expect(requests, 0);
  });

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
