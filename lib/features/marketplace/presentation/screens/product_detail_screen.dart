import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/utils/number_formatters.dart';
import 'package:farm2fork_mobile/core/widgets/app_badge.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/core/widgets/section_header.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/auth/presentation/widgets/auth_required_sheet.dart';
import 'package:farm2fork_mobile/features/cart/presentation/providers/cart_controller.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/presentation/providers/marketplace_providers.dart';
import 'package:farm2fork_mobile/features/marketplace/presentation/utils/product_l10n.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;

  void _increment() => setState(() => _quantity++);
  void _decrement() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider).asData?.value;
    final productAsync = ref.watch(productByIdProvider(widget.productId));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: productAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
        error: (e, _) => Center(child: Text(context.l10n.errorOccurred)),
        data: (product) {
          if (product == null) {
            return Center(child: Text(context.l10n.noDataFound));
          }
          return _ProductDetailBody(
            product: product,
            quantity: _quantity,
            onIncrement: _increment,
            onDecrement: _decrement,
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
                  .addItem(product, quantity: _quantity);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    context.l10n.addedToCart,
                    style: AppTextStyles.small.copyWith(color: AppColors.white),
                  ),
                  backgroundColor: AppColors.primaryGreen,
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              );
              context.pop();
            },
          );
        },
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _ProductDetailBody extends StatelessWidget {
  const _ProductDetailBody({
    required this.product,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.onAddToCart,
  });

  final Product product;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    final isAvailable = product.status == ProductStatus.active;
    final locale = Localizations.localeOf(context);

    return CustomScrollView(
      slivers: [
        // ── App Bar with Hero image ──────────────────────────────────────
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          backgroundColor: AppColors.backgroundLight,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.94),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textDark,
              ),
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: product.images.isNotEmpty
                ? Image.network(product.images.first, fit: BoxFit.cover)
                : Container(
                    color: AppColors.primaryGreenSoft,
                    child: const Icon(
                      Icons.eco_rounded,
                      size: 100,
                      color: AppColors.primaryGreen,
                    ),
                  ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title row ──────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(product.name, style: AppTextStyles.h2),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _StatusChip(status: product.status),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),

                // ── Price ──────────────────────────────────────────────
                Text(
                  context.l10n.priceAmountWithUnit(
                    formatCurrencyAmount(product.price, locale),
                    productUnitLabel(context, product.unit),
                  ),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.primaryGreenDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 19,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Quality Badge + Available Quantity ─────────────────
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _InfoPill(
                      icon: Icons.verified_rounded,
                      label: context.l10n.qualityGradeWithValue(
                        qualityGradeLabel(context, product.qualityGrade),
                      ),
                      color: AppColors.primaryGreen,
                    ),
                    _InfoPill(
                      icon: Icons.inventory_2_rounded,
                      label: context.l10n.quantityAmountWithUnit(
                        formatCompactNumber(product.quantity, locale),
                        productUnitLabel(context, product.unit),
                      ),
                      color: AppColors.secondaryBlue,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Description ────────────────────────────────────────
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(title: context.l10n.description),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        product.description,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textMuted,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Farmer Card ────────────────────────────────────────
                _FarmerCard(product: product),
                const SizedBox(height: AppSpacing.xl),

                // ── Quantity Selector ──────────────────────────────────
                if (isAvailable) ...[
                  AppCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: SectionHeader(title: context.l10n.quantity),
                        ),
                        _QuantitySelector(
                          quantity: quantity,
                          onIncrement: onIncrement,
                          onDecrement: onDecrement,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Add to Cart ────────────────────────────────────
                  AppButton(
                    label: context.l10n.addToCart,
                    icon: Icons.shopping_cart_outlined,
                    expand: true,
                    onPressed: onAddToCart,
                  ),
                ] else
                  _OutOfStockBanner(),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final ProductStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ProductStatus.active => (
        productStatusLabel(context, status),
        AppColors.success,
      ),
      ProductStatus.inactive => (
        productStatusLabel(context, status),
        AppColors.accentYellow,
      ),
      ProductStatus.soldOut => (
        productStatusLabel(context, status),
        AppColors.errorRed,
      ),
    };
    return AppBadge(
      label: label,
      icon: Icons.verified_outlined,
      backgroundColor: color.withValues(alpha: 0.12),
      foregroundColor: color,
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppBadge(
      label: label,
      icon: icon,
      backgroundColor: color.withValues(alpha: 0.10),
      foregroundColor: color,
    );
  }
}

class _FarmerCard extends StatelessWidget {
  const _FarmerCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final farmer = product.farmer;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: context.l10n.farmerInfo),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primaryGreenSoft,
                child: Text(
                  farmer.name.isNotEmpty ? farmer.name[0].toUpperCase() : '?',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      farmer.name,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      farmer.farmName,
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Rating
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: AppColors.accentYellow,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    farmer.rating.toStringAsFixed(1),
                    style: AppTextStyles.small.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.secondaryBlue,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  farmer.farmLocationAddress,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.shopping_bag_outlined,
                size: 14,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(width: 4),
              Text(
                context.l10n.totalSales(farmer.totalSales),
                style: AppTextStyles.small.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _QBtn(
          icon: Icons.remove_rounded,
          onTap: onDecrement,
          enabled: quantity > 1,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Text(
            '$quantity',
            style: AppTextStyles.h2.copyWith(color: AppColors.primaryGreen),
          ),
        ),
        _QBtn(icon: Icons.add_rounded, onTap: onIncrement, enabled: true),
      ],
    );
  }
}

class _QBtn extends StatelessWidget {
  const _QBtn({required this.icon, required this.onTap, required this.enabled});
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? AppColors.primaryGreenSoft : AppColors.surfaceMedium,
          border: Border.all(
            color: enabled
                ? AppColors.primaryGreen.withValues(alpha: 0.5)
                : AppColors.surfaceMedium,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled
              ? AppColors.primaryGreen
              : AppColors.textDark.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

class _OutOfStockBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.block_rounded, color: AppColors.errorRed, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Text(
            context.l10n.outOfStock,
            style: AppTextStyles.body.copyWith(
              color: AppColors.errorRed,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
