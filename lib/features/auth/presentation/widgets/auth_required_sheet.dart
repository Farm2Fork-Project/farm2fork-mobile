import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';

/// Show a bottom sheet explaining why login is required.
/// [message] must be a localized string (e.g. context.l10n.loginToAddToCart).
Future<void> showAuthRequiredSheet(
  BuildContext context, {
  required String message,
}) {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (_) => AuthRequiredSheet(message: message),
  );
}

class AuthRequiredSheet extends StatelessWidget {
  const AuthRequiredSheet({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePadding,
          AppSpacing.lg,
          AppSpacing.pagePadding,
          AppSpacing.pagePadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceMedium,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(context.l10n.loginRequired, style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textMuted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: context.l10n.login,
              expand: true,
              onPressed: () {
                Navigator.pop(context);
                context.push('/auth/login');
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: context.l10n.createAccount,
              variant: AppButtonVariant.secondary,
              expand: true,
              onPressed: () {
                Navigator.pop(context);
                context.push('/auth/signup');
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.l10n.authRequiredDismiss,
                style:
                    AppTextStyles.small.copyWith(color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
