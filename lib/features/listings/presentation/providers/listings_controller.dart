import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/listings/data/repositories/mock_listings_repository.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/farmer_summary.dart';
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
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authState = ref.read(authControllerProvider).asData?.value;
      if (authState == null || authState.user == null) return [];
      return ref
          .read(listingsRepositoryProvider)
          .getFarmerListings(authState.user!.id);
    });
  }

  Future<void> addListing({
    required String name,
    required ProductCategory category,
    required String description,
    required double price,
    required double quantity,
    required ProductUnit unit,
    required QualityGrade qualityGrade,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authState = ref.read(authControllerProvider).asData?.value;
      if (authState == null || authState.user == null) {
        throw Exception('Unauthorized');
      }

      final repository = ref.read(listingsRepositoryProvider);
      final rawFarmerId = authState.user!.id;
      final farmerId = rawFarmerId.replaceAll('mock_', '');

      // Create a farmer summary from auth profile or default
      final farmerSummary = FarmerSummary(
        id: farmerId,
        name: 'Ali Hassan', // default mock farmer name
        farmName: 'Hassan Organic Farm',
        farmLocationAddress: 'Multan, Punjab',
        rating: 4.8,
        totalSales: 312,
      );

      final newProduct = Product(
        id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
        farmerId: farmerId,
        name: name,
        category: category,
        description: description,
        price: price,
        quantity: quantity,
        unit: unit,
        images: [],
        qualityGrade: qualityGrade,
        status: ProductStatus.active,
        farmer: farmerSummary,
      );

      await repository.createListing(newProduct);
      return repository.getFarmerListings(rawFarmerId);
    });
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
