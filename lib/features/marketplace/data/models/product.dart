import 'package:freezed_annotation/freezed_annotation.dart';
import 'product_category.dart';
import 'farmer_summary.dart';

part 'product.freezed.dart';
part 'product.g.dart';

/// Quality grade of the product following agri-standards.
enum QualityGrade {
  @JsonValue('A')
  a,
  @JsonValue('B')
  b,
  @JsonValue('C')
  c,
}

/// Unit values supported by the backend products collection.
enum ProductUnit { kg, ton, dozen, piece, litre }

/// Current listing status of the product.
enum ProductStatus {
  active,
  inactive,
  @JsonValue('sold_out')
  soldOut,
}

@freezed
abstract class Product with _$Product {
  const factory Product({
    @JsonKey(name: '_id') required String id,
    required String farmerId,
    required String name,
    required ProductCategory category,
    required String description,

    /// Price in PKR per unit.
    required double price,
    required double quantity,

    /// Unit enum matching the backend schema.
    required ProductUnit unit,
    @Default([]) List<String> images,
    @Default(QualityGrade.a) QualityGrade qualityGrade,
    String? qrCode,
    String? initialBlockchainRecordId,
    @Default(ProductStatus.active) ProductStatus status,

    /// Embedded farmer info — avoids a second network call in list views.
    required FarmerSummary farmer,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
