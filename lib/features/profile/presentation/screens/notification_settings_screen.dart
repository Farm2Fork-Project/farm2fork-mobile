import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/core/widgets/app_notice_banner.dart';
import 'package:farm2fork_mobile/features/notifications/data/notifications_repository.dart';
import 'package:farm2fork_mobile/features/notifications/presentation/widgets/notification_entry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/notifications/push_controller.dart';

final notificationsInboxProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  if (ref.watch(authControllerProvider).value?.user == null) return [];
  final list = await ref.watch(notificationsProvider.future);
  return [
    for (final n in list)
      {
        'id': n.id,
        'title': n.title,
        'message': n.message,
        'isRead': n.isRead,
        'type': n.kind.wire,
        'createdAt': n.createdAt.toIso8601String(),
      },
  ];
});

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});
  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsState();
}

class _NotificationSettingsState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _busy = false;
  bool _error = false;
  bool _denied = false;
  Future<void> _toggle(bool enabled) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = false;
      _denied = false;
    });
    try {
      final controller = ref.read(pushControllerProvider.notifier);
      if (enabled) {
        await controller.disable();
      } else {
        final granted = await controller.enable();
        if (mounted) setState(() => _denied = !granted);
      }
    } catch (_) {
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _readAll() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = false;
    });
    try {
      await ref.read(notificationActionsProvider).markAllRead();
    } catch (_) {
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = ref.watch(authControllerProvider).value?.user;
    final push = ref.watch(pushControllerProvider);
    final inbox = ref.watch(notificationsInboxProvider);
    final enabled = push.value ?? false;
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(l10n.notificationSettings, style: AppTextStyles.h3),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.notifications_outlined,
                        color: AppColors.primaryGreenDark,
                        size: 28,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        l10n.notificationDeviceAlerts,
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.pushDescription,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textMuted,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (push.isLoading)
                        const LinearProgressIndicator()
                      else
                        Text(
                          enabled
                              ? l10n.notificationEnabled
                              : l10n.notificationDisabled,
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.primaryGreenDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      const SizedBox(height: AppSpacing.lg),
                      AppButton(
                        label: enabled ? l10n.pushDisable : l10n.pushEnable,
                        expand: true,
                        isLoading: _busy,
                        onPressed: _busy || push.isLoading || user == null
                            ? null
                            : () => _toggle(enabled),
                      ),
                      if (user == null) Text(l10n.pushSignIn),
                      if (_denied) ...[
                        const SizedBox(height: AppSpacing.md),
                        AppNoticeBanner(
                          message: l10n.pushDenied,
                          kind: AppNoticeKind.info,
                        ),
                      ],
                      if (_error || push.hasError) ...[
                        const SizedBox(height: AppSpacing.md),
                        AppNoticeBanner(message: l10n.errorOccurred),
                      ],
                      if (push.hasError)
                        TextButton(
                          onPressed: () =>
                              ref.invalidate(pushControllerProvider),
                          child: Text(l10n.retry),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(l10n.pushInbox, style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.notificationInboxHint,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    TextButton(
                      onPressed: _busy || inbox.isLoading
                          ? null
                          : () => ref.invalidate(notificationsProvider),
                      child: Text(l10n.dispatchRefresh),
                    ),
                    TextButton(
                      onPressed:
                          _busy ||
                              user == null ||
                              inbox.isLoading ||
                              !(inbox.value?.any((n) => n['isRead'] == false) ??
                                  false)
                          ? null
                          : _readAll,
                      child: Text(l10n.pushReadAll),
                    ),
                  ],
                ),
                inbox.when(
                  loading: () => Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Semantics(
                      label: l10n.loading,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  error: (_, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppNoticeBanner(message: l10n.errorOccurred),
                      TextButton(
                        onPressed: () => ref.invalidate(notificationsProvider),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                  data: (items) => Column(
                    children: [
                      if (items.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Text(l10n.pushEmpty),
                        ),
                      for (final item in items.take(3))
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: NotificationEntry(
                            notification: AppNotification.fromJson(item),
                            onTap: () => context.push('/notifications'),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: l10n.notificationViewInbox,
                  variant: AppButtonVariant.quiet,
                  expand: true,
                  onPressed: user == null
                      ? null
                      : () => context.push('/notifications'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
