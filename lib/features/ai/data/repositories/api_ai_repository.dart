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
    return PriceSuggestion(
      minPrice: _number(dto['predictedMinPrice']),
      maxPrice: _number(dto['predictedMaxPrice']),
      confidence: _number(dto['confidenceScore']),
      ruleBased: dto['method'] == 'rule_based',
    );
  }

  @override
  Future<QualityCheck> checkQuality({
    required List<int> bytes,
    required String filename,
    required String mimeType,
    required GradableCrop crop,
  }) async {
    final dto = await _guard(
      () => _api.checkQuality(
        bytes: bytes,
        filename: filename,
        mimeType: mimeType,
        crop: crop.name,
      ),
      on422: AiErrorKind.invalidPhoto,
    );
    final suggested = dto['suggestedListingGrade'] as String?;
    return QualityCheck(
      modelGrade: (dto['modelGrade'] as String?) ?? '?',
      suggestedListingGrade: suggested == null
          ? null
          : ProductDtoMapper.gradeFromWire(suggested),
      confidence: _number(dto['confidenceScore']),
      cropSupported: dto['cropSupported'] != false,
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
