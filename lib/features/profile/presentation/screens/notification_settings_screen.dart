import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';

final orderUpdatesProvider = NotifierProvider<_OrderUpdatesNotifier, bool>(
  _OrderUpdatesNotifier.new,
);

class _OrderUpdatesNotifier extends Notifier<bool> {
  @override
  bool build() => true;
  void set(bool val) => state = val;
}

final shipmentUpdatesProvider = NotifierProvider<_ShipmentUpdatesNotifier, bool>(
  _ShipmentUpdatesNotifier.new,
);

class _ShipmentUpdatesNotifier extends Notifier<bool> {
  @override
  bool build() => true;
  void set(bool val) => state = val;
}

final communityAlertsProvider = NotifierProvider<_CommunityAlertsNotifier, bool>(
  _CommunityAlertsNotifier.new,
);

class _CommunityAlertsNotifier extends Notifier<bool> {
  @override
  bool build() => true;
  void set(bool val) => state = val;
}

final marketingAlertsProvider = NotifierProvider<_MarketingAlertsNotifier, bool>(
  _MarketingAlertsNotifier.new,
);

class _MarketingAlertsNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool val) => state = val;
}

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderUpdates = ref.watch(orderUpdatesProvider);
    final shipmentUpdates = ref.watch(shipmentUpdatesProvider);
    final communityAlerts = ref.watch(communityAlertsProvider);
    final marketingAlerts = ref.watch(marketingAlertsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(context.l10n.notificationsTitle, style: AppTextStyles.h2),
        elevation: 0,
        backgroundColor: AppColors.backgroundLight,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Text(
                context.l10n.notificationsSubtitle,
                style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
              ),
            ),
            AppCard(
              child: Column(
                children: [
                  _buildSwitchTile(
                    context,
                    title: context.l10n.orderUpdates,
                    subtitle: context.l10n.orderUpdatesDesc,
                    value: orderUpdates,
                    icon: Icons.receipt_long_rounded,
                    onChanged: (val) =>
                        ref.read(orderUpdatesProvider.notifier).set(val),
                  ),
                  const Divider(color: AppColors.surfaceMedium, height: 1),
                  _buildSwitchTile(
                    context,
                    title: context.l10n.shipmentUpdates,
                    subtitle: context.l10n.shipmentUpdatesDesc,
                    value: shipmentUpdates,
                    icon: Icons.local_shipping_rounded,
                    onChanged: (val) =>
                        ref.read(shipmentUpdatesProvider.notifier).set(val),
                  ),
                  const Divider(color: AppColors.surfaceMedium, height: 1),
                  _buildSwitchTile(
                    context,
                    title: context.l10n.communityAlerts,
                    subtitle: context.l10n.communityAlertsDesc,
                    value: communityAlerts,
                    icon: Icons.forum_rounded,
                    onChanged: (val) =>
                        ref.read(communityAlertsProvider.notifier).set(val),
                  ),
                  const Divider(color: AppColors.surfaceMedium, height: 1),
                  _buildSwitchTile(
                    context,
                    title: context.l10n.marketingAlerts,
                    subtitle: context.l10n.marketingAlertsDesc,
                    value: marketingAlerts,
                    icon: Icons.campaign_rounded,
                    onChanged: (val) =>
                        ref.read(marketingAlertsProvider.notifier).set(val),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: const BoxDecoration(
              color: AppColors.primaryGreenSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primaryGreenDark,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primaryGreen,
            activeTrackColor: AppColors.primaryGreenSoft,
            inactiveThumbColor: AppColors.textMuted,
            inactiveTrackColor: AppColors.surfaceMedium,
          ),
        ],
      ),
    );
  }
}
