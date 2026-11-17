import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/utils/number_formatters.dart';
import 'package:farm2fork_mobile/features/shipments/presentation/widgets/delivery_route.dart';
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

class _ShipmentCard extends StatelessWidget {
  const _ShipmentCard({required this.shipment});

  final Shipment shipment;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final failed = shipment.status == ShipmentStatus.failed;
    final statusColor = failed ? AppColors.errorRed : AppColors.success;
    final finished = shipment.actualDelivery ?? shipment.updatedAt;
    final fee = shipment.deliveryFee;
    String place(ShipmentAddress a) =>
        [a.street, a.city].where((part) => part.isNotEmpty).join(', ');

    return AppCard(
      onTap: () => context.push('/shipments/${shipment.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  MaterialLocalizations.of(
                    context,
                  ).formatMediumDate(finished.toLocal()),
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              AppBadge(
                label: failed ? l10n.shipmentFailed : l10n.shipmentDelivered,
                backgroundColor: statusColor.withValues(alpha: 0.1),
                foregroundColor: statusColor,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          DeliveryRoute(
            pickup: RouteStop(
              label: l10n.pickupFarm,
              title: place(shipment.pickupAddress),
            ),
            dropoff: RouteStop(
              label: l10n.deliveryDestination,
              title: place(shipment.deliveryAddress),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1, color: AppColors.surfaceMedium),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.shipmentNumber(isolateLtr(_shortId(shipment.id))),
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              if (fee != null && !failed)
                Text(
                  l10n.currencyAmount(
                    formatCurrencyAmount(fee, Localizations.localeOf(context)),
                  ),
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreenDark,
                  ),
                ),
              const SizedBox(width: AppSpacing.xs),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Database ids are 24 characters; the tail is enough to tell two apart.
  static String _shortId(String id) =>
      id.length > 8 ? id.substring(id.length - 6).toUpperCase() : id;
}
