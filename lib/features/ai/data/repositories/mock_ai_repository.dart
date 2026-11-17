import 'package:farm2fork_mobile/features/ai/data/models/ai_models.dart';
import 'package:farm2fork_mobile/features/ai/data/repositories/ai_repository.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_category.dart';

/// Offline stand-in with no verified price observations and untrained grading.
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
    // Offline builds have no verified market observation.
    throw const AiException(AiErrorKind.noPriceRule);
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
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return QualityCheck(
      modelGrade: 'B',
      suggestedListingGrade: null,
      confidence: 0.27,
      cropSupported: true,
      lowConfidence: true,
      modelStatus: AiModelStatus.untrained,
    );
  }
}
