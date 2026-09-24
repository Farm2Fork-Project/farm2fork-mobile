import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/utils/number_formatters.dart';
import 'package:farm2fork_mobile/core/widgets/app_badge.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/core/widgets/app_state_placeholder.dart';
import 'package:farm2fork_mobile/features/farm_location/presentation/farm_location_prompt.dart';
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
              // Only while the pickup location is incomplete.
              const SliverToBoxAdapter(child: FarmLocationPrompt()),
              // Summary of the farmer's real listings. (This used to show a
              // hardcoded "Hassan Organic Farm / 4.8 / 312 sales" to every
              // farmer; there is no farmer-profile endpoint yet, so only
              // numbers derived from their own listings are shown.)
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding,
                  vertical: AppSpacing.md,
                ),
                sliver: SliverToBoxAdapter(
                  child: _ListingsSummary(
                    listings: listingsAsync.asData?.value,
                  ),
                ),
              ),

              // Listings list
              listingsAsync.when(
                data: (products) {
                  if (products.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: AppEmptyState(
                        message: context.l10n.noDataFound,
                        subtitle: context.l10n.listingsDescription,
                        icon: Icons.inventory_2_outlined,
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
                  child: AppErrorState(
                    icon: Icons.error_outline_rounded,
                    onRetry: () => ref
                        .read(listingsControllerProvider.notifier)
                        .fetchListings(),
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
              color: AppColors.primaryGreenSoft,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Center(
              child: Icon(
                Icons.spa_rounded,
                color: AppColors.primaryGreenDark,
                size: 38,
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
                        style: AppTextStyles.h3.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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
                if (product.originLedgerStatus != null) ...[
                  const SizedBox(height: 4),
                  _LedgerBadge(status: product.originLedgerStatus!),
                ],
                const SizedBox(height: 4),
                Text(
                  formattedPrice,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.primaryGreenDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${context.l10n.quantity}: ${product.quantity} ${_getLocalizedUnit(context, product.unit)}',
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Wrap, not Row: on narrow phones the 48dp actions drop
                // below the status instead of overflowing or shrinking.
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Status row
                    Row(
                      mainAxisSize: MainAxisSize.min,
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    // Actions - 48dp targets with labels: this is a
                    // farmer task screen (design-language doc).
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: context.l10n.listingViewJourney,
                          icon: const Icon(
                            Icons.timeline_rounded,
                            color: AppColors.primaryGreen,
                            size: 22,
                          ),
                          onPressed: () => context.push(
                            AppNavConfig.traceRouteForProduct(product.id),
                          ),
                        ),
                        IconButton(
                          tooltip: product.status == ProductStatus.active
                              ? context.l10n.listingHide
                              : context.l10n.listingShow,
                          icon: Icon(
                            product.status == ProductStatus.active
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: AppColors.secondaryBlue,
                            size: 22,
                          ),
                          onPressed: () => ref
                              .read(listingsControllerProvider.notifier)
                              .toggleStatus(product.id, product.status),
                        ),
                        IconButton(
                          tooltip: context.l10n.listingDelete,
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.errorRed,
                            size: 22,
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
        title: Text(
          context.l10n.deleteListingConfirmTitle,
          style: AppTextStyles.h3,
        ),
        content: Text(
          context.l10n.deleteListingConfirmMessage,
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.l10n.cancel,
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

class _ListingsSummary extends StatelessWidget {
  const _ListingsSummary({required this.listings});

  /// Null while loading or on error: counts show a dash, never a guess.
  final List<Product>? listings;

  @override
  Widget build(BuildContext context) {
    int? count(ProductStatus status) =>
        listings?.where((p) => p.status == status).length;

    return AppCard(
      backgroundColor: AppColors.primaryGreenDark,
      borderColor: AppColors.primaryGreenDark,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: _SummaryMetric(
              label: context.l10n.productStatusActive,
              value: count(ProductStatus.active),
            ),
          ),
          Expanded(
            child: _SummaryMetric(
              label: context.l10n.productStatusSoldOut,
              value: count(ProductStatus.soldOut),
            ),
          ),
          Expanded(
            child: _SummaryMetric(
              label: context.l10n.productStatusInactive,
              value: count(ProductStatus.inactive),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value});

  final String label;
  final int? value;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value == null ? '–' : formatCompactNumber(value!, locale),
          style: AppTextStyles.h2.copyWith(color: AppColors.white),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.small.copyWith(
            color: AppColors.primaryGreenSoft,
          ),
        ),
      ],
    );
  }
}

/// Ledger state of the listing's `listed` provenance record.
class _LedgerBadge extends StatelessWidget {
  const _LedgerBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (label, icon, background, foreground) = switch (status) {
      'confirmed' => (
        l10n.ledgerConfirmed,
        Icons.verified_user_rounded,
        AppColors.primaryGreenSoft,
        AppColors.primaryGreenDark,
      ),
      'failed' => (
        l10n.ledgerFailed,
        Icons.error_outline_rounded,
        AppColors.white,
        AppColors.errorRed,
      ),
      'missing' => (
        l10n.ledgerMissing,
        Icons.remove_circle_outline_rounded,
        AppColors.surfaceLight,
        AppColors.textMuted,
      ),
      _ => (
        l10n.ledgerPending,
        Icons.hourglass_top_rounded,
        AppColors.accentYellowSoft,
        AppColors.textDark,
      ),
    };
    return AppBadge(
      label: label,
      icon: icon,
      backgroundColor: background,
      foregroundColor: foreground,
    );
  }
}
