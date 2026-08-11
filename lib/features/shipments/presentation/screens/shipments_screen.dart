import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_badge.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/available_delivery.dart';
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
        title: Text(context.l10n.shipmentsTitle, style: AppTextStyles.h2),
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
              if (dashboard.available.isEmpty && dashboard.mine.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_shipping_rounded,
                          size: 64,
                          color: AppColors.textMuted.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          context.l10n.noDataFound,
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(AppSpacing.pagePadding),
                children: [
                  if (dashboard.available.isNotEmpty) ...[
                    Text(
                      context.l10n.availableDeliveries,
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    for (final delivery in dashboard.available)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _AvailableDeliveryCard(delivery: delivery),
                      ),
                  ],
                  if (dashboard.mine.isNotEmpty) ...[
                    if (dashboard.available.isNotEmpty)
                      const SizedBox(height: AppSpacing.lg),
                    Text(context.l10n.myDeliveries, style: AppTextStyles.h3),
                    const SizedBox(height: AppSpacing.md),
                    for (final shipment in dashboard.mine)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _ShipmentCard(shipment: shipment),
                      ),
                  ],
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.errorRed,
                    size: 48,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(context.l10n.errorOccurred, style: AppTextStyles.body),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () => ref
                        .read(shipmentsControllerProvider.notifier)
                        .fetchShipments(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                    ),
                    child: Text(
                      context.l10n.retry,
                      style: const TextStyle(color: AppColors.white),
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

class _AvailableDeliveryCard extends ConsumerWidget {
  const _AvailableDeliveryCard({required this.delivery});

  final AvailableDelivery delivery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.deliveryRequest, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${delivery.pickupCity}, ${delivery.pickupProvince} → ${delivery.deliveryCity}, ${delivery.deliveryProvince}',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.deliveryItemCount(delivery.itemCount),
            style: AppTextStyles.small.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => ref
                  .read(shipmentsControllerProvider.notifier)
                  .claim(delivery.orderId),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.white,
              ),
              child: Text(context.l10n.claimDelivery),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShipmentCard extends ConsumerWidget {
  const _ShipmentCard({required this.shipment});
  final Shipment shipment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              Text(
                context.l10n.shipmentNumber(shipment.id),
                style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
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

          // Update Status Action Buttons
          if (shipment.status != ShipmentStatus.delivered &&
              shipment.status != ShipmentStatus.failed) ...[
            const Divider(color: AppColors.surfaceMedium),
            const SizedBox(height: AppSpacing.md),
            _buildUpdateControls(context, ref),
          ],
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
                            update.status.name.toUpperCase(),
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

  Widget _buildUpdateControls(BuildContext context, WidgetRef ref) {
    final nextStatus = switch (shipment.status) {
      ShipmentStatus.assigned => ShipmentStatus.pickedUp,
      ShipmentStatus.pickedUp => ShipmentStatus.inTransit,
      ShipmentStatus.inTransit => ShipmentStatus.delivered,
      _ => null,
    };

    if (nextStatus == null) return const SizedBox.shrink();

    final actionLabel = switch (nextStatus) {
      ShipmentStatus.pickedUp => context.l10n.confirmPickup,
      ShipmentStatus.inTransit => context.l10n.startTransit,
      ShipmentStatus.delivered => context.l10n.confirmDelivery,
      _ => '',
    };

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          ref
              .read(shipmentsControllerProvider.notifier)
              .updateShipmentStatus(
                shipmentId: shipment.id,
                status: nextStatus,
                note: context.l10n.shipmentStatusUpdate(
                  _statusLabel(context, nextStatus),
                ),
              );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
        child: Text(
          actionLabel,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
      ),
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
