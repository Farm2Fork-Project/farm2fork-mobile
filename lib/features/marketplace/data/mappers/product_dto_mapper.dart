import 'package:farm2fork_mobile/features/marketplace/data/models/farmer_summary.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_category.dart';

/// Maps the backend `ProductResponseDto` to the client [Product] model and
/// back, shared by every repository that reads or writes `/products`.
///
/// The backend DTO differs from the mobile model in two ways reconciled here:
///  * `category` is a free-form string on the backend but a 4-value enum on the
///    client. Unknown categories fall back to [ProductCategory.vegetables] (the
///    UI groups under "All" regardless, so this never hides a product).
///  * the backend embeds only public farm identity (`farmer`: farm name, city,
///    province) - no personal name, rating or sales, so those stay empty/zero
///    and the UI hides them.
abstract final class ProductDtoMapper {
  /// Adapts a backend product DTO into the client [Product] model.
  static Product fromDto(Map<String, dynamic> dto) {
    final farmerId = (dto['farmerId'] as String?) ?? '';
    return Product(
      id: (dto['id'] as String?) ?? (dto['_id'] as String?) ?? '',
      farmerId: farmerId,
      name: (dto['name'] as String?) ?? '',
      category: categoryFromWire(dto['category'] as String?),
      description: (dto['description'] as String?) ?? '',
      price: _toDouble(dto['price']),
      quantity: _toDouble(dto['quantity']),
      unit: unitFromWire(dto['unit'] as String?),
      images: _toStringList(dto['images']),
      qualityGrade: gradeFromWire(dto['qualityGrade'] as String?),
      qrCode: dto['qrCode'] as String?,
      initialBlockchainRecordId: dto['initialBlockchainRecordId'] as String?,
      status: statusFromWire(dto['status'] as String?),
      originLedgerStatus: dto['originLedgerStatus'] as String?,
      farmer: _farmer(farmerId, dto['farmer']),
    );
  }

  /// Public farm identity embedded by the backend; an empty summary (never
  /// invented values) when the farmer has no profile.
  static FarmerSummary _farmer(String farmerId, Object? farmer) {
    // The backend embeds only public farm identity (farm name, city,
    // province) - never a personal name, rating or sales it doesn't have.
    if (farmer is! Map) {
      return FarmerSummary(
        id: farmerId,
        name: '',
        farmName: '',
        farmLocationAddress: '',
      );
    }
    final place = [
      farmer['city'],
      farmer['province'],
    ].whereType<String>().where((part) => part.isNotEmpty).join(', ');
    return FarmerSummary(
      id: farmerId,
      name: '',
      farmName: (farmer['farmName'] as String?) ?? '',
      farmLocationAddress: place,
    );
  }

  static ProductCategory categoryFromWire(String? value) {
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

  static ProductUnit unitFromWire(String? value) {
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

  static QualityGrade gradeFromWire(String? value) {
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

  static ProductStatus statusFromWire(String? value) {
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

  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static List<String> _toStringList(Object? value) {
    if (value is List) {
      return value.whereType<String>().toList(growable: false);
    }
    return const [];
  }

  /// Wire value the backend expects for a listing status.
  static String statusToWire(ProductStatus status) => switch (status) {
    ProductStatus.active => 'active',
    ProductStatus.inactive => 'inactive',
    ProductStatus.soldOut => 'sold_out',
  };

  /// Wire value the backend expects for a unit.
  static String unitToWire(ProductUnit unit) => unit.name;

  /// Wire value the backend expects for a quality grade.
  static String gradeToWire(QualityGrade grade) => grade.name.toUpperCase();
}
