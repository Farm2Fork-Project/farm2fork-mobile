import 'dart:async';

import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/features/shipments/presentation/widgets/buyer_delivery_code.dart';
import 'package:farm2fork_mobile/features/shipments/presentation/widgets/delivery_live_map.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/core/widgets/app_state_placeholder.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/shipment.dart';
import 'package:farm2fork_mobile/features/shipments/data/repositories/shipments_repository_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shipmentTrackingProvider = FutureProvider.autoDispose
    .family<Shipment, String>((ref, shipmentId) async {
      final auth = await ref.watch(authControllerProvider.future);
      if (!auth.isAuthenticated) throw StateError('Authentication required');
      return ref.read(shipmentsRepositoryProvider).getById(shipmentId);
    });

/// How often an open tracking screen refreshes an active delivery.
const trackingRefreshInterval = Duration(seconds: 30);

class ShipmentTrackingScreen extends ConsumerStatefulWidget {
  const ShipmentTrackingScreen({super.key, required this.shipmentId});

  final String shipmentId;

  @override
  ConsumerState<ShipmentTrackingScreen> createState() =>
      _ShipmentTrackingScreenState();
}

class _ShipmentTrackingScreenState
    extends ConsumerState<ShipmentTrackingScreen> {
  Timer? _refresh;

  String get shipmentId => widget.shipmentId;

  @override
  void initState() {
    super.initState();
    _refresh = Timer.periodic(trackingRefreshInterval, (_) {
      final shipment = ref.read(shipmentTrackingProvider(shipmentId)).value;
      if (shipment != null && _isActive(shipment.status)) {
        ref.invalidate(shipmentTrackingProvider(shipmentId));
      }
    });
  }

  @override
  void dispose() {
    _refresh?.cancel();
    super.dispose();
  }

  bool _isActive(ShipmentStatus status) =>
      status != ShipmentStatus.delivered && status != ShipmentStatus.failed;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider).asData?.value;
    final role = auth?.user?.role;
    final shipmentAsync = ref.watch(shipmentTrackingProvider(shipmentId));
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(context.l10n.shipmentTracking, style: AppTextStyles.h2),
        backgroundColor: AppColors.backgroundLight,
      ),
      body: shipmentAsync.when(
        skipLoadingOnRefresh: true,
        skipLoadingOnReload: false,
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
        error: (_, _) => AppErrorState(
          onRetry: () => ref.invalidate(shipmentTrackingProvider(shipmentId)),
        ),
        data: (shipment) => RefreshIndicator(
          color: AppColors.primaryGreen,
          onRefresh: () =>
              ref.refresh(shipmentTrackingProvider(shipmentId).future),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            children: [
              if ((role == AppUserRole.buyer &&
                      (shipment.status == ShipmentStatus.pickedUp ||
                          shipment.status == ShipmentStatus.inTransit)) ||
                  (role == AppUserRole.farmer &&
                      shipment.status == ShipmentStatus.assigned)) ...[
                DeliveryLiveMap(
                  shipment: shipment,
                  forFarmer: role == AppUserRole.farmer,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              if (auth?.user?.role == AppUserRole.buyer &&
                  shipment.status != ShipmentStatus.delivered &&
                  shipment.status != ShipmentStatus.failed)
                BuyerDeliveryCode(
                  key: ValueKey(
                    '${auth?.user?.id}:${shipment.id}:${shipment.transporterId}',
                  ),
                  shipmentId: shipmentId,
                ),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.shipmentTimeline,
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    for (final entry in shipment.statusHistory) ...[
                      Text(
                        _statusLabel(context, entry.status),
                        style: AppTextStyles.label,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        MaterialLocalizations.of(
                          context,
                        ).formatMediumDate(entry.timestamp.toLocal()),
                        style: AppTextStyles.small,
                      ),
                      Text(entry.note, style: AppTextStyles.body),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ],
                ),
              ),
            ],
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
