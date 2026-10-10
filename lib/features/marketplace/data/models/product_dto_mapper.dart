import 'package:farm2fork_mobile/features/marketplace/data/models/farmer_summary.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_category.dart';

/// Shared mapping for buyer products and farmer-owned listings.
class ProductDtoMapper {
  const ProductDtoMapper();

  /// Adapts a backend product DTO into the client [Product] model.
  Product fromDto(Map<String, dynamic> dto) {
    final farmerId = (dto['farmerId'] as String?) ?? '';
    return Product(
      id: (dto['id'] as String?) ?? (dto['_id'] as String?) ?? '',
      farmerId: farmerId,
      name: (dto['name'] as String?) ?? '',
      category: _categoryFromString(dto['category'] as String?),
      description: (dto['description'] as String?) ?? '',
      price: _toDouble(dto['price']),
      quantity: _toDouble(dto['quantity']),
      unit: _unitFromString(dto['unit'] as String?),
      images: _toStringList(dto['images']),
      qualityGrade: _gradeFromString(dto['qualityGrade'] as String?),
      qrCode: dto['qrCode'] as String?,
      initialBlockchainRecordId: dto['initialBlockchainRecordId'] as String?,
      status: _statusFromString(dto['status'] as String?),
      farmer: _farmerStub(farmerId),
    );
  }

  /// Placeholder farmer until the listing endpoint embeds farmer detail or a
  /// profiles endpoint is wired. Carries the real id so detail screens can
  /// later fetch the full profile.
  FarmerSummary _farmerStub(String farmerId) => FarmerSummary(
    id: farmerId,
    name: '',
    farmName: '',
    farmLocationAddress: '',
  );

  ProductCategory _categoryFromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'fruits':
        return ProductCategory.fruits;
      case 'grains':
        return ProductCategory.grains;
      case 'dairy':
        return ProductCategory.dairy;
      case 'vegetables':
        return ProductCategory.vegetables;
      default:
        return ProductCategory.vegetables;
    }
  }

  ProductUnit _unitFromString(String? value) {
    switch (value) {
      case 'ton':
        return ProductUnit.ton;
      case 'dozen':
        return ProductUnit.dozen;
      case 'piece':
        return ProductUnit.piece;
      case 'litre':
        return ProductUnit.litre;
      case 'kg':
      default:
        return ProductUnit.kg;
    }
  }

  QualityGrade _gradeFromString(String? value) {
    switch (value) {
      case 'B':
        return QualityGrade.b;
      case 'C':
        return QualityGrade.c;
      case 'A':
      default:
        return QualityGrade.a;
    }
  }

  ProductStatus _statusFromString(String? value) {
    switch (value) {
      case 'inactive':
        return ProductStatus.inactive;
      case 'sold_out':
        return ProductStatus.soldOut;
      case 'active':
      default:
        return ProductStatus.active;
    }
  }

  double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  List<String> _toStringList(Object? value) {
    if (value is List) {
      return value.whereType<String>().toList(growable: false);
    }
    return const [];
  }
}
