import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_badge.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/features/listings/presentation/providers/listings_controller.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';

class ListingsScreen extends ConsumerWidget {
  const ListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(listingsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(context.l10n.listingsTitle, style: AppTextStyles.h2),
        elevation: 0,
        backgroundColor: AppColors.backgroundLight,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/farmer/create-listing'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          context.l10n.navCreateListing,
          style: AppTextStyles.body.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(listingsControllerProvider.notifier).fetchListings(),
          color: AppColors.primaryGreen,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Dashboard summary header
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding,
                  vertical: AppSpacing.md,
                ),
                sliver: SliverToBoxAdapter(
                  child: AppCard(
                    backgroundColor: AppColors.primaryGreenDark,
                    borderColor: AppColors.primaryGreenDark,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: AppColors.primaryGreenSoft,
                              child: const Icon(
                                Icons.agriculture_rounded,
                                color: AppColors.primaryGreenDark,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hassan Organic Farm',
                                    style: AppTextStyles.h3.copyWith(
                                      color: AppColors.white,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_rounded,
                                        color: AppColors.accentYellow,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Multan, Punjab',
                                        style: AppTextStyles.small.copyWith(
                                          color: AppColors.primaryGreenSoft,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const Divider(color: AppColors.primaryGreen, height: 1),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.rating,
                                  style: AppTextStyles.small.copyWith(
                                    color: AppColors.primaryGreenSoft,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: AppColors.accentYellow,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '4.8',
                                      style: AppTextStyles.body.copyWith(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sales', // fallback if totalSales is dynamic
                                  style: AppTextStyles.small.copyWith(
                                    color: AppColors.primaryGreenSoft,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  context.l10n.totalSales(312),
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Listings list
              listingsAsync.when(
                data: (products) {
                  if (products.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xxl),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 64,
                                color: AppColors.textMuted.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                context.l10n.noDataFound,
                                style: AppTextStyles.h3.copyWith(
                                  color: AppColors.textMuted,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                context.l10n.listingsDescription,
                                style: AppTextStyles.small.copyWith(
                                  color: AppColors.textMuted,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pagePadding,
                      vertical: AppSpacing.sm,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final product = products[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _ListingCard(product: product),
                        );
                      }, childCount: products.length),
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
                error: (error, stackTrace) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.pagePadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.errorRed,
                            size: 48,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            context.l10n.errorOccurred,
                            style: AppTextStyles.body,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ElevatedButton(
                            onPressed: () => ref
                                .read(listingsControllerProvider.notifier)
                                .fetchListings(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                            ),
                            child: Text(
                              context.l10n.retry,
                              style: const TextStyle(color: AppColors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ), // space for FAB
            ],
          ),
        ),
      ),
    );
  }
}

class _ListingCard extends ConsumerWidget {
  const _ListingCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = product.status == ProductStatus.active
        ? AppColors.primaryGreen
        : AppColors.textMuted;

    final localizedStatus = product.status == ProductStatus.active
        ? context.l10n.productStatusActive
        : (product.status == ProductStatus.soldOut
              ? context.l10n.productStatusSoldOut
              : context.l10n.productStatusInactive);

    final formattedPrice = context.l10n.priceAmountWithUnit(
      product.price.toStringAsFixed(0),
      _getLocalizedUnit(context, product.unit),
    );

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Crop thumbnail container
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.surfaceMedium),
            ),
            child: const Center(
              child: Icon(
                Icons.spa_rounded,
                color: AppColors.primaryGreen,
                size: 36,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Details column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: AppTextStyles.h3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppBadge(
                      label: _getLocalizedGrade(context, product.qualityGrade),
                      backgroundColor: AppColors.secondaryBlueSoft,
                      foregroundColor: AppColors.secondaryBlue,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  formattedPrice,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${context.l10n.quantity}: ${product.quantity} ${_getLocalizedUnit(context, product.unit)}',
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Status row
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          localizedStatus,
                          style: AppTextStyles.small.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    // Actions
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            product.status == ProductStatus.active
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: AppColors.secondaryBlue,
                            size: 20,
                          ),
                          onPressed: () => ref
                              .read(listingsControllerProvider.notifier)
                              .toggleStatus(product.id, product.status),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.errorRed,
                            size: 20,
                          ),
                          onPressed: () => _confirmDelete(context, ref),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.removeItem, style: AppTextStyles.h3),
        content: Text(
          '${context.l10n.itemRemoved}?',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.l10n.authRequiredDismiss,
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(listingsControllerProvider.notifier)
                  .deleteProduct(product.id);
              Navigator.pop(ctx);
            },
            child: Text(
              context.l10n.removeItem,
              style: const TextStyle(
                color: AppColors.errorRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getLocalizedUnit(BuildContext context, ProductUnit unit) {
    return switch (unit) {
      ProductUnit.kg => context.l10n.unitKg,
      ProductUnit.ton => context.l10n.unitTon,
      ProductUnit.dozen => context.l10n.unitDozen,
      ProductUnit.piece => context.l10n.unitPiece,
      ProductUnit.litre => context.l10n.unitLitre,
    };
  }

  String _getLocalizedGrade(BuildContext context, QualityGrade grade) {
    return switch (grade) {
      QualityGrade.a => context.l10n.gradeA,
      QualityGrade.b => context.l10n.gradeB,
      QualityGrade.c => context.l10n.gradeC,
    };
  }
}
