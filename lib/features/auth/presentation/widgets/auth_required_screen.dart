import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';

/// Full-screen auth prompt shown in the Cart tab for guest users.
class AuthRequiredScreen extends StatelessWidget {
  const AuthRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(context.l10n.navCart, style: AppTextStyles.h3),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shopping_basket_outlined,
                size: 64,
                color: AppColors.primaryGreenSoft,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                context.l10n.loginRequired,
                style: AppTextStyles.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                context.l10n.loginToAddToCart,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppButton(
                label: context.l10n.login,
                expand: true,
                onPressed: () => context.push('/auth/login'),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: context.l10n.createAccount,
                variant: AppButtonVariant.secondary,
                expand: true,
                onPressed: () => context.push('/auth/signup'),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: () => context.go('/guest/marketplace'),
                child: Text(
                  context.l10n.authRequiredDismiss,
                  style:
                      AppTextStyles.small.copyWith(color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
