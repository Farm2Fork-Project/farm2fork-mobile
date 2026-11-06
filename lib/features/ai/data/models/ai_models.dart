import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';

/// Crops the grading model knows (farm2fork-ai constants.CROP_CLASSES).
enum GradableCrop {
  wheat,
  rice,
  mango,
  maize,
  other;

  bool get supportsGrading => this != other;
}

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
    required this.unit,
    required this.currency,
    required this.modelVersion,
    required this.commodity,
    required this.observedOn,
    required this.marketScope,
    required this.marketCount,
    required this.source,
    required this.sourceUrl,
    required this.predictionId,
  });
  final double minPrice;
  final double maxPrice;
  final String unit,
      currency,
      modelVersion,
      commodity,
      observedOn,
      marketScope,
      source,
      sourceUrl,
      predictionId;
  final int marketCount;
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
    this.needsReview = true,
    this.reviewReason,
    this.photoSimilarity,
  });

  /// Raw model output, A-D.
  final String modelGrade;

  /// Null when the model says D (below any listable grade).
  final QualityGrade? suggestedListingGrade;
  final double confidence;
  final bool cropSupported;
  final bool lowConfidence;
  final AiModelStatus modelStatus;
  final bool needsReview;
  final String? reviewReason;
  final double? photoSimilarity;
  bool get canApply =>
      !needsReview &&
      reviewReason == null &&
      cropSupported &&
      !lowConfidence &&
      confidence.isFinite &&
      confidence >= 0.7 &&
      confidence <= 1 &&
      modelStatus == AiModelStatus.trained &&
      photoSimilarity != null &&
      photoSimilarity!.isFinite &&
      photoSimilarity! >= -1 &&
      photoSimilarity! <= 1 &&
      const ['A', 'B', 'C'].contains(modelGrade) &&
      suggestedListingGrade != null &&
      suggestedListingGrade!.name.toUpperCase() == modelGrade;
}

/// Thrown for errors the farmer can act on; [kind] picks the message.
enum AiErrorKind {
  unavailable,
  tooManyRequests,
  noPriceRule,
  invalidPhoto,
  unsupportedCrop,
  failed,
}

class AiException implements Exception {
  const AiException(this.kind);
  final AiErrorKind kind;
}
