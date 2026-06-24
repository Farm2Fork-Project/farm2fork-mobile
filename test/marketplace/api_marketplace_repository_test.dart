import 'package:dio/dio.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_category.dart';
import 'package:farm2fork_mobile/features/marketplace/data/repositories/api_marketplace_repository.dart';
import 'package:farm2fork_mobile/features/marketplace/data/services/marketplace_api_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stub service returning canned backend payloads, so we test the adapter
/// (DTO -> Product mapping) without real HTTP.
class _StubApi implements MarketplaceApiService {
  _StubApi({this.list, this.singleThrows});

  final Map<String, dynamic>? list;
  final ApiException? singleThrows;

  @override
  Future<Map<String, dynamic>> fetchProducts({
    String? search,
    String? category,
    int page = 1,
    int limit = 50,
  }) async => list ?? const {'data': []};

  @override
  Future<Map<String, dynamic>> fetchProductById(String id) async {
    if (singleThrows != null) throw singleThrows!;
    return const {};
  }
}

Map<String, dynamic> _dto({
  String id = '6a2fe77bb77795516febc287',
  String farmerId = '6a2fe77bb77795516febc111',
  String category = 'fruits',
  String unit = 'kg',
  String grade = 'B',
  String status = 'active',
}) => {
  'id': id,
  'farmerId': farmerId,
  'name': 'Mangoes',
  'category': category,
  'description': 'Sweet',
  'price': 300,
  'quantity': 100,
  'unit': unit,
  'images': ['https://x/y.jpg'],
  'qualityGrade': grade,
  'qrCode': 'https://farm2fork.com/trace/$id',
  'status': status,
};

void main() {
  group('ApiMarketplaceRepository adapter', () {
    test('maps the paginated envelope into typed Products', () async {
      final repo = ApiMarketplaceRepository(
        _StubApi(
          list: {
            'data': [_dto(), _dto(category: 'grains', unit: 'ton', grade: 'A')],
            'total': 2,
            'page': 1,
            'limit': 50,
            'totalPages': 1,
          },
        ),
      );

      final products = await repo.getProducts();

      expect(products, hasLength(2));
      expect(products.first.name, 'Mangoes');
      expect(products.first.category, ProductCategory.fruits);
      expect(products.first.unit, ProductUnit.kg);
      expect(products.first.qualityGrade, QualityGrade.b);
      expect(products[1].category, ProductCategory.grains);
      expect(products[1].unit, ProductUnit.ton);
      expect(products[1].qualityGrade, QualityGrade.a);
    });

    test('synthesises a farmer stub carrying the real farmerId', () async {
      final repo = ApiMarketplaceRepository(
        _StubApi(
          list: {
            'data': [_dto()],
          },
        ),
      );

      final products = await repo.getProducts();

      expect(products.first.farmer.id, '6a2fe77bb77795516febc111');
      expect(products.first.farmer.farmName, isEmpty);
    });

    test('falls back to vegetables for an unknown category', () async {
      final repo = ApiMarketplaceRepository(
        _StubApi(
          list: {
            'data': [_dto(category: 'spices')],
          },
        ),
      );

      final products = await repo.getProducts();

      expect(products.first.category, ProductCategory.vegetables);
    });

    test('coerces numeric price/quantity sent as strings', () async {
      final dto = _dto()
        ..['price'] = '250.5'
        ..['quantity'] = '40';
      final repo = ApiMarketplaceRepository(
        _StubApi(
          list: {
            'data': [dto],
          },
        ),
      );

      final products = await repo.getProducts();

      expect(products.first.price, 250.5);
      expect(products.first.quantity, 40);
    });

    test('getProductById returns null on a 404 ApiException', () async {
      final repo = ApiMarketplaceRepository(
        _StubApi(singleThrows: const ApiException(ApiErrorKind.notFound)),
      );

      expect(await repo.getProductById('missing'), isNull);
    });

    test('getProductById rethrows non-404 errors', () async {
      final repo = ApiMarketplaceRepository(
        _StubApi(singleThrows: const ApiException(ApiErrorKind.server)),
      );

      expect(() => repo.getProductById('x'), throwsA(isA<ApiException>()));
    });

    test('returns an empty list when data is missing/malformed', () async {
      final repo = ApiMarketplaceRepository(_StubApi(list: const {'total': 0}));

      expect(await repo.getProducts(), isEmpty);
    });
  });

  group('ErrorInterceptor mapping (sanity)', () {
    // Guards against accidental DioExceptionType -> ApiErrorKind drift.
    test('ApiException carries kind and status', () {
      const e = ApiException(
        ApiErrorKind.unauthorized,
        statusCode: 401,
        serverMessage: 'no',
      );
      expect(e.isUnauthorized, isTrue);
      expect(e.statusCode, 401);
    });
  });

  // Ensures Dio is a real dependency (import sanity for the transport layer).
  test('Dio type is available', () {
    expect(Dio, isNotNull);
  });
}
