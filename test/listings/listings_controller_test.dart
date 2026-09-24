import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/features/auth/data/models/auth_user.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/listings/data/models/new_listing.dart';
import 'package:farm2fork_mobile/features/listings/data/repositories/listings_repository.dart';
import 'package:farm2fork_mobile/features/listings/data/repositories/listings_repository_provider.dart';
import 'package:farm2fork_mobile/features/listings/presentation/providers/listings_controller.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/farmer_summary.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_category.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestAuthController extends AuthController {
  @override
  Future<AuthState> build() async => AuthState(
    status: AuthStatus.authenticated,
    user: const AuthUser(
      id: 'farmer-1',
      email: 'farmer@example.com',
      role: AppUserRole.farmer,
      isVerified: true,
      isActive: true,
    ),
  );
}

Product _product(String id) => Product(
  id: id,
  farmerId: 'farmer-1',
  name: 'Chaunsa Mangoes',
  category: ProductCategory.fruits,
  description: '',
  price: 320,
  quantity: 400,
  unit: ProductUnit.kg,
  images: const [],
  qualityGrade: QualityGrade.a,
  status: ProductStatus.active,
  farmer: FarmerSummary(
    id: 'farmer-1',
    name: '',
    farmName: '',
    farmLocationAddress: '',
  ),
);

class _Repo implements ListingsRepository {
  _Repo({this.failCreate = false});

  final bool failCreate;
  final listings = [_product('p1')];
  NewListing? submitted;

  @override
  Future<List<Product>> getFarmerListings(String farmerId) async => [
    ...listings,
  ];

  @override
  Future<Product> createListing(String farmerId, NewListing listing) async {
    submitted = listing;
    if (failCreate) throw Exception('offline');
    final product = _product('p2');
    listings.insert(0, product);
    return product;
  }

  @override
  Future<Product> updateListingStatus(String id, ProductStatus s) =>
      throw UnimplementedError();

  @override
  Future<void> deleteListing(String productId) => throw UnimplementedError();
}

Future<(ProviderContainer, bool)> _publish(_Repo repo) async {
  final container = ProviderContainer(
    overrides: [
      authControllerProvider.overrideWith(_TestAuthController.new),
      listingsRepositoryProvider.overrideWithValue(repo),
    ],
  );
  await container.read(authControllerProvider.future);
  container.listen(listingsControllerProvider, (_, _) {});
  await container.read(listingsControllerProvider.future);
  final ok = await container
      .read(listingsControllerProvider.notifier)
      .addListing(
        name: 'Chaunsa Mangoes',
        category: ProductCategory.fruits,
        description: '',
        price: 320,
        quantity: 400,
        unit: ProductUnit.kg,
        qualityGrade: QualityGrade.a,
      );
  return (container, ok);
}

void main() {
  test('a published listing refreshes the farmer\'s list', () async {
    final repo = _Repo();
    final (container, ok) = await _publish(repo);
    addTearDown(container.dispose);

    expect(ok, isTrue);
    expect(repo.submitted!.name, 'Chaunsa Mangoes');
    expect(
      container.read(listingsControllerProvider).requireValue.map((p) => p.id),
      ['p2', 'p1'],
    );
  });

  test(
    'a failed publish keeps the existing list instead of an error',
    () async {
      final (container, ok) = await _publish(_Repo(failCreate: true));
      addTearDown(container.dispose);

      expect(ok, isFalse);
      final state = container.read(listingsControllerProvider);
      expect(state.hasError, isFalse);
      expect(state.requireValue.map((p) => p.id), ['p1']);
    },
  );
}
