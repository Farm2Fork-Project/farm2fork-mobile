import 'package:flutter/material.dart';
import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_avatar.dart';
import 'package:farm2fork_mobile/core/widgets/app_badge.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/core/widgets/app_notice_banner.dart';
import 'package:farm2fork_mobile/core/widgets/app_settings_tile.dart';
import 'package:farm2fork_mobile/core/widgets/section_header.dart';
import 'package:farm2fork_mobile/features/auth/data/models/auth_user.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/auth/presentation/utils/auth_role_l10n.dart';
import 'package:farm2fork_mobile/features/profile/presentation/providers/profile_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(authControllerProvider).asData?.value.user;
    // The backend's display name also falls back to the business or farm name;
    // until it loads (or if it fails) the signed-in user's own name is used.
    final profileState = ref.watch(profileControllerProvider);
    final loaded = profileState.asData?.value;
    final profile = loaded?.user.id == user?.id ? loaded : null;
    final displayName = profile?.displayName ?? user?.displayName;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(l10n.profile, style: AppTextStyles.h2),
        elevation: 0,
        backgroundColor: AppColors.backgroundLight,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(profileControllerProvider);
                try {
                  await ref.read(profileControllerProvider.future);
                } catch (_) {}
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.pagePadding),
                children: [
                  Text(
                    l10n.profileOverviewHint,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textMuted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (profileState.isLoading) ...[
                    const LinearProgressIndicator(),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  if (profileState.hasError) ...[
                    AppNoticeBanner(message: l10n.profileLoadFailed),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton(
                        onPressed: () =>
                            ref.invalidate(profileControllerProvider),
                        child: Text(l10n.retry),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  if (user != null && displayName != null) ...[
                    _ProfileHeader(
                      user: user.copyWith(
                        avatarUrl: profile?.user.avatarUrl,
                        clearAvatar:
                            profile != null && profile.user.avatarUrl == null,
                      ),
                      displayName: displayName,
                      onTap: () => context.push('/settings/profile'),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                  _Section(
                    title: l10n.profileSectionAccount,
                    children: [
                      AppSettingsTile(
                        title: l10n.editProfile,
                        subtitle: l10n.profileEditHint,
                        icon: Icons.person_outline_rounded,
                        onTap: () => context.push('/settings/profile'),
                      ),
                      AppSettingsTile(
                        title: l10n.notificationsTitle,
                        subtitle: l10n.profileNotificationHint,
                        icon: Icons.notifications_rounded,
                        onTap: () =>
                            context.push(AppNavConfig.notificationsRoute),
                      ),
                      if (user?.role == AppUserRole.farmer)
                        AppSettingsTile(
                          title: l10n.loansTitle,
                          icon: Icons.account_balance_rounded,
                          onTap: () =>
                              context.push(AppNavConfig.farmerLoansRoute),
                        ),
                      if (user?.role == AppUserRole.buyer)
                        AppSettingsTile(
                          title: l10n.feedTitle,
                          icon: Icons.forum_rounded,
                          onTap: () =>
                              context.push(AppNavConfig.buyerCommunityRoute),
                        ),
                    ],
                  ),
                  _Section(
                    title: l10n.profileSectionPreferences,
                    children: [
                      AppSettingsTile(
                        title: l10n.notificationSettings,
                        icon: Icons.notifications_none_rounded,
                        onTap: () => context.push('/settings/notifications'),
                      ),
                      AppSettingsTile(
                        title: l10n.languageDisplay,
                        subtitle: l10n.profilePreferencesHint,
                        icon: Icons.language_rounded,
                        onTap: () => context.push('/settings/language-display'),
                      ),
                    ],
                  ),
                  _Section(
                    title: l10n.helpInformation,
                    children: [
                      AppSettingsTile(
                        title: l10n.contactUs,
                        icon: Icons.chat_bubble_outline_rounded,
                        onTap: () => context.push('/settings/contact-us'),
                      ),
                      AppSettingsTile(
                        title: l10n.faqs,
                        icon: Icons.help_outline_rounded,
                        onTap: () => context.push('/settings/faqs'),
                      ),
                      AppSettingsTile(
                        title: l10n.aboutUs,
                        icon: Icons.info_outline_rounded,
                        onTap: () => context.push('/settings/about'),
                      ),
                      AppSettingsTile(
                        title: l10n.privacyPolicy,
                        icon: Icons.security_rounded,
                        onTap: () => context.push('/settings/privacy'),
                      ),
                      AppSettingsTile(
                        title: l10n.termsConditions,
                        icon: Icons.description_outlined,
                        onTap: () => context.push('/settings/terms'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const _SignOutSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Avatar, name, role, email and verification state. The whole card opens Edit
/// profile.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.user,
    required this.displayName,
    required this.onTap,
  });

  final AuthUser user;
  final String displayName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final roleLabel = user.role.localizedLabel(context);
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          AppAvatar(name: displayName, imageUrl: user.avatarUrl, size: 64),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.ltr,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    AppBadge(label: roleLabel, icon: user.role.icon),
                    if (user.isVerified)
                      AppBadge(
                        label: l10n.verifiedBadge,
                        icon: Icons.verified_rounded,
                        backgroundColor: AppColors.secondaryBlueSoft,
                        foregroundColor: AppColors.secondaryBlue,
                      )
                    else
                      AppBadge(
                        label: l10n.notVerifiedBadge,
                        icon: Icons.error_outline_rounded,
                        backgroundColor: AppColors.accentYellowSoft,
                        foregroundColor: AppColors.textDark,
                      ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.chevron_left_rounded
                : Icons.chevron_right_rounded,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title, titleColor: AppColors.primaryGreenDark),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            padding: EdgeInsets.zero,
            // ListTile ink needs a Material between it and the card's coloured
            // decoration, or taps show no feedback.
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    if (i > 0)
                      const Divider(color: AppColors.surfaceMedium, height: 1),
                    children[i],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sign out confirms in place: the button expands into a short question with
/// Cancel and Logout, rather than opening a dialog.
class _SignOutSection extends ConsumerStatefulWidget {
  const _SignOutSection();

  @override
  ConsumerState<_SignOutSection> createState() => _SignOutSectionState();
}

class _SignOutSectionState extends ConsumerState<_SignOutSection> {
  final _key = GlobalKey();
  bool _confirming = false;
  bool _working = false;
  String? _error;

  void _ask() {
    setState(() {
      _confirming = true;
      _error = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _key.currentContext;
      if (ctx != null && ctx.mounted) {
        Scrollable.ensureVisible(
          ctx,
          duration: MediaQuery.disableAnimationsOf(ctx)
              ? Duration.zero
              : const Duration(milliseconds: 200),
        );
      }
    });
  }

  Future<void> _confirm() async {
    setState(() {
      _working = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).signOut();
      // Normally the router replaces this screen first; if not, stop spinning.
      if (mounted) setState(() => _working = false);
    } catch (_) {
      if (mounted) {
        setState(() {
          _working = false;
          _error = context.l10n.authErrorGeneric;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (!_confirming) {
      return KeyedSubtree(
        key: _key,
        child: AppButton(
          label: l10n.logout,
          icon: Icons.logout_rounded,
          variant: AppButtonVariant.quiet,
          expand: true,
          onPressed: _ask,
        ),
      );
    }
    return KeyedSubtree(
      key: _key,
      child: Semantics(
        liveRegion: true,
        container: true,
        child: AppCard(
          borderColor: AppColors.errorRed.withValues(alpha: 0.4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.logoutConfirmTitle, style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.logoutConfirmMessage,
                style: AppTextStyles.small.copyWith(
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.md),
                AppNoticeBanner(message: _error!),
              ],
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: l10n.cancel,
                      variant: AppButtonVariant.quiet,
                      expand: true,
                      onPressed: _working
                          ? null
                          : () => setState(() => _confirming = false),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: l10n.logout,
                      variant: AppButtonVariant.danger,
                      expand: true,
                      isLoading: _working,
                      onPressed: _working ? null : _confirm,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
