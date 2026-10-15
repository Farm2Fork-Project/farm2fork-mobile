import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_badge.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/core/widgets/app_state_placeholder.dart';
import 'package:farm2fork_mobile/core/utils/bidi_utils.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/shipment.dart';
import 'package:farm2fork_mobile/features/shipments/presentation/providers/shipments_controller.dart';

class ShipmentsScreen extends ConsumerWidget {
  const ShipmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shipmentsAsync = ref.watch(shipmentsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(context.l10n.deliveryHistoryTitle, style: AppTextStyles.h2),
        elevation: 0,
        backgroundColor: AppColors.backgroundLight,
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(shipmentsControllerProvider.notifier).fetchShipments(),
          color: AppColors.primaryGreen,
          child: shipmentsAsync.when(
            data: (dashboard) {
              if (!dashboard.mine.any(
                (s) =>
                    s.status == ShipmentStatus.delivered ||
                    s.status == ShipmentStatus.failed,
              )) {
                return AppEmptyState(
                  message: context.l10n.noDeliveriesYet,
                  icon: Icons.local_shipping_rounded,
                );
              }

              return ListView(
                padding: const EdgeInsets.all(AppSpacing.pagePadding),
                children: [
                  for (final shipment in dashboard.mine.where(
                    (s) =>
                        s.status == ShipmentStatus.delivered ||
                        s.status == ShipmentStatus.failed,
                  ))
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _ShipmentCard(shipment: shipment),
                    ),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            ),
            error: (error, stack) => AppErrorState(
              icon: Icons.error_outline_rounded,
              onRetry: () => ref
                  .read(shipmentsControllerProvider.notifier)
                  .fetchShipments(),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShipmentCard extends ConsumerStatefulWidget {
  const _ShipmentCard({required this.shipment});
  final Shipment shipment;
  @override
  ConsumerState<_ShipmentCard> createState() => _ShipmentCardState();
}

class _ShipmentCardState extends ConsumerState<_ShipmentCard> {
  Shipment get shipment => widget.shipment;
  @override
  Widget build(BuildContext context) {
    final statusColor = switch (shipment.status) {
      ShipmentStatus.assigned => AppColors.accentYellow,
      ShipmentStatus.pickedUp => AppColors.secondaryBlue,
      ShipmentStatus.inTransit => AppColors.primaryGreen,
      ShipmentStatus.delivered => AppColors.success,
      ShipmentStatus.failed => AppColors.errorRed,
    };

    final statusText = _statusLabel(context, shipment.status);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  context.l10n.shipmentNumber(isolateLtr(shipment.id)),
                  style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              AppBadge(
                label: statusText,
                backgroundColor: statusColor.withValues(alpha: 0.1),
                foregroundColor: statusColor,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.surfaceMedium),
          const SizedBox(height: AppSpacing.md),

          // Addresses
          _buildAddressRow(
            context,
            icon: Icons.storefront_rounded,
            label: context.l10n.pickupFarm,
            address:
                '${shipment.pickupAddress.street}, ${shipment.pickupAddress.city}',
          ),
          const SizedBox(height: AppSpacing.md),
          _buildAddressRow(
            context,
            icon: Icons.location_on_rounded,
            label: context.l10n.deliveryDestination,
            address:
                '${shipment.deliveryAddress.street}, ${shipment.deliveryAddress.city}',
          ),

          const SizedBox(height: AppSpacing.lg),
          const Divider(color: AppColors.surfaceMedium),
          const SizedBox(height: AppSpacing.md),

          // Real status timeline
          Text(context.l10n.shipmentTimeline, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          _buildTimeline(context),

          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildAddressRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String address,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primaryGreen),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 2),
              Text(address, style: AppTextStyles.body),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: shipment.statusHistory.length,
      itemBuilder: (context, index) {
        final update = shipment.statusHistory[index];
        final isLast = index == shipment.statusHistory.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: AppColors.primaryGreen.withValues(alpha: 0.3),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _statusLabel(context, update.status),
                            style: AppTextStyles.small.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryGreenDark,
                            ),
                          ),
                          Text(
                            '${update.timestamp.hour}:${update.timestamp.minute.toString().padLeft(2, '0')}',
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(update.note, style: AppTextStyles.body),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _statusLabel(BuildContext context, ShipmentStatus status) =>
      switch (status) {
        ShipmentStatus.assigned => context.l10n.shipmentAssigned,
        ShipmentStatus.pickedUp => context.l10n.shipmentPickedUp,
        ShipmentStatus.inTransit => context.l10n.shipmentInTransit,
        ShipmentStatus.delivered => context.l10n.shipmentDelivered,
        ShipmentStatus.failed => context.l10n.shipmentFailed,
      };
}
