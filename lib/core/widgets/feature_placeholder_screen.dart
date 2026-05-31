import 'package:flutter/material.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_badge.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/core/widgets/section_header.dart';

class FeaturePlaceholderScreen extends StatelessWidget {
  const FeaturePlaceholderScreen({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.trustForward = false,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool trustForward;

  @override
  Widget build(BuildContext context) {
    final headerColor = trustForward
        ? AppColors.primaryGreenDark
        : AppColors.white;
    final borderColor = trustForward
        ? AppColors.primaryGreenDark
        : AppColors.surfaceMedium;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: Text(title, style: AppTextStyles.h3)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: [
          AppCard(
            backgroundColor: headerColor,
            borderColor: borderColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: trustForward
                      ? AppColors.accentYellowSoft
                      : AppColors.primaryGreenSoft,
                  child: Icon(
                    icon,
                    color: AppColors.primaryGreenDark,
                    size: 28,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SectionHeader(
                  title: title,
                  subtitle: description,
                  titleColor: trustForward ? AppColors.white : null,
                  subtitleColor: trustForward
                      ? AppColors.primaryGreenSoft
                      : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppBadge(
                  label: context.l10n.featureComingSoon,
                  icon: Icons.construction_rounded,
                  backgroundColor: trustForward
                      ? AppColors.accentYellowSoft
                      : AppColors.primaryGreenSoft,
                  foregroundColor: AppColors.primaryGreenDark,
                ),
              ],
            ),
          ),
          if (trustForward) ...[
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              child: Text(
                context.l10n.paymentOptionsNote,
                style: AppTextStyles.small.copyWith(
                  color: AppColors.textMuted,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
