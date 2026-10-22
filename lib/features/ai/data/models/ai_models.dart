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

/// Observed AMIS Punjab wholesale mandi prices for a dated trading day.
class PriceSuggestion {
  const PriceSuggestion({
    required this.minPrice,
    required this.maxPrice,
    required this.commodity,
    required this.observedOn,
    required this.marketScope,
    required this.marketCount,
  });

  /// PKR per unit.
  final double minPrice;
  final double maxPrice;

  /// Official commodity name(s) the range comes from.
  final String commodity;

  /// Mandi trading day.
  final DateTime observedOn;

  /// The farmer's own market, or "Punjab" for the middle half of markets.
  final String marketScope;
  final int marketCount;

  bool get punjabWide => marketScope == 'Punjab';

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
    this.reviewReason,
  });

  /// Raw model output, A-D; null when the photo needs review.
  final String? modelGrade;

  /// Null when the model says D (below any listable grade).
  final QualityGrade? suggestedListingGrade;
  final double confidence;
  final bool cropSupported;
  final bool lowConfidence;
  final AiModelStatus modelStatus;

  /// Set when no grade may be shown: the farmer retakes or grades manually.
  final QualityReviewReason? reviewReason;

  bool get needsReview => reviewReason != null || modelGrade == null;
}

enum QualityReviewReason { lowConfidence, unfamiliarPhoto, photoCheckUnavailable }

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
