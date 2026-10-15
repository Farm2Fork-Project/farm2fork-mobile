import 'package:flutter/material.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/utils/number_formatters.dart';
import 'package:farm2fork_mobile/features/notifications/data/notifications_repository.dart';

IconData notificationIcon(NotificationKind kind) => switch (kind) {
  NotificationKind.orderPlaced => Icons.receipt_long_rounded,
  NotificationKind.paymentConfirmed => Icons.payments_rounded,
  NotificationKind.shipmentAssigned => Icons.person_pin_circle_rounded,
  NotificationKind.deliveryUpdate => Icons.local_shipping_rounded,
  NotificationKind.loanUpdate => Icons.account_balance_rounded,
  NotificationKind.deliveryOffer => Icons.campaign_rounded,
  NotificationKind.adminAction => Icons.info_outline_rounded,
};

class NotificationEntry extends StatelessWidget {
  const NotificationEntry({
    super.key,
    required this.notification,
    required this.onTap,
  });
  final AppNotification notification;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final n = notification;
    return Material(
      color: n.isRead ? AppColors.white : AppColors.primaryGreenSoft,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.surfaceLight,
                child: Icon(
                  notificationIcon(n.kind),
                  color: AppColors.primaryGreenDark,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!n.isRead) ...[
                      Text(
                        context.l10n.pushUnread,
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.primaryGreenDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                    ],
                    Text(
                      n.title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: n.isRead
                            ? FontWeight.w600
                            : FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      n.message,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.textMuted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      formatShortDate(
                        n.createdAt,
                        Localizations.localeOf(context),
                      ),
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
      ),
    );
  }
}
