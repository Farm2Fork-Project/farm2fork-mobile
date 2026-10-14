import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/location/geo_point.dart';
import 'package:farm2fork_mobile/core/location/location_service.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/available_delivery.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/shipment.dart';
import 'package:farm2fork_mobile/features/shipments/data/repositories/shipments_repository_provider.dart';
import 'package:farm2fork_mobile/features/shipments/presentation/providers/shipments_controller.dart';

/// Everything the transporter's Deliveries tab shows.
class DispatchState {
  const DispatchState({
    required this.status,
    required this.offers,
    this.active,
  });

  final TransporterStatus status;
  final List<AvailableDelivery> offers;

  /// The delivery in progress, if any (one at a time).
  final Shipment? active;
}

/// Transporter dispatch: go online with the current location, see nearby
/// fixed-price offers, accept or decline, then drive the accepted delivery.
class DispatchController extends AsyncNotifier<DispatchState> {
  @override
  Future<DispatchState> build() => _load();

  Future<void> refresh() async {
    state = await AsyncValue.guard(_load);
  }

  /// Throws [LocationException] when the location can't be read.
  Future<void> goOnline() async {
    final here = await ref.read(locationServiceProvider).current();
    await ref
        .read(shipmentsRepositoryProvider)
        .setAvailability(online: true, location: here);
    await refresh();
  }

  Future<void> goOffline() async {
    await ref.read(shipmentsRepositoryProvider).setAvailability(online: false);
    await refresh();
  }

  /// Heartbeat while online; failures are ignored (the next one retries).
  Future<void> reportLocation(GeoPoint location) async {
    try {
      await ref.read(shipmentsRepositoryProvider).reportLocation(location);
    } on Object {
      // Best effort.
    }
  }

  Future<Shipment> accept(String orderId) async {
    try {
      return await ref.read(shipmentsRepositoryProvider).claim(orderId);
    } finally {
      await refresh();
      ref.invalidate(shipmentsControllerProvider);
    }
  }

  Future<void> decline(String orderId) async {
    // Hide it immediately; the server call makes it permanent.
    final current = state.asData?.value;
    if (current != null) {
      state = AsyncData(
        DispatchState(
          status: current.status,
          active: current.active,
          offers: current.offers.where((o) => o.orderId != orderId).toList(),
        ),
      );
    }
    await ref.read(shipmentsRepositoryProvider).decline(orderId);
  }

  Future<void> advance({
    required String shipmentId,
    required ShipmentStatus status,
    required String note,
  }) async {
    await ref
        .read(shipmentsRepositoryProvider)
        .updateStatus(shipmentId: shipmentId, status: status, note: note);
    await refresh();
    ref.invalidate(shipmentsControllerProvider);
  }

  Future<DispatchState> _load() async {
    final repo = ref.read(shipmentsRepositoryProvider);
    final status = await repo.getStatus();
    final activeId = status.activeShipmentId;
    final results = await Future.wait<Object?>([
      activeId == null ? Future.value(null) : repo.getById(activeId),
      // Offers are empty server-side during a delivery or while offline.
      status.online && activeId == null
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
