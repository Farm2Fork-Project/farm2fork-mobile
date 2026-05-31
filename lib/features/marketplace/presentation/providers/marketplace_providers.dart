import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_category.dart';
import 'package:farm2fork_mobile/features/marketplace/data/repositories/marketplace_repository.dart';
import 'package:farm2fork_mobile/features/marketplace/data/repositories/mock_marketplace_repository.dart';

// ─── Repository Provider ─────────────────────────────────────────────────────

/// Swap [MockMarketplaceRepository] for the real Dio implementation later.
final marketplaceRepositoryProvider = Provider<MarketplaceRepository>(
  (ref) => MockMarketplaceRepository(),
);

// ─── Active Category Filter ───────────────────────────────────────────────────

/// null means "All categories".
final activeCategoryProvider =
    NotifierProvider<_CategoryNotifier, ProductCategory?>(
      _CategoryNotifier.new,
    );

class _CategoryNotifier extends Notifier<ProductCategory?> {
  @override
  ProductCategory? build() => null;

  void select(ProductCategory? category) => state = category;
}

// ─── Search Query ─────────────────────────────────────────────────────────────

final searchQueryProvider = NotifierProvider<_SearchNotifier, String>(
  _SearchNotifier.new,
);

class _SearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) => state = value;
  void clear() => state = '';
}

// ─── Products List ────────────────────────────────────────────────────────────

/// Fetches products filtered by [activeCategoryProvider].
/// Re-fetches automatically when the active category changes.
final productsProvider = FutureProvider.autoDispose<List<Product>>((ref) {
  final repo = ref.watch(marketplaceRepositoryProvider);
  final category = ref.watch(activeCategoryProvider);
  final query = ref.watch(searchQueryProvider).trim();

  if (query.isNotEmpty) {
    return repo.searchProducts(query);
  }
  return repo.getProducts(category: category);
});

// ─── Single Product ───────────────────────────────────────────────────────────

final productByIdProvider = FutureProvider.autoDispose.family<Product?, String>(
  (ref, id) {
    final repo = ref.watch(marketplaceRepositoryProvider);
    return repo.getProductById(id);
  },
);
