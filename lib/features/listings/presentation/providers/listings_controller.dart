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
  bool _mutating = false;

  Future<bool> addListing({
    required String name,
    required ProductCategory category,
    required String description,
    required double price,
    required double quantity,
    required ProductUnit unit,
    required QualityGrade qualityGrade,
    List<String> images = const [],
    String? productId,
    ProductStatus? status,
    Product? original,
  }) async {
    final authState = ref.read(authControllerProvider).asData?.value;
    if (authState == null || authState.user == null) return false;

    if (_mutating) return false;
    _mutating = true;
    final previous = state;
    try {
      final repository = ref.read(listingsRepositoryProvider);
      final farmerId = authState.user!.id;
      final draft = NewListing(
        name: name,
        category: category,
        description: description,
        price: price,
        quantity: quantity,
        unit: unit,
        qualityGrade: qualityGrade,
        images: images,
        status: status,
        original: original,
      );
      final product = productId == null
          ? await repository.createListing(farmerId, draft)
          : await repository.updateListing(productId, draft);
      final current = previous.asData?.value ?? [];
      state = AsyncData(
        productId == null
            ? [product, ...current]
            : [
                for (final item in current)
                  if (item.id == product.id) product else item,
              ],
      );
      return true;
    } catch (_) {
      state = previous;
      return false;
    } finally {
      _mutating = false;
    }
  }

  Future<bool> toggleStatus(
    String productId,
    ProductStatus currentStatus,
  ) async {
    if (_mutating) return false;
    _mutating = true;
    final previous = state;
    try {
      final nextStatus = currentStatus == ProductStatus.active
          ? ProductStatus.inactive
          : ProductStatus.active;
      final updated = await ref
          .read(listingsRepositoryProvider)
          .updateListingStatus(productId, nextStatus);
      state = AsyncData([
        for (final product in previous.asData?.value ?? <Product>[])
          if (product.id == productId) updated else product,
      ]);
      return true;
    } catch (_) {
      state = previous;
      return false;
    } finally {
      _mutating = false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    if (_mutating) return false;
    _mutating = true;
    final previous = state;
    try {
      await ref.read(listingsRepositoryProvider).deleteListing(productId);
      state = AsyncData([
        for (final product in previous.asData?.value ?? <Product>[])
          if (product.id == productId)
            product.copyWith(status: ProductStatus.inactive)
          else
            product,
      ]);
      return true;
    } catch (_) {
      state = previous;
      return false;
    } finally {
      _mutating = false;
    }
  }
}
