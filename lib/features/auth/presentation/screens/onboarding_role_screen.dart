import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/core/widgets/section_header.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/onboarding_session.dart';

/// Post-sign-in role picker: a new identity chooses farmer/buyer/transporter
/// before completing the matching KYC form.
class OnboardingRoleScreen extends ConsumerWidget {
  const OnboardingRoleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(onboardingSessionProvider);

    // Reached without an active onboarding (e.g. deep link): back to login.
    if (session == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/auth/login');
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(context.l10n.createAccount, style: AppTextStyles.h3),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: [
          SectionHeader(
            title: context.l10n.signUpSelectRole,
            subtitle: context.l10n.onboardingProfileSubtitle,
          ),
          const SizedBox(height: AppSpacing.md),
          _RoleCard(
            icon: Icons.agriculture_rounded,
            label: context.l10n.roleFarmer,
            description: context.l10n.farmerRoleDescription,
            onTap: () => context.push('/auth/onboarding/farmer'),
          ),
          const SizedBox(height: AppSpacing.sm),
          _RoleCard(
            icon: Icons.shopping_basket_rounded,
            label: context.l10n.roleBuyer,
            description: context.l10n.buyerRoleDescription,
            onTap: () => context.push('/auth/onboarding/buyer'),
          ),
          const SizedBox(height: AppSpacing.sm),
          _RoleCard(
            icon: Icons.local_shipping_rounded,
            label: context.l10n.roleTransporter,
            description: context.l10n.transporterRoleDescription,
            onTap: () => context.push('/auth/onboarding/transporter'),
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
