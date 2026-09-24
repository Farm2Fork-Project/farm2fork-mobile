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
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool expand;

  /// Shows a spinner in place of the icon/label and disables taps, while
  /// keeping the button's normal (not greyed-out) colors -- for an async
  /// action that's already in flight, as opposed to one that's unavailable.
  final bool isLoading;

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

    final content = isLoading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: foreground,
            ),
          )
        : Row(
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
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: isLoading
              ? background
              : AppColors.surfaceMedium,
          disabledForegroundColor: isLoading
              ? foreground
              : AppColors.textMuted,
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
