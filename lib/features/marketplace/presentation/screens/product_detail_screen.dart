import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Farm2Fork/core/theme/app_colors.dart';
import 'package:Farm2Fork/core/theme/app_sizes.dart';
import 'package:Farm2Fork/core/theme/app_typography.dart';
import 'package:Farm2Fork/core/localization/l10n_extension.dart';
import 'package:Farm2Fork/features/marketplace/data/models/product.dart';
import 'package:Farm2Fork/features/marketplace/presentation/providers/marketplace_providers.dart';
import 'package:Farm2Fork/features/cart/presentation/providers/cart_controller.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;

  void _increment() => setState(() => _quantity++);
  void _decrement() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productByIdProvider(widget.productId));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: productAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
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
              ref.read(cartControllerProvider.notifier).addItem(product, quantity: _quantity);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    context.l10n.addedToCart,
                    style: AppTextStyles.small.copyWith(color: AppColors.white),
                  ),
                  backgroundColor: AppColors.primaryGreen,
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
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
    final isAvailable = product.status == ProductStatus.available;

    return CustomScrollView(
      slivers: [
        // ── App Bar with Hero image ──────────────────────────────────────
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          backgroundColor: AppColors.white,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: product.imageUrls.isNotEmpty
                ? Image.network(product.imageUrls.first, fit: BoxFit.cover)
                : Container(
                    color: AppColors.primaryGreen.withValues(alpha: 0.15),
                    child: const Icon(Icons.eco_rounded, size: 100, color: AppColors.primaryGreen),
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
                    Expanded(child: Text(product.name, style: AppTextStyles.h2)),
                    const SizedBox(width: AppSpacing.sm),
                    _StatusChip(status: product.status),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),

                // ── Price ──────────────────────────────────────────────
                Text(
                  'PKR ${product.pricePerUnit.toStringAsFixed(0)} / ${product.unit}',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Quality Badge + Available Quantity ─────────────────
                Row(
                  children: [
                    _InfoPill(
                      icon: Icons.verified_rounded,
                      label:
                          '${context.l10n.qualityGrade}: ${_gradeLabel(context, product.qualityGrade)}',
                      color: AppColors.primaryGreen,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _InfoPill(
                      icon: Icons.inventory_2_rounded,
                      label: '${product.availableQuantity.toStringAsFixed(0)} ${product.unit}',
                      color: AppColors.secondaryBlue,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Description ────────────────────────────────────────
                Text(
                  context.l10n.description,
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  product.description,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textDark.withValues(alpha: 0.7),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Farmer Card ────────────────────────────────────────
                _FarmerCard(product: product),
                const SizedBox(height: AppSpacing.xl),

                // ── Quantity Selector ──────────────────────────────────
                if (isAvailable) ...[
                  Text(
                    context.l10n.quantity,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _QuantitySelector(
                    quantity: quantity,
                    onIncrement: onIncrement,
                    onDecrement: onDecrement,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Add to Cart ────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onAddToCart,
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: Text(context.l10n.addToCart),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                        textStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                    ),
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

  String _gradeLabel(BuildContext context, QualityGrade grade) => switch (grade) {
    QualityGrade.aPlus => context.l10n.gradeAPlus,
    QualityGrade.a => context.l10n.gradeA,
    QualityGrade.b => context.l10n.gradeB,
    QualityGrade.c => context.l10n.gradeC,
  };
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final ProductStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ProductStatus.available => (context.l10n.available, AppColors.success),
      ProductStatus.outOfStock => (context.l10n.outOfStock, AppColors.errorRed),
      ProductStatus.comingSoon => (context.l10n.comingSoon, AppColors.accentYellow),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: AppTextStyles.small.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.small.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _FarmerCard extends StatelessWidget {
  const _FarmerCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final farmer = product.farmer;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.farmerInfo,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
                child: Text(
                  farmer.name.isNotEmpty ? farmer.name[0].toUpperCase() : '?',
                  style: AppTextStyles.h2.copyWith(color: AppColors.primaryGreen),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      farmer.name,
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      farmer.farmName,
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.textDark.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              // Rating
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 16, color: AppColors.accentYellow),
                  const SizedBox(width: 2),
                  Text(
                    farmer.rating.toStringAsFixed(1),
                    style: AppTextStyles.small.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.secondaryBlue),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  farmer.farmLocationAddress,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textDark.withValues(alpha: 0.65),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.shopping_bag_outlined, size: 14, color: AppColors.primaryGreen),
              const SizedBox(width: 4),
              Text(
                context.l10n.totalSales(farmer.totalSales),
                style: AppTextStyles.small.copyWith(
                  color: AppColors.textDark.withValues(alpha: 0.65),
                ),
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
        _QBtn(icon: Icons.remove_rounded, onTap: onDecrement, enabled: quantity > 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Text('$quantity', style: AppTextStyles.h2.copyWith(color: AppColors.primaryGreen)),
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
          color: enabled ? AppColors.primaryGreen.withValues(alpha: 0.1) : AppColors.surfaceMedium,
          border: Border.all(
            color: enabled
                ? AppColors.primaryGreen.withValues(alpha: 0.5)
                : AppColors.surfaceMedium,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? AppColors.primaryGreen : AppColors.textDark.withValues(alpha: 0.3),
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
