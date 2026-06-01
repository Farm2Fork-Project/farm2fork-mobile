import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/core/widgets/section_header.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(context.l10n.createAccount, style: AppTextStyles.h3),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: [
          SectionHeader(title: context.l10n.signUpSelectRole),
          const SizedBox(height: AppSpacing.md),
          _RoleCard(
            icon: Icons.shopping_basket_rounded,
            label: context.l10n.roleBuyer,
            description: context.l10n.buyerRoleDescription,
            onTap: () => context.push('/auth/signup/buyer'),
          ),
          const SizedBox(height: AppSpacing.sm),
          _RoleCard(
            icon: Icons.agriculture_rounded,
            label: context.l10n.roleFarmer,
            description: context.l10n.farmerRoleDescription,
            onTap: () => context.push('/auth/signup/farmer'),
          ),
          const SizedBox(height: AppSpacing.sm),
          _RoleCard(
            icon: Icons.local_shipping_rounded,
            label: context.l10n.roleTransporter,
            description: context.l10n.transporterRoleDescription,
            onTap: () => context.push('/auth/signup/transporter'),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.l10n.alreadyHaveAccount,
                style: AppTextStyles.small.copyWith(color: AppColors.textMuted),
              ),
              TextButton(
                onPressed: () => context.go('/auth/login'),
                child: Text(
                  context.l10n.login,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryGreenSoft,
            child: Icon(icon, color: AppColors.primaryGreenDark),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textMuted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}
