import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';

/// Crops the grading model knows (farm2fork-ai constants.CROP_CLASSES).
enum GradableCrop { wheat, rice, mango, maize, cotton, sugarcane }

enum AiModelStatus { trained, untrained, unavailable }

class AiStatus {
  const AiStatus({required this.available, this.qualityModel});

  final bool available;
  final AiModelStatus? qualityModel;
}

class PriceSuggestion {
  const PriceSuggestion({
    required this.minPrice,
    required this.maxPrice,
    required this.confidence,
    required this.ruleBased,
  });

  /// PKR per unit.
  final double minPrice;
  final double maxPrice;
  final double confidence;

  /// True for the master-context 10.3 rule-based estimate (not market data).
  final bool ruleBased;

  double get midpoint => ((minPrice + maxPrice) / 2).roundToDouble();
}

class QualityCheck {
  const QualityCheck({
    required this.modelGrade,
    required this.suggestedListingGrade,
    required this.confidence,
    required this.cropSupported,
    required this.lowConfidence,
    required this.modelStatus,
  });

  /// Raw model output, A-D.
  final String modelGrade;

  /// Null when the model says D (below any listable grade).
  final QualityGrade? suggestedListingGrade;
  final double confidence;
  final bool cropSupported;
  final bool lowConfidence;
  final AiModelStatus modelStatus;
}

/// Thrown for errors the farmer can act on; [kind] picks the message.
enum AiErrorKind {
  unavailable,
  tooManyRequests,
  noPriceRule,
  invalidPhoto,
  failed,
}

class AiException implements Exception {
  const AiException(this.kind);
  final AiErrorKind kind;
}
