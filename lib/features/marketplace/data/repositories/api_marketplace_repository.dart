import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/farmer_summary.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_category.dart';
import 'package:farm2fork_mobile/features/marketplace/data/services/marketplace_api_service.dart';
import 'marketplace_repository.dart';

/// Real [MarketplaceRepository] backed by the backend `/products` API.
///
/// The backend [ProductResponseDto] differs from the mobile [Product] model in
/// two ways this adapter reconciles:
///  * `category` is a free-form string on the backend but a 4-value enum on the
///    client. Unknown categories fall back to [ProductCategory.vegetables] (the
///    UI groups under "All" regardless, so this never hides a product).
///  * the listing endpoint returns only `farmerId`, not embedded farmer detail.
///    A minimal [FarmerSummary] is synthesised from the id; rich farmer info
///    awaits a profiles endpoint (tracked separately).
class ApiMarketplaceRepository implements MarketplaceRepository {
  ApiMarketplaceRepository(this._api);

  final MarketplaceApiService _api;

  @override
  Future<List<Product>> getProducts({ProductCategory? category}) async {
    final body = await _api.fetchProducts(category: category?.name);
    return _parseList(body);
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final body = await _api.fetchProducts(search: query);
    return _parseList(body);
  }

  @override
  Future<Product?> getProductById(String id) async {
    try {
      final json = await _api.fetchProductById(id);
      return _fromDto(json);
    } on ApiException catch (e) {
      if (e.kind == ApiErrorKind.notFound) return null;
      rethrow;
    }
  }

  List<Product> _parseList(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(_fromDto)
        .toList(growable: false);
  }

  /// Adapts a backend product DTO into the client [Product] model.
  Product _fromDto(Map<String, dynamic> dto) {
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
