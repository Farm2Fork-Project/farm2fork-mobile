import 'package:flutter/material.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, quiet, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, border) = switch (variant) {
      AppButtonVariant.primary => (
        AppColors.primaryGreen,
        AppColors.white,
        AppColors.primaryGreen,
      ),
      AppButtonVariant.secondary => (
        AppColors.primaryGreenSoft,
        AppColors.primaryGreenDark,
        AppColors.primaryGreenSoft,
      ),
      AppButtonVariant.quiet => (
        AppColors.white,
        AppColors.primaryGreen,
        AppColors.surfaceMedium,
      ),
      AppButtonVariant.danger => (
        AppColors.errorRed,
        AppColors.white,
        AppColors.errorRed,
      ),
    };

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );

    return SizedBox(
      width: expand ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: AppColors.surfaceMedium,
          disabledForegroundColor: AppColors.textMuted,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          textStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            side: BorderSide(color: border),
          ),
        ),
        child: content,
      ),
    );
  }
}
