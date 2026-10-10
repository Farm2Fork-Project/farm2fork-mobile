import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/features/marketplace/presentation/providers/marketplace_providers.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/listings/data/repositories/listings_repository_provider.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/farmer_summary.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_category.dart';

final listingsControllerProvider =
    AsyncNotifierProvider<ListingsController, List<Product>>(
      ListingsController.new,
    );

class ListingsController extends AsyncNotifier<List<Product>> {
  List<Product>? _creationRetryListings;

  @override
  Future<List<Product>> build() async {
    _creationRetryListings = null;
    final authState = ref.watch(authControllerProvider).asData?.value;
    if (authState == null || authState.user == null) {
      return [];
    }
    final repository = ref.watch(listingsRepositoryProvider);
    return repository.getFarmerListings(authState.user!.id);
  }

  Future<void> fetchListings() async {
    if (!state.hasValue) state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authState = ref.read(authControllerProvider).asData?.value;
      if (authState == null || authState.user == null) return [];
      return ref
          .read(listingsRepositoryProvider)
          .getFarmerListings(authState.user!.id);
    });
  }

  Future<bool> addListing({
    required String name,
    required ProductCategory category,
    required String description,
    required double price,
    required double quantity,
    required ProductUnit unit,
    required QualityGrade qualityGrade,
  }) async {
    if (state.isLoading) return false;
    final previous = state.value ?? _creationRetryListings ?? <Product>[];
    state = const AsyncLoading();
    try {
      final user = ref.read(authControllerProvider).asData?.value.user;
      if (user == null) {
        throw const ApiException(ApiErrorKind.unauthorized);
      }
      final created = await ref
          .read(listingsRepositoryProvider)
          .createListing(
            Product(
              id: '', // The backend assigns the persisted identity.
              farmerId: user.id,
              name: name,
              category: category,
              description: description,
              price: price,
              quantity: quantity,
              unit: unit,
              images: [],
              qualityGrade: qualityGrade,
              farmer: FarmerSummary(
                id: user.id,
                name: '',
                farmName: '',
                farmLocationAddress: '',
              ),
            ),
          );
      // A successful write is success even if a later refresh is unavailable.
      state = AsyncData([created, ...previous]);
      _creationRetryListings = null;
      ref.invalidate(productsProvider);
      return true;
    } catch (error, stackTrace) {
      _creationRetryListings = previous;
      state = AsyncError(error, stackTrace);
      return false;
    }
  }

  Future<void> toggleStatus(
    String productId,
    ProductStatus currentStatus,
  ) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authState = ref.read(authControllerProvider).asData?.value;
      if (authState == null || authState.user == null) {
        throw const ApiException(ApiErrorKind.unauthorized);
      }
      final repository = ref.read(listingsRepositoryProvider);
      final nextStatus = currentStatus == ProductStatus.active
          ? ProductStatus.inactive
          : ProductStatus.active;
      await repository.updateListingStatus(productId, nextStatus);
      ref.invalidate(productsProvider);
      ref.invalidate(productByIdProvider(productId));
      return repository.getFarmerListings(authState.user!.id);
    });
  }

  Future<void> deleteProduct(String productId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authState = ref.read(authControllerProvider).asData?.value;
      if (authState == null || authState.user == null) {
        throw const ApiException(ApiErrorKind.unauthorized);
      }
      final repository = ref.read(listingsRepositoryProvider);
      await repository.deleteListing(productId);
      ref.invalidate(productsProvider);
      ref.invalidate(productByIdProvider(productId));
      return repository.getFarmerListings(authState.user!.id);
    });
  }
}
