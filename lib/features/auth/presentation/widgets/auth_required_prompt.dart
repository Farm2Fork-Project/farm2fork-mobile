import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';

class AuthRequiredPrompt extends StatelessWidget {
  const AuthRequiredPrompt({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.showDismiss = true,
    this.onLogin,
    this.onSignup,
    this.onDismiss,
  });

  final String message;
  final String? title;
  final IconData? icon;
  final bool showDismiss;
  final VoidCallback? onLogin;
  final VoidCallback? onSignup;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final promptTitle = title ?? context.l10n.loginRequired;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primaryGreenSoft,
            child: Icon(
              icon ?? Icons.lock_outline_rounded,
              color: AppColors.primaryGreenDark,
              size: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            promptTitle,
            style: AppTextStyles.h3,
            textAlign: TextAlign.center,
          ),
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
            onPressed: onLogin ?? () => context.push('/auth/login'),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: context.l10n.createAccount,
            variant: AppButtonVariant.secondary,
            expand: true,
            onPressed: onSignup ?? () => context.push('/auth/login'),
          ),
          if (showDismiss) ...[
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: onDismiss ?? () => Navigator.pop(context),
              child: Text(
                context.l10n.authRequiredDismiss,
                style: AppTextStyles.small.copyWith(color: AppColors.textMuted),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Future<void> showAuthRequiredSheet(
  BuildContext context, {
  required String message,
  String? title,
  IconData? icon,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePadding,
          AppSpacing.lg,
          AppSpacing.pagePadding,
          AppSpacing.pagePadding,
        ),
        child: AuthRequiredPrompt(
          message: message,
          title: title,
          icon: icon,
          onLogin: () {
            Navigator.pop(context);
            context.push('/auth/login');
          },
          onSignup: () {
            Navigator.pop(context);
            context.push('/auth/login');
          },
          onDismiss: () => Navigator.pop(context),
        ),
      ),
    ),
  );
}
