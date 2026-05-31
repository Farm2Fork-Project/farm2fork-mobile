import 'package:flutter/material.dart';
import 'package:Farm2Fork/core/theme/app_colors.dart';
import 'package:Farm2Fork/core/theme/app_sizes.dart';
import 'package:Farm2Fork/core/theme/app_typography.dart';
import 'package:Farm2Fork/features/marketplace/data/models/product.dart';
import 'package:Farm2Fork/core/localization/l10n_extension.dart';

/// Compact product card for grid display on the Marketplace screen.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    final isAvailable = product.status == ProductStatus.available;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image area ──────────────────────────────────────────────
            Stack(
              children: [
                _ProductImage(imageUrls: product.imageUrls),
                if (!isAvailable)
                  Positioned.fill(
                    child: Container(
                      color: AppColors.black.withValues(alpha: 0.45),
                      alignment: Alignment.center,
                      child: Text(
                        context.l10n.outOfStock,
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: AppSpacing.sm,
                  left: AppSpacing.sm,
                  child: _GradeBadge(grade: product.qualityGrade),
                ),
              ],
            ),

            // ── Info area ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.farmer.farmName,
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.textDark.withValues(alpha: 0.55),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PKR ${product.pricePerUnit.toStringAsFixed(0)}/${product.unit}',
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      _AddButton(enabled: isAvailable, onTap: onAddToCart),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Private helpers ──────────────────────────────────────────────────────────

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imageUrls});
  final List<String> imageUrls;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      width: double.infinity,
      child: imageUrls.isNotEmpty
          ? Image.network(imageUrls.first, fit: BoxFit.cover)
          : Container(
              color: AppColors.primaryGreen.withValues(alpha: 0.12),
              child: const Icon(Icons.eco_rounded, size: 48, color: AppColors.primaryGreen),
            ),
    );
  }
}

class _GradeBadge extends StatelessWidget {
  const _GradeBadge({required this.grade});
  final QualityGrade grade;

  Color get _color => switch (grade) {
    QualityGrade.aPlus => const Color(0xFF2E7D32),
    QualityGrade.a => AppColors.primaryGreen,
    QualityGrade.b => AppColors.accentYellow,
    QualityGrade.c => AppColors.errorRed,
  };

  String get _label => switch (grade) {
    QualityGrade.aPlus => 'A+',
    QualityGrade.a => 'A',
    QualityGrade.b => 'B',
    QualityGrade.c => 'C',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(color: _color, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text(
        _label,
        style: AppTextStyles.small.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.enabled, required this.onTap});
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primaryGreen : AppColors.textDark.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.add_rounded,
          size: 18,
          color: enabled ? AppColors.white : AppColors.textDark.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
