import 'package:farm2fork_mobile/features/listings/data/models/new_listing.dart';
import 'package:farm2fork_mobile/features/listings/data/repositories/api_listings_repository.dart';
import 'package:farm2fork_mobile/features/listings/data/services/listings_api_service.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_category.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingApi implements ListingsApiService {
  Map<String, dynamic>? created;
  (String, Map<String, dynamic>)? updated;
  String? deleted;

  Map<String, dynamic> _product({String status = 'active'}) => {
    'id': '6a2fe77bb77795516febc287',
    'farmerId': '6a2fe77bb77795516febc111',
    'name': 'Chaunsa Mangoes',
    'category': 'fruits',
    'price': 320,
    'quantity': 400,
    'unit': 'kg',
    'images': <String>[],
    'qualityGrade': 'A',
    'qrCode': 'http://localhost:3001/trace/6a2fe77bb77795516febc287',
    'initialBlockchainRecordId': '6a2fe77bb77795516febc289',
    'status': status,
  };

  @override
  Future<Map<String, dynamic>> fetchMine() async => {
    'data': [_product(), _product(status: 'inactive')],
  };

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    created = body;
    return _product();
  }

  @override
  Future<Map<String, dynamic>> update(
    String productId,
    Map<String, dynamic> body,
  ) async {
    updated = (productId, body);
    return _product(status: body['status'] as String);
  }

  @override
  Future<void> delete(String productId) async => deleted = productId;
}

void main() {
  test('lists the farmer\'s own listings, including inactive ones', () async {
    final listings = await ApiListingsRepository(
      _RecordingApi(),
    ).getFarmerListings('ignored-by-api');
    expect(listings.map((p) => p.status), [
      ProductStatus.active,
      ProductStatus.inactive,
    ]);
    expect(listings.first.initialBlockchainRecordId, isNotNull);
  });

  test('publishes exactly the backend CreateProductDto shape', () async {
    final api = _RecordingApi();
    await ApiListingsRepository(api).createListing(
      'farmer-1',
      const NewListing(
        name: '  Chaunsa Mangoes ',
        category: ProductCategory.fruits,
        description: '',
        price: 320,
        quantity: 400,
        unit: ProductUnit.kg,
        qualityGrade: QualityGrade.a,
      ),
    );
    expect(api.created, {
      'name': 'Chaunsa Mangoes',
      'category': 'fruits',
      'price': 320.0,
      'quantity': 400.0,
      'unit': 'kg',
      'qualityGrade': 'A',
    });
  });

  test('sends status changes and deletes to the product endpoints', () async {
    final api = _RecordingApi();
    final repo = ApiListingsRepository(api);

    final updated = await repo.updateListingStatus(
      '6a2fe77bb77795516febc287',
      ProductStatus.soldOut,
    );
    await repo.deleteListing('6a2fe77bb77795516febc287');

    expect(api.updated!.$1, '6a2fe77bb77795516febc287');
    expect(api.updated!.$2, {'status': 'sold_out'});
    expect(updated.status, ProductStatus.soldOut);
    expect(api.deleted, '6a2fe77bb77795516febc287');
  });
}
