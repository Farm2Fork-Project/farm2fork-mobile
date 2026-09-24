import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/location/geo_point.dart';
import 'package:farm2fork_mobile/core/location/location_messages.dart';
import 'package:farm2fork_mobile/core/location/location_service.dart';
import 'package:farm2fork_mobile/core/maps/app_map.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/utils/number_formatters.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/core/widgets/app_state_placeholder.dart';
import 'package:farm2fork_mobile/features/notifications/presentation/widgets/notification_bell.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/available_delivery.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/shipment.dart';
import 'package:farm2fork_mobile/features/shipments/presentation/providers/dispatch_controller.dart';

/// How often an online transporter's location is re-sent even when they
/// haven't moved, so the server keeps treating it as fresh.
const _heartbeatInterval = Duration(minutes: 4);

/// Transporter home: online toggle, the delivery in progress, and nearby
/// fixed-price offers to accept or decline.
class DeliveriesScreen extends ConsumerStatefulWidget {
  const DeliveriesScreen({super.key});

  @override
  ConsumerState<DeliveriesScreen> createState() => _DeliveriesScreenState();
}

class _DeliveriesScreenState extends ConsumerState<DeliveriesScreen>
    with WidgetsBindingObserver {
  StreamSubscription<GeoPoint>? _positionSub;
  Timer? _heartbeat;
  GeoPoint? _lastPosition;
  bool _toggling = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTracking();
    super.dispose();
  }

  // Foreground only: tracking stops when the app is backgrounded and
  // resumes (with a refresh) when it comes back.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(dispatchControllerProvider.notifier).refresh();
      _syncTracking();
    } else if (state == AppLifecycleState.paused) {
      _stopTracking();
    }
  }

  void _syncTracking() {
    final online =
        ref.read(dispatchControllerProvider).asData?.value.status.online ??
        false;
    if (online) {
      _startTracking();
    } else {
      _stopTracking();
    }
  }

  void _startTracking() {
    if (_positionSub != null) return;
    final controller = ref.read(dispatchControllerProvider.notifier);
    _positionSub = ref.read(locationServiceProvider).watch().listen(
      (position) {
        _lastPosition = position;
        controller.reportLocation(position);
      },
      // Permission revoked mid-session: stay online, the heartbeat
      // stops refreshing and the server lets the location go stale.
      onError: (_) {},
    );
    _heartbeat = Timer.periodic(_heartbeatInterval, (_) {
      final position = _lastPosition;
      if (position != null) controller.reportLocation(position);
    });
  }

  void _stopTracking() {
    _positionSub?.cancel();
    _positionSub = null;
    _heartbeat?.cancel();
    _heartbeat = null;
  }

  Future<void> _toggle(bool online) async {
    setState(() => _toggling = true);
    final controller = ref.read(dispatchControllerProvider.notifier);
    try {
      if (online) {
        await controller.goOnline();
      } else {
        await controller.goOffline();
      }
    } on LocationException catch (e) {
      if (mounted) {
        showLocationFailure(
          context,
          ref.read(locationServiceProvider),
          e.failure,
        );
      }
    } on Object {
      if (mounted) _snack(context.l10n.dispatchActionFailed);
    } finally {
      if (mounted) setState(() => _toggling = false);
    }
  }

  void _snack(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    ref.listen(dispatchControllerProvider, (_, _) => _syncTracking());
    final dispatch = ref.watch(dispatchControllerProvider);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(l10n.deliveriesTitle, style: AppTextStyles.h2),
        backgroundColor: AppColors.backgroundLight,
        centerTitle: true,
        actions: const [NotificationBell()],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryGreen,
          onRefresh: () =>
              ref.read(dispatchControllerProvider.notifier).refresh(),
          child: dispatch.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            ),
            error: (_, _) => AppErrorState(
              onRetry: () =>
                  ref.read(dispatchControllerProvider.notifier).refresh(),
            ),
            data: (state) => ListView(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              children: [
                _OnlineCard(
                  status: state.status,
                  busy: _toggling,
                  onChanged: _toggle,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (state.active != null)
                  _ActiveDelivery(shipment: state.active!)
                else if (!state.status.online)
                  _Hint(
                    icon: Icons.power_settings_new_rounded,
                    text: l10n.offlineHint,
                  )
                else if (state.offers.isEmpty)
                  _Hint(
                    icon: Icons.radar_rounded,
                    text: l10n.noOffersNearby(
                      state.status.radiusKm.toStringAsFixed(0),
                    ),
                  )
                else ...[
                  Text(l10n.offersNearYou, style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.md),
                  for (final offer in state.offers)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _OfferCard(offer: offer, onMessage: _snack),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnlineCard extends StatelessWidget {
  const _OnlineCard({
    required this.status,
    required this.busy,
    required this.onChanged,
  });

  final TransporterStatus status;
  final bool busy;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final online = status.online;
    return AppCard(
      backgroundColor: online
          ? AppColors.primaryGreen.withValues(alpha: 0.08)
          : AppColors.white,
      borderColor: online ? AppColors.primaryGreen : AppColors.surfaceMedium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                online
                    ? Icons.wifi_tethering_rounded
                    : Icons.portable_wifi_off_rounded,
                color: online ? AppColors.primaryGreen : AppColors.textMuted,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  online ? l10n.youAreOnline : l10n.youAreOffline,
                  style: AppTextStyles.h3,
                ),
              ),
              if (busy)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Switch.adaptive(
                  value: online,
                  activeTrackColor: AppColors.primaryGreen,
                  onChanged: onChanged,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            online
                ? l10n.onlineSubtitle(status.radiusKm.toStringAsFixed(0))
                : l10n.offlineSubtitle,
            style: AppTextStyles.small.copyWith(height: 1.4),
          ),
          if (online && !status.locationFresh) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.locationStaleWarning,
              style: AppTextStyles.small.copyWith(color: AppColors.errorRed),
            ),
          ],
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
    child: Column(
      children: [
        Icon(icon, size: 56, color: AppColors.textMuted),
        const SizedBox(height: AppSpacing.md),
        Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
        ),
      ],
    ),
  );
}

