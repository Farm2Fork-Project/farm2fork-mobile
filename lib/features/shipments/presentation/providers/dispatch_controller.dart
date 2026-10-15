import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/location/geo_point.dart';
import 'package:farm2fork_mobile/core/location/location_service.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/available_delivery.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/shipment.dart';
import 'package:farm2fork_mobile/features/shipments/data/repositories/shipments_repository_provider.dart';
import 'package:farm2fork_mobile/features/shipments/presentation/providers/shipments_controller.dart';

class DispatchState {
  const DispatchState({
    required this.status,
    required this.offers,
    this.active,
    this.refreshFailed = false,
    this.needsReconciliation = false,
  });
  final TransporterStatus status;
  final List<AvailableDelivery> offers;
  final Shipment? active;
  final bool refreshFailed;
  final bool needsReconciliation;
}

class DispatchController extends AsyncNotifier<DispatchState> {
  int _generation = 0;
  bool _mutating = false;
  String? _mutationUserId;
  String? get _userId =>
      ref.read(authControllerProvider).asData?.value.user?.id;
  bool get _sameMutationUser =>
      _mutationUserId != null && _mutationUserId == _userId;
  @override
  Future<DispatchState> build() async {
    _generation++;
    final auth = await ref.watch(authControllerProvider.future);
    if (auth.user?.role != AppUserRole.transporter) {
      return const DispatchState(
        status: TransporterStatus(
          online: false,
          locationFresh: false,
          radiusKm: 0,
        ),
        offers: [],
      );
    }
    return _load();
  }

  Future<void>? _refreshing;
  Future<void> refresh({bool force = false}) async {
    final pending = _refreshing;
    if (pending != null) {
      await pending;
      if (!force || !ref.mounted) return;
    }
    final request = _refresh();
    _refreshing = request;
    try {
      await request;
    } finally {
      if (identical(_refreshing, request)) _refreshing = null;
    }
  }

  Future<void> _refresh() async {
    final generation = ++_generation;
    final userId = _userId;
    final previous = state.asData?.value;
    try {
      final value = await _load();
      if (ref.mounted && generation == _generation && userId == _userId) {
        state = AsyncData(value);
      }
    } on Object catch (error, stack) {
      if (!ref.mounted || generation != _generation || userId != _userId) {
        return;
      }
      state = previous == null
          ? AsyncError(error, stack)
          : AsyncData(
              DispatchState(
                status: previous.status,
                offers: previous.offers,
                active: previous.active,
                refreshFailed: true,
                needsReconciliation: previous.needsReconciliation,
              ),
            );
    }
  }

  Future<T> _mutate<T>(Future<T> Function() action) async {
    if (_mutating) throw StateError('A delivery action is already in progress');
    if (state.asData?.value.needsReconciliation == true) {
      throw StateError(
        'Refresh the delivery before retrying an uncertain action',
      );
    }
    if (ref.read(authControllerProvider).asData?.value.user?.role !=
        AppUserRole.transporter) {
      throw StateError('Transporter required');
    }
    _mutationUserId = _userId;
    _mutating = true;
    try {
      return await action();
    } finally {
      _mutating = false;
      _mutationUserId = null;
    }
  }

