import 'package:flutter/material.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';

enum AppNoticeKind { error, success, info }

/// Inline message for forms. Announced to screen readers when it appears and
/// never relies on colour alone (each kind has its own icon).
class AppNoticeBanner extends StatelessWidget {
  const AppNoticeBanner({
    super.key,
    required this.message,
    this.kind = AppNoticeKind.error,
  });

  final String message;
  final AppNoticeKind kind;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (kind) {
      AppNoticeKind.error => (AppColors.errorRed, Icons.error_outline_rounded),
      AppNoticeKind.success => (
        AppColors.success,
        Icons.check_circle_outline_rounded,
      ),
      AppNoticeKind.info => (
        AppColors.secondaryBlue,
        Icons.info_outline_rounded,
      ),
    };
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.small.copyWith(color: color, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
