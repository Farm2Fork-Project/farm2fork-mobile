import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:farm2fork_mobile/features/shipments/presentation/widgets/delivery_actions.dart';
import 'package:farm2fork_mobile/features/shipments/presentation/widgets/delivery_route.dart';

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

/// Obtain a new foreground position periodically, even while stationary.
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
  Timer? _offersTimer;
  bool _foreground = true;
  int? _locatingGeneration;
  bool _locationFailed = false;
  int _trackingGeneration = 0;
  bool _toggling = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _foreground =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
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
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground) {
      ref.read(dispatchControllerProvider.notifier).refresh();
      _syncTracking();
    } else {
      _stopTracking();
    }
  }

  void _syncTracking() {
    if (!mounted) return;
    final status = ref.read(dispatchControllerProvider).asData?.value.status;
    // Keep sharing during a delivery even when offline for new offers: the
    // farmer and buyer follow the active job on their tracking map.
    final share =
        status != null && (status.online || status.activeShipmentId != null);
    if (_foreground && share) {
      _startTracking();
    } else {
      _stopTracking();
    }
  }

  Future<void> _sharePosition(int generation, [GeoPoint? position]) async {
    if (!_foreground ||
        _locatingGeneration == generation ||
        generation != _trackingGeneration) {
      return;
    }
    _locatingGeneration = generation;
    try {
      final fresh =
          position ?? await ref.read(locationServiceProvider).current();
      if (!mounted || !_foreground || generation != _trackingGeneration) return;
      await ref.read(dispatchControllerProvider.notifier).reportLocation(fresh);
      if (mounted && generation == _trackingGeneration && _locationFailed) {
        setState(() => _locationFailed = false);
      }
    } on Object {
      if (mounted && generation == _trackingGeneration && !_locationFailed) {
        setState(() => _locationFailed = true);
      }
    } finally {
      if (_locatingGeneration == generation) _locatingGeneration = null;
    }
  }

  void _startTracking() {
    if (!_foreground || _positionSub != null) return;
    final generation = ++_trackingGeneration;
    _positionSub = ref
        .read(locationServiceProvider)
        .watch()
        .listen(
          (position) => unawaited(_sharePosition(generation, position)),
          onError: (Object _) {
            if (mounted && generation == _trackingGeneration) {
              setState(() => _locationFailed = true);
            }
          },
        );
    unawaited(_sharePosition(generation));
    _heartbeat = Timer.periodic(
      _heartbeatInterval,
      (_) => unawaited(_sharePosition(generation)),
    );
    _offersTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted && _foreground && generation == _trackingGeneration) {
        ref.read(dispatchControllerProvider.notifier).refresh();
      }
    });
  }

  void _stopTracking() {
    _trackingGeneration++;
    _positionSub?.cancel();
    _positionSub = null;
    _heartbeat?.cancel();
    _heartbeat = null;
    _offersTimer?.cancel();
    _offersTimer = null;
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
        actions: [const NotificationBell()],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryGreen,
          onRefresh: () =>
              ref.read(dispatchControllerProvider.notifier).refresh(),
          child: dispatch.when(
            skipLoadingOnReload: false,
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            ),
            error: (_, _) => AppErrorState(
              onRetry: () =>
                  ref.read(dispatchControllerProvider.notifier).refresh(),
            ),
            data: (state) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              children: [
                _OnlineCard(
                  status: state.status,
                  busy: _toggling,
                  onChanged: _toggle,
                ),
                if (state.needsReconciliation) ...[
                  const SizedBox(height: AppSpacing.md),
                  _Notice(text: l10n.deliveryReconcileRequired),
                ],
                if (state.refreshFailed) ...[
                  const SizedBox(height: AppSpacing.md),
                  AppErrorState(
                    onRetry: () =>
                        ref.read(dispatchControllerProvider.notifier).refresh(),
                  ),
                ],
                if (_locationFailed ||
                    (state.status.online && !state.status.locationFresh)) ...[
                  const SizedBox(height: AppSpacing.md),
                  _Notice(
                    text: l10n.locationStaleWarning,
                    actions: [
                      TextButton(
                        onPressed: () => _sharePosition(_trackingGeneration),
                        child: Text(l10n.retry),
                      ),
                      TextButton(
                        onPressed: () => ref
                            .read(locationServiceProvider)
                            .openSettingsFor(LocationFailure.deniedForever),
                        child: Text(l10n.settings),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
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
                const SizedBox(height: AppSpacing.lg),
                _EarningsLink(
                  onTap: () => context.push('/transporter/earnings'),
                ),
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
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      backgroundColor: online ? AppColors.primaryGreenSoft : AppColors.white,
      borderColor: online ? AppColors.primaryGreen : AppColors.surfaceMedium,
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: online ? AppColors.success : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  online ? l10n.youAreOnline : l10n.youAreOffline,
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: 2),
                Text(
                  online
                      ? l10n.onlineShort(status.radiusKm.toStringAsFixed(0))
                      : l10n.offlineSubtitle,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textMuted,
                    height: 1.35,
                  ),
                ),
                if (online)
                  Text(
                    l10n.locationOpenAppNote,
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.textMuted,
                      height: 1.35,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (busy)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            Semantics(
              label: online ? l10n.dispatchGoOffline : l10n.dispatchGoOnline,
              child: Switch.adaptive(
                value: online,
                activeTrackColor: AppColors.primaryGreen,
                onChanged: onChanged,
              ),
            ),
        ],
      ),
    );
  }
}

