import 'package:flutter/material.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/utils/number_formatters.dart';
import 'package:farm2fork_mobile/core/widgets/app_badge.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/presentation/utils/product_l10n.dart';

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
    final isAvailable = product.status == ProductStatus.active;
    final locale = Localizations.localeOf(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.surfaceMedium),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.045),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image area ──────────────────────────────────────────────
              Stack(
                children: [
                  _ProductImage(images: product.images),
                  if (!isAvailable)
                    Positioned.fill(
                      child: Container(
                        color: AppColors.black.withValues(alpha: 0.45),
                        alignment: Alignment.center,
                        child: Text(
                          productStatusLabel(context, product.status),
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  PositionedDirectional(
                    top: AppSpacing.sm,
                    start: AppSpacing.sm,
                    child: AppBadge(
                      label: qualityGradeLabel(context, product.qualityGrade),
                      icon: Icons.verified_rounded,
                      backgroundColor: AppColors.white.withValues(alpha: 0.92),
                      foregroundColor: _gradeColor(product.qualityGrade),
                    ),
                  ),
                ],
              ),

              // ── Info area ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
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
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                      maxLines: 2,
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            context.l10n.priceAmountWithUnit(
                              formatCurrencyAmount(product.price, locale),
                              productUnitLabel(context, product.unit),
                            ),
                            style: AppTextStyles.small.copyWith(
                              color: AppColors.primaryGreenDark,
                              fontWeight: FontWeight.w800,
                              fontSize: 12.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _AddButton(enabled: isAvailable, onTap: onAddToCart),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Private helpers ──────────────────────────────────────────────────────────

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.images});
  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      width: double.infinity,
      child: images.isNotEmpty
          ? Image.network(images.first, fit: BoxFit.cover)
          : Container(
              color: AppColors.primaryGreenSoft,
              child: const Icon(
                Icons.eco_rounded,
                size: 48,
                color: AppColors.primaryGreen,
              ),
            ),
    );
  }
}

Color _gradeColor(QualityGrade grade) {
  return switch (grade) {
    QualityGrade.a => AppColors.primaryGreen,
    QualityGrade.b => AppColors.accentYellow,
    QualityGrade.c => AppColors.errorRed,
  };
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
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primaryGreen
              : AppColors.textDark.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.add_rounded,
          size: 18,
          color: enabled
              ? AppColors.white
              : AppColors.textDark.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
