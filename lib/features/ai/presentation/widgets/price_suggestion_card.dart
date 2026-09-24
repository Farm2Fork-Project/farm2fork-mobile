import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/utils/number_formatters.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/features/ai/data/models/ai_models.dart';
import 'package:farm2fork_mobile/features/ai/data/repositories/ai_repository_provider.dart';
import 'package:farm2fork_mobile/features/ai/presentation/widgets/ai_assist_messages.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_category.dart';

/// Fair-price helper on the pricing step. The estimate is rule-based and
/// says so; the farmer applies it explicitly.
class PriceSuggestionCard extends ConsumerStatefulWidget {
  const PriceSuggestionCard({
    super.key,
    required this.productName,
    required this.category,
    required this.unit,
    required this.grade,
    required this.unitLabel,
    required this.onApply,
  });

  final String productName;
  final ProductCategory category;
  final ProductUnit unit;
  final QualityGrade grade;
  final String unitLabel;
  final ValueChanged<double> onApply;

  @override
  ConsumerState<PriceSuggestionCard> createState() =>
      _PriceSuggestionCardState();
}

class _PriceSuggestionCardState extends ConsumerState<PriceSuggestionCard> {
  PriceSuggestion? _suggestion;
  AiErrorKind? _error;
  bool _loading = false;

  @override
  void didUpdateWidget(covariant PriceSuggestionCard old) {
    super.didUpdateWidget(old);
    // A range for another unit or grade would be misleading: drop it.
    if (old.unit != widget.unit || old.grade != widget.grade) {
      _suggestion = null;
    }
  }

  Future<void> _suggest() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final suggestion = await ref
          .read(aiRepositoryProvider)
          .suggestPrice(
            productName: widget.productName,
            category: widget.category,
            unit: widget.unit,
            grade: widget.grade,
          );
      if (mounted) setState(() => _suggestion = suggestion);
    } on AiException catch (e) {
      if (mounted) setState(() => _error = e.kind);
    } catch (_) {
      if (mounted) setState(() => _error = AiErrorKind.failed);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    final suggestion = _suggestion;

    return AppCard(
      backgroundColor: AppColors.surfaceLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                size: 18,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(l10n.aiPriceTitle, style: AppTextStyles.h3)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: l10n.aiSuggestPrice,
            icon: Icons.sell_outlined,
            variant: AppButtonVariant.secondary,
            expand: true,
            isLoading: _loading,
            onPressed: _loading ? null : _suggest,
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            AiNote(
              text: aiErrorMessage(context, _error!),
              tone: AiNoteTone.error,
            ),
          ],
          if (suggestion != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.aiPriceRange(
                formatCurrencyAmount(suggestion.minPrice, locale),
                formatCurrencyAmount(suggestion.maxPrice, locale),
                widget.unitLabel,
              ),
              style: AppTextStyles.h3.copyWith(
                color: AppColors.primaryGreenDark,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            if (suggestion.ruleBased) AiNote(text: l10n.aiPriceRuleBased),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l10n.aiUsePrice(
                formatCurrencyAmount(suggestion.midpoint, locale),
              ),
              variant: AppButtonVariant.quiet,
              onPressed: () => widget.onApply(suggestion.midpoint),
            ),
          ],
        ],
      ),
    );
  }
}
