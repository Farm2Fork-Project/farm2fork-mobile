import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/features/auth/data/models/auth_user.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/listings/data/repositories/listings_repository.dart';
import 'package:farm2fork_mobile/features/listings/data/repositories/listings_repository_provider.dart';
import 'package:farm2fork_mobile/features/listings/presentation/providers/listings_controller.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_category.dart';

class FarmerAuth extends AuthController {
  @override
  Future<AuthState> build() async => const AuthState(
    status: AuthStatus.authenticated,
    user: AuthUser(
      id: 'farmer-id',
      email: 'farmer@example.test',
      role: AppUserRole.farmer,
      isVerified: true,
      isActive: true,
    ),
  );
}

class RecordingListings implements ListingsRepository {
  Product? created;
  bool fail = false;
  int creates = 0;
  @override
  Future<List<Product>> getFarmerListings(String farmerId) async =>
      created == null ? [] : [created!];
  @override
  Future<Product> createListing(Product product) async {
    creates++;
    if (fail) throw const ApiException(ApiErrorKind.network);
    return created = product.copyWith(
      id: 'server-id',
      qrCode: '/trace/server-id',
    );
  }

  @override
  Future<void> deleteListing(String id) async {
    created = null;
  }

  @override
  Future<Product> updateListingStatus(String id, ProductStatus status) async =>
      created = created!.copyWith(status: status);
}

void main() {
  late ProviderContainer container;
  late RecordingListings repository;
  setUp(() async {
    repository = RecordingListings();
    container = ProviderContainer(
      overrides: [
        authControllerProvider.overrideWith(FarmerAuth.new),
        listingsRepositoryProvider.overrideWithValue(repository),
      ],
    );
    await container.read(authControllerProvider.future);
    await container.read(listingsControllerProvider.future);
  });
  tearDown(() => container.dispose());

  Future<bool> create() => container
      .read(listingsControllerProvider.notifier)
      .addListing(
        name: 'Mangoes',
        category: ProductCategory.fruits,
        description: 'Fresh',
        price: 100,
        quantity: 20,
        unit: ProductUnit.kg,
        qualityGrade: QualityGrade.b,
      );

  test(
    'creation succeeds with server identity and no fabricated profile',
    () async {
      expect(await create(), isTrue);
      final result = container
          .read(listingsControllerProvider)
          .requireValue
          .single;
      expect(result.id, 'server-id');
      expect(result.farmer.name, isEmpty);
      expect(result.farmer.farmName, isEmpty);
      expect(result.farmer.totalSales, 0);
    },
  );

  test('failed save reports failure and can be retried', () async {
    repository.fail = true;
    expect(await create(), isFalse);
    expect(container.read(listingsControllerProvider).hasError, isTrue);
    repository.fail = false;
    expect(await create(), isTrue);
    expect(repository.creates, 2);
  });

  test('status and delete refresh the farmer list', () async {
    await create();
    final controller = container.read(listingsControllerProvider.notifier);
    await controller.toggleStatus('server-id', ProductStatus.active);
    expect(
      container.read(listingsControllerProvider).requireValue.single.status,
      ProductStatus.inactive,
    );
    await controller.deleteProduct('server-id');
    expect(container.read(listingsControllerProvider).requireValue, isEmpty);
  });

  test('retry preserves existing listings after a failed creation', () async {
    await create();
    repository.fail = true;
    expect(await create(), isFalse);
    repository.fail = false;
    expect(await create(), isTrue);
    expect(
      container.read(listingsControllerProvider).requireValue,
      hasLength(2),
    );
  });
}
