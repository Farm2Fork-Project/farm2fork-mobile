import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/localization/locale_controller.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/theme/font_size_controller.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/core/widgets/section_header.dart';

class LanguageDisplayScreen extends ConsumerWidget {
  const LanguageDisplayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(localeControllerProvider);
    final fontScale = ref.watch(fontSizeControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(context.l10n.languageDisplayTitle, style: AppTextStyles.h2),
        elevation: 0,
        backgroundColor: AppColors.backgroundLight,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: [
            // Language Selection section
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(title: context.l10n.selectLanguage),
                  const SizedBox(height: AppSpacing.md),
                  localeAsync.when(
                    data: (locale) => Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: context.l10n.english,
                            variant: locale.languageCode == 'en'
                                ? AppButtonVariant.primary
                                : AppButtonVariant.quiet,
                            expand: true,
                            onPressed: locale.languageCode == 'en'
                                ? null
                                : () => ref
                                      .read(localeControllerProvider.notifier)
                                      .setLocale(const Locale('en')),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppButton(
                            label: context.l10n.urdu,
                            variant: locale.languageCode == 'ur'
                                ? AppButtonVariant.primary
                                : AppButtonVariant.quiet,
                            expand: true,
                            onPressed: locale.languageCode == 'ur'
                                ? null
                                : () => ref
                                      .read(localeControllerProvider.notifier)
                                      .setLocale(const Locale('ur')),
                          ),
                        ),
                      ],
                    ),
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    error: (_, _) => Text(context.l10n.errorOccurred),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Font Sizing section
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(title: context.l10n.fontSize),
                  const SizedBox(height: AppSpacing.md),
                  _buildFontSizeSelectors(context, ref, currentScale: fontScale),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Live Preview Card
            AppCard(
              backgroundColor: AppColors.primaryGreenSoft,
              borderColor: AppColors.primaryGreen.withValues(alpha: 0.2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.textScalePreview,
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.primaryGreenDark,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    context.l10n.textScalePreviewDesc,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeSelectors(
    BuildContext context,
    WidgetRef ref, {
    required double currentScale,
  }) {
    final sizes = [
      _FontSizeOption(label: context.l10n.fontSizeSmall, scale: 0.85),
      _FontSizeOption(label: context.l10n.fontSizeMedium, scale: 1.0),
      _FontSizeOption(label: context.l10n.fontSizeLarge, scale: 1.15),
      _FontSizeOption(label: context.l10n.fontSizeXLarge, scale: 1.30),
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: sizes.map((opt) {
        final isSelected = (currentScale - opt.scale).abs() < 0.01;
        return ChoiceChip(
          label: Text(opt.label),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              ref.read(fontSizeControllerProvider.notifier).setScale(opt.scale);
            }
          },
          selectedColor: AppColors.primaryGreen,
          backgroundColor: AppColors.white,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.white : AppColors.textDark,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          side: BorderSide(
            color: isSelected ? AppColors.primaryGreen : AppColors.surfaceMedium,
          ),
        );
      }).toList(),
    );
  }
}

class _FontSizeOption {
  final String label;
  final double scale;

  _FontSizeOption({required this.label, required this.scale});
}
