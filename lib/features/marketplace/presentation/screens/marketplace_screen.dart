import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_category.dart';
import 'package:farm2fork_mobile/features/marketplace/presentation/providers/marketplace_providers.dart';
import 'package:farm2fork_mobile/features/marketplace/presentation/widgets/product_card.dart';
import 'package:farm2fork_mobile/features/cart/presentation/providers/cart_controller.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    ref.read(searchQueryProvider.notifier).update(value);
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final activeCategory = ref.watch(activeCategoryProvider);
    final productsAsync = ref.watch(productsProvider);
    final cartCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          context.l10n.marketplace,
          style: AppTextStyles.h2.copyWith(color: AppColors.primaryGreen),
        ),
        actions: [
          Stack(
            alignment: AlignmentDirectional.topEnd,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                color: AppColors.textDark,
                onPressed: () => context.go('/cart'),
              ),
              if (cartCount > 0)
                PositionedDirectional(
                  end: 8,
                  top: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppColors.errorRed,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$cartCount',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Column(
        children: [
          // ── Search Bar ──────────────────────────────────────────────────
          _SearchBar(
            controller: _searchController,
            onChanged: _onSearch,
            onClear: _clearSearch,
          ),

          // ── Category Chips ───────────────────────────────────────────────
          _CategoryChips(
            selected: activeCategory,
            onSelect: (cat) =>
                ref.read(activeCategoryProvider.notifier).select(cat),
          ),

          // ── Product Grid ─────────────────────────────────────────────────
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              ),
              error: (e, _) => _ErrorState(
                message: context.l10n.errorOccurred,
                onRetry: () => ref.invalidate(productsProvider),
              ),
              data: (products) {
                if (products.isEmpty) {
                  return _EmptyState(message: context.l10n.noDataFound);
                }
                return RefreshIndicator(
                  color: AppColors.primaryGreen,
                  onRefresh: () async => ref.invalidate(productsProvider),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(AppSpacing.pagePadding),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppSpacing.md,
                          mainAxisSpacing: AppSpacing.md,
                          childAspectRatio: 0.72,
                        ),
                    itemCount: products.length,
                    itemBuilder: (context, i) {
                      final product = products[i];
                      return ProductCard(
                        product: product,
                        onTap: () =>
                            context.push('/marketplace/products/${product.id}'),
                        onAddToCart: () {
                          ref
                              .read(cartControllerProvider.notifier)
                              .addItem(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                context.l10n.addedToCart,
                                style: AppTextStyles.small.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                              backgroundColor: AppColors.primaryGreen,
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Private Widgets ──────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.pagePadding,
        AppSpacing.md,
        AppSpacing.pagePadding,
        AppSpacing.sm,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: context.l10n.searchHint,
          hintStyle: AppTextStyles.small.copyWith(
            color: AppColors.textDark.withValues(alpha: 0.45),
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primaryGreen,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded),
                  color: AppColors.textDark.withValues(alpha: 0.5),
                  onPressed: onClear,
                )
              : null,
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            borderSide: BorderSide(
              color: AppColors.primaryGreen.withValues(alpha: 0.25),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            borderSide: const BorderSide(
              color: AppColors.primaryGreen,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.selected, required this.onSelect});

  final ProductCategory? selected;
  final ValueChanged<ProductCategory?> onSelect;

  @override
  Widget build(BuildContext context) {
    final categories = ProductCategory.values;
    return SizedBox(
      height: 44,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        scrollDirection: Axis.horizontal,
        children: [
          _Chip(
            label: context.l10n.allCategories,
            isSelected: selected == null,
            onTap: () => onSelect(null),
          ),
          ...categories.map(
            (cat) => _Chip(
              label: _categoryLabel(context, cat),
              isSelected: selected == cat,
              onTap: () => onSelect(cat),
            ),
          ),
        ],
      ),
    );
  }

  String _categoryLabel(BuildContext context, ProductCategory cat) =>
      switch (cat) {
        ProductCategory.vegetables => context.l10n.categoryVegetables,
        ProductCategory.fruits => context.l10n.categoryFruits,
        ProductCategory.grains => context.l10n.categoryGrains,
        ProductCategory.dairy => context.l10n.categoryDairy,
      };
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGreen : AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryGreen
                  : AppColors.primaryGreen.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.small.copyWith(
              color: isSelected ? AppColors.white : AppColors.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: AppColors.textDark.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textDark.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 64,
            color: AppColors.errorRed,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(message, style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(context.l10n.retry),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
