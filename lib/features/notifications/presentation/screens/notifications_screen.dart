import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/utils/number_formatters.dart';
import 'package:farm2fork_mobile/core/widgets/app_state_placeholder.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/notifications/data/notifications_repository.dart';
import 'package:farm2fork_mobile/features/notifications/presentation/notification_routes.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _icon(NotificationKind kind) => switch (kind) {
    NotificationKind.orderPlaced => Icons.receipt_long_rounded,
    NotificationKind.paymentConfirmed => Icons.payments_rounded,
    NotificationKind.shipmentAssigned => Icons.person_pin_circle_rounded,
    NotificationKind.deliveryUpdate => Icons.local_shipping_rounded,
    NotificationKind.loanUpdate => Icons.account_balance_rounded,
    NotificationKind.deliveryOffer => Icons.campaign_rounded,
    NotificationKind.adminAction => Icons.info_rounded,
  };

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    AppNotification n,
  ) async {
    final repo = ref.read(notificationsRepositoryProvider);
    if (!n.isRead) {
      await repo.markRead(n.id).catchError((_) {});
      ref
        ..invalidate(notificationsProvider)
        ..invalidate(unreadNotificationsProvider);
    }
    final role = ref.read(authControllerProvider).asData?.value.role;
    if (role == null || !context.mounted) return;
    final route = routeForNotification(
      role: role,
      type: n.kind.wire,
      relatedEntityId: n.relatedEntityId,
      relatedEntityModel: n.relatedEntityModel,
    );
    if (route == null) return;
    // Tabs are switched with go, detail screens are pushed.
    if (route.startsWith('/shipments/')) {
      context.push(route);
    } else {
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final items = ref.watch(notificationsProvider);
    final locale = Localizations.localeOf(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(l10n.notificationsTitle, style: AppTextStyles.h3),
        backgroundColor: AppColors.backgroundLight,
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(notificationsRepositoryProvider).markAllRead();
              ref
                ..invalidate(notificationsProvider)
                ..invalidate(unreadNotificationsProvider);
            },
            child: Text(l10n.markAllRead),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryGreen,
        onRefresh: () async {
          ref
            ..invalidate(notificationsProvider)
            ..invalidate(unreadNotificationsProvider);
          await ref.read(notificationsProvider.future);
        },
        child: items.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          ),
          error: (_, _) => AppErrorState(
            onRetry: () => ref.invalidate(notificationsProvider),
          ),
          data: (list) => list.isEmpty
              ? AppEmptyState(
                  message: l10n.noNotificationsYet,
                  icon: Icons.notifications_none_rounded,
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  itemCount: list.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: AppColors.surfaceMedium),
                  itemBuilder: (context, index) {
                    final n = list[index];
                    return ListTile(
                      tileColor: n.isRead
                          ? null
                          : AppColors.primaryGreen.withValues(alpha: 0.06),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryGreenSoft,
                        child: Icon(
                          _icon(n.kind),
                          color: AppColors.primaryGreenDark,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        n.title,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: n.isRead
                              ? FontWeight.w500
                              : FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        '${n.message}\n${formatShortDate(n.createdAt, locale)}',
                        style: AppTextStyles.small.copyWith(height: 1.4),
                      ),
                      isThreeLine: true,
                      onTap: () => _open(context, ref, n),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
