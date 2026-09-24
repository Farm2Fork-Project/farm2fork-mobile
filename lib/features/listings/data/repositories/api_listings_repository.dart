import 'package:farm2fork_mobile/features/listings/data/models/new_listing.dart';
import 'package:farm2fork_mobile/features/listings/data/repositories/listings_repository.dart';
import 'package:farm2fork_mobile/features/listings/data/services/listings_api_service.dart';
import 'package:farm2fork_mobile/features/marketplace/data/mappers/product_dto_mapper.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';

/// Real [ListingsRepository] backed by the farmer `/products` endpoints.
class ApiListingsRepository implements ListingsRepository {
  ApiListingsRepository(this._api);

  final ListingsApiService _api;

  @override
  Future<List<Product>> getFarmerListings(String farmerId) async {
    final body = await _api.fetchMine();
    final data = body['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(ProductDtoMapper.fromDto)
        .toList(growable: false);
  }

  @override
  Future<Product> createListing(String farmerId, NewListing listing) async {
    final description = listing.description.trim();
    return ProductDtoMapper.fromDto(
      await _api.create({
        'name': listing.name.trim(),
        'category': listing.category.name,
        'description': ?(description.isEmpty ? null : description),
        'price': listing.price,
        'quantity': listing.quantity,
        'unit': ProductDtoMapper.unitToWire(listing.unit),
        'qualityGrade': ProductDtoMapper.gradeToWire(listing.qualityGrade),
      }),
    );
  }

  @override
  Future<Product> updateListingStatus(
    String productId,
    ProductStatus status,
  ) async {
    return ProductDtoMapper.fromDto(
      await _api.update(productId, {
        'status': ProductDtoMapper.statusToWire(status),
      }),
    );
  }

  @override
  Future<void> deleteListing(String productId) => _api.delete(productId);
}
