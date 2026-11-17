import 'package:dio/dio.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/features/ai/data/models/ai_models.dart';
import 'package:farm2fork_mobile/features/ai/data/repositories/ai_repository.dart';
import 'package:farm2fork_mobile/features/ai/data/services/ai_api_service.dart';
import 'package:farm2fork_mobile/features/marketplace/data/mappers/product_dto_mapper.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_category.dart';

class ApiAiRepository implements AiRepository {
  ApiAiRepository(this._api);

  final AiApiService _api;

  @override
  Future<AiStatus> status() async {
    try {
      final dto = await _api.status();
      return AiStatus(
        available: dto['available'] == true,
        qualityModel: _modelStatus(dto['qualityModel']),
      );
    } catch (_) {
      return const AiStatus(available: false);
    }
  }

  @override
  Future<PriceSuggestion> suggestPrice({
    required String productName,
    required ProductCategory category,
    required ProductUnit unit,
    required QualityGrade grade,
  }) async {
    final dto = await _guard(
      () => _api.suggestPrice({
        'productName': productName.trim(),
        'category': category.name,
        'unit': ProductDtoMapper.unitToWire(unit),
        'qualityGrade': ProductDtoMapper.gradeToWire(grade),
      }),
      on422: AiErrorKind.noPriceRule,
    );
    String requiredText(String key) {
      final value = dto[key];
      if (value is! String || value.trim().isEmpty) {
        throw const AiException(AiErrorKind.failed);
      }
      return value;
    }

    final min = _number(dto['predictedMinPrice']);
    final max = _number(dto['predictedMaxPrice']);
    final date = requiredText('observedOn');
    final parsedDate = DateTime.tryParse(date);
    final count = dto['marketCount'];
    final sourceUrl = requiredText('sourceUrl');
    final uri = Uri.tryParse(sourceUrl);
    if (dto['method'] != 'official_wholesale' ||
        dto['currency'] != 'PKR' ||
        dto['unit'] != ProductDtoMapper.unitToWire(unit) ||
        !min.isFinite ||
        !max.isFinite ||
        min <= 0 ||
        max < min ||
        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date) ||
        parsedDate == null ||
        parsedDate.toIso8601String().substring(0, 10) != date ||
        date.compareTo(
              DateTime.now().toUtc().toIso8601String().substring(0, 10),
            ) >
            0 ||
        count is! int ||
        count < 1 ||
        uri == null ||
        !const ['http', 'https'].contains(uri.scheme) ||
        uri.userInfo.isNotEmpty ||
        uri.host.isEmpty) {
      throw const AiException(AiErrorKind.failed);
    }
    return PriceSuggestion(
      minPrice: min,
      maxPrice: max,
      unit: requiredText('unit'),
      currency: requiredText('currency'),
      modelVersion: requiredText('modelVersion'),
      commodity: requiredText('commodity'),
      observedOn: date,
      marketScope: requiredText('marketScope'),
      marketCount: count,
      source: requiredText('source'),
      sourceUrl: sourceUrl,
      predictionId: requiredText('predictionId'),
    );
  }

  @override
  Future<QualityCheck> checkQuality({
    required List<int> bytes,
    required String filename,
    required String mimeType,
    required GradableCrop crop,
  }) async {
    if (!crop.supportsGrading) {
      throw const AiException(AiErrorKind.unsupportedCrop);
    }
    final dto = await _guard(
      () => _api.checkQuality(
        bytes: bytes,
        filename: filename,
        mimeType: mimeType,
        crop: crop.name,
      ),
      on422: AiErrorKind.invalidPhoto,
    );
    final suggested = dto['suggestedListingGrade'];
    final similarity = dto['photoSimilarity'];
    final confidence = _number(dto['confidenceScore']);
    final safe =
        dto.containsKey('reviewReason') &&
        dto['reviewReason'] == null &&
        similarity is num &&
        similarity.isFinite &&
        similarity >= -1 &&
        similarity <= 1 &&
        dto['needsReview'] == false &&
        dto['cropSupported'] == true &&
        dto['crop'] == crop.name &&
        dto['lowConfidence'] == false &&
        confidence.isFinite &&
        confidence >= 0.7 &&
        confidence <= 1 &&
        dto['modelStatus'] == 'trained' &&
        const ['A', 'B', 'C'].contains(dto['modelGrade']) &&
        const ['A', 'B', 'C'].contains(suggested) &&
        suggested == dto['modelGrade'];

    return QualityCheck(
      modelGrade: (dto['modelGrade'] as String?) ?? '?',
      suggestedListingGrade: !safe
          ? null
          : ProductDtoMapper.gradeFromWire(suggested as String),
      confidence: _number(dto['confidenceScore']),
      cropSupported: dto['cropSupported'] == true,
      needsReview: !safe,
      reviewReason: dto['reviewReason'] as String?,
      photoSimilarity: dto['photoSimilarity'] is num
          ? (dto['photoSimilarity'] as num).toDouble()
          : null,
      lowConfidence: dto['lowConfidence'] == true,
      modelStatus: _modelStatus(dto['modelStatus']) ?? AiModelStatus.untrained,
    );
  }

  /// Maps transport errors to what the farmer can act on.
  Future<Map<String, dynamic>> _guard(
    Future<Map<String, dynamic>> Function() call, {
    required AiErrorKind on422,
  }) async {
    try {
      return await call();
    } catch (error) {
      final api = error is ApiException
          ? error
          : error is DioException && error.error is ApiException
          ? error.error as ApiException
          : null;
      final status = api?.statusCode;
      if (status == 429) throw const AiException(AiErrorKind.tooManyRequests);
      if (status == 422) throw AiException(on422);
      if (status == 400 || status == 413 || status == 415) {
        throw const AiException(AiErrorKind.invalidPhoto);
      }
      if (status == 503 ||
          api?.kind == ApiErrorKind.network ||
          api?.kind == ApiErrorKind.timeout) {
        throw const AiException(AiErrorKind.unavailable);
      }
      throw const AiException(AiErrorKind.failed);
    }
  }

  static AiModelStatus? _modelStatus(Object? value) => switch (value) {
    'trained' => AiModelStatus.trained,
    'untrained' => AiModelStatus.untrained,
    'unavailable' => AiModelStatus.unavailable,
    _ => null,
  };

  static double _number(Object? value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
}