/// A warning the transporter should act on, with optional actions.
class _Notice extends StatelessWidget {
  const _Notice({required this.text, this.actions = const []});

  final String text;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(AppSpacing.md),
    backgroundColor: AppColors.accentYellowSoft,
    borderColor: AppColors.accentYellow,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 20,
              color: AppColors.textDark,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.small.copyWith(height: 1.4),
              ),
            ),
          ],
        ),
        if (actions.isNotEmpty)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Wrap(children: actions),
          ),
      ],
    ),
  );
}

class _Hint extends StatelessWidget {
  const _Hint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      vertical: AppSpacing.xxxl,
      horizontal: AppSpacing.lg,
    ),
    child: Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: AppColors.primaryGreenSoft,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 34, color: AppColors.primaryGreen),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textMuted,
            height: 1.45,
          ),
        ),
      ],
    ),
  );
}

class _EarningsLink extends StatelessWidget {
  const _EarningsLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppCard(
    onTap: onTap,
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.md,
    ),
    child: Row(
      children: [
        const Icon(Icons.payments_outlined, color: AppColors.primaryGreen),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            context.l10n.deliveryEarnings,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textMuted,
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
              '${i.productName} ×${i.quantity % 1 == 0 ? i.quantity.toInt() : i.quantity} ${switch (i.unit) {
                'kg' => l10n.unitKg,
                'ton' => l10n.unitTon,
                'dozen' => l10n.unitDozen,
                'piece' => l10n.unitPiece,
                'litre' => l10n.unitLitre,
                _ => l10n.deliveryUnitUnavailable,
              }}',
        )
        .join(', ');
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.dispatchEarning, style: AppTextStyles.label),
                    Text(
                      _money(context, offer.deliveryFee),
                      style: AppTextStyles.h1.copyWith(
                        color: AppColors.primaryGreenDark,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: _showMap,
                icon: const Icon(Icons.map_outlined, size: 18),
                label: Text(l10n.viewOnMap),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          DeliveryRoute(
            pickup: RouteStop(
              label: l10n.pickupFarm,
              title: offer.farmName ?? offer.pickupCity,
              detail: offer.farmName == null ? null : offer.pickupCity,
            ),
            dropoff: RouteStop(
              label: l10n.deliveryDestination,
              title: offer.deliveryCity,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              DeliveryFact(
                icon: Icons.near_me_outlined,
                text: l10n.toPickupKm(
                  offer.distanceToPickupKm.toStringAsFixed(1),
                ),
              ),
              DeliveryFact(
                icon: Icons.route_outlined,
                text: l10n.tripKm(offer.deliveryDistanceKm.toStringAsFixed(1)),
              ),
            ],
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  size: 16,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    items,
                    style: AppTextStyles.small.copyWith(height: 1.4),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
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
                flex: 2,
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

    final nextHint = switch (shipment.status) {
      ShipmentStatus.assigned => l10n.nextStepHeadToPickup,
      ShipmentStatus.pickedUp => l10n.nextStepStartTrip,
      ShipmentStatus.inTransit => l10n.nextStepHandover,
      _ => null,
    };
    String place(ShipmentAddress a) =>
        [a.street, a.city].where((part) => part.isNotEmpty).join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(l10n.activeDeliveryTitle, style: AppTextStyles.h3),
            ),
            if (shipment.deliveryFee != null)
              Text(
                l10n.youEarn(_money(context, shipment.deliveryFee!)),
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primaryGreenDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (pickup != null && dropoff != null)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.md),
                  ),
                  child: SizedBox(
                    height: 190,
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
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DeliveryProgress(status: shipment.status),
                    if (nextHint != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        nextHint,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    DeliveryRoute(
                      pickup: RouteStop(
                        label: l10n.pickupFarm,
                        title: place(shipment.pickupAddress),
                        detail: shipment.pickupAddress.province,
                      ),
                      dropoff: RouteStop(
                        label: l10n.deliveryDestination,
                        title: place(shipment.deliveryAddress),
                        detail: shipment.deliveryAddress.province,
                      ),
                    ),
                    for (final (role, contact) in [
                      (l10n.roleFarmer, shipment.pickupContact),
                      (l10n.roleBuyer, shipment.deliveryContact),
                    ])
                      if (contact != null)
                        _ContactRow(role: role, contact: contact),
                    const SizedBox(height: AppSpacing.lg),
                    if (next != null)
                      AppButton(
                        label: nextLabel,
                        expand: true,
                        isLoading: _busy,
                        onPressed: _busy
                            ? null
                            : () async {
                                if (next == ShipmentStatus.delivered) {
                                  await showDeliveryAction(context, shipment);
                                } else {
                                  await _advance(next);
                                }
                              },
                      ),
                    if (target != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      AppButton(
                        label: headingToPickup
                            ? l10n.navigateToPickup
                            : l10n.navigateToDropoff,
                        icon: Icons.navigation_rounded,
                        variant: AppButtonVariant.secondary,
                        expand: true,
                        onPressed: () async {
                          try {
                            if (await openDirections(target)) return;
                          } on Object {
                            /* The address stays visible above. */
                          }
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.navigationUnavailable),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.surfaceMedium),
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () =>
                            context.push('/shipments/${shipment.id}'),
                        icon: const Icon(Icons.timeline_rounded, size: 18),
                        label: Text(
                          l10n.shipmentTimeline,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const VerticalDivider(
                      width: 1,
                      color: AppColors.surfaceMedium,
                    ),
                    Expanded(
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.errorRed,
                        ),
                        onPressed: _busy
                            ? null
                            : () async {
                                final reported = await showDeliveryAction(
                                  context,
                                  shipment,
                                  issue: true,
                                );
                                if (reported == true && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.problemReportSuccess),
                                    ),
                                  );
                                }
                              },
                        icon: const Icon(
                          Icons.report_problem_outlined,
                          size: 18,
                        ),
                        label: Text(
                          l10n.reportProblemShort,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Who to call at a stop, labelled by role so the two rows are not confused.
class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.role, required this.contact});

  final String role;
  final Map<String, String?> contact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = contact['name'] ?? '';
    final phone = contact['phone'];
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.md),
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.xs,
        AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.surfaceMedium),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(role, style: AppTextStyles.label),
                Text(
                  name,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (phone != null)
                  Text(
                    phone,
                    textDirection: TextDirection.ltr,
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
          if (phone != null)
            IconButton.filledTonal(
              tooltip: l10n.callContact(name),
              icon: const Icon(Icons.call_rounded),
              onPressed: () async {
                try {
                  if (await launchUrl(
                    Uri(scheme: 'tel', path: phone),
                    mode: LaunchMode.externalApplication,
                  )) {
                    return;
                  }
                } on Object {
                  /* The number stays visible for manual dialing. */
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.dispatchActionFailed)),
                  );
                }
              },
            ),
        ],
      ),
    );
  }
}
