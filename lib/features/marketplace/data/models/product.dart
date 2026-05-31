import 'package:freezed_annotation/freezed_annotation.dart';
import 'product_category.dart';
import 'farmer_summary.dart';

part 'product.freezed.dart';
part 'product.g.dart';

/// Quality grade of the product following agri-standards.
enum QualityGrade { aPlus, a, b, c }

/// Current listing status of the product.
enum ProductStatus { available, outOfStock, comingSoon }

@freezed
abstract class Product with _$Product {
  const factory Product({
    required String id,
    required String farmerId,
    required String name,
    required ProductCategory category,
    required String description,

    /// Price in PKR per unit.
    required double pricePerUnit,
    required double availableQuantity,

    /// Unit label e.g. "kg", "dozen", "litre".
    required String unit,
    @Default([]) List<String> imageUrls,
    @Default(QualityGrade.a) QualityGrade qualityGrade,
    @Default(ProductStatus.available) ProductStatus status,

    /// Embedded farmer info — avoids a second network call in list views.
    required FarmerSummary farmer,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
}
