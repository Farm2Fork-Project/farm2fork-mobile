import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/utils/number_formatters.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/core/widgets/app_notice_banner.dart';
import 'package:farm2fork_mobile/core/widgets/app_state_placeholder.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/notifications/data/notifications_repository.dart';
import 'package:farm2fork_mobile/features/notifications/presentation/notification_routes.dart';
import 'package:farm2fork_mobile/features/notifications/presentation/widgets/notification_entry.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});
  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsState();
}

class _NotificationsState extends ConsumerState<NotificationsScreen> {
  bool _unreadOnly = false;
  bool _busy = false;
  bool _error = false;
  final _read = <String>{};

  Future<void> _mark({AppNotification? item}) async {
    if (_busy || (item != null && (item.isRead || _read.contains(item.id)))) {
      return;
    }
    setState(() {
      _busy = true;
      _error = false;
    });
    try {
      final actions = ref.read(notificationActionsProvider);
      if (item == null) {
        await actions.markAllRead();
      } else {
        await actions.markRead(item.id);
      }
      if (!mounted) return;
      setState(() {
        if (item != null) {
          _read.add(item.id);
        } else {
          _read.addAll(
            ref.read(notificationsProvider).value?.map((n) => n.id) ??
                <String>[],
          );
        }
      });

    } catch (_) {
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _refresh() async {
    if (_busy) return;
    ref.invalidate(notificationsProvider);
    ref.invalidate(unreadNotificationsProvider);
    try {
      await ref.read(notificationsProvider.future);
    } catch (_) {
      /* Provider shows the retry state. */
    }
  }

  Future<void> _open(AppNotification n) async {
    final role = ref.read(authControllerProvider).value?.role;
    final route = role == null
        ? null
        : routeForNotification(
            role: role,
            type: n.kind.wire,
            relatedEntityId: n.relatedEntityId,
            relatedEntityModel: n.relatedEntityModel,
          );
    // Reading the content never depends on the network write succeeding.
    unawaited(_mark(item: n));
    final navigate = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.white,
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (sheetContext) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * .8,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(n.title, style: AppTextStyles.h3)),
                    IconButton(
                      tooltip: context.l10n.close,
                      onPressed: () => sheetContext.pop(false),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  formatShortDate(n.createdAt, Localizations.localeOf(context)),
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  n.message,
                  style: AppTextStyles.body.copyWith(height: 1.6),
                ),
                if (route != null) ...[
                  const SizedBox(height: AppSpacing.xxl),
                  AppButton(
                    label: context.l10n.notificationViewRelated,
                    expand: true,
                    onPressed: () => sheetContext.pop(true),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    if (!mounted || navigate != true || route == null) return;
    if (route.startsWith('/shipments/')) {
      context.push(route);
    } else {
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = ref.watch(notificationsProvider);
    final list = items.value
        ?.map((n) => _read.contains(n.id) ? n.read() : n)
        .toList();
    final unread = list?.where((n) => !n.isRead).length ?? 0;
    final visible = _unreadOnly ? list?.where((n) => !n.isRead).toList() : list;
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(l10n.notificationsTitle, style: AppTextStyles.h3),
        actions: [
          IconButton(
            tooltip: l10n.notificationSettings,
            onPressed: () => context.push('/settings/notifications'),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: RefreshIndicator(
              color: AppColors.primaryGreen,
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(AppSpacing.pagePadding),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.notificationInboxHint,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              ChoiceChip(
                                selectedColor: AppColors.primaryGreenSoft,
                                checkmarkColor: AppColors.primaryGreenDark,
                                label: Text(l10n.notificationAll),
                                selected: !_unreadOnly,
                                onSelected: (_) =>
                                    setState(() => _unreadOnly = false),
                              ),
                              ChoiceChip(
                                selectedColor: AppColors.primaryGreenSoft,
                                checkmarkColor: AppColors.primaryGreenDark,
                                label: Text('${l10n.pushUnread} ($unread)'),
                                selected: _unreadOnly,
                                onSelected: (_) =>
                                    setState(() => _unreadOnly = true),
                              ),
                              TextButton(
                                onPressed:
                                    _busy || items.isLoading || unread == 0
                                    ? null
                                    : () => _mark(),
                                child: Text(
                                  _busy
                                      ? l10n.notificationUpdating
                                      : l10n.markAllRead,
                                ),
                              ),
                            ],
                          ),
                          if (_error) ...[
                            const SizedBox(height: AppSpacing.md),
                            AppNoticeBanner(
                              message: l10n.notificationUpdateFailed,
                              kind: AppNoticeKind.error,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (items.isLoading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (items.hasError)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: AppErrorState(
                        onRetry: () => ref.invalidate(notificationsProvider),
                      ),
                    )
                  else if (visible == null || visible.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: AppEmptyState(
                        message: _unreadOnly
                            ? l10n.notificationCaughtUp
                            : l10n.noNotificationsYet,
                        subtitle: l10n.notificationEmptyHint,
                        icon: Icons.notifications_none_rounded,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverList.separated(
                        itemCount: visible.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (_, index) => NotificationEntry(
                          notification: visible[index],
                          onTap: _busy ? null : () => _open(visible[index]),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
