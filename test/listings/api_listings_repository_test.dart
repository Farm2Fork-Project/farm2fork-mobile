import 'package:dio/dio.dart';
import 'package:farm2fork_mobile/features/marketplace/data/services/marketplace_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/features/listings/data/repositories/api_listings_repository.dart';
import 'package:farm2fork_mobile/features/listings/data/services/listings_api_service.dart';
import 'package:farm2fork_mobile/features/listings/data/repositories/mock_listings_repository.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_category.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/farmer_summary.dart';

final product = Product(
  id: 'local-id',
  farmerId: 'farmer',
  name: 'Mangoes',
  category: ProductCategory.fruits,
  description: 'Fresh',
  price: 300,
  quantity: 20,
  unit: ProductUnit.kg,
  qualityGrade: QualityGrade.b,
  farmer: const FarmerSummary(
    id: 'farmer',
    name: '',
    farmName: '',
    farmLocationAddress: '',
  ),
);

Map<String, dynamic> dto(String id, {String status = 'active'}) => {
  'id': id,
  'farmerId': 'farmer',
  'name': 'Mangoes',
  'category': 'fruits',
  'description': 'Fresh',
  'price': 300,
  'quantity': 20,
  'unit': 'kg',
  'qualityGrade': 'B',
  'status': status,
  'qrCode': '/trace/$id',
};

void main() {
  late Dio dio;
  late ApiListingsRepository repository;
  late List<RequestOptions> requests;
  setUp(() {
    dio = Dio();
    requests = [];
    repository = ApiListingsRepository(ListingsApiService(dio));
  });
  tearDown(() => dio.close());

  test(
    'explicit mock mode assigns usable distinct listing identities',
    () async {
      final mock = MockListingsRepository();
      final first = await mock.createListing(product.copyWith(id: ''));
      final second = await mock.createListing(product.copyWith(id: ''));
      addTearDown(() async {
        await mock.deleteListing(first.id);
        await mock.deleteListing(second.id);
      });
      expect(first.id, isNotEmpty);
      expect(second.id, isNot(first.id));
    },
  );

  test(
    'loads all own pages without trusting a caller supplied farmer id',
    () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            requests.add(request);
            expect(request.path, '/products/mine');
            expect(request.queryParameters.containsKey('farmerId'), isFalse);
            final page = request.queryParameters['page'] as int;
            handler.resolve(
              Response(
                requestOptions: request,
                data: {
                  'data': [
                    dto('p$page', status: page == 1 ? 'active' : 'inactive'),
                  ],
                  'totalPages': 2,
                },
              ),
            );
          },
        ),
      );
      final results = await repository.getFarmerListings('untrusted-id');
      expect(results.map((p) => p.id), ['p1', 'p2']);
      expect(results.last.status, ProductStatus.inactive);
      expect(results.first.farmer.name, isEmpty);
      expect(requests, hasLength(2));
    },
  );

  test(
    'create sends only writable fields and returns server identity and QR',
    () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            expect(request.method, 'POST');
            expect(request.path, '/products');
            expect(request.data, {
              'name': 'Mangoes',
              'category': 'fruits',
              'description': 'Fresh',
              'price': 300.0,
              'quantity': 20.0,
              'unit': 'kg',
              'images': <String>[],
              'qualityGrade': 'B',
            });
            handler.resolve(
              Response(requestOptions: request, data: dto('server-id')),
            );
          },
        ),
      );
      final saved = await repository.createListing(product);
      expect(saved.id, 'server-id');
      expect(saved.qrCode, '/trace/server-id');
    },
  );

  test('status change and soft delete use backend endpoints', () async {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          requests.add(request);
          expect(request.path, '/products/server-id');
          if (request.method == 'PATCH') {
            expect(request.data, {'status': 'sold_out'});
            handler.resolve(
              Response(
                requestOptions: request,
                data: dto('server-id', status: 'sold_out'),
              ),
            );
          } else {
            expect(request.method, 'DELETE');
            handler.resolve(
              Response(requestOptions: request, data: {'deleted': true}),
            );
          }
        },
      ),
    );
    expect(
      (await repository.updateListingStatus(
        'server-id',
        ProductStatus.soldOut,
      )).status,
      ProductStatus.soldOut,
    );
    await repository.deleteListing('server-id');
    expect(requests, hasLength(2));
  });

  test('buyer marketplace excludes inactive and sold-out listings', () async {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          expect(request.queryParameters['status'], 'active');
          handler.resolve(
            Response(requestOptions: request, data: {'data': []}),
          );
        },
      ),
    );
    await MarketplaceApiService(dio).fetchProducts();
  });

  test('unwraps network errors for localized UI handling', () async {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          handler.reject(
            DioException(
              requestOptions: request,
              error: const ApiException(
                ApiErrorKind.forbidden,
                statusCode: 403,
              ),
            ),
          );
        },
      ),
    );
    await expectLater(
      repository.createListing(product),
      throwsA(
        isA<ApiException>().having(
          (e) => e.kind,
          'kind',
          ApiErrorKind.forbidden,
        ),
      ),
    );
  });
}
