import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_dto_mapper.dart';
import '../services/listings_api_service.dart';
import 'listings_repository.dart';

class ApiListingsRepository implements ListingsRepository {
  ApiListingsRepository(this._api);
  final ListingsApiService _api;
  static const _mapper = ProductDtoMapper();

  @override
  Future<List<Product>> getFarmerListings(String farmerId) async {
    // Ownership is derived from the authenticated session by /products/mine.
    final products = <Product>[];
    var page = 1;
    int totalPages;
    do {
      final body = await _api.fetchMine(page);
      final data = body['data'];
      if (data is! List) throw const ApiException(ApiErrorKind.unknown);
      products.addAll(data.cast<Map<String, dynamic>>().map(_mapper.fromDto));
      totalPages = (body['totalPages'] as num?)?.toInt() ?? 1;
      page++;
    } while (page <= totalPages);
    return products;
  }

  @override
  Future<Product> createListing(Product product) async => _mapper.fromDto(
    await _api.create({
      'name': product.name,
      'category': product.category.name,
      'description': product.description,
      'price': product.price,
      'quantity': product.quantity,
      'unit': product.unit.name,
      'images': product.images,
      'qualityGrade': product.qualityGrade.name.toUpperCase(),
    }),
  );

  @override
  Future<Product> updateListingStatus(
    String productId,
    ProductStatus status,
  ) async => _mapper.fromDto(
    await _api.updateStatus(
      productId,
      status == ProductStatus.soldOut ? 'sold_out' : status.name,
    ),
  );

  @override
  Future<void> deleteListing(String productId) => _api.delete(productId);
}
