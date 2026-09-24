import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/listings/data/models/new_listing.dart';
import 'package:farm2fork_mobile/features/listings/data/repositories/listings_repository_provider.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_category.dart';

final listingsControllerProvider =
    AsyncNotifierProvider<ListingsController, List<Product>>(
      ListingsController.new,
    );

class ListingsController extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
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

  /// Publishes a listing. Returns whether it succeeded; on failure the
  /// previously loaded listings are kept (not replaced by an error state), so
  /// the create screen can keep the farmer's form and explain what happened.
  Future<bool> addListing({
    required String name,
    required ProductCategory category,
    required String description,
    required double price,
    required double quantity,
    required ProductUnit unit,
    required QualityGrade qualityGrade,
  }) async {
    final authState = ref.read(authControllerProvider).asData?.value;
    if (authState == null || authState.user == null) return false;

    final previous = state;
    state = const AsyncLoading();
    try {
      final repository = ref.read(listingsRepositoryProvider);
      final farmerId = authState.user!.id;
      await repository.createListing(
        farmerId,
        NewListing(
          name: name,
          category: category,
          description: description,
          price: price,
          quantity: quantity,
          unit: unit,
          qualityGrade: qualityGrade,
        ),
      );
      state = AsyncData(await repository.getFarmerListings(farmerId));
      return true;
    } catch (_) {
      state = previous;
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
        throw Exception('Unauthorized');
      }
      final repository = ref.read(listingsRepositoryProvider);
      final nextStatus = currentStatus == ProductStatus.active
          ? ProductStatus.inactive
          : ProductStatus.active;
      await repository.updateListingStatus(productId, nextStatus);
      return repository.getFarmerListings(authState.user!.id);
    });
  }

  Future<void> deleteProduct(String productId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authState = ref.read(authControllerProvider).asData?.value;
      if (authState == null || authState.user == null) {
        throw Exception('Unauthorized');
      }
      final repository = ref.read(listingsRepositoryProvider);
      await repository.deleteListing(productId);
      return repository.getFarmerListings(authState.user!.id);
    });
  }
}
