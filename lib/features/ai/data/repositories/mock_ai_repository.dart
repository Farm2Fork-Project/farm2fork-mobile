import 'package:farm2fork_mobile/features/ai/data/models/ai_models.dart';
import 'package:farm2fork_mobile/features/ai/data/repositories/ai_repository.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_category.dart';

/// Offline stand-in for USE_MOCKS builds. Mirrors the real service's honesty:
/// rule-based prices and an untrained (preview) grading model.
class MockAiRepository implements AiRepository {
  @override
  Future<AiStatus> status() async =>
      const AiStatus(available: true, qualityModel: AiModelStatus.untrained);

  @override
  Future<PriceSuggestion> suggestPrice({
    required String productName,
    required ProductCategory category,
    required ProductUnit unit,
    required QualityGrade grade,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (unit == ProductUnit.dozen || unit == ProductUnit.piece) {
      throw const AiException(AiErrorKind.noPriceRule);
    }
    final factor = unit == ProductUnit.ton ? 1000 : 1;
    return PriceSuggestion(
      minPrice: 100.0 * factor,
      maxPrice: 180.0 * factor,
      confidence: 0.35,
      ruleBased: true,
    );
  }

  @override
  Future<QualityCheck> checkQuality({
    required List<int> bytes,
    required String filename,
    required String mimeType,
    required GradableCrop crop,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return QualityCheck(
      modelGrade: 'B',
      suggestedListingGrade: QualityGrade.b,
      confidence: 0.27,
      cropSupported:
          crop != GradableCrop.cotton && crop != GradableCrop.sugarcane,
      lowConfidence: true,
      modelStatus: AiModelStatus.untrained,
    );
  }
}
