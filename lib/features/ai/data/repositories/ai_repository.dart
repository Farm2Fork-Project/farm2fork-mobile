import 'package:farm2fork_mobile/features/ai/data/models/ai_models.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_category.dart';

abstract class AiRepository {
  Future<AiStatus> status();

  Future<PriceSuggestion> suggestPrice({
    required String productName,
    required ProductCategory category,
    required ProductUnit unit,
    required QualityGrade grade,
  });

  Future<QualityCheck> checkQuality({
    required List<int> bytes,
    required String filename,
    required String mimeType,
    required GradableCrop crop,
  });
}