  Future<void> goOnline() => _mutate(() async {
    final here = await ref.read(locationServiceProvider).current();
    if (!ref.mounted || !_sameMutationUser) throw StateError('Account changed');
    await ref
        .read(shipmentsRepositoryProvider)
        .setAvailability(online: true, location: here);
    await refresh(force: true);
  });
  Future<void> goOffline() => _mutate(() async {
    await ref.read(shipmentsRepositoryProvider).setAvailability(online: false);
    await refresh(force: true);
  });
  Future<void> reportLocation(GeoPoint location) =>
      ref.read(shipmentsRepositoryProvider).reportLocation(location);
  Future<Shipment> accept(String orderId) => _mutate(() async {
    try {
      return await ref.read(shipmentsRepositoryProvider).claim(orderId);
    } finally {
      await refresh(force: true);
      if (ref.mounted) ref.invalidate(shipmentsControllerProvider);
    }
  });
  Future<void> decline(String orderId) => _mutate(() async {
    await ref.read(shipmentsRepositoryProvider).decline(orderId);
    final current = state.asData?.value;
    if (ref.mounted && _sameMutationUser && current != null) {
      state = AsyncData(
        DispatchState(
          status: current.status,
          offers: current.offers
              .where((offer) => offer.orderId != orderId)
              .toList(),
          active: current.active,
          refreshFailed: current.refreshFailed,
        ),
      );
    }
  });
  Future<void> advance({
    required String shipmentId,
    required ShipmentStatus status,
    required String note,
  }) => _mutate(() async {
    final updated = await _reconciledWrite(
      shipmentId,
      status,
      () => ref
          .read(shipmentsRepositoryProvider)
          .updateStatus(shipmentId: shipmentId, status: status, note: note),
    );
    _applyShipment(updated);
    await refresh(force: true);
    if (ref.mounted) ref.invalidate(shipmentsControllerProvider);
  });
  Future<void> complete(String id, String code, String note) =>
      _mutate(() async {
        final updated = await _reconciledWrite(
          id,
          ShipmentStatus.delivered,
          () => ref.read(shipmentsRepositoryProvider).complete(id, code, note),
        );
        _applyShipment(updated);
        await refresh(force: true);
        if (ref.mounted) ref.invalidate(shipmentsControllerProvider);
      });
  Future<void> reportIssue(String id, String reason, String note) => _mutate(
    () async {
      final updated = await _reconciledWrite(
        id,
        ShipmentStatus.failed,
        () =>
            ref.read(shipmentsRepositoryProvider).reportIssue(id, reason, note),
      );
      _applyShipment(updated);
      await refresh(force: true);
      if (ref.mounted) ref.invalidate(shipmentsControllerProvider);
    },
  );
  Future<Shipment> _reconciledWrite(
    String id,
    ShipmentStatus expected,
    Future<Shipment> Function() write,
  ) async {
    try {
      return await write();
    } on Object {
      if (!ref.mounted || !_sameMutationUser) rethrow;
      Shipment? current;
      try {
        current = await ref.read(shipmentsRepositoryProvider).getById(id);
      } on Object {
        if (ref.mounted && _sameMutationUser) {
          final previous = state.asData?.value;
          if (previous != null) {
            state = AsyncData(
              DispatchState(
                status: previous.status,
                offers: previous.offers,
                active: previous.active,
                refreshFailed: true,
                needsReconciliation: true,
              ),
            );
          }
        }
      }
      if (!ref.mounted || !_sameMutationUser) rethrow;
      if (current != null) {
        _applyShipment(current);
        if (current.status == expected) return current;
        await refresh(force: true);
      }
      rethrow;
    }
  }

  void _applyShipment(Shipment shipment) {
    if (!ref.mounted || !_sameMutationUser) return;
    _generation++;
    final current = state.asData?.value;
    if (current == null) return;
    // Match the backend's activeDeliveryFilter: a failed delivery still
    // reserves the transporter while goods remain in their custody.
    final issue = shipment.issue;
    final retainsCustody =
        shipment.status == ShipmentStatus.failed &&
        issue != null &&
        (issue['stage'] == 'picked_up' || issue['stage'] == 'in_transit') &&
        !issue.containsKey('resolvedAt');
    final terminal =
        shipment.status == ShipmentStatus.delivered ||
        (shipment.status == ShipmentStatus.failed && !retainsCustody);
    state = AsyncData(
      DispatchState(
        status: TransporterStatus(
          online: current.status.online,
          locationFresh: current.status.locationFresh,
          radiusKm: current.status.radiusKm,
          lastLocationAt: current.status.lastLocationAt,
          activeShipmentId: terminal ? null : shipment.id,
        ),
        active: terminal ? null : shipment,
        offers: const [],
      ),
    );
  }

  Future<DispatchState> _load() async {
    if (ref.read(authControllerProvider).asData?.value.user?.role !=
        AppUserRole.transporter) {
      return const DispatchState(
        status: TransporterStatus(
          online: false,
          locationFresh: false,
          radiusKm: 0,
        ),
        offers: [],
      );
    }
    final repo = ref.read(shipmentsRepositoryProvider);
    final status = await repo.getStatus();
    final results = await Future.wait<Object?>([
      status.activeShipmentId == null
          ? Future.value(null)
          : repo.getById(status.activeShipmentId!),
      status.online && status.activeShipmentId == null
          ? repo.getAvailable()
          : Future.value(const <AvailableDelivery>[]),
    ]);
    return DispatchState(
      status: status,
      active: results[0] as Shipment?,
      offers: results[1]! as List<AvailableDelivery>,
    );
  }
}

final dispatchControllerProvider =
    AsyncNotifierProvider<DispatchController, DispatchState>(
      DispatchController.new,
    );
