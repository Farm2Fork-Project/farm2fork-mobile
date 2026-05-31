import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';

class GuestAccountScreen extends StatelessWidget {
  const GuestAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(context.l10n.profile, style: AppTextStyles.h3),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primaryGreenSoft,
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 40,
                  color: AppColors.primaryGreenDark,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                context.l10n.welcomeToFarm2Fork,
                style: AppTextStyles.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                context.l10n.guestWelcomeSubtitle,
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
            ],
          ),
        ),
      ),
    );
  }
}
