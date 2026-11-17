import 'package:flutter/material.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/location/geo_point.dart';
import 'package:farm2fork_mobile/core/maps/app_map.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/shipment.dart';

/// Where the transporter is relative to the place the viewer cares about:
/// the buyer's drop-off once goods are on the way, or the farmer's pickup
/// while the transporter is heading there. Positions come from the
/// transporter app while it is open; the caption says how old they are.
class DeliveryLiveMap extends StatelessWidget {
  const DeliveryLiveMap({
    super.key,
    required this.shipment,
    required this.forFarmer,
    this.now,
  });

  final Shipment shipment;
  final bool forFarmer;

  /// Injected by tests; defaults to the current time.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final place = forFarmer ? shipment.pickupAddress : shipment.deliveryAddress;
    final placePoint = place.lat == null || place.lng == null
        ? null
        : GeoPoint(place.lat!, place.lng!);
    final at = shipment.transporterLocationAt;
    final transporter =
        shipment.transporterLat == null || shipment.transporterLng == null
        ? null
        : GeoPoint(shipment.transporterLat!, shipment.transporterLng!);
    final center = transporter ?? placePoint;
    if (center == null) return const SizedBox.shrink();

    final minutes = at == null
        ? null
        : (now ?? DateTime.now()).difference(at).inMinutes;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.deliveryMapTitle, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: SizedBox(
              height: 220,
              child: AppMap(
                config: AppMapConfig(
                  center: center,
                  zoom: 13,
                  fitMarkers: transporter != null && placePoint != null,
                  markers: [
                    if (placePoint != null)
                      AppMarker(
                        id: 'place',
                        at: placePoint,
                        kind: forFarmer
                            ? AppMarkerKind.pickup
                            : AppMarkerKind.dropoff,
                        title: forFarmer
                            ? l10n.mapYourFarm
                            : l10n.mapYourDropoff,
                      ),
                    if (transporter != null)
                      AppMarker(
                        id: 'transporter',
                        at: transporter,
                        kind: AppMarkerKind.transporter,
                        title: l10n.mapTransporter,
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            minutes == null
                ? l10n.transporterLocationWaiting
                : minutes < 1
                ? l10n.transporterLocationJustNow
                : l10n.transporterLocationMinutes(minutes),
            style: AppTextStyles.small,
          ),
        ],
      ),
    );
  }
}
