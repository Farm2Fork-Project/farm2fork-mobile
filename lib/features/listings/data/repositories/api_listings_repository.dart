import 'dart:convert';
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
    final products = <Product>[];
    var page = 1;
    int totalPages;
    do {
      final body = await _api.fetchMine(page);
      final data = body['data'];
      if (data is! List) {
        throw const FormatException('Invalid listing response');
      }
      products.addAll(
        data.cast<Map<String, dynamic>>().map(ProductDtoMapper.fromDto),
      );
      totalPages = (body['totalPages'] as num?)?.toInt() ?? 1;
      page++;
    } while (page <= totalPages);
    return products;
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
        if (listing.images.isNotEmpty) 'images': listing.images,
      }),
    );
  }

  @override
  Future<List<String>> uploadPhotos(List<ListingPhoto> photos) =>
      _api.uploadPhotos(photos);

  @override
  Future<Product> updateListing(String productId, NewListing listing) async {
    final values = <String, dynamic>{
      'name': listing.name.trim(),
      'category': listing.category.name,
      'description': listing.description.trim(),
      'price': listing.price,
      'quantity': listing.quantity,
      'unit': ProductDtoMapper.unitToWire(listing.unit),
      'qualityGrade': ProductDtoMapper.gradeToWire(listing.qualityGrade),
      'images': listing.images,
      if (listing.status != null)
        'status': ProductDtoMapper.statusToWire(listing.status!),
    };
    final original = listing.original;
    if (original != null) {
      final before = <String, dynamic>{
        'name': original.name,
        'category': original.category.name,
        'description': original.description,
        'price': original.price,
        'quantity': original.quantity,
        'unit': ProductDtoMapper.unitToWire(original.unit),
        'qualityGrade': ProductDtoMapper.gradeToWire(original.qualityGrade),
        'images': original.images,
        'status': ProductDtoMapper.statusToWire(original.status),
      };
      if ((listing.status == ProductStatus.active) ==
          (original.status == ProductStatus.active)) {
        values.remove('status');
      }
      values.removeWhere(
        (key, value) => jsonEncode(value) == jsonEncode(before[key]),
      );
      if (values.containsKey('quantity')) {
        values['expectedQuantity'] = original.quantity;
      }
    }
    return ProductDtoMapper.fromDto(await _api.update(productId, values));
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
