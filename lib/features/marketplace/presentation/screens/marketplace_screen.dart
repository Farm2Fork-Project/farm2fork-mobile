import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_badge.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/core/widgets/section_header.dart';
import 'package:farm2fork_mobile/features/cart/presentation/providers/cart_controller.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/auth/presentation/widgets/auth_required_sheet.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_category.dart';
import 'package:farm2fork_mobile/features/marketplace/presentation/providers/marketplace_providers.dart';
import 'package:farm2fork_mobile/features/marketplace/presentation/widgets/product_card.dart';

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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider).asData?.value;
    final activeCategory = ref.watch(activeCategoryProvider);
    final productsAsync = ref.watch(productsProvider);
    final cartCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(context.l10n.marketplace, style: AppTextStyles.h3),
        actions: [
          Stack(
            alignment: AlignmentDirectional.topEnd,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                color: AppColors.primaryGreenDark,
                onPressed: () {
                  if (authState?.isAuthenticated != true) {
                    showAuthRequiredSheet(
                      context,
                      message: context.l10n.loginToAddToCart,
                    );
                    return;
                  }
                  context.go(
                    AppNavConfig.routeFor(
                      AppUserRole.buyer,
                      AppNavDestination.cart,
                    ),
                  );
                },
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
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.pagePadding,
              AppSpacing.sm,
              AppSpacing.pagePadding,
              0,
            ),
            child: _MarketplaceHeader(cartCount: cartCount),
          ),
          _SearchBar(
            controller: _searchController,
            onChanged: (value) =>
                ref.read(searchQueryProvider.notifier).update(value),
            onClear: () {
              _searchController.clear();
              ref.read(searchQueryProvider.notifier).clear();
            },
          ),
          _CategoryChips(
            selected: activeCategory,
            onSelect: (cat) =>
                ref.read(activeCategoryProvider.notifier).select(cat),
          ),
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
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 600;
                      return GridView.builder(
                        padding: const EdgeInsets.all(AppSpacing.pagePadding),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isWide ? 3 : 2,
                          crossAxisSpacing: AppSpacing.md,
                          mainAxisSpacing: AppSpacing.md,
                          childAspectRatio: isWide ? 0.82 : 0.70,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, i) {
                          final product = products[i];
                          return ProductCard(
                            product: product,
                            onTap: () => context.push(
                              '/marketplace/products/${product.id}',
                            ),
                            onAddToCart: () {
                              if (authState?.isAuthenticated != true) {
                                showAuthRequiredSheet(
                                  context,
                                  message: context.l10n.loginToAddToCart,
                                );
                                return;
                              }
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

class _MarketplaceHeader extends StatelessWidget {
  const _MarketplaceHeader({required this.cartCount});

  final int cartCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primaryGreenDark,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreenDark.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SectionHeader(
        title: context.l10n.marketplace,
        subtitle: context.l10n.searchHint,
        titleColor: AppColors.white,
        subtitleColor: AppColors.primaryGreenSoft,
        trailing: AppBadge(
          label: '$cartCount',
          icon: Icons.shopping_cart_outlined,
          backgroundColor: AppColors.accentYellowSoft,
          foregroundColor: AppColors.primaryGreenDark,
        ),
      ),
    );
  }
}

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
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primaryGreen,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded),
                  color: AppColors.textMuted,
                  onPressed: onClear,
                )
              : null,
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
            color: isSelected ? AppColors.primaryGreenDark : AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryGreenDark
                  : AppColors.surfaceStrong,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.small.copyWith(
              color: isSelected ? AppColors.white : AppColors.primaryGreenDark,
              fontWeight: FontWeight.w700,
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
            color: AppColors.textMuted.withValues(alpha: 0.45),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
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
          AppButton(
            label: context.l10n.retry,
            icon: Icons.refresh_rounded,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
