import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/core/widgets/section_header.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/auth/presentation/utils/auth_role_l10n.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.asData?.value.user;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(context.l10n.profile, style: AppTextStyles.h2),
        elevation: 0,
        backgroundColor: AppColors.backgroundLight,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: [
            // User profile card
            if (user != null) ...[
              AppCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primaryGreenSoft,
                      child: Icon(
                        user.role.icon,
                        color: AppColors.primaryGreenDark,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.signedInAsRole(
                              user.role.localizedLabel(context),
                            ),
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.email,
                            style: AppTextStyles.small.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // App Settings section
            SectionHeader(
              title: context.l10n.appSettings,
              titleColor: AppColors.primaryGreenDark,
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsTile(
                    title: context.l10n.notificationSettings,
                    icon: Icons.notifications_none_rounded,
                    onTap: () => context.push('/settings/notifications'),
                  ),
                  const Divider(color: AppColors.surfaceMedium, height: 1),
                  _SettingsTile(
                    title: context.l10n.languageDisplay,
                    icon: Icons.language_rounded,
                    onTap: () => context.push('/settings/language-display'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Help & Information section
            SectionHeader(
              title: context.l10n.helpInformation,
              titleColor: AppColors.primaryGreenDark,
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsTile(
                    title: context.l10n.contactUs,
                    icon: Icons.chat_bubble_outline_rounded,
                    onTap: () => context.push('/settings/contact-us'),
                  ),
                  const Divider(color: AppColors.surfaceMedium, height: 1),
                  _SettingsTile(
                    title: context.l10n.faqs,
                    icon: Icons.help_outline_rounded,
                    onTap: () => context.push('/settings/faqs'),
                  ),
                  const Divider(color: AppColors.surfaceMedium, height: 1),
                  _SettingsTile(
                    title: context.l10n.aboutUs,
                    icon: Icons.info_outline_rounded,
                    onTap: () => context.push('/settings/about'),
                  ),
                  const Divider(color: AppColors.surfaceMedium, height: 1),
                  _SettingsTile(
                    title: context.l10n.privacyPolicy,
                    icon: Icons.security_rounded,
                    onTap: () => context.push('/settings/privacy'),
                  ),
                  const Divider(color: AppColors.surfaceMedium, height: 1),
                  _SettingsTile(
                    title: context.l10n.termsConditions,
                    icon: Icons.description_outlined,
                    onTap: () => context.push('/settings/terms'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Logout Button
            AppButton(
              label: context.l10n.logout,
              icon: Icons.logout_rounded,
              variant: AppButtonVariant.danger,
              expand: true,
              onPressed: authState.isLoading
                  ? null
                  : () => ref.read(authControllerProvider.notifier).signOut(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 2,
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: AppColors.primaryGreenSoft,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: AppColors.primaryGreenDark,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textMuted,
      ),
      onTap: onTap,
    );
  }
}
