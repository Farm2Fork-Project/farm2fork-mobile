import 'package:flutter/material.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/shipment.dart';

/// One end of a delivery: where it is and, once known, who to call there.
class RouteStop {
  const RouteStop({required this.label, required this.title, this.detail});

  final String label;
  final String title;
  final String? detail;
}

/// Pickup and drop-off drawn as two connected stops, so the direction of
/// travel reads at a glance in both LTR and RTL.
class DeliveryRoute extends StatelessWidget {
  const DeliveryRoute({super.key, required this.pickup, required this.dropoff});

  final RouteStop pickup;
  final RouteStop dropoff;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _Stop(stop: pickup, filled: false, connectBelow: true),
      _Stop(stop: dropoff, filled: true, connectBelow: false),
    ],
  );
}

class _Stop extends StatelessWidget {
  const _Stop({
    required this.stop,
    required this.filled,
    required this.connectBelow,
  });

  final RouteStop stop;
  final bool filled;
  final bool connectBelow;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 20,
          child: Column(
            children: [
              const SizedBox(height: 3),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled ? AppColors.primaryGreen : AppColors.white,
                  border: Border.all(color: AppColors.primaryGreen, width: 2.5),
                ),
              ),
              if (connectBelow)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    color: AppColors.surfaceStrong,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: connectBelow ? AppSpacing.md : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stop.label, style: AppTextStyles.label),
                const SizedBox(height: 2),
                Text(
                  stop.title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                if (stop.detail != null && stop.detail!.isNotEmpty)
                  Text(
                    stop.detail!,
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.textMuted,
                      height: 1.35,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

/// Pick up → on the way → hand over, with the current step highlighted.
class DeliveryProgress extends StatelessWidget {
  const DeliveryProgress({super.key, required this.status});

  final ShipmentStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = switch (status) {
      ShipmentStatus.assigned => 0,
      ShipmentStatus.pickedUp => 1,
      ShipmentStatus.inTransit => 2,
      ShipmentStatus.delivered => 3,
      ShipmentStatus.failed => -1,
    };
    final labels = [
      l10n.deliveryStepPickup,
      l10n.deliveryStepOnTheWay,
      l10n.deliveryStepHandover,
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                end: i == labels.length - 1 ? 0 : AppSpacing.xs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      color: i < current
                          ? AppColors.primaryGreen
                          : i == current
                          ? AppColors.accentYellow
                          : AppColors.surfaceMedium,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    labels[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label.copyWith(
                      color: i <= current
                          ? AppColors.textDark
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Small rounded fact, e.g. a distance or an item count.
class DeliveryFact extends StatelessWidget {
  const DeliveryFact({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
    decoration: BoxDecoration(
      color: AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      border: Border.all(color: AppColors.surfaceMedium),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: AppSpacing.xs),
        Flexible(child: Text(text, style: AppTextStyles.small)),
      ],
    ),
  );
}
