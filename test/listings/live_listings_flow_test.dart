// Run via ../farm2fork-backend/scripts/test/mobile-listings-e2e.ts.
// Uses a real local Nest server, signed test JWTs, and disposable MongoDB.
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/core/network/interceptors/error_interceptor.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/features/listings/data/repositories/api_listings_repository.dart';
import 'package:farm2fork_mobile/features/listings/data/services/listings_api_service.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_category.dart';
import 'package:farm2fork_mobile/features/listings/data/models/new_listing.dart';
import 'package:farm2fork_mobile/features/marketplace/data/repositories/api_marketplace_repository.dart';
import 'package:farm2fork_mobile/features/marketplace/data/services/marketplace_api_service.dart';

void main() {
  const url = String.fromEnvironment('LISTINGS_TEST_API');
  const farmerToken = String.fromEnvironment('LISTINGS_TEST_FARMER_TOKEN');
  const otherToken = String.fromEnvironment('LISTINGS_TEST_OTHER_TOKEN');
  const buyerToken = String.fromEnvironment('LISTINGS_TEST_BUYER_TOKEN');
  const farmerId = String.fromEnvironment('LISTINGS_TEST_FARMER_ID');

  test(
    'farmer persists a listing, buyer sees it, ownership and soft delete hold',
    () async {
      Dio client(String token) => Dio(
        BaseOptions(baseUrl: url, headers: {'Authorization': 'Bearer $token'}),
      )..interceptors.add(ErrorInterceptor());
      final owner = client(farmerToken);
      final other = client(otherToken);
      final buyer = client(buyerToken);
      addTearDown(() {
        owner.close();
        other.close();
        buyer.close();
      });
      final listings = ApiListingsRepository(ListingsApiService(owner));
      final foreignListings = ApiListingsRepository(ListingsApiService(other));
      final buyerListings = ApiListingsRepository(ListingsApiService(buyer));
      final marketplace = ApiMarketplaceRepository(
        MarketplaceApiService(buyer),
      );
      final draft = NewListing(
        name: 'E2E Mangoes',
        category: ProductCategory.fruits,
        description: 'Test harvest',
        price: 300,
        quantity: 20,
        unit: ProductUnit.kg,
        qualityGrade: QualityGrade.b,
      );
      final saved = await listings.createListing(farmerId, draft);
      expect(saved.id, matches(RegExp(r'^[a-f0-9]{24}$')));
      expect(saved.farmerId, farmerId);
      expect(saved.qrCode, contains(saved.id));
      // Fresh repository proves this is persisted, not local list mutation.
      final fresh = ApiListingsRepository(ListingsApiService(owner));
      expect((await fresh.getFarmerListings('ignored')).single.id, saved.id);
      expect(
        (await marketplace.searchProducts('E2E Mangoes')).single.id,
        saved.id,
      );
      expect(await foreignListings.getFarmerListings(farmerId), isEmpty);
      final forbidden = throwsA(
        isA<ApiException>().having(
          (e) => e.kind,
          'kind',
          ApiErrorKind.forbidden,
        ),
      );
      await expectLater(
        foreignListings.updateListingStatus(saved.id, ProductStatus.inactive),
        forbidden,
      );
      await expectLater(foreignListings.deleteListing(saved.id), forbidden);
      await expectLater(
        buyerListings.createListing(farmerId, draft),
        forbidden,
      );
      await listings.updateListingStatus(saved.id, ProductStatus.inactive);
      expect(await marketplace.searchProducts('E2E Mangoes'), isEmpty);
      await listings.updateListingStatus(saved.id, ProductStatus.active);
      expect(await marketplace.searchProducts('E2E Mangoes'), hasLength(1));
      await listings.deleteListing(saved.id);
      expect(await marketplace.searchProducts('E2E Mangoes'), isEmpty);
      expect(
        (await fresh.getFarmerListings(farmerId)).single.status,
        ProductStatus.inactive,
      );
    },
    skip: url.isEmpty ? 'Requires the disposable backend E2E harness' : false,
  );
}