String _money(BuildContext context, num amount) => context.l10n.currencyAmount(
  formatCurrencyAmount(amount, Localizations.localeOf(context)),
);

class _OfferCard extends ConsumerStatefulWidget {
  const _OfferCard({required this.offer, required this.onMessage});

  final AvailableDelivery offer;
  final ValueChanged<String> onMessage;

  @override
  ConsumerState<_OfferCard> createState() => _OfferCardState();
}

class _OfferCardState extends ConsumerState<_OfferCard> {
  bool _busy = false;

  Future<void> _accept() async {
    setState(() => _busy = true);
    try {
      await ref
          .read(dispatchControllerProvider.notifier)
          .accept(widget.offer.orderId);
    } on Object catch (error) {
      if (!mounted) return;
      final conflict =
          (error is ApiException && error.statusCode == 409) ||
          (error is DioException &&
              error.error is ApiException &&
              (error.error! as ApiException).statusCode == 409);
      widget.onMessage(
        conflict
            ? context.l10n.offerNoLongerAvailable
            : context.l10n.dispatchActionFailed,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _decline() async {
    setState(() => _busy = true);
    try {
      await ref
          .read(dispatchControllerProvider.notifier)
          .decline(widget.offer.orderId);
    } on Object {
      if (mounted) widget.onMessage(context.l10n.dispatchActionFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showMap() {
    final offer = widget.offer;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * 0.7,
        child: Column(
          children: [
            Expanded(
              child: AppMap(
                config: AppMapConfig(
                  center: offer.pickup,
                  fitMarkers: true,
                  markers: [
                    AppMarker(
                      id: 'pickup',
                      at: offer.pickup,
                      kind: AppMarkerKind.pickup,
                      title: offer.farmName ?? offer.pickupCity,
                    ),
                    AppMarker(
                      id: 'dropoff',
                      at: offer.dropoffArea,
                      kind: AppMarkerKind.dropoff,
                      title: offer.deliveryCity,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                sheetContext.l10n.dropoffApproximateNote,
                style: AppTextStyles.small.copyWith(color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final offer = widget.offer;
    final items = offer.items
        .map(
          (i) =>
              '${i.productName} ×${i.quantity % 1 == 0 ? i.quantity.toInt() : i.quantity}',
        )
        .join(', ');
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _money(context, offer.deliveryFee),
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _showMap,
                icon: const Icon(Icons.map_rounded, size: 18),
                label: Text(l10n.viewOnMap),
              ),
            ],
          ),
          Text(
            l10n.offerRoute(
              offer.farmName ?? offer.pickupCity,
              offer.pickupCity,
              offer.deliveryCity,
            ),
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.offerDistances(
              offer.distanceToPickupKm.toStringAsFixed(1),
              offer.deliveryDistanceKm.toStringAsFixed(1),
            ),
            style: AppTextStyles.small.copyWith(color: AppColors.textMuted),
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(items, style: AppTextStyles.small),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: l10n.declineDelivery,
                  variant: AppButtonVariant.secondary,
                  onPressed: _busy ? null : _decline,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: l10n.acceptDelivery,
                  icon: Icons.check_rounded,
                  isLoading: _busy,
                  onPressed: _busy ? null : _accept,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActiveDelivery extends ConsumerStatefulWidget {
  const _ActiveDelivery({required this.shipment});

  final Shipment shipment;

  @override
  ConsumerState<_ActiveDelivery> createState() => _ActiveDeliveryState();
}

class _ActiveDeliveryState extends ConsumerState<_ActiveDelivery> {
  bool _busy = false;

  GeoPoint? _pin(ShipmentAddress address) =>
      address.lat == null || address.lng == null
      ? null
      : GeoPoint(address.lat!, address.lng!);

  String _statusLabel(ShipmentStatus status) => switch (status) {
    ShipmentStatus.assigned => context.l10n.shipmentAssigned,
    ShipmentStatus.pickedUp => context.l10n.shipmentPickedUp,
    ShipmentStatus.inTransit => context.l10n.shipmentInTransit,
    ShipmentStatus.delivered => context.l10n.shipmentDelivered,
    ShipmentStatus.failed => context.l10n.shipmentFailed,
  };

  Future<void> _advance(ShipmentStatus next) async {
    setState(() => _busy = true);
    try {
      await ref
          .read(dispatchControllerProvider.notifier)
          .advance(
            shipmentId: widget.shipment.id,
            status: next,
            note: context.l10n.shipmentStatusUpdate(_statusLabel(next)),
          );
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.dispatchActionFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final shipment = widget.shipment;
    final pickup = _pin(shipment.pickupAddress);
    final dropoff = _pin(shipment.deliveryAddress);
    final headingToPickup = shipment.status == ShipmentStatus.assigned;
    final target = headingToPickup ? pickup : dropoff;
    final next = switch (shipment.status) {
      ShipmentStatus.assigned => ShipmentStatus.pickedUp,
      ShipmentStatus.pickedUp => ShipmentStatus.inTransit,
      ShipmentStatus.inTransit => ShipmentStatus.delivered,
      _ => null,
    };
    final nextLabel = switch (next) {
      ShipmentStatus.pickedUp => l10n.confirmPickup,
      ShipmentStatus.inTransit => l10n.startTransit,
      ShipmentStatus.delivered => l10n.confirmDelivery,
      _ => '',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.activeDeliveryTitle, style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.md),
        if (pickup != null && dropoff != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 220,
              child: AppMap(
                config: AppMapConfig(
                  center: pickup,
                  fitMarkers: true,
                  showMyLocation: true,
                  markers: [
                    AppMarker(
                      id: 'pickup',
                      at: pickup,
                      kind: AppMarkerKind.pickup,
                    ),
                    AppMarker(
                      id: 'dropoff',
                      at: dropoff,
                      kind: AppMarkerKind.dropoff,
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _statusLabel(shipment.status),
                      style: AppTextStyles.h3,
                    ),
                  ),
                  if (shipment.deliveryFee != null)
                    Text(
                      l10n.youEarn(_money(context, shipment.deliveryFee!)),
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _AddressLine(
                icon: Icons.agriculture_rounded,
                label: l10n.pickupFarm,
                address: shipment.pickupAddress,
              ),
              const SizedBox(height: AppSpacing.sm),
              _AddressLine(
                icon: Icons.location_on_rounded,
                label: l10n.deliveryDestination,
                address: shipment.deliveryAddress,
              ),
              const SizedBox(height: AppSpacing.md),
              if (target != null)
                AppButton(
                  label: headingToPickup
                      ? l10n.navigateToPickup
                      : l10n.navigateToDropoff,
                  icon: Icons.navigation_rounded,
                  variant: AppButtonVariant.secondary,
                  expand: true,
                  onPressed: () => openDirections(target),
                ),
              if (next != null) ...[
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: nextLabel,
                  expand: true,
                  isLoading: _busy,
                  onPressed: _busy ? null : () => _advance(next),
                ),
              ],
              const SizedBox(height: AppSpacing.xs),
              Center(
                child: TextButton(
                  onPressed: () => context.push('/shipments/${shipment.id}'),
                  child: Text(l10n.shipmentTimeline),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AddressLine extends StatelessWidget {
  const _AddressLine({
    required this.icon,
    required this.label,
    required this.address,
  });

  final IconData icon;
  final String label;
  final ShipmentAddress address;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 20, color: AppColors.primaryGreen),
      const SizedBox(width: AppSpacing.sm),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
            ),
            Text(
              [
                address.street,
                address.city,
                address.province,
              ].where((part) => part.isNotEmpty).join(', '),
              style: AppTextStyles.body,
            ),
          ],
        ),
      ),
    ],
  );
}
