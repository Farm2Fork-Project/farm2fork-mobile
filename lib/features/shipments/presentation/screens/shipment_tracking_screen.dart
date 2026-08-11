import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/shipment.dart';
import 'package:farm2fork_mobile/features/shipments/data/repositories/shipments_repository_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shipmentTrackingProvider = FutureProvider.autoDispose
    .family<Shipment, String>((ref, shipmentId) {
      return ref.read(shipmentsRepositoryProvider).getById(shipmentId);
    });

class ShipmentTrackingScreen extends ConsumerWidget {
  const ShipmentTrackingScreen({super.key, required this.shipmentId});

  final String shipmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shipmentAsync = ref.watch(shipmentTrackingProvider(shipmentId));
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(context.l10n.shipmentTracking, style: AppTextStyles.h2),
        backgroundColor: AppColors.backgroundLight,
      ),
      body: shipmentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(context.l10n.errorOccurred)),
        data: (shipment) => ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.l10n.shipmentTimeline, style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.md),
                  for (final entry in shipment.statusHistory) ...[
                    Text(
                      _statusLabel(context, entry.status),
                      style: AppTextStyles.label,
                    ),
                    const SizedBox(height: 2),
                    Text(entry.note, style: AppTextStyles.body),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ],
              ),
            ),
          ],
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
